// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 */

/**
 * @typedef {number[]} NodePosition
 */

export class FormElementNode {
    /** @type {FormElement} */
    element;

    /** @type {FormElementNode[]} */
    subElementNodes = [];

    index = 0;

    /** @type {FormElementNode|undefined} */
    parentNode;

    expanded = true;

    /** @type {string} */
    get id() {
        return this.element.id;
    }

    /** @type {NodePosition} */
    get position() {
        /** @type {FormElementNode[]} */
        const ancestors = [this];
        let parent = this.parentNode;
        while (parent) {
            ancestors.push(parent);
            parent = parent.parentNode;
        }
        return ancestors.reverse().map((n) => n.index);
    }

    /** @type {number} */
    get depth() {
        return this.position.length;
    }

    /** @type {boolean} */
    get expandable() {
        return this.subElementNodes.length > 0;
    }

    /** @type {FormElementNode|undefined} */
    get siblingBefore() {
        if (!this.parentNode) {
            return undefined;
        }
        const siblingIndex = this.index > 0 ? this.index - 1 : -1;
        return this.parentNode.subElementNodes[siblingIndex];
    }

    /** @type {FormElementNode|undefined} */
    get siblingAfter() {
        if (!this.parentNode) {
            return undefined;
        }
        const siblingIndex = this.index < this.parentNode.subElementNodes.length - 1 ? this.index + 1 : -1;
        return this.parentNode.subElementNodes[siblingIndex];
    }

    /**
     *
     * @param {FormElement} element
     */
    constructor(element) {
        this.element = element;
    }

    /**
     *
     * @param {string} id
     * @returns {boolean}
     */
    hasSubElementNode(id) {
        return !!this.subElementNodes.find((n => n.id === id));
    }

    /**
     *
     * @param {FormElementNode} node
     */
    appendSubElementNode(node) {
        if (node.parentNode === this && node.index === this.subElementNodes.length - 1) {
            // it's already at the expected place
            return;
        }
        if (node.parentNode) {
            node.parentNode.removeSubElementNode(node.id);
        }
        node.parentNode = this;
        this.subElementNodes.push(node);
        this._rebuildSubIndexes();
    }

    /**
     *
     * @param {FormElementNode} node
     * @param {number} index
     */
    insertSubElementNode(node, index) {
        if (node.parentNode === this && node.index === index) {
            // it's already at the expected place
            return;
        }
        // removeSubElementNode changes the indexes, so we need the targetNode
        // to get the right index in case the node is already in the this.subElementNodes
        const targetNode = this.subElementNodes[index];
        if (node.parentNode) {
            node.parentNode.removeSubElementNode(node.id);
        }
        if (targetNode) {
            index = targetNode.index;
        }
        node.parentNode = this;
        this.subElementNodes.splice(index, 0, node);
        this._rebuildSubIndexes();
    }

    /**
     *
     * @param {FormElementNode} node
     */
    insertSubElementNodeBySortOrder(node) {
        const sortOrder = node.element.sortOrder || 0;
        let index = 0;
        for (let i = 0; i < this.subElementNodes.length; i++) {
            const currentSortOrder = this.subElementNodes[i].element.sortOrder || 0;
            if (sortOrder > currentSortOrder) {
                // put it before the current node
                index = i;
                break;
            } else {
                // put it after the current node temporarily
                index = i + 1;
            }
        }
        this.insertSubElementNode(node, index);
    }

    /**
     *
     * @param {string} id
     */
    removeSubElementNode(id) {
        this.subElementNodes = this.subElementNodes.filter(n => n.id !== id);
        this._rebuildSubIndexes();
    }

    /**
     *
     * @param {string[]} ids
     */
    removeSubElementNodes(ids) {
        this.subElementNodes = this.subElementNodes.filter(n => !ids.includes(n.id));
        this._rebuildSubIndexes();
    }

    /**
     *
     * @param {FormElementNode} node
     * @param {string} targetNodeId
     */
    insertSubElementNodeBefore(node, targetNodeId) {
        if (node.id === targetNodeId) {
            return;
        }
        const targetNode = this.subElementNodes.find(n => n.id === targetNodeId);
        if (!targetNode) {
            return;
        }
        if (node.parentNode) {
            node.parentNode.removeSubElementNode(node.id);
        }
        node.parentNode = this;
        this.subElementNodes.splice(targetNode.index, 0, node);
        this._rebuildSubIndexes();
    }

    /**
     *
     * @param {FormElementNode} node
     * @param {string} targetNodeId
     */
    insertSubElementNodeAfter(node, targetNodeId) {
        if (node.id === targetNodeId) {
            return;
        }
        const targetNode = this.subElementNodes.find(n => n.id === targetNodeId);
        if (!targetNode) {
            return;
        }
        if (node.parentNode) {
            node.parentNode.removeSubElementNode(node.id);
        }
        node.parentNode = this;
        this.subElementNodes.splice(targetNode.index + 1, 0, node);
        this._rebuildSubIndexes();
    }

    _rebuildSubIndexes() {
        this.subElementNodes.forEach((node, index) => {
            node.index = index;
        });
    }
}
