// @ts-check

import { api, LightningElement } from 'lwc';

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').VirtualFormElement} VirtualFormElement
 * @typedef {import('../sortableList/sortableList').HoveringState} HoveringState
 * @typedef {import('./typings').FormElementListController} FormElementListController
 * @typedef {import('./typings').FormElementListRegisterDetail} FormElementListRegisterDetail
 */

export default class FormElementList extends LightningElement {
    /** @type {(FormElement|VirtualFormElement)[]} */
    _elements = [];
    @api get elements() {
        return this._elements;
    }
    set elements(val) {
        this._elements = val || [];
    }

    /** @type {number|string} */
    @api maxHeight;

    /** @param {CustomEvent<FormElementListRegisterDetail>} event */
    handleSortableListRegister(event) {
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent('formelementlistregister', {
            cancelable: true,
            bubbles: true,
            composed: true,
            detail: event.detail,
        }));
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleEditElement(event) {
        this.dispatchEvent(
            new CustomEvent('editelement', {
                detail: { value: event.detail.value }
            })
        );
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleDeleteElement(event) {
        this.dispatchEvent(
            new CustomEvent('deleteelement', {
                detail: { value: event.detail.value }
            })
        );
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleDataChange(event) {
        this.dispatchEvent(
            new CustomEvent('elementschange', {
                detail: event.detail,
            })
        );
    }

    /**
     *
     * @param {CustomEvent<HoveringState>} event
     */
    handleHoveringItem(event) {
        this.dispatchEvent(
            new CustomEvent('hovering', {
                detail: event.detail
            })
        );
    }

    /**
     *
     * @param {CustomEvent<{value: FormElement, depth: number}>} event
     */
    handleExpandChange(event) {
        this.dispatchEvent(
            new CustomEvent('expandchange', {
                detail: event.detail
            })
        );
    }
}
