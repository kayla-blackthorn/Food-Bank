// @ts-check

/**
 * the following diagram shows the final structure of the elements after parsing
 *                     ┌─────┐ ┌─────┐
 *                   ┌─┤  3  ├─┤  4  │
 *   ┌─────┐ ┌─────┐ │ └─────┘ └─────┘
 * ┌─┤  1  ├─┤  2  ├─┤
 * │ └─────┘ └─────┘ │ ┌─────┐
 * │                 └─┤  5  │
 * │ ┌─────┐           └─────┘
 * └─┤  6  │
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
    {
        id: 'e4',
        question: 'question 4',
        sortOrder: 9
    },
    {
        id: 'e5',
        question: 'question 5',
        sortOrder: 8,
    },
    {
        id: 'e6',
        question: 'question 6',
        sortOrder: 7,
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
        elementId: 'e2',
        nextElementId: 'e3'
    },
    {
        id: 'c3',
        elementId: 'e3',
        nextElementId: 'e4'
    },
    {
        id: 'c4',
        elementId: 'e2',
        nextElementId: 'e5'
    }
];

export const formElements = /** @type {FormElement[]} */ (_formElements);
export const formConditions = /** @type {FormElementCondition[]} */ (_formConditions);
