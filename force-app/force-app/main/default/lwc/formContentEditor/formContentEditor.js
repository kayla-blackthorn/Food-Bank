import LightningModal from 'lightning/modal';
import { api, track } from 'lwc';
import { SfdcObjects, FormFields } from 'c/formShared';

export default class FormContentEditor extends LightningModal {
    /** @type {string} */
    @api formId;

    @track objectApiName = SfdcObjects.FORM_OBJECT.objectApiName;

    @track nameField = FormFields.NAME_FIELD.fieldApiName;

    @track saving = false;

    @track loading = true;

    get saveButtonLabel() {
        return this.saving ? 'Saving' : 'Save';
    }

    handleLoaded() {
        this.loading = false;
    }

    handleCancel() {
        this.close();
    }

    handleSubmit() {
        this.saving = true;
    }

    handleSuccess() {
        this.saving = false;
        this.close();
    }

    handleError() {
        this.saving = false;
    }
}
