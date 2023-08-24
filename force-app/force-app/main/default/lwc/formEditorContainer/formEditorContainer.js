// @ts-check

/**
 * This is a data wrapper for formEditor, it doesn't handle the form building logic
 * but handling the data communication with salesforce
 */

/**
 * @typedef {import('../formShared/typings').Form} Form
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementsAndConditions} FormElementsAndConditions
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formEditor/formEditor').SaveFormElementsOptions} SaveFormElementsOptions
 * @typedef {import('../formEditor/formEditor').default} FormEditor
 */

import { api, LightningElement, track, wire } from 'lwc';
import { getRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadFormElements from '@salesforce/apex/FormController.loadFormElements';
import loadFormElementConditions from '@salesforce/apex/FormController.loadFormElementConditions';
import saveFormElements from '@salesforce/apex/FormController.saveFormElements';
import FormContentEditor from 'c/formContentEditor';
import { reduceErrors } from 'c/helpers';
import {
    normalizeFormElements, normalizeFormElementConditions, denormalizeFormElements,
    FormFields,
} from 'c/formShared';

const FORM_FIELDS = [FormFields.ID_FIELD, FormFields.NAME_FIELD];

export default class FormEditorContainer extends LightningElement {
    /** @type {string} */
    @api recordId;

    /** @type {Form} */
    @track form;

    /** @type {FormElementsAndConditions} */
    @track elementsAndConditions;

    @track saving = false;

    @track errorMessage = '';

    /** a save operation is scheduled if true */
    _saveScheduled = false;

    /** record the internal saving status, this.saving could be true when this._saving is false  */
    _saving = false;

    /** @type {boolean} */
    get formLoaded() {
        return !!(this.form && this.elementsAndConditions);
    }

    /** @type {boolean} */
    get hasError() {
        return !!(!this.formLoaded && this.errorMessage);
    }

    /** @type {boolean} */
    get loading() {
        return !this.formLoaded && !this.hasError;
    }

    /** @type {FormEditor} */
    get _formEditor() {
        return /** @type {any} */(this.template.querySelector('c-form-editor'));
    }

    @wire(getRecord, { recordId: '$recordId', fields: FORM_FIELDS })
    wiredFormRecord({ error, data }) {
        if (error) {
            this.errorMessage = reduceErrors(error).join(',') || 'Failed to load form data';
        } else if (data) {
            this.form = {
                id: data.fields[FormFields.ID_FIELD.fieldApiName].value,
                name: data.fields[FormFields.NAME_FIELD.fieldApiName].value,
            };
        }
    }

    connectedCallback() {
        this.loadFormElementsAndConditions();
    }

    async loadFormElementsAndConditions() {
        try {
            const [elements, conditions] = await Promise.all([
                loadFormElements({ formId: this.recordId }),
                loadFormElementConditions({ formId: this.recordId }),
            ]);

            this.elementsAndConditions = {
                elements: normalizeFormElements(elements),
                conditions: normalizeFormElementConditions(conditions),
            };
        } catch (err) {
            this.errorMessage = reduceErrors(err).join(',') || 'Failed to load Form Elements';
        }
    }

     /**
     *
     * @param {SaveFormElementsOptions} options
     * @returns
     */
     async saveFormElementSortOrders(options) {
        const editor = this._formEditor;
        const updates = editor.getUpdates();
        if (updates.length === 0) {
            if (!options.silent) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Form Elements saved successfully',
                        variant: 'success'
                    })
                );
            }
            return;
        }
        const elements = denormalizeFormElements(updates);
        try {
            await saveFormElements({ elements });
            editor.commitUpdates(updates)
            if (!options.silent) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Form Elements saved successfully',
                        variant: 'success'
                    })
                );
            }
        } catch (err) {
            // show the notification for error regardless of the silent option.
            this._showErrorNotification('Failed to update Form Elements', reduceErrors(err));
        }
    }

    async handleReloadForm() {
        this.errorMessage = '';
        try {
            if (!this.form) {
                await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            }
        } catch (err) {
            this._showErrorNotification('Failed to refresh the form data', reduceErrors(err));
        }
        if (!this.elementsAndConditions) {
            // this would not throw an error
            await this.loadFormElementsAndConditions();
        }
    }

    /**
     *
     * @param {CustomEvent<{options: SaveFormElementsOptions|undefined}>} event
     */
    handleSaveForm(event) {
        this._scheduleSave(event.detail.options);
    }

    /**
     * @param {CustomEvent<{value: Form}>} event
     */
    async handleEditForm(event) {
        const form = event.detail.value;
        FormContentEditor.open({
            size: 'small',
            description: `Edit ${form.name}`,
            formId: form.id,
        });
    }

    /**
     * Schedule a save operation
     *
     * Purpose: avoid running save concurrently or unnecessarily, which may cause data inconsistent issue
     *
     * @param {SaveFormElementsOptions=} options
     */
    _scheduleSave(options) {
        this._saveScheduled = true;
        this._processScheduledSave(options);
    }

    /**
     *
     * @param {SaveFormElementsOptions=} options
     */
    async _processScheduledSave(options) {
        if (!this._saveScheduled || this._saving) {
            return;
        }
        this._saveScheduled = false;
        this._saving = true;
        if (!this.saving) {
            this.saving = true;
        }
        await this.saveFormElementSortOrders({ silent: options?.silent || false });
        this._saving = false;
        if (this._saveScheduled) {
            this._processScheduledSave({ silent: true });
        } else {
            this.saving = false;
        }
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
