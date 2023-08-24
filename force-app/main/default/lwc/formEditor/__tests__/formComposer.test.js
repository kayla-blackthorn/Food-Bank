// @ts-check
/**
 * @typedef {import('../../formShared/typings').FormElement} FormElement
 * @typedef {import('../../formShared/typings').VirtualFormElement} VirtualFormElement
 * @typedef {import('../../formShared/typings').FormElementCondition} FormElementCondition
 */

import { FormComposer, CONDITION_INCOMPLETE, CONDITION_CIRCULAR_DEPENDENCY } from '../formComposer';
import { BeDependedOnError, GroupMismatchError } from '../errors';
import { formElements, formConditions } from './__fixtures__/formElementsBasic';
import { formElements as formElementsOutOfOrder, formConditions as formConditionsOutOfOrder } from './__fixtures__/formElementsOutOfOrder';
import { formElements as formElementsAdvanced, formConditions as formConditionsAdvanced } from './__fixtures__/formElementsAdvanced';
import { formElements as formElementsAdvanced2, formConditions as formConditionsAdvanced2 } from './__fixtures__/formElementsAdvanced2';
import { formElements as formElementsDupeCondition, formConditions as formConditionsDupeCondition } from './__fixtures__/formElementsDupeCondition';
import { formElements as formElementsCircularDependency, formConditions as formConditionsCircularDependency } from './__fixtures__/formElementsCircularDependency';

describe('FormComposer', () => {
    describe('Initially build the form', () => {
        it('should return elements with the right levels and order', () => {
            const composer = new FormComposer(formElements, formConditions);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e2', 2],
                ['e3', 3],
                ['e4', 4],
                ['e5', 3],

                ['e6', 1],
            ]);
        });

        it('should return elements with the right levels and order when the elements and conditions are out of order', () => {
            const composer = new FormComposer(formElementsOutOfOrder, formConditionsOutOfOrder);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e2', 2],
                ['e3', 3],
                ['e4', 4],
                ['e5', 3],

                ['e6', 1],
            ]);
        });

        it('should return elements with the right levels and order when there are multiple conditions for a single element', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
                ['e10', 3],

                ['e2', 1],
                ['e6', 2],

                ['e3', 1],
                ['e7', 2],
                ['e8', 2],
                ['e9', 3],
            ]);
        });

        it('should render correctly there are multiple conditions with the same controlling element', () => {
            const composer = new FormComposer(formElementsDupeCondition, formConditionsDupeCondition);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e2', 2],

                ['e3', 1],
            ]);
        });

        it('should ignore circular dependency conditions when rendering', () => {
            const composer = new FormComposer(formElementsCircularDependency, formConditionsCircularDependency);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e2', 2],

                ['e3', 1],
            ]);
        });

        it('should keep the source order when sort order is empty', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' },
                { id: 'e2' },
                { id: 'e3' },
                { id: 'e4'},
            ]);
            const composer = new FormComposer(sourceElements);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e2', 1],
                ['e3', 1],
                ['e4', 1],
            ]);
        });
    });

    describe('Invalid condition detection', () => {
        it('Should consider a condition invalid if element or next element is empty', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e1', nextElementId: undefined },
            ]);
            const composer = new FormComposer(sourceElements, sourceConditions);
            expect(composer.invalidConditions).toEqual(new Map([
                [CONDITION_INCOMPLETE, [sourceConditions[1]]]
            ]));
        });

        it('Should consider a condition invalid if element equals next element', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e1', nextElementId: 'e1' },
            ]);
            const composer = new FormComposer(sourceElements, sourceConditions);
            expect(composer.invalidConditions).toEqual(new Map([
                [CONDITION_CIRCULAR_DEPENDENCY, [sourceConditions[1]]]
            ]));
        });

        it('Should consider a condition invalid if next element is already controlled by element directly', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e2', nextElementId: 'e1' },
            ]);
            const composer = new FormComposer(sourceElements, sourceConditions);
            expect(composer.invalidConditions).toEqual(new Map([
                [CONDITION_CIRCULAR_DEPENDENCY, [sourceConditions[1]]]
            ]));
        });

        it('Should consider a condition invalid if next element is already controlled by element indirectly', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }, { id: 'e3' }, { id: 'e4' },
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e2', nextElementId: 'e3' },
                { id: 'c3', elementId: 'e3', nextElementId: 'e4' },
                { id: 'c3', elementId: 'e4', nextElementId: 'e1' },
            ]);
            const composer = new FormComposer(sourceElements, sourceConditions);
            expect(composer.invalidConditions).toEqual(new Map([
                [CONDITION_CIRCULAR_DEPENDENCY, [sourceConditions[3]]]
            ]));
        });
    });

    describe('Retrive form elements hierarchy', () => {
        it('Should be able to retrive a sub hierarchy', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const hierarchy = composer.getFormElementsHierarchy('e5');
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e5', 2],
                ['e10', 3],
            ]);
        });

        it('Should be able to retrive nodes with inspection mode', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const hierarchy = composer.getFormElementsHierarchy('e5', { mode: 'inspection' });
            const v1 = /** @type {VirtualFormElement} */(hierarchy[0].element);
            const v3 = /** @type {VirtualFormElement} */(hierarchy[3].element);
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(v1.virtual).toBe(true);
            expect(v3.virtual).toBe(true);
            expect(hierarchy[0].level).toBe(1);
            expect(hierarchy[3].level).toBe(1)
            expect(elements.slice(1, 3)).toEqual([
                ['e5', 2],
                ['e10', 3],
            ]);
            expect(elements.slice(4)).toEqual([
                ['e9', 3],
            ]);
        });
    });

    describe('Expand/collapse a sub hierarchy (hierarchy mode)', () => {
        it('Should be able to expand a sub hierarchy with depth 0', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', 0);
            const hierarchy = composer.getFormElementsHierarchy('e1');
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
            ]);
        });

        it('Should be able to expand a sub hierarchy with depth 1', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', 1);
            const hierarchy = composer.getFormElementsHierarchy('e1');
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
            ]);
        });

        it('Should be able to expand a sub hierarchy with depth Infinity', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', Infinity);
            const hierarchy2 = composer.getFormElementsHierarchy('e1');
            const elements2 = hierarchy2.map(h => ([h.element.id, h.level]));
            expect(elements2).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
                ['e10', 3],
            ]);
        });
    });

    describe('Expand/collapse a sub hierarchy in (inspection mode)', () => {
        it('Should be able to expand a sub hierarchy with depth 0', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', 0);
            const hierarchy = composer.getFormElementsHierarchy('e1', { mode: 'inspection' });
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            const v1 = /** @type {VirtualFormElement} */(hierarchy[1].element);
            expect(elements.slice(0, 1)).toEqual([
                ['e1', 1],
            ]);
            expect(v1.virtual).toBe(true);
            expect(hierarchy[1].level).toBe(1);
            expect(elements.slice(2)).toEqual([
                ['e9', 3],
            ]);
        });

        it('Should be able to expand a sub hierarchy with depth 1', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', 1);
            const hierarchy = composer.getFormElementsHierarchy('e1', { mode: 'inspection' });
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            const v3 = /** @type {VirtualFormElement} */(hierarchy[3].element);
            expect(elements.slice(0, 3)).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
            ]);
            expect(v3.virtual).toBe(true);
            expect(hierarchy[3].level).toBe(1);
            expect(elements.slice(4)).toEqual([
                ['e9', 3],
            ]);
        });

        it('Should be able to expand a sub hierarchy with depth Infinity', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            composer.expandSubHierarchy('e1', Infinity);
            const hierarchy = composer.getFormElementsHierarchy('e1', { mode: 'inspection' });
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            const v4 = /** @type {VirtualFormElement} */(hierarchy[4].element);
            expect(elements.slice(0, 4)).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
                ['e10', 3],
            ]);
            expect(v4.virtual).toBe(true);
            expect(hierarchy[4].level).toBe(1);
            expect(elements.slice(5)).toEqual([
                ['e9', 3],
            ]);
        });
    });

    describe('Move an element around', () => {
        it('should support move an element around when elements has one conditon at most', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const { mutated, error } = composer.moveElement('e5', 'e4', 'before');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toBe(true);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e1', 1],
                ['e5', 2],
                ['e10', 3],
                ['e4', 2],

                ['e2', 1],
                ['e6', 2],

                ['e3', 1],
                ['e7', 2],
                ['e8', 2],
                ['e9', 3],
            ]);
        });

        it('should recalculate the hierarchy when moving an element around in case there are elements with multiple conditions (up)', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const { mutated, error } = composer.moveElement('e3', 'e2', 'before');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toBe(true);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
                ['e10', 3],

                ['e3', 1],
                ['e7', 2],
                ['e8', 2],

                ['e2', 1],
                ['e9', 2],
                ['e6', 2],
            ]);
        });

        it('should recalculate the hierarchy when moving an element around in case there are elements with multiple conditions (down)', () => {
            const composer = new FormComposer(formElementsAdvanced, formConditionsAdvanced);
            const { mutated, error } = composer.moveElement('e1', 'e3', 'after');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toBe(true);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e2', 1],
                ['e6', 2],

                ['e3', 1],
                ['e7', 2],
                ['e8', 2],

                ['e1', 1],
                ['e4', 2],
                ['e5', 2],
                ['e10', 3],
                ['e9', 4],
            ]);
        });

        it('should keep the original ordering for not re parenting elements after recalculating the hierarchy', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.moveElement('e1', 'e2', 'after');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toBe(true);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e2', 1],
                ['e5', 2],

                ['e1', 1],
                ['e4', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('should not move elements if dry run', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.moveElement('e1', 'e2', 'after', { dryRun: true });
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toBe(false);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('should only allow move inside of the same group', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.moveElement('e4', 'e1', 'after');
            expect(mutated).toBe(false);
            expect(error).toBeInstanceOf(GroupMismatchError);
        });
    });

    describe('Update an element', () => {
        it('Should partially update an element', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const element = {
                id: 'e6',
                question: 'question 6',
                sortOrder: 7
            };
            composer.updateFormElement(element.id, { question: 'modified' });
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));

            // the hierarchy should not change since no conditions are updated
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
            const e6 = hierarchy.find(h => h.element.id === element.id).element;
            expect(e6.question).toEqual('modified');
        });

        it('Should update an element and conditions (1)', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const element = {
                id: 'e6',
                question: 'question 6',
                sortOrder: 7
            };
            composer.updateFormElement(element.id, { question: 'modified' }, []);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));

            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e7', 2],

                ['e6', 1],
            ]);
            const e6 = hierarchy.find(h => h.element.id === element.id).element;
            expect(e6.question).toEqual('modified');
        });

        it('Should update an element and conditions (2)', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const element = {
                id: 'e6',
                question: 'question 6',
                sortOrder: 7
            };
            const conditions = [
                {
                    id: 'c4',
                    elementId: 'e3',
                    nextElementId: 'e6'
                },
                {
                    id: 'c6',
                    elementId: 'e7',
                    nextElementId: 'e6'
                },
            ];
            composer.updateFormElement(element.id, { question: 'modified' }, /** @type {FormElementCondition[]} */ (conditions));
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));

            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e7', 2],
                ['e6', 3],
            ]);
            const e6 = hierarchy.find(h => h.element.id === element.id).element;
            expect(e6.question).toEqual('modified');
        });

        it('Should rearrange the elements in the hierarchy when update an element and its conditions', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }, { id: 'e3' }, { id: 'e4'},
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e2', nextElementId: 'e4' },
                { id: 'c2', elementId: 'e3', nextElementId: 'e4' },
            ]);
            /**
             * The parsed structure of the above elements and conditions,
             * element 4 is controlled by 2 and 3
             *   ┌─────┐
             * ┌─┤  1  │
             * │ └─────┘
             * │
             * │ ┌─────┐
             * ├─┤  2A │
             * │ └─────┘
             * │
             * │ ┌─────┐  ┌─────┐
             * └─┤  3A ├──┤  4C │
             *   └─────┘  └─────┘
             */
            const composer = new FormComposer(sourceElements, sourceConditions);
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(elements).toEqual([
                ['e1', 1], ['e2', 1], ['e3', 1], ['e4', 2]
            ]);

            /** @type {FormElementCondition} */
            const newCondition = /** @type {any} */ (
                { id: 'c3', elementId: 'e1', nextElementId: 'e3' }
            );
            /**
             *  The structure will become the following after applying the new condition for 3
             *  element 4 is controlled by 2 and 3
             *   ┌─────┐ ┌─────┐
             * ┌─┤  1  ├─┤  3A │
             * │ └─────┘ └─────┘
             * │
             * │ ┌─────┐ ┌─────┐
             * └─┤  2A ├─┤  4C │
             *   └─────┘ └─────┘
             */
            composer.updateFormElement('e3', {}, [newCondition]);
            const hierarchy1 = composer.getFormElementsHierarchy();
            const elements1 = hierarchy1.map(h => ([h.element.id, h.level]));
            expect(elements1).toEqual([
                ['e1', 1], ['e3', 2], ['e2', 1], ['e4', 2]
            ]);
        });
    });

    describe('Add an element', () => {
        it('Should add an element', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const element = {
                id: 'e8',
                question: 'question 8',
                sortOrder: 5
            };
            const conditions = [
                {
                    id: 'c6',
                    elementId: 'e5',
                    nextElementId: 'e8'
                },
            ];
            composer.addFormElement(/** @type {FormElement} */ (element), /** @type {FormElementCondition[]} */ (conditions));
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));

            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],
                ['e8', 3],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('Should update an element instead if it already exist', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const element = {
                id: 'e6',
                question: 'modified',
                sortOrder: 7
            };
            composer.addFormElement(/** @type {FormElement} */ (element));
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));

            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
            const e6 = hierarchy.find(h => h.element.id === element.id).element;
            expect(e6.question).toEqual('modified');
        });
    });

    describe('Remove an element', () => {
        it('Should remove an element', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.removeFormElement('e5');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toEqual(true);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('Should not remove an element if dry run', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.removeFormElement('e5', { dryRun: true });
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toEqual(false);
            expect(error).toBeFalsy();
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('Should not remove an element if the element is depended on by other elements (all in the sub tree) when removing it', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.removeFormElement('e2');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toEqual(false);
            expect(error).toBeInstanceOf(BeDependedOnError);
            const context = /** @type {BeDependedOnError} */(error).context;
            expect(context.affectedElementIds).toEqual(context.subHierarchyElementIds)
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });

        it('Should not remove an element if the element is depended on by other elements (not all in the sub tree) when removing it', () => {
            const composer = new FormComposer(formElementsAdvanced2, formConditionsAdvanced2);
            const { mutated, error } = composer.removeFormElement('e1');
            const hierarchy = composer.getFormElementsHierarchy();
            const elements = hierarchy.map(h => ([h.element.id, h.level]));
            expect(mutated).toEqual(false);
            expect(error).toBeInstanceOf(BeDependedOnError);
            const context = /** @type {BeDependedOnError} */(error).context;
            expect(context.affectedElementIds).toEqual(['e4', 'e6']);
            expect(context.subHierarchyElementIds).toEqual(['e4']);
            expect(elements).toEqual([
                ['e1', 1],
                ['e4', 2],

                ['e2', 1],
                ['e5', 2],

                ['e3', 1],
                ['e6', 2],
                ['e7', 2],
            ]);
        });
    });

    describe('Calculate sort order updates', () => {
        it('Should calculate the updates inside each group', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }, { id: 'e3' }, { id: 'e4'}, { id: 'e5'}, { id: 'e6'},
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e1', nextElementId: 'e3' },
                { id: 'c3', elementId: 'e4', nextElementId: 'e5' },
                { id: 'c4', elementId: 'e4', nextElementId: 'e6' },
            ]);
            /**
             * The parsed structure of the above elements and conditions
             *              ┌─────┐
             *           ┌──┤  2  │
             *   ┌─────┐ │  └─────┘
             * ┌─┤  1  ├─┤
             * │ └─────┘ │  ┌─────┐
             * │         └──┤  3  │
             * │            └─────┘
             * │
             * │            ┌─────┐
             * │         ┌──┤  5  │
             * │ ┌─────┐ │  └─────┘
             * └─┤  4  ├─┤
             *   └─────┘ │  ┌─────┐
             *           └──┤  6  │
             *              └─────┘
             */
            const composer = new FormComposer(sourceElements, sourceConditions);
            const updates = composer.calcSortOrderUpdates();
            expect(updates).toEqual([
                { id: 'e3', sortOrder: 100 },
                { id: 'e2', sortOrder: 110 },

                { id: 'e6', sortOrder: 100 },
                { id: 'e5', sortOrder: 110 },

                { id: 'e4', sortOrder: 100 },
                { id: 'e1', sortOrder: 110 }
            ]);
        });

        it('Should skip the calculations for groups with zero or only one element', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }, { id: 'e3' }, { id: 'e4'}, { id: 'e5'},
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e1', nextElementId: 'e3' },
                { id: 'c3', elementId: 'e4', nextElementId: 'e5' },
            ]);
            /**
             * The parsed structure of the above elements and conditions
             *              ┌─────┐
             *           ┌──┤  2  │
             *   ┌─────┐ │  └─────┘
             * ┌─┤  1  ├─┤
             * │ └─────┘ │  ┌─────┐
             * │         └──┤  3  │
             * │            └─────┘
             * │
             * │ ┌─────┐    ┌─────┐
             * └─┤  4  ├────┤  5  │
             *   └─────┘    └─────┘
             */
            const composer = new FormComposer(sourceElements, sourceConditions);
            const updates = composer.calcSortOrderUpdates();
            expect(updates).toEqual([
                { id: 'e3', sortOrder: 100 },
                { id: 'e2', sortOrder: 110 },

                { id: 'e4', sortOrder: 100 },
                { id: 'e1', sortOrder: 110 }
            ]);
        });
    });

    describe('#getControllingElementCandidates', () => {
        it('Should return elements with no relationship to the controlled node', () => {
            /** @type {FormElement[]} */
            const sourceElements = /** @type {Partial<FormElement[]>} */ ([
                { id: 'e1' }, { id: 'e2' }, { id: 'e3' }, { id: 'e4'}, { id: 'e5'}, { id: 'e6'},
            ]);
            /** @type {FormElementCondition[]} */
            const sourceConditions = /** @type {Partial<FormElementCondition[]>} */ ([
                { id: 'c1', elementId: 'e1', nextElementId: 'e2' },
                { id: 'c2', elementId: 'e1', nextElementId: 'e4' },
                { id: 'c3', elementId: 'e3', nextElementId: 'e4' },
                { id: 'c4', elementId: 'e4', nextElementId: 'e5' },
                { id: 'c5', elementId: 'e3', nextElementId: 'e6' },
            ]);
            /**
             * The parsed structure of the above elements and conditions,
             * element 4 is controlled by 1 and 3
             *   ┌─────┐   ┌─────┐
             * ┌─┤  1A ├───┤  2  │
             * │ └─────┘   └─────┘
             * │
             * │           ┌─────┐  ┌─────┐
             * │         ┌─┤  4C ├──┤  5  │
             * │ ┌─────┐ │ └─────┘  └─────┘
             * └─┤  3A ├─┤
             *   └─────┘ │ ┌─────┐
             *           └─┤  6  │
             *             └─────┘
             */
            const composer = new FormComposer(sourceElements, sourceConditions);

            // return all elements for new node
            let elementIds = composer.getControllingElementCandidates().map(e => e.id);
            expect(elementIds).toEqual(['e1', 'e2', 'e3', 'e4', 'e5', 'e6']);

            // return no relationship elements for existing node
            elementIds = composer.getControllingElementCandidates('e1').map(e => e.id);
            expect(elementIds).toEqual(['e3', 'e6']);
        });
    });
});
