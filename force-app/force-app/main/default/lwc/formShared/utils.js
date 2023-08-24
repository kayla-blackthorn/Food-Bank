// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').VirtualFormElement} VirtualFormElement
 */

/**
 *
 * @param {FormElement|VirtualFormElement} element
 * @returns {element is VirtualFormElement}
 */
export function isVirtualFormElement(element) {
    return /** @type {VirtualFormElement} */(element).virtual;
}
