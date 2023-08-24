// @ts-check

/**
 * @typedef {import('./typings').FormElementCondition} FormElementCondition
 */

export const ID = 'id';
export const NAME = 'name';
export const ELEMENT_ID = 'elementId';
export const NEXT_ELEMENT_ID = 'nextElementId';
export const CONDITION_OPERATOR = 'conditionOperator';
export const CONDITION_VALUE = 'conditionValue';

export const pushable = [
    ID, ELEMENT_ID, NEXT_ELEMENT_ID, CONDITION_OPERATOR, CONDITION_VALUE
];
