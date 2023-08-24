// @ts-check

/**
 * @typedef {import('./typings').FormElement} FormElement
 * @typedef {import('./sfdcTypings').SfdcFormElement} SfdcFormElement
 */

import * as FieldNames from './formElementFieldNames';
import * as Fields from './formElementFields';

const elementFieldMappings = [
    [Fields.ID_FIELD.fieldApiName, FieldNames.ID],
    [Fields.NAME_FIELD.fieldApiName, FieldNames.NAME],
    [Fields.FORM_FIELD.fieldApiName, FieldNames.FORM_ID],
    [Fields.TYPE_FIELD.fieldApiName, FieldNames.TYPE],
    [Fields.HINT_FIELD.fieldApiName, FieldNames.HINT],
    [Fields.REQUIRED_FIELD.fieldApiName, FieldNames.REQUIRED],
    [Fields.QUESTION_FIELD.fieldApiName, FieldNames.QUESTION],
    [Fields.QUESTION_RICHTEXT_FIELD.fieldApiName, FieldNames.QUESTION_RICHTEXT],
    [Fields.SORT_ORDER_FIELD.fieldApiName, FieldNames.SORT_ORDER],
    [Fields.MAPS_TO_OBJECT_FIELD.fieldApiName, FieldNames.MAPS_TO_OBJECT],
    [Fields.MAPS_TO_FIELD_FIELD.fieldApiName, FieldNames.MAPS_TO_FIELD],
    [Fields.BIG_LIST_GROUP_FIELD.fieldApiName, FieldNames.BIG_LIST_GROUP_ID],
    [Fields.PICKLIST_VALUES_FIELD.fieldApiName, FieldNames.PICKLIST_VALUES],
    [Fields.DEFAULT_VALUE_FIELD.fieldApiName, FieldNames.DEFAULT_VALUE],
    [Fields.DEFAULT_CHECKBOX_VALUE_FIELD.fieldApiName, FieldNames.DEFAULT_CHECKBOX_VALUE],
];

const sfdcFieldsToNormalizedFields = elementFieldMappings.reduce((acc, cur) => {
    acc[cur[0]] = cur[1];
    return acc;
}, /** @type {Record<string, string>} */({}));

const normalizedFieldsToSfdcFields = elementFieldMappings.reduce((acc, cur) => {
    acc[cur[1]] = cur[0];
    return acc;
}, /** @type {Record<string, string>} */({}));

/**
 *
 * @param {string} fieldApiName
 * @returns {string}
 */
export function getFieldNameByFieldApiName(fieldApiName) {
    return sfdcFieldsToNormalizedFields[fieldApiName];
}

/**
 * @param {SfdcFormElement} element
 * @returns {FormElement}
 */
export function normalizeFormElement(element) {
    return Object.entries(element).reduce((acc, [name, value]) => {
        const newName = sfdcFieldsToNormalizedFields[name] || name;
        acc[newName] = value;
        return acc;
    }, /** @type {FormElement} */({}));
}

/**
 * @param {SfdcFormElement[]} elements
 * @returns {FormElement[]}
 */
export function normalizeFormElements(elements) {
    return elements.map(e => normalizeFormElement(e));
}

/**
 * @template {FormElement|Partial<FormElement>} T
 * @param {T} element
 * @returns {T extends FormElement ? SfdcFormElement : Partial<SfdcFormElement>}
 */
export function denormalizeFormElement(element) {
    return Object.entries(element).reduce((acc, [name, value]) => {
        const newName = normalizedFieldsToSfdcFields[name] || name;
        acc[newName] = value;
        return acc;
    }, /** @type {T extends FormElement ? SfdcFormElement : Partial<SfdcFormElement>} */({}));
}

/**
 * @template {FormElement|Partial<FormElement>} T
 * @param {T[]} elements
 */
export function denormalizeFormElements(elements) {
    return elements.map(e => denormalizeFormElement(e));
}
