// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formShared/typings').FormElementConditionOperator} FormElementConditionOperator
 * @typedef {import('../typings/input').ValidatableInput} ValidatableInput
 */

/**
 * @template T
 * @typedef {import('../typings/dom').ChangeEvent<T>} ChangeEvent
 */

/**
 * @typedef {'Yes'|'No'} YesOrNo
 */

/**
 * @template T
 * @typedef {import('../typings/picklist').ViewValue<T>} ViewValue
 */

/**
 * @typedef {object} ConditionAddons
 * @property {string=} selectedType The type of selected controlling element
 */

/**
 * @typedef {Partial<FormElementCondition> & { id: string } & ConditionAddons} ExpandedCondition
 */

import { api, LightningElement, track } from 'lwc';
import { QuestionTypes } from 'c/formShared';

/** @type {ViewValue<FormElementConditionOperator>[]} */
const operatorOptions = [
    { label: 'Equals', value: 'Equals'},
    { label: 'Contains', value: 'Contains' },
];

// lightning-combobox options doesn't support boolean value, so use string instead
// use Yes and No so that it's compatible with the legacy events form
/** @type {ViewValue<YesOrNo>[]} */
const checkboxOptions = [
    { label: 'Checked', value: 'Yes' },
    { label: 'Unchecked', value: 'No' },
];

export default class FormElementConditionEditor extends LightningElement {
    /** @type {ExpandedCondition} */
    _condition;
    @api get condition() {
        return this._condition;
    }
    set condition(val) {
        this._condition = val;
        this._onConditionChange(val);
    }

    /** @type {ViewValue<string>[]} */
    @api availableElementOptions = [];

    /** @type {string} */
    @track conditionValue;

    /** @type {ViewValue<FormElementConditionOperator>[]} */
    @track operatorOptions = operatorOptions;

    /** @type {{ text?: boolean; checkbox?: boolean }} */
    @track valueTypes = { text: true };

    /** @type {ViewValue<YesOrNo>[]} */
    @track checkboxOptions = checkboxOptions;

    /**
     * @returns {boolean}
     */
    @api reportValidity() {
        /** @type {ValidatableInput[]} */
        const inputs = /** @type {any} */(Array.from(this.template.querySelectorAll('lightning-input, lightning-combobox, c-combobox-autocomplete')));
        const isAllValid = inputs.every(input => input.checkValidity());
        if (!isAllValid) {
            inputs.forEach(input => input.reportValidity());
        }
        return isAllValid;
    }

    /**
     * Normalize condition value
     * @param {ExpandedCondition} condition
     */
    _onConditionChange(condition) {
        switch (condition.selectedType) {
            case QuestionTypes.CHECKBOX: {
                this.valueTypes = { checkbox: true };
                let checkboxValue = condition.conditionValue;
                if (checkboxValue && !this._isValidCheckboxValue(checkboxValue)) {
                    // sf condition value is a text field, YesOrNo is saved for checkbox condition
                    // reset to undefined if it's not YesOrNo
                    checkboxValue = undefined;
                }
                this.conditionValue = checkboxValue;
                break;
            }
            default: {
                this.valueTypes = { text: true };
                this.conditionValue = condition.conditionValue;
            }
        }
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setElementId(event) {
        const value = event.target.value;
        this._notifyChange({ elementId: value, conditionValue: undefined });
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setOperator(event) {
        const value = /** @type {FormElementConditionOperator} */(event.target.value);
        this._notifyChange({ conditionOperator: value });
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    setValue(event) {
        const value = event.target.value;
        this._notifyChange({ conditionValue: this._valueOrNull(value) });
    }

    deleteCondition() {
        this.dispatchEvent(new CustomEvent('conditiondelete', {
            detail: {
                id: this.condition.id,
            }
        }));
    }

    /**
     *
     * @param {Partial<FormElementCondition>} data
     */
    _notifyChange(data) {
        this.dispatchEvent(new CustomEvent('conditionchange', {
            detail: { ...data, id: this.condition.id }
        }));
    }

    /**
     *
     * @param {string} value
     * @returns {boolean}
     */
    _isValidCheckboxValue(value) {
        /** @type {YesOrNo[]} */
        const values = ['Yes', 'No'];
        return values.includes(/** @type {any} */(value));
    }

    /**
     * Convert empty string to null, other types of values are untouched
     *
     * @param {any} value
     * @returns
     */
    _valueOrNull(value) {
        if (typeof value === 'string') {
            return value || null;
        }
        return value;
    }
}
