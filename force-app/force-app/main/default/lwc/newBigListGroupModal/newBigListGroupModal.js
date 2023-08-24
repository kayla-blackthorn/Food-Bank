// @ts-check

/**
 * @typedef {import('../typings/input').ValidatableInput} ValidatableInput
 */

/**
 * @template T
 * @typedef {import('../typings/dom').ChangeEvent<T>} ChangeEvent
 */

import { api } from "lwc";
import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FORM_BIG_LIST_GROUP_OBJECT from "@salesforce/schema/Form_Big_List_Group__c";
import { reduceErrors } from "c/helpers";

export default class NewBigListGroupModal extends LightningModal {
    /** @type {string} */
    @api modalTitle;

    /** @type {string} */
    saveButtonLabel = "Save";

    /** @type {string} */
    get formBigListGroupApiName() {
        return FORM_BIG_LIST_GROUP_OBJECT.objectApiName;
    }

    handleClose() {
        this.close();
    }

    handleSave() {
        if (!this._validate()) {
            return;
        }
        this.template.querySelector("lightning-record-edit-form").submit();
    }

    /**
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    handleSuccess(event) {
        const recordId = event.detail.id;
        this.close({ recordId });
    }

    /**
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    handleError(event) {
        const error = event.detail;
        this._showErrorNotification("Failed to save the Form Big List Group", reduceErrors(error));
    }

    /**
     * @returns {boolean}
     */
    _validate() {
        /** @type {ValidatableInput[]} */
        const inputs = this.template.querySelectorAll("lightning-input-field");
        let isAllValid = true;
        inputs.forEach((input) => {
            if (input.required && !input.value) {
                input.reportValidity();
                isAllValid = false;
            }
        });

        return isAllValid;
    }

    /**
     *
     * @param {string} title
     * @param {string[]} messages
     */
    _showErrorNotification(title, messages) {
        messages = messages || [];
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message: messages.join(","),
                variant: "error",
                mode: "sticky"
            })
        );
    }
}
