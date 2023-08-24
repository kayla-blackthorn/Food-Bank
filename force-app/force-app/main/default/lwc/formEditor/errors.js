// @ts-check

import { ApplicationError } from 'c/utils';

export class GroupMismatchError extends ApplicationError {
    /**
     *
     * @param {string} message
     */
    constructor(message) {
        super(message, 'element_gorup_mismatch');
    }
}

/** @extends {ApplicationError<{id: string}>} */
export class ElementNotFoundError extends ApplicationError {
    /**
     *
     * @param {string} message
     * @param {{id: string}} context;
     */
    constructor(message, context) {
        super(message, 'element_not_found', context);
    }
}

/**
 * @typedef BeDependedOnErrorContext
 * @property {string} id id of the target element
 * @property {string[]} subHierarchyElementIds ids of the elements that attached on the hierarchy of the target element directly
 * @property {string[]} affectedElementIds ids of all the elements that could be affected by the target element
 */

/** @extends {ApplicationError<BeDependedOnErrorContext>} */
export class BeDependedOnError extends ApplicationError {
    /**
     *
     * @param {string} message
     * @param {BeDependedOnErrorContext} context;
     */
    constructor(message, context) {
        super(message, 'element_be_depended_on', context);
    }
}
