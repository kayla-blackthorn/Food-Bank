// @ts-check

/**
 * @typedef {import('../utils/error').ApplicationError} ApplicationError
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formShared/typings').FormElementLeveled} FormElementLeveled
 * @typedef {import('../formElementList/typings').DropPosition} DropPosition
 * @typedef {import('./formElementNode').NodePosition} NodePosition
 */

/**
 * @typedef {object} MutationOptions
 * @property {boolean=} dryRun
 */

/**
 * @typedef {object} MutationResult
 * @property {boolean=} mutated
 * @property {ApplicationError=} error
 */

/**
 * @typedef {object} RetriveNodesInHierarchyOptions
 * @property {boolean=} expandedOnly
 */

/**
 * @typedef {'inspection'|'hierarchy'} GetFormElementsHierarchyMode
 */

/**
 * @typedef {object} GetFormElementsHierarchyOptions
 * @property {GetFormElementsHierarchyMode=} mode default to 'hierarchy'
 */

/**
 * @typedef {object} RetriveNodesAffectedByOptions
 * @property {boolean} includeSelf
 */

/**
 * @typedef {Pick<FormElement, 'id' | 'sortOrder'>} SortOrderUpdate
 */

import { generateUniqueId } from 'c/utils';
import { FormElementNode } from './formElementNode';
import { NumberSequencer } from './numberSequencer';
import { GroupMismatchError, ElementNotFoundError, BeDependedOnError } from './errors';

export const CONDITION_INCOMPLETE = 'incomplete';
export const CONDITION_CIRCULAR_DEPENDENCY = 'circular_dependency';

/**
 * @typedef {CONDITION_INCOMPLETE|CONDITION_CIRCULAR_DEPENDENCY} ConditionInvalidReason
 */

/**
 * A form composer for constructing froms with form elements and form element conditions.
 *
 * Note: this class maintains the local data only, the goal is to provide logic management for the form designer
 *
 * Features:
 * - Build form element hierarchy from form elements and form element conditions.
 * - Detect circular dependency when building the hierarchy.
 * - Add new form element (optionally with form element conditions).
 * - Update existing form element (optionally with form element conditions).
 * - Remove form element.
 * - Move form element arround in the hierarchy.
 * - Expand/Collapse sub hierarchy.
 * - Calculate nesssary sort order updates
 */
export class FormComposer {
    static rootElementId = 'root';
    static maxResolvingAttempts = 5000;

    /** @type {FormElementNode} */
    rootElementNode;

    /** @type {Map<string,FormElementNode>} */
    indexedElementNodes;

    /** @type {Map<string,FormElementCondition[]>} groupped conditions by nextElementId */
    indexedConditions;

    /** @type {Map<ConditionInvalidReason, FormElementCondition[]>} */
    invalidConditions;

    numberSequencer = new NumberSequencer();

    get elementCount() {
        // exclude rootElementNode which is a logic node
        return this.indexedElementNodes.size - 1;
    }

    /**
     *
     * @param {FormElement[]=} formElements
     * @param {FormElementCondition[]=} formConditions
     */
    constructor(formElements, formConditions) {
        this.setElementsAndConditions(formElements, formConditions);
    }

    /**
     * Set form elements and form element conditions
     *
     * Note: this will clear any existing data in the composer and build a completely new form hierarchy
     *
     * @param {FormElement[]=} formElements
     * @param {FormElementCondition[]=} formConditions
     */
    setElementsAndConditions(formElements, formConditions) {
        this.rootElementNode = new FormElementNode(/** @type {FormElement} */ ({ id: FormComposer.rootElementId }));
        this.indexedElementNodes = new Map([[this.rootElementNode.id, this.rootElementNode]]);
        this.indexedConditions = new Map();
        this.invalidConditions = new Map();
        this._buildForm(formElements || [], formConditions || []);
    }

    /**
     *
     * @param {FormElement[]} formElements
     * @param {FormElementCondition[]} formConditions
     */
    _buildForm(formElements, formConditions) {
        this._parseConditions(formConditions);
        /** @type {Set<string>} */
        const removed = new Set();
        let resolvingAttempts = 0; // this is a safe guard to avoid infinite loop
        let remainingElements = formElements;
        while (remainingElements.length > 0 && resolvingAttempts < FormComposer.maxResolvingAttempts) {
            resolvingAttempts += 1;
            remainingElements.forEach((element) => {
                const conditions = this.indexedConditions.get(element.id) || [];
                if (conditions.every((c) =>this.indexedElementNodes.has(c.elementId))) {
                    // all dependencies are ready, it's time to add the element to the hierarchy
                    removed.add(element.id);
                    const node = new FormElementNode(element);
                    const controllingNode = this._findBottomControllingNodeByConditions(conditions);
                    controllingNode.insertSubElementNodeBySortOrder(node);
                    this.indexedElementNodes.set(node.id, node);
                }
            });
            remainingElements = remainingElements.filter(
                (element) => !removed.has(element.id)
            );
            removed.clear();
        }
        if (resolvingAttempts === FormComposer.maxResolvingAttempts) {
            // this is a final safe guard for circular dependency in case the circular dependency detection missed some cases
            console.warn(`Max resolving attempts(${FormComposer.maxResolvingAttempts}) reached, there may be an infinite loop happened.`);
        }
    }

    /**
     *
     * @param {FormElementCondition[]} formConditions
     */
    _parseConditions(formConditions) {
        /** @type {Set<string>} */
        const controllingElementIds = new Set();
        formConditions.forEach(condition => {
            if (!this._isConditionComplete(condition)) {
                return;
            }
            if (controllingElementIds.has(condition.nextElementId)) {
                // next element is already a controlling element, only detect circular dependency in this case
                // this is an optimization to avoid unnecessary circular dependency detection
                if (!this._isConditionCircularDependencyFree(condition)) {
                    return;
                }
            }
            controllingElementIds.add(condition.elementId);
            const conditions = this.indexedConditions.get(condition.nextElementId) || [];
            conditions.push(condition);
            this.indexedConditions.set(condition.nextElementId, conditions);
        });
    }

    /**
     *
     * @param {FormElementCondition} condition
     */
    _isConditionComplete(condition) {
        if (!condition.elementId || !condition.nextElementId) {
            this._recordInvalidCondition(CONDITION_INCOMPLETE, condition);
            return false;
        }
        return true;
    }

    /**
     *
     * @param {FormElementCondition} condition
     */
    _isConditionCircularDependencyFree(condition) {
        if (condition.elementId === condition.nextElementId) {
            this._recordInvalidCondition(CONDITION_CIRCULAR_DEPENDENCY, condition);
            return false;
        }

        // detect circular dependency in the hierarchy
        let isControlled = false;
        let conditions = this.indexedConditions.get(condition.elementId) || [];
        while(conditions.length > 0) {
            if (conditions.some(c => c.elementId === condition.nextElementId)) {
                isControlled = true;
                break;
            }
            if (conditions.length === 1) {
                // most of the elements have only one condition, so add a small optimization for this case
                conditions = this.indexedConditions.get(conditions[0].elementId) || [];
            } else {
                conditions = conditions.flatMap(c => this.indexedConditions.get(c.elementId) || []);
            }
        }
        if (isControlled) {
            this._recordInvalidCondition(CONDITION_CIRCULAR_DEPENDENCY, condition);
        }
        return !isControlled;
    }

    /**
     *
     * @param {ConditionInvalidReason} reason
     * @param {FormElementCondition} condition
     */
    _recordInvalidCondition(reason, condition) {
        const conditions = this.invalidConditions.get(reason) || [];
        conditions.push(condition);
        this.invalidConditions.set(reason, conditions);
    }

    /**
     * Move an element around in the hierarchy
     *
     * @param {string} sourceId
     * @param {string} targetId
     * @param {DropPosition} position
     * @param {MutationOptions=} options
     *
     * @returns {MutationResult}
     */
    moveElement(sourceId, targetId, position, options) {
        if (sourceId === targetId) {
            return { mutated: false };
        }
        const sourceNode = this.indexedElementNodes.get(sourceId);
        const targetNode = this.indexedElementNodes.get(targetId);
        if (targetNode.parentNode !== sourceNode.parentNode) {
            const error = new GroupMismatchError('Can only move elements inside of the same group');
            return { mutated: false, error };
        }
        if (options?.dryRun) {
            return { mutated: false };
        }
        const previousIndex = sourceNode.index;
        let nextIndex;
        if (position === 'before') {
            nextIndex = targetNode.index;
        } else if (position === 'after') {
            nextIndex = targetNode.index + 1;
        }
        if (previousIndex + 1 === nextIndex) {
            // the element is not actually moved
            return { mutated: false };
        }
        this._reattachNodeAndAffectedNodes(sourceNode, sourceNode.parentNode, nextIndex);
        return { mutated: true };
    }

    /**
     * Update an form element
     *
     * 1. if the controlling node does not change, the node should keep the original position
     * 2. if the controlling node changes, the node should be attached to the nearest position the controlling node
     *
     * Notice: circular dependency is not detected here, the caller should make sure it's circular dependency free
     *
     * @param {string} elementId
     * @param {Partial<FormElement>} element
     * @param {FormElementCondition[]=} conditions
     */
    updateFormElement(elementId, element, conditions) {
        const node = this.indexedElementNodes.get(elementId);
        if (!node) {
            return;
        }
        conditions = conditions || this.indexedConditions.get(elementId) || [];
        const controllingNode = this._findBottomControllingNodeByConditions(conditions);
        this.indexedConditions.set(node.id, conditions);
        node.element = { ...node.element, ...element };
        this._reattachNodeAndAffectedNodes(node, controllingNode);
    }

    /**
     * Update the value of an form element
     *
     * @param {string} elementId
     * @param {Partial<FormElement>} element
     */
    updateFormElementValue(elementId, element) {
        const node = this.indexedElementNodes.get(elementId);
        if (!node) {
            return;
        }
        node.element = { ...node.element, ...element };
    }

    /**
     * Add a new form element or update a form element if it already exists in the hierarchy
     *
     * @param {FormElement} element
     * @param {FormElementCondition[]=} conditions
     */
    addFormElement(element, conditions) {
        if (this.indexedElementNodes.has(element.id)) {
            // the element already exists, update it instead
            this.updateFormElement(element.id, element, conditions);
            return;
        }
        conditions = conditions || [];
        const node = new FormElementNode(element);
        const controllingNode = this._findBottomControllingNodeByConditions(conditions);
        controllingNode.appendSubElementNode(node);
        this.indexedConditions.set(node.id, conditions);
        this.indexedElementNodes.set(node.id, node);
    }

    /**
     * Remove an form element
     *
     * Notice: the action is aborted if the element is still depended (directly or indirectly) on by other elements
     *
     * @param {string} elementId
     * @param {MutationOptions=} options
     * @returns {MutationResult}
     */
    removeFormElement(elementId, options) {
        const node = this.indexedElementNodes.get(elementId);
        if (!node) {
            const error = new ElementNotFoundError('Element does not exist', { id: elementId });
            return { mutated: false, error };
        }

        const affectedNodes = this._retriveNodesAffectedBy(node);
        if (affectedNodes.length > 0) {
            const subHierarchyNodes = this._retriveNodesInHierarchy(node);
            const error = new BeDependedOnError('Cannot delete an element with controlled element(s)', {
                id: node.id,
                subHierarchyElementIds: subHierarchyNodes.map(n => n.id),
                affectedElementIds: affectedNodes.map(n => n.id),
            });
            return { mutated: false, error };
        }

        if (options?.dryRun) {
            return { mutated: false };
        }

        node.parentNode.removeSubElementNode(node.id);
        this.indexedConditions.delete(node.id);
        this.indexedElementNodes.delete(node.id);
        return { mutated: true };
    }

    /**
     *
     * @param {string} elementId
     * @param {number} depth
     */
    expandSubHierarchy(elementId, depth = Infinity) {
        const node = this.indexedElementNodes.get(elementId);
        if (!node) {
            return;
        }
        const nodes = this._retriveNodesInHierarchy(node, [node]);
        const expandedDepth = node.depth + depth;
        for (const n of nodes) {
            if (expandedDepth > n.depth) {
                n.expanded = true;
            }  else {
                n.expanded = false;
            }
        }
    }

    /**
     * Test whether the root hierarchy is expandable
     *
     * Note: it's considered expandable if any direct child of root is expandable
     *
     *  @returns {boolean}
     */
    isRootHierarchyExpandable() {
        return this.rootElementNode.subElementNodes.some(n => n.expandable);
    }

    /**
     * Test whether the root hierarchy is expanded
     *
     * Note: it's considered expanded if any direct child of root is expanded
     *
     *  @returns {boolean}
     */
    isRootHierarchyExpanded() {
        return this.rootElementNode.subElementNodes.some(n => n.expandable && n.expanded);
    }

    /**
     * @param {string=} elementId
     * @param {GetFormElementsHierarchyOptions=} options
     * @returns {FormElementLeveled[]}
     */
    getFormElementsHierarchy(elementId, options) {
        const startNode = elementId ? this.indexedElementNodes.get(elementId) : this.rootElementNode;
        if (!startNode) {
            throw new ElementNotFoundError('Element does not exist', { id: elementId });
        }
        /** @type {FormElementLeveled[]} */
        let output = [];
        /** @type {GetFormElementsHierarchyMode} */
        const mode = startNode === this.rootElementNode ? 'hierarchy' : options?.mode || 'hierarchy';
        if (mode === 'inspection') {
            const descendantNodes = this._retriveNodesInHierarchy(startNode, [], { expandedOnly: false });
            const affectedNodes = this._retriveNodesAffectedBy(startNode, { includeSelf: true });
            /** @type {Set<string>} */
            const descendantNodeIds = new Set();
            descendantNodes.forEach(n => descendantNodeIds.add(n.id));
            /** @type {Set<string>} */
            const affectedButDetachedNodeIds = new Set();
            /** @type {Map<string, boolean>} */
            const expandedState = new Map([[startNode.parentNode.id, true]]);
            affectedNodes.forEach(n => {
                const level = n.position.length - 1;
                if (!descendantNodeIds.has(n.id)) {
                    // the node is not in the sub hierarchy of startNode
                    affectedButDetachedNodeIds.add(n.id);
                    if (!affectedButDetachedNodeIds.has(n.parentNode.id)) {
                        // it is a orphan node in affectedNodes, force to expand its parent
                        // so that it's visible in the output
                        expandedState.set(n.parentNode.id, true);
                        // its parent is also sure to not be in descendantNodeIds
                        // add it into affectedButDetachedNodeIds so that we don't add unnecessary
                        // virtual elements in case there are sibling nodes of the current nodes
                        affectedButDetachedNodeIds.add(n.parentNode.id);
                        if (level > 1) {
                            // add a virtual element when it's not the first level to get a better UI/UX
                            output.push({
                                element: { id: generateUniqueId('ve'), virtual: true, question: 'This is a virtual element' },
                                level: 1,
                                expandable: false,
                                expanded: false,
                            });
                        }
                    }
                }
                // respect the expanded feature
                if (!expandedState.get(n.parentNode.id)) {
                    return;
                }
                expandedState.set(n.id, n.expanded);
                output.push({
                    element: n.element,
                    level,
                    expandable: n.expandable,
                    expanded: n.expanded,
                });
            });
        } else {
            const startNodes = startNode === this.rootElementNode ? [] : [startNode];
            const nodes = this._retriveNodesInHierarchy(startNode, startNodes, { expandedOnly: true });
            output = nodes.map(n => ({
                element: n.element,
                level: n.position.length - 1,
                expandable: n.expandable,
                expanded: n.expanded,
            }));
        }
        return output;
    }

    /**
     * Get the conditions that control the target element
     * @param {string} elementId
     * @returns {FormElementCondition[]}
     */
    getElementConditions(elementId) {
        return this.indexedConditions.get(elementId) || [];
    }

    /**
     * Find all the controlling element candidates for an element
     *
     * Note: The candidates should not be affected by the target element, it could create a
     * circular dependency if a candidate is affected by the element directly (the candidate
     * has a condition controlled by the element) or indirectly (the candidate has a condition
     * controlled by an ancestor of the element).
     *
     * @param {string=} elementId
     * @returns {FormElement[]}
     */
    getControllingElementCandidates(elementId) {
        /** @type {FormElementNode[]} */
        let nodes = this._retriveNodesInHierarchy(this.rootElementNode);
        const node = this.indexedElementNodes.get(elementId);
        if (node) {
            const affected = this._retriveNodesAffectedBy(node);
            const ids = new Set(affected.map(n => n.id));
            // also excludes self
            ids.add(elementId);
            nodes = nodes.filter(n => !ids.has(n.id));
        }
        return nodes.map(n => n.element);
    }

    /**
     * Calculate the sort order updates required to keep the order
     *
     * Note: the algorithm only guarantees the order inside each group to reduce cpu/memory usage
     *
     * @returns {SortOrderUpdate[]}
     */
    calcSortOrderUpdates() {
        const nodes = this._retriveNodesInHierarchy(this.rootElementNode);
        // no need to do a sorting if there is zero or one sub node
        const aggregateNodes = nodes.filter(n => n.subElementNodes.length > 1);
        aggregateNodes.push(this.rootElementNode);

        return aggregateNodes.flatMap(node => {
            const sortOrders = node.subElementNodes.map(n => n.element.sortOrder);
            const { updates } = this.numberSequencer.calcSequenceUpdates(sortOrders);
            return updates.map(update => ({
                id: node.subElementNodes[update.index].id,
                sortOrder: update.value,
            }));
        });
    }

    inspectSortOrders() {
        const nodes = this._retriveNodesInHierarchy(this.rootElementNode);
        return nodes.map(n => n.element.sortOrder);
    }

    /**
     *
     * @param {FormElementNode} node
     * @param {FormElementNode} controllingNode
     * @param {number=} insertIndex
     */
    _reattachNodeAndAffectedNodes(node, controllingNode, insertIndex) {
        if (node.parentNode === controllingNode && (
            insertIndex === undefined || node.index === insertIndex
        )) {
            return;
        }
        // need to get the affected nodes before updating the node due to the way _retriveNodesAffectedBy works
        const affectedNodes = this._retriveNodesAffectedBy(node);
        const index = insertIndex !== undefined ? insertIndex : this._calcInsertPositionIndex(node, controllingNode);
        controllingNode.insertSubElementNode(node, index);
        affectedNodes.forEach(n => {
            const c = this._findBottomControllingNode(n);
            if (c === n.parentNode) {
                // no need to reattach the node to a new parent
                return;
            }
            c.insertSubElementNode(n, this._calcInsertPositionIndex(n, c));
        });
    }

    /**
     * Find an expected insert index
     * 1. if the controlling node comes below of the node, put the node on the top of the controlling node
     * 2. if the controlling node comes above of the node, put the node on the nearest(below) position of the original position
     *
     * @param {FormElementNode} node
     * @param {FormElementNode} newControllingNode
     * @returns {number}
     */
    _calcInsertPositionIndex(node, newControllingNode) {
        const index = this._findBottomPositionIndex([node.position, newControllingNode.position]);
        if (index === 1) {
            // the controlling node comes below of the node
            return 0;
        }
        let parent = node.parentNode;
        let sibling = node.siblingBefore;
        while (parent !== this.rootElementNode && parent !== newControllingNode) {
            sibling = parent;
            parent = parent.parentNode;
        }
        if (parent === this.rootElementNode && newControllingNode !== this.rootElementNode) {
            return newControllingNode.subElementNodes.length;
        }
        return sibling ? sibling.index + 1 : newControllingNode.subElementNodes.length;
    }

    /**
     * Find all nodes that affected by a node
     *
     * Note: The returned nodes are in dependency order
     *
     * Note: It's wrong to just return the sub hierarchy of the "node" since
     * a node could be controlled by multiple nodes. The nodes attached on other
     * sub hierarchies could be also affected by the "node"
     *
     * Notice: the method only works in a stable hierarchy, the algorithm depends on
     * a fact: the "nodes" come in dependency order in the hierarchy
     *
     * @param {FormElementNode} node
     * @param {RetriveNodesAffectedByOptions=} options
     * @returns {FormElementNode[]}
     */
    _retriveNodesAffectedBy(node, options) {
        const nodes = this._retriveNodesInHierarchy(this.rootElementNode);
        /** @type {Set<string>} */
        const affected = new Set([node.id]);
        nodes.forEach(n => {
            const conditions = this.indexedConditions.get(n.id) || [];
            if (conditions.some(c => affected.has(c.elementId))) {
                affected.add(n.id);
            }
        });
        if (!options?.includeSelf) {
            // remove self from the result
            affected.delete(node.id);
        }
        return [...affected].map(id => this.indexedElementNodes.get(id));
    }

    /**
     * Find all nodes in the sub hierarchy of a node
     *
     * Note: A hierarchy is a logic tree, it's "logic" because a node can be controlled by multiple
     * nodes, in other words a node can have multiple parents, but in a tree a node can have only one
     * parent.
     *
     * @param {FormElementNode} node
     * @param {FormElementNode[]=} output
     * @param {RetriveNodesInHierarchyOptions=} options
     * @returns {FormElementNode[]}
     */
    _retriveNodesInHierarchy(node, output = [], options) {
        if (options?.expandedOnly && !node.expanded) {
            return output;
        }
        node.subElementNodes.forEach(n => {
            output.push(n);
            if (n.subElementNodes.length > 0) {
                this._retriveNodesInHierarchy(n, output, options);
            }
        });
        return output;
    }

    /**
     * Find the controlling node that a node should be attached to
     *
     * Notice: The "node" should be attached in the hierarchy already,
     * it does not work for a new orphan node
     *
     * @param {FormElementNode} node
     * @returns {FormElementNode}
     */
    _findBottomControllingNode(node) {
        const conditions = this.indexedConditions.get(node.id) || [];
        if (conditions.length < 2) {
            // The node's parent in the hierarchy won't change if it doesn't have more than 1 hierarchy
            return node.parentNode;
        }
        return this._findBottomControllingNodeByConditions(conditions);
    }

    /**
     * Find the bottom controlling node for a list of conditions
     *
     * Notice: the conditions should control the same controlled node, or the behavior is undefined
     *
     * @param {FormElementCondition[]} conditions
     * @returns {FormElementNode}
     */
    _findBottomControllingNodeByConditions(conditions) {
        if (conditions.length === 0) {
            return this.rootElementNode;
        }
        const controllingNodes = conditions.map((c) => this.indexedElementNodes.get(c.elementId));
        const positions = controllingNodes.map((n) => n.position);
        const index = this._findBottomPositionIndex(positions);
        return controllingNodes[index];
    }

    /**
     * Find the index of the bottom position in a list of positions
     *
     * @param {NodePosition[]} positions
     * @returns {number}
     */
    _findBottomPositionIndex(positions) {
        let index = 0;
        let found = positions[index];
        for (let i = 1; i < positions.length; i++) {
            const current = positions[i];
            const count = Math.max(found.length, current.length);
            for (let j = 0; j < count; j++) {
                const v1 = found[j];
                const v2 = current[j];
                if (v1 === undefined || v1 < v2) {
                    found = current;
                    index = i;
                    break;
                } else if (v2 === undefined || v1 > v2) {
                    break;
                }
            }
        }
        return index;
    }
}
