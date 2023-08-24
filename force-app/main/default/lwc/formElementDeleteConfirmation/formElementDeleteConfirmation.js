// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 */

import LightningModal from 'lightning/modal';
import { api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteFormElements from '@salesforce/apex/FormController.deleteFormElements';
import { reduceErrors } from 'c/helpers';
import { denormalizeFormElement } from 'c/formShared';

export default class FormElementDeleteConfirmation extends LightningModal {
    /** @type {FormElement} */
    @api element;

    @api message = '';

    @api actionMessage = '';

    @api deletable = false;

    @api requireInspection = false;

    /** @type {boolean} */
    @track deleting;

    get deleteButtonLabel() {
        return this.deleting ? 'Deleting' : 'Delete';
    }

    handleCancel() {
        this.close({ deleted: false });
    }

    handleInspect() {
        this.close({ deleted: false, inspectionMode: true });
    }

    async handleDelete() {
        this.disableClose = true;
        this.deleting = true;
        let succeed = false;
        try {
            await deleteFormElements({
                elements: [denormalizeFormElement({ id: this.element.id })],
            });
            succeed = true;
        } catch (err) {
            this._showErrorNotification('Failed to delete the Form Element', reduceErrors(err));
        } finally {
            this.disableClose = false;
            this.deleting = false;
        }
        if (succeed) {
            this.close({ deleted: true });
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
