// @ts-check

/**
 * the following diagram shows the final structure of the elements after parsing
 *   ┌─────┐   ┌─────┐
 * ┌─┤  1  ├───┤  2  │
 * │ └─────┘   └─────┘
 * │
 * │ ┌─────┐
 * └─┤  3  │
 *   └─────┘
 */

/**
 * @typedef {import('../../../formShared/typings').FormElement} FormElement
 * @typedef {import('../../../formShared/typings').FormElementCondition} FormElementCondition
 */

/** @type {Partial<FormElement>[]} */
const _formElements = [
    {
        id: 'e1',
        question: 'question 1',
        sortOrder: 12
    },
    {
        id: 'e2',
        question: 'question 2',
        sortOrder: 11
    },
    {
        id: 'e3',
        question: 'question 3',
        sortOrder: 10
    },
];

/** @type {Partial<FormElementCondition>[]} */
const _formConditions = [
    {
        id: 'c1',
        elementId: 'e1',
        nextElementId: 'e2'
    },
    {
        id: 'c2',
        elementId: 'e1',
        nextElementId: 'e2'
    },
];

export const formElements = /** @type {FormElement[]} */ (_formElements);
export const formConditions = /** @type {FormElementCondition[]} */ (_formConditions);