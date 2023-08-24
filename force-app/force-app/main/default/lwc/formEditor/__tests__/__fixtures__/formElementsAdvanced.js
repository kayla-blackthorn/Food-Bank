// @ts-check

/**
 * The primary purpose is to test the conditions handling for element 9,
 * it's controlled by multiple elements (tagged with char A), the following
 * diagram shows the final structure of the elements after parsing
 *             ┌─────┐
 *           ┌─┤  4  │
 *   ┌─────┐ │ └─────┘
 * ┌─┤  1  ├─┤
 * │ └─────┘ │ ┌─────┐ ┌──────┐
 * │         └─┤ 5 A ├─┤ 10 A │
 * │           └─────┘ └──────┘
 * │
 * │ ┌─────┐   ┌─────┐
 * ├─┤ 2 A ├───┤  6  │
 * │ └─────┘   └─────┘
 * │
 * │           ┌─────┐
 * │         ┌─┤ 7 A │
 * │ ┌─────┐ │ └─────┘
 * └─┤  3  ├─┤
 *   └─────┘ │ ┌─────┐ ┌─────┐
 *           └─┤ 8 A ├─┤  9  │
 *             └─────┘ └─────┘
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
    {
        id: 'e7',
        question: 'question 7',
        sortOrder: 6,
    },
    {
        id: 'e8',
        question: 'question 8',
        sortOrder: 5,
    },
    {
        id: 'e9',
        question: 'question 9',
        sortOrder: 4,
    },
    {
        id: 'e10',
        question: 'question 10',
        sortOrder: 3,
    },
];

/** @type {Partial<FormElementCondition>[]} */
const _formConditions = [
    {
        id: 'c1',
        elementId: 'e1',
        nextElementId: 'e4'
    },
    {
        id: 'c2',
        elementId: 'e1',
        nextElementId: 'e5'
    },
    {
        id: 'c3',
        elementId: 'e5',
        nextElementId: 'e10'
    },
    {
        id: 'c4',
        elementId: 'e2',
        nextElementId: 'e6'
    },
    {
        id: 'c5',
        elementId: 'e3',
        nextElementId: 'e7'
    },
    {
        id: 'c6',
        elementId: 'e3',
        nextElementId: 'e8'
    },
    // the following conditions are for element 9
    {
        id: 'c7',
        elementId: 'e8',
        nextElementId: 'e9'
    },
    {
        id: 'c8',
        elementId: 'e5',
        nextElementId: 'e9'
    },
    {
        id: 'c9',
        elementId: 'e10',
        nextElementId: 'e9'
    },
    {
        id: 'c10',
        elementId: 'e7',
        nextElementId: 'e9'
    },
    {
        id: 'c10',
        elementId: 'e2',
        nextElementId: 'e9'
    },
];

export const formElements = /** @type {FormElement[]} */ (_formElements);
export const formConditions = /** @type {FormElementCondition[]} */ (_formConditions);
