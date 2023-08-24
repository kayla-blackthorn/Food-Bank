// @ts-check

/**
 * @typedef {import ('./typings').EditorFieldsVisibility} EditorFieldsVisibility;
 */

/** @type {EditorFieldsVisibility} */
export const input = {
    question: true,
    questionRichtext: true,
    type: true,
    required: true,
    mapsToObject: true,
    mapsToField: true,
    defaultValue: true,
    hint: true,
};

/** @type {EditorFieldsVisibility} */
export const picklist = {
    ...input,
    picklistValues: true,
};


/** @type {EditorFieldsVisibility} */
export const checkbox = {
    ...input,
    defaultValue: false,
    defaultCheckboxValue: true,
};

/** @type {EditorFieldsVisibility} */
export const bigListGroup = {
    ...input,
    bigListGroupId: true,
};

/** @type {EditorFieldsVisibility} */
export const divider = {
    type: true,
    question: true,
    questionRichtext: true,
};

/** @type {EditorFieldsVisibility} */
export const hidden = {
    type: true,
    question: true,
    questionRichtext: true,
    mapsToObject: true,
    mapsToField: true,
    defaultValue: true,
};

/** @type {EditorFieldsVisibility} */
export const parameter = {
    type: true,
    question: true,
    questionRichtext: true,
    mapsToObject: true,
    mapsToField: false,
    defaultValue: true,
};

/** @type {EditorFieldsVisibility} */
export const fileUpload = {
    type: true,
    question: true,
    questionRichtext: true,
    mapsToObject: true,
    mapsToField: false,
    defaultValue: false,
};
