/**
 * @typedef {'true' | 'false'} TrueOrFalse
 */

/**
 * @typedef {object} Form
 * @property {string} id
 * @property {string} name
 */

/**
 * @typedef {object} FormElement
 * @property {string} id
 * @property {string} name
 * @property {string} formId
 * @property {string} type
 * @property {string} question
 * @property {string} questionRichtext
 * @property {string} hint
 * @property {boolean} required
 * @property {number} sortOrder
 * @property {string} mapsToObject
 * @property {string} mapsToField
 * @property {string} defaultValue
 * @property {boolean} defaultCheckboxValue
 * @property {string} picklistValues
 * @property {string} bigListGroupId
 */

/**
 * @typedef {object} VirtualFormElement
 * @property {string} id
 * @property {boolean} virtual
 * @property {string} question
 */

/**
 * @typedef {'Contains' | 'Equals'} FormElementConditionOperator
 */

/**
 * @typedef {object} FormElementCondition
 * @property {string} id
 * @property {string} name
 * @property {string} elementId
 * @property {string} nextElementId
 * @property {FormElementConditionOperator} conditionOperator
 * @property {string} conditionValue
 */

/**
 * @typedef {object} FormElementLeveled
 * @property {FormElement|VirtualFormElement} element
 * @property {number} level
 * @property {boolean} expandable
 * @property {boolean} expanded
 * @property {string=} message
 */

/**
 * @typedef {object} FormElementsAndConditions
 * @property {FormElement[]} elements
 * @property {FormElementCondition[]} conditions
 */

export {};
