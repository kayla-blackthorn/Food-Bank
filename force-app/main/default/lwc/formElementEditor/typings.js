/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').TrueOrFalse} TrueOrFalse
 */

/**
 * @typedef {{[k in keyof Partial<FormElement>]: boolean}} EditorFieldsVisibility
 */

/**
 * @typedef {object} ElementAddons
 * @property {TrueOrFalse=} _required
 * @property {TrueOrFalse=} _defaultCheckboxValue
 */

/**
 * @typedef {Partial<FormElement> & ElementAddons} ExpandedElement
 */

export {};
