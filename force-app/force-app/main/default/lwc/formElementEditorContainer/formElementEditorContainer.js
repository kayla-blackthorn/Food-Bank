// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../typings/objectInfo').Field} ObjectField
 * @typedef {import('../typings/objectInfo').ObjectInfo} ObjectInfo
 * @typedef {import('../formElementEditor/formElementEditor').default} FormElementEditor
 * @typedef {import('../formElementEditor/formElementEditor').FormElementMutations} FormElementMutations
 */

/**
 * @template T
 * @typedef {import('../typings/picklist').ViewValue<T>} ViewValue
 */

import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import saveElementAndConditions from '@salesforce/apex/FormController.saveElementAndConditions';
import loadMapToObjectList from '@salesforce/apex/FormController.listMapToObjects';
import { reduceErrors } from 'c/helpers';
import {
    FormElementFields as Fields, QuestionTypes, getElementFieldNameByFieldApiName,
    denormalizeFormElement, denormalizeFormElementConditions, normalizeFormElement,
    normalizeFormElementConditions, SfdcObjects,
} from 'c/formShared';
import { visibleFields } from './visibleFields';

export default class FormElementEditorContainer extends LightningModal {
    /** @type {string} */
    @api formId;

    /** @type {FormElement} */
    @api element;

    /** @type {FormElementCondition[]} */
    @api conditions;

    /** @type {FormElement[]} */
    @api availableElements;

    /** @type {Record<string, string>} */
    @track labels;

    /** @type {ViewValue<string>[]} */
    @track questionTypes = [];

    /** @type {ViewValue<string>[]} */
    @track mapsToObjectOptions = [];

    /** @type {ViewValue<string>[]} */
    @track mapsToFieldOptions = [];

    /** @type {ViewValue<string>[]} */
    @track bigListGroupOptions = [];

    @track saving = false;

    _loadingBigListGroups = false;

    /** @type {string} */
    _questionType;

    get saveButtonLabel() {
        return this.saving ? 'Saving' : 'Save';
    }

    get modalTitle() {
        return this.element ? 'Edit a Question' : 'Add a Question';
    }

    /** @type {FormElementEditor} */
    get _formElementEditor() {
        return /** @type {any} */(this.template.querySelector('c-form-element-editor'));
    }

    @wire(getObjectInfo, { objectApiName: SfdcObjects.FORM_ELEMENT_OBJECT })
    wireFormElementFields({ data, error }) {
        if (data) {
            this._formElementRecordTypeId = data.defaultRecordTypeId;
            this.labels = this._calcLabels(data.fields);
        } else if (error) {
            this._showErrorNotification('Failed to load filed labels', reduceErrors(error));
            this.labels = this._calcLabels();
        }
    }

     /** @type {string} */
     _formElementRecordTypeId;
     // @ts-ignore
     @wire(getPicklistValues, { recordTypeId: '$_formElementRecordTypeId', fieldApiName: Fields.TYPE_FIELD })
     wireQuestionTypes({ error, data }) {
         if (data) {
             this.questionTypes = data.values.map(item => {
                 return {
                     label: item.label,
                     value: item.value
                 };
             });
         } else if (error) {
            this._showErrorNotification('Failed to load question types', reduceErrors(error));
         }
     }

    /** @type {Record<string, ObjectField>} */
    _mapsToFieldsFullInfo;
     /** @type {string} */
    _mapsToObjectObjectApiName;
    @wire(getObjectInfo, { objectApiName: '$_mapsToObjectObjectApiName' })
    wireMapsToFields({ data, error }) {
        if (data) {
            this._mapsToFieldsFullInfo = data.fields;
        } else {
            this._mapsToFieldsFullInfo = undefined;
        }
        if (error) {
            this._showErrorNotification('Failed to load object fields', reduceErrors(error));
        }
        this.mapsToFieldOptions = this._calcMapsToFieldOptions(this._mapsToFieldsFullInfo, this._questionType);
    }

    connectedCallback() {
        this._loadMapsToObjects();
        if (this.element) {
            // load async resources for editing an element
            this._questionType = this.element.type;
            this._setMapsToObject(this.element.mapsToObject);
        }
    }

    handleCancel() {
        this.close();
    }

    async handleSave() {
        const editor = this._formElementEditor;
        if (!editor.reportValidity()) {
            return;
        }
        this.saving = true;
        this.disableClose = true;
        try {
            const elementAndConditions = await this._saveElementAndConditions(editor.getMutations());
            this.disableClose = false;
            this.dispatchEvent(new RefreshEvent());
            this.close(elementAndConditions);
        } catch (err) {
            this.disableClose = false;
            this._showErrorNotification('Failed to save the Form Element', reduceErrors(err));
        } finally {
            this.saving = false;
        }
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleQuestionTypeChange(event) {
        this._questionType = event.detail.value;
        this.mapsToFieldOptions = this._calcMapsToFieldOptions(this._mapsToFieldsFullInfo, this._questionType);
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleMapsToObjectChange(event) {
        const objectName = event.detail.value;
        this._setMapsToObject(objectName)
    }

    /**
     *
     * @param {string=} objectName
     */
    _setMapsToObject(objectName) {
        this.mapsToFieldOptions = [];
        this._mapsToFieldsFullInfo = {};
        switch (objectName) {
            case 'Contact': {
                this._mapsToObjectObjectApiName = SfdcObjects.CONTACT_OBJECT;
                break;
            }
            case 'Lead': {
                this._mapsToObjectObjectApiName = SfdcObjects.LEAD_OBJECT;
                break;
            }
            case 'Account': {
                this._mapsToObjectObjectApiName = SfdcObjects.ACCOUNT_OBJECT;
                break;
            }
            default: {
                this._mapsToObjectObjectApiName = '';
            }
        }
    }

    /**
     *
     * @param {FormElementMutations} mutations
     */
    async _saveElementAndConditions(mutations) {
        const parameters = this._transformMutationsToDMLParameters(mutations);
        const { element, conditions } = await saveElementAndConditions(parameters);
        return {
            element: normalizeFormElement(element),
            conditions: normalizeFormElementConditions(conditions),
        }
    }

    /**
     *
     * @param {FormElementMutations} mutations
     */
    _transformMutationsToDMLParameters(mutations) {
        const element = mutations.created || mutations.updated || { id: this.element.id };
        const conditionMutations = mutations.conditionMutations || {};
        const conditions = [...conditionMutations.created || [], ...conditionMutations.updated || []];
        /** @type {Partial<FormElementCondition>[]} */
        const conditionsToRemove = (conditionMutations.deleted || []).map(id => ({ id }));
        return {
            element: denormalizeFormElement(element),
            conditions: denormalizeFormElementConditions(conditions),
            conditionsToRemove: denormalizeFormElementConditions(conditionsToRemove),
        };
    }

    /**
     *
     * @param {Record<string, ObjectField>=} fieldsInfo
     * @param {string=} questionType
     * @returns {ViewValue<string>[]}
     */
    _calcMapsToFieldOptions(fieldsInfo, questionType) {
        /** @type {ViewValue<string>[]} */
        const options = [
            { label:'--None--',value:'' },
        ];
        if (!fieldsInfo) {
            return options;
        }
        //below allows the array that question type answer can be stored in which fields
        //like date can be saved only in  date field or string field nothing else
        /** @type {Record<string, string[]>} */
        const allowedTypesMap = {
            [QuestionTypes.DATE]: ['Date','String'],
            [QuestionTypes.PICKLIST]: ['TextArea','String','Picklist','MultiPicklist'],
            [QuestionTypes.MULTI_SELECT_PICKLIST]: ['TextArea','String','MultiPicklist'],
            [QuestionTypes.EMAIL]: ['String','Email'],
            [QuestionTypes.CHECKBOX]: ['String','Boolean'],
            [QuestionTypes.TEXT_30000]: ['TextArea'],
            [QuestionTypes.BIG_LIST_GROUP]: ['TextArea','String','Reference'],
            [QuestionTypes.NUMBER]: ['Number','String','TextArea','Int','Double','Currency','Percent'],
            //mapping text value to picklist may only fail - for restricted picklist - so lets not allow it ,'Picklist','MultiPicklist'
            [QuestionTypes.TEXT]: ['Phone','TextArea','String'],
            [QuestionTypes.URL]: ['TextArea','String', 'Url'],
        };

        const allowedTypes = allowedTypesMap[questionType] || [];
        Object.values(fieldsInfo).forEach(info => {
            if (info.updateable && allowedTypes.includes(info.dataType)) {
                options.push({ label: info.label, value: info.apiName });
            }
        });
        return options;
    }

    _loadMapsToObjects() {
        // simulate the metadata fetching
        loadMapToObjectList().then((result) => {
            this.mapsToObjectOptions = [{ label: '--None--', value: ''}];
            result.forEach((obj) => {
                this.mapsToObjectOptions.push({ label: obj.label, value: obj.value });
            })
        });
    }

    /**
     *
     * @param {Record<string, ObjectField>=} fieldsInfo
     * @returns {Record<string, string>=}
     */
    _calcLabels(fieldsInfo) {
        if (!fieldsInfo) {
            return undefined;
        }
        return Object.values(fieldsInfo)
        .filter(info => visibleFields.has(info.apiName))
        .reduce((acc, cur) => {
            const fieldName = getElementFieldNameByFieldApiName(cur.apiName);
            if (fieldName) {
                acc[fieldName] = cur.label;
            }
            return acc;
        }, /** @type {Record<string, string>}  */({}));
    }

    /**
     *
     * @param {string} title
     * @param {string[]} messages
     */
    _showErrorNotification(title, messages) {
        messages = messages || [];
        this.dispatchEvent(new ShowToastEvent({
            title,
            message: messages.join(','),
            variant: 'error',
            mode: 'sticky',
        }));
    }
}
