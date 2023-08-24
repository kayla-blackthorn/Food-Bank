// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formShared/sfdcTypings').SfdcFormElementCondition} SfdcFormElementCondition
 */

import * as FieldNames from './formElementConditionFieldNames';
import * as Fields from './formElementConditionFields';


const elementFieldMappings = [
    [Fields.ID_FIELD.fieldApiName, FieldNames.ID],
    [Fields.NAME_FIELD.fieldApiName, FieldNames.NAME],
    [Fields.ELEMENT_FIELD.fieldApiName, FieldNames.ELEMENT_ID],
    [Fields.NEXT_ELEMENT_FIELD.fieldApiName, FieldNames.NEXT_ELEMENT_ID],
    [Fields.CONDITION_OPERATOR_FIELD.fieldApiName, FieldNames.CONDITION_OPERATOR],
    [Fields.CONDITION_VALUE_FIELD.fieldApiName, FieldNames.CONDITION_VALUE],
];

const sfdcFieldsToNormalizedFields = elementFieldMappings.reduce((acc, cur) => {
    acc[cur[0]] = cur[1];
    return acc;
}, /** @type {Record<string, string>} */({}))

const normalizedFieldsToSfdcFields = elementFieldMappings.reduce((acc, cur) => {
    acc[cur[1]] = cur[0];
    return acc;
}, /** @type {Record<string, string>} */({}))

/**
 *
 * @param {string} fieldApiName
 * @returns {string}
 */
export function getFieldNameByFieldApiName(fieldApiName) {
    return sfdcFieldsToNormalizedFields[fieldApiName];
}

/**
 * @param {SfdcFormElementCondition} condition
 * @returns {FormElementCondition}
 */
export function normalizeFormElementCondition(condition) {
    return Object.entries(condition).reduce((acc, [name, value]) => {
        const newName = sfdcFieldsToNormalizedFields[name] || name;
        acc[newName] = value;
        return acc;
    }, /** @type {FormElementCondition} */({}));
}

/**
 * @param {SfdcFormElementCondition[]} conditions
 * @returns {FormElementCondition[]}
 */
export function normalizeFormElementConditions(conditions) {
    return conditions.map(c => normalizeFormElementCondition(c));
}

/**
 * @template {FormElementCondition|Partial<FormElementCondition>} T
 * @param {T} condition
 * @returns {T extends FormElementCondition ? SfdcFormElementCondition : Partial<SfdcFormElementCondition>}
 */
export function denormalizeFormElementCondition(condition) {
    return Object.entries(condition).reduce((acc, [name, value]) => {
        const newName = normalizedFieldsToSfdcFields[name] || name;
        acc[newName] = value;
        return acc;
    }, /** @type {T extends FormElementCondition ? SfdcFormElementCondition : Partial<SfdcFormElementCondition>} */({}));
}

/**
 * @template {FormElementCondition|Partial<FormElementCondition>} T
 * @param {T[]} conditions
 */
export function denormalizeFormElementConditions(conditions) {
    return conditions.map(c => denormalizeFormElementCondition(c));
}
