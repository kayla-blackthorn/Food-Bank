// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../typings/input').ValidatableInput} ValidatableInput
 * @typedef {import('../formElementConditionEditor/formElementConditionEditor').default} FormElementConditionEditor
 * @typedef {import('../formElementConditionEditor/formElementConditionEditor').ExpandedCondition} ExpandedCondition
 */

/**
 * @typedef {import('./mutationsCalculator').ConditionMutations} ConditionMutations
 */

/**
 * @template T
 * @typedef {import('../typings/dom').ChangeEvent<T>} ChangeEvent
 */

/**
 * @template T
 * @typedef {import('../typings/picklist').ViewValue<T>} ViewValue
 */

/**
 * @typedef {'true'|'false'} TrueOrFalse
 */

import { api, LightningElement, track } from 'lwc';
import { generateUniqueId } from 'c/utils';
import { calcConditionMutations } from './mutationsCalculator';

// lightning-combobox options doesn't support boolean value, so use string instead
/** @type {ViewValue<TrueOrFalse>[]} */
const conditionOptions = [
    { label: 'Always', value: 'false' },
    { label: 'When the condition(s) is met', value: 'true' },
];

/**
 * Editor for updating/creating/deleting form element conditions
 *
 * Notice: Only the first value of the @api inputs are used, any future changes are ignored
 */
export default class FormElementConditionsEditor extends LightningElement {
    /** @type {FormElement|undefined} */
    @api element;

    /** @type {FormElementCondition[]} */
    _conditions = [];
    @api get conditions() {
        return this._conditions;
    }
    set conditions(val) {
        this._conditions = val || [];
    }

    /** @type {FormElement[]} */
    _availableElements = [];
    @api get availableElements() {
        return this._availableElements;
    }
    set availableElements(val) {
        this._availableElements = val || [];
    }

    /** @type {ExpandedCondition[]} */
    @track mutableConditions = [];

    /** @type {ViewValue<string>[]} */
    @track availableElementOptions = [];

    /** @type {ViewValue<TrueOrFalse>[]} */
    @track conditionOptions = conditionOptions;

    @track showConditions = false;
    /** @type {TrueOrFalse} */
    @track showConditionsValue = 'false';

    connectedCallback() {
        this.availableElementOptions = this._calcAvailableElementOptions(this.availableElements);
        this.mutableConditions = this._createMutableConditions(this.conditions);
        this.showConditions = this.conditions.length > 0;
        this.showConditionsValue = this.showConditions ? 'true' : 'false';
    }

    /**
     * @returns {boolean}
     */
    @api reportValidity() {
        /** @type {FormElementConditionEditor[]} */
        const editors = /** @type {any} */(Array.from(this.template.querySelectorAll('c-form-element-condition-editor')));
        /** @type {boolean[]} */
        const validities = [];
        editors.forEach(editor => validities.push(editor.reportValidity()));
        return validities.every(valid => valid);
    }

    /**
     * @returns {ConditionMutations|undefined}
     */
    @api getMutations() {
        const mutableConditions = this.showConditions ? this.mutableConditions : [];
        return calcConditionMutations(this.conditions, mutableConditions);
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setShowConditions(event) {
        const value = /** @type {TrueOrFalse} */(event.target.value);
        this.showConditionsValue = value;
        this.showConditions = value === 'true';
        if (this.showConditions && this.mutableConditions.length === 0) {
            this.addNewCondition();
        }
    }

    /**
     *
     * @param {CustomEvent<ExpandedCondition & { id: string }>} event
     */
    updateCondition(event) {
        const { id, ...data } = event.detail;
        /** @type {FormElement} */
        let element;
        if (data.elementId) {
            element = this.availableElements.find(e => e.id === data.elementId);
        }
        this.mutableConditions = this.mutableConditions.map(c => {
            if (c.id === id) {
                const selectedType = element ? element.type : c.selectedType;
                return { ...c, ...data, selectedType };
            }
            return c;
        });
    }

    /**
     *
     * @param {CustomEvent<{id: string}>} event
     */
    deleteCondition(event) {
        const id = event.detail.id;
        this.mutableConditions = this.mutableConditions.filter(c => c.id !== id);
        if (this.mutableConditions.length === 0) {
            this.showConditionsValue = 'false';
            this.showConditions = false;
        }
    }

    resetConditions() {
        this.mutableConditions = this._createMutableConditions(this.conditions);
        if (this.mutableConditions.length === 0) {
            this.showConditionsValue = 'false';
            this.showConditions = false;
        }
    }

    addNewCondition() {
        const id = generateUniqueId('c');
        this.mutableConditions = [...this.mutableConditions, { id, nextElementId: this.element?.id }];
    }

    /**
     * @param {FormElement[]} availableElements
     * @returns {ViewValue<string>[]}
     */
    _calcAvailableElementOptions(availableElements) {
        return availableElements.map(e => ({ label: e.question || e.id, value: e.id }));
    }

    /**
     *
     * @param {FormElementCondition[]} conditions
     * @returns {ExpandedCondition[]}
     */
    _createMutableConditions(conditions) {
        const indexed = this.availableElements.reduce((acc, cur) => {
            acc[cur.id] = cur;
            return acc;
        }, /** @type {Record<string, FormElement>} */({}));
        return conditions.map(c => {
            const selectedType = indexed[c.elementId].type;
            return {...c, selectedType};
        });
    }
}
