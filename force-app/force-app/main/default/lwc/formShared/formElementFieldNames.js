// @ts-check

/**
 * @typedef {import('./typings').FormElement} FormElement
 */

export const ID = 'id';
export const NAME = 'name';
export const FORM_ID = 'formId';
export const TYPE = 'type';
export const HINT = 'hint';
export const QUESTION = 'question';
export const QUESTION_RICHTEXT = 'questionRichtext';
export const REQUIRED = 'required';
export const MAPS_TO_OBJECT = 'mapsToObject';
export const MAPS_TO_FIELD = 'mapsToField';
export const DEFAULT_VALUE = 'defaultValue';
export const DEFAULT_CHECKBOX_VALUE = 'defaultCheckboxValue';
export const PICKLIST_VALUES = 'picklistValues';
export const SORT_ORDER = 'sortOrder';
export const BIG_LIST_GROUP_ID = 'bigListGroupId';

export const pushable = [
    ID, FORM_ID, TYPE, HINT, QUESTION, QUESTION_RICHTEXT, REQUIRED, MAPS_TO_OBJECT,
    MAPS_TO_FIELD, DEFAULT_VALUE, DEFAULT_CHECKBOX_VALUE, PICKLIST_VALUES,
    SORT_ORDER, BIG_LIST_GROUP_ID
];
