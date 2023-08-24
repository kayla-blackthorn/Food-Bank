import { FormElementFields as fields } from 'c/formShared';

export const visibleFields = new Set([
    fields.QUESTION_FIELD.fieldApiName,
    fields.QUESTION_RICHTEXT_FIELD.fieldApiName,
    fields.TYPE_FIELD.fieldApiName,
    fields.REQUIRED_FIELD.fieldApiName,
    fields.MAPS_TO_OBJECT_FIELD.fieldApiName,
    fields.MAPS_TO_FIELD_FIELD.fieldApiName,
    fields.BIG_LIST_GROUP_FIELD.fieldApiName,
    fields.PICKLIST_VALUES_FIELD.fieldApiName,
    fields.DEFAULT_VALUE_FIELD.fieldApiName,
    fields.DEFAULT_CHECKBOX_VALUE_FIELD.fieldApiName,
    fields.HINT_FIELD.fieldApiName,
]);
