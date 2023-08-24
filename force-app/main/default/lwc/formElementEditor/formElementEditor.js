// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formShared/typings').TrueOrFalse} TrueOrFalse
 * @typedef {import('../typings/objectInfo').Field} ObjectField
 * @typedef {import('../typings/objectInfo').ObjectInfo} ObjectInfo
 * @typedef {import('../typings/input').ValidatableInput} ValidatableInput
 * @typedef {import('../formElementConditionsEditor/formElementConditionsEditor').default} FormElementConditionsEditor
 * @typedef {import('../formElementConditionsEditor/mutationsCalculator').ConditionMutations} ConditionMutations
 */

/**
 * @typedef {import('./typings').EditorFieldsVisibility} EditorFieldsVisibility
 * @typedef {import('./typings').ExpandedElement} ExpandedElement
 * @typedef {import('./mutationsCalculator').ElementMutations} ElementMutations
 */

/**
 * @typedef {object} ElementMutationsAddons
 * @property {ConditionMutations=} conditionMutations
*/

/**
 * @typedef {ElementMutationsAddons & ElementMutations} FormElementMutations
*/

/**
 * @template T
 * @typedef {import('../typings/dom').ChangeEvent<T>} ChangeEvent
 */

/**
 * @template T
 * @typedef {import('../typings/picklist').ViewValue<T>} ViewValue
 */

import { api, track, LightningElement } from 'lwc';

import FORM_BIG_LIST_GROUP_OBJECT from '@salesforce/schema/Form_Big_List_Group__c';
import { FormElementFieldNames as FieldNames, QuestionTypes } from 'c/formShared';
import { calcElementMutations } from './mutationsCalculator';
import * as fieldsVisibility from './fieldsVisibility';
import NewBigListGroupModal from 'c/newBigListGroupModal';

// lightning-combobox options doesn't support boolean value, so use string instead
/** @type {ViewValue<TrueOrFalse>[]} */
const yesOrNoOptions = [
    { label: 'Yes', value: 'true' },
    { label: 'No', value: 'false' },
];

// lightning-combobox options doesn't support boolean value, so use string instead
/** @type {ViewValue<TrueOrFalse>[]} */
const checkboxOptions = [
    { label: 'Checked', value: 'true' },
    { label: 'Unchecked', value: 'false' },
];

export default class FormElementEditor extends LightningElement {
    /** @type {string} */
    @api formId;

    /** @type {FormElement} */
    @api element;

    /** @type {FormElementCondition[]} */
    @api conditions;

    /** @type {FormElement[]} */
    @api availableElements;

    /** @type {Record<string, string>} */
    @api labels; // labels is guaranteed to be a none null object by it's parent

    /** @type {ViewValue<string>[]} */
    @api questionTypes = [];

    /** @type {ViewValue<string>[]} */
    @api mapsToObjectOptions = [];

    /** @type {ViewValue<string>[]} */
    @api mapsToFieldOptions = [];

    /** @type {ViewValue<string>[]} */
    @api bigListGroupOptions = [];

    /** @type {ViewValue<TrueOrFalse>[]} */
    @track yesOrNoOptions = yesOrNoOptions;

    /** @type {ViewValue<TrueOrFalse>[]} */
    @track checkboxOptions = checkboxOptions;

    /** @type {Record<string, ObjectField>} */
    @track elementFieldsInfo = {};

    /** @type {EditorFieldsVisibility} */
    @track fieldsVisibility = {};

    /** @type {ExpandedElement} */
    @track mutableElement;

    get isDivider() {
        return this.mutableElement.type === QuestionTypes.DIVIDER;
    }

    /** @type {string} */
    get formBigListGroupApiName() {
        return FORM_BIG_LIST_GROUP_OBJECT.objectApiName;
    }

    connectedCallback() {
        this.mutableElement = { ...this.element };
        this.mutableElement._required = this.mutableElement.required ? 'true' : 'false';
        this.mutableElement._defaultCheckboxValue = this.mutableElement.defaultCheckboxValue ? 'true' : 'false';
        if (!this.mutableElement.formId) {
            this.mutableElement.formId = this.formId;
        }
        this.fieldsVisibility = this._calcFieldsVisibility(this.mutableElement.type);
    }

    /**
     * @returns {boolean}
     */
    @api reportValidity() {
        // lightning-input-rich-text does not have reportValidity api, but it's
        // always valid in this use case, just skip it
        /** @type {ValidatableInput[]} */
        const inputs = /** @type {any} */(Array.from(this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, c-lookup')));
        let isAllValid = inputs.every(input => input.checkValidity());
        if (!isAllValid) {
            inputs.forEach(input => input.reportValidity());
        }
        /** @type {FormElementConditionsEditor} */
        const conditionsEditor = /** @type {any} */(this.template.querySelector('c-form-element-conditions-editor'));
        if (!conditionsEditor.reportValidity()) {
            isAllValid = false;
        }
        return isAllValid;
    }

    /**
     * @returns {FormElementMutations}
     */
    @api getMutations() {
        /** @type {FormElementConditionsEditor} */
        const conditionsEditor = /** @type {any} */(this.template.querySelector('c-form-element-conditions-editor'));
        const conditionMutations = conditionsEditor.getMutations();
        const mutations = calcElementMutations(this.element, this.mutableElement);
        return {
            ...mutations,
            conditionMutations,
        };
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setQuestionType(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.TYPE, value);
        /** @type {Partial<{ [P in keyof FormElement]: boolean }>} */
        this.fieldsVisibility = this._calcFieldsVisibility(value);
        this.dispatchEvent(new CustomEvent('typechange', {
            detail: {
                value,
            },
        }));
    }

    /**
     * Set the value for Supplemental Question Information
     *
     * Notice: it's not actually a HTMLTextAreaElement, it has value but not name,
     * just give it a type so we can get the value
     *
     * @param {ChangeEvent<HTMLTextAreaElement>} event
     */
    setQuestionRichtext(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.QUESTION_RICHTEXT, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setQuestion(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.QUESTION, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setMapsToObject(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.MAPS_TO_OBJECT, value);
        // always reset mapsToField when mapsToObject changes
        this._setFieldValue(FieldNames.MAPS_TO_FIELD, '');

        this.dispatchEvent(new CustomEvent('mapstoobjectchange', {
            detail: {
                value,
            },
        }));
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setMapsToField(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.MAPS_TO_FIELD, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setBigListGroupId(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.BIG_LIST_GROUP_ID, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setRequired(event) {
        const value = /** @type {TrueOrFalse} */(event.target.value);
        const required = value === 'true' ? true : false;
        this._setFieldValue(FieldNames.REQUIRED, required);
        // this is special for required, bc lightning-combobox doesn't support boolean value
        this._setFieldValue(`_${FieldNames.REQUIRED}`, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setPicklistValues(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.PICKLIST_VALUES, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setDefaultValue(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.DEFAULT_VALUE, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setDefaultCheckboxValue(event) {
        const value = /** @type {TrueOrFalse} */(event.target.value);
        const checked = value === 'true' ? true : false;
        this._setFieldValue(FieldNames.DEFAULT_CHECKBOX_VALUE, checked);
        // this is special for checkbox, bc lightning-combobox doesn't support boolean value
        this._setFieldValue(`_${FieldNames.DEFAULT_CHECKBOX_VALUE}`, value);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setHint(event) {
        const value = event.target.value;
        this._setFieldValue(FieldNames.HINT, value);
    }

    async openCreateNewBigListGroupModal() {
        const result = await NewBigListGroupModal.open({
            size: 'small',
            modalTitle: 'Create new Form Big List Group',
        });

        if (result?.recordId) {
            this._setFieldValue(FieldNames.BIG_LIST_GROUP_ID, result.recordId);
            this.template.querySelector('c-lookup').resetSelection({ recordId : result.recordId });
        }
    }

    /**
     * @param {string} questionType
     * @returns {EditorFieldsVisibility}
     */
    _calcFieldsVisibility(questionType) {
        switch (questionType) {
            case QuestionTypes.PICKLIST:
            case QuestionTypes.MULTI_SELECT_PICKLIST: {
                return fieldsVisibility.picklist;
            }
            case QuestionTypes.CHECKBOX: {
                return fieldsVisibility.checkbox;
            }
            case QuestionTypes.BIG_LIST_GROUP: {
                return fieldsVisibility.bigListGroup;
            }
            case QuestionTypes.DIVIDER: {
                return fieldsVisibility.divider;
            }
            case QuestionTypes.HIDDEN: {
                return fieldsVisibility.hidden;
            }
            case QuestionTypes.PARAMETER: {
                return fieldsVisibility.parameter;
            }
            case QuestionTypes.FILE_UPLOAD: {
                return fieldsVisibility.fileUpload;
            }
            default: {
                return fieldsVisibility.input;
            }
        }
    }

    /**
     *
     * @param {string} name
     * @param {any} value
     */
    _setFieldValue(name, value) {
        this.mutableElement[name] = this._valueOrNull(value);
    }

    /**
     * Convert empty string to null, other types of values are untouched
     *
     * @param {any} value
     * @returns
     */
     _valueOrNull(value) {
        if (typeof value === 'string') {
            return value || null;
        }
        return value;
    }
}
