// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('./typings').ExpandedElement} ExpandedElement
 */

/**
 * @typedef {Partial<FormElement>} CreatedMutation
 * @typedef {Partial<ExpandedElement> & { id: string }} UpdatedMutation
 * @typedef {string} DeletedMutation
 */

/**
 * @typedef {object} ElementMutations
 * @property {CreatedMutation=} created
 * @property {UpdatedMutation=} updated
 */

import { FormElementFieldNames as FieldNames } from 'c/formShared';

/**
 * @param {FormElement|undefined} element
 * @param {ExpandedElement} mutatedElement
 * @returns {ElementMutations|undefined}
 */
export function calcElementMutations(element, mutatedElement) {
    /** @type {ElementMutations} */
    const mutations = {};
    if (element) {
        // the element is updated
        const diff = FieldNames.pushable.reduce((acc, name) => {
            if (element[name] !== mutatedElement[name]) {
                acc = acc || {};
                acc[name] = mutatedElement[name];
            }
            return acc;
        }, /** @type {Partial<FormElement>|undefined} */ (undefined));
        if (diff) {
            mutations.updated = { ...diff, id: element.id };
        }
    } else {
        // it's a new element
        const newElement = FieldNames.pushable.reduce((acc, name) => {
            if (name !== FieldNames.ID && mutatedElement[name] !== undefined) {
                acc[name] = mutatedElement[name];
            }
            return acc;
        }, /** @type {Partial<FormElement>} */ ({ sortOrder: 0 }));
        mutations.created = newElement;
    }

    return Object.keys(mutations).length > 0 ? mutations : undefined;
}
