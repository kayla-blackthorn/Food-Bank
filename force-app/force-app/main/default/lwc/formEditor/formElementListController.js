// @ts-check

/**
 * @typedef {import('../formElementList/typings').DropPosition} DropPosition
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').VirtualFormElement} VirtualFormElement
 * @typedef {import('../formElementList/typings').FormElementListController} IFormElementListController
 * @typedef {import('./formComposer').FormComposer} FormComposer
 */

import { isVirtualFormElement } from 'c/formShared';

/**
 * @implements {IFormElementListController}
 */
export class FormElementListController {
    /** @type {FormComposer} */
    formComposer;

    /**
     * @param {FormComposer} formComposer
     */
    constructor(formComposer) {
        this.formComposer = formComposer;
    }

    /**
     *
     * @param {FormElement} sourceElement
     * @param {FormElement|VirtualFormElement} targetElement
     * @param {DropPosition} position
     * @returns {boolean}
     */
    canMove(sourceElement, targetElement, position) {
        if (isVirtualFormElement(targetElement)) {
            return false;
        }
        const { error } = this.formComposer.moveElement(sourceElement.id, targetElement.id, position, { dryRun: true });
        return !error;
    }
}
