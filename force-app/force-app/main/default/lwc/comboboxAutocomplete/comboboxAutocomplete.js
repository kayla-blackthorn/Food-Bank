// @ts-check

/**
 * @template T
 * @typedef {import('../typings/picklist').ViewValue<T>} ViewValue
 */

/**
 * @template T
 * @typedef {ViewValue<T> & {focused?: boolean; selected?: boolean}} ComboboxOption
 */

/**
 * @template T
 * @typedef {import('../typings/dom').ChangeEvent<T>} ChangeEvent
 */

/**
 * @typedef {import('../typings/geometry').Rect} Rect
 */

/**
 * @typedef {'up'|'down'} PopupDirection
 */

/**
 * @typedef {object} AttachParameters
 * @property {Element|Window} containingParent
 * @property {Element|Document} scrollParent
 * @property {PopupDirection} direction
 * @property {Element} dropdownEl
 * @property {Element} inputEl
 * @property {number} dropdownHeight
 * @property {number} dropdownMinWidth
 * @property {Rect} containingRect
 * @property {Rect} rootContainingRect
 * @property {number} remSize
 */

import { LightningElement, api, track } from 'lwc';
import { coerceBooleanProperty, classSet } from 'c/utils';
import { getScrollParent, getFixedContainingBlock, getBoundingClientRect } from './domHelpers';
import { throttle } from 'c/utils';

// copied from the base-components-recipes project
const VIEWPORT_HEIGHT_SMALL = 834;

export default class ComboboxAutocomplete extends LightningElement {
    _required = false;
    @api get required() {
        return this._required;
    }
    set required(val) {
        this._required = coerceBooleanProperty(val);
    }

    _readOnly = false;
    @api get readOnly() {
        return this._readOnly;
    }
    set readOnly(val) {
        this._readOnly = coerceBooleanProperty(val);
    }

    _disabled = false;
    @api get disabled() {
        // consider disabled if it's readonly
        return this._disabled || this._readOnly;
    }
    set disabled(val) {
        this._disabled = coerceBooleanProperty(val);
    }

    @api name = '';
    @api label = '';
    @api placeholder = '';
    @api messageWhenValueMissing = 'Complete this field.';
    @api fieldLevelHelp = '';

    _controlledValue = '';
    _value = ''
    @api get value() {
        return this._value;
    }
    set value(val) {
        this._value = val || '';
        this._controlledValue = this._value;
        this.inputText = this._calcInputText();
    }

    /** @type {ViewValue<string>[]} */
    _options = [];
    @api get options() {
        return this._options;
    }
    set options(val) {
        this._options = val;
        this.inputText = this._calcInputText();
    }

    @track inputText = '';

    @track focused = false;
    @track opened = false;

    /** @type {ComboboxOption<string>[]} */
    @track filteredOptions = [];

    @track errorMessage = '';

    @track dropdownPlacementStyle = '';

    /** @type {AttachParameters} */
    _attachParameters;

    _focusedIndex = -1;

    get hasOptions() {
        return this.filteredOptions.length > 0;
    }

    get dropdownLength() {
        return window.innerHeight <= VIEWPORT_HEIGHT_SMALL ? 5 : 7;
    }

    get computedComboboxClass() {
        return classSet('slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click')
            .add({
                'slds-is-open': this.opened,
            })
            .toString();
    }

    get computedFormElementClass() {
        return classSet('slds-form-element')
            .add({
                'slds-has-error': this.errorMessage,
            })
            .toString();
    }

    get computedDropdownClass() {
        const dropdownLengthClass = `slds-dropdown_length-with-icon-${this.dropdownLength}`
        return `slds-dropdown slds-dropdown_left slds-dropdown_fluid ${dropdownLengthClass}`;
    }

    get expanded() {
        return this.opened ? 'true' : 'false';
    }

    get hasError() {
        return !!this.errorMessage;
    }

    get invalid() {
        return this.hasError ? 'true' : 'false';
    }

    get inputEl() {
        return this.template.querySelector('input');
    }

    get dropdownEl() {
        return this.template.querySelector('.slds-dropdown');
    }

    connectedCallback() {
        this.filteredOptions = this.options;
    }

    @api blur() {
        this.inputEl.blur();
        if (this.opened) {
            this._close();
        }
    }

    @api focus() {
        this.inputEl.focus();
    }

    @api checkValidity() {
        return this._isValueValid();
    }

    @api reportValidity() {
        this._updateErrorMessage();
        return !this.hasError;
    }

    /**
     *
     * @param {string=} message
     */
    @api setCustomValidity(message) {
        this.errorMessage = message || '';
    }

    @api showHelpMessageIfInvalid() {
        this.reportValidity();
    }

    /**
     *
     * @param {ChangeEvent<HTMLInputElement>} event
     */
    handleInputTextChange(event) {
        this.inputText = event.target.value;
        if (!this.opened) {
            this._open();
        } else {
            this._updateFilteredOptions();
        }
    }

    handleClearText() {
        this.inputText = '';
        if (!this.opened) {
            this._open();
        } else {
            this._updateFilteredOptions();
        }
        this.inputEl.focus();
    }

    _updateFilteredOptions = throttle(100, () => {
        const filterText = this.inputText || '';
        if (!filterText) {
            this.filteredOptions = this.options;
        } else {
            this.filteredOptions = this.options.filter(option => {
                return option.label.toLowerCase().includes(filterText.toLowerCase());
            });
        }
        this.filteredOptions = this.filteredOptions.map((option) => {
            if (option.value === this.value) {
                return { ...option, selected: true };
            }
            return option;
        });
    });

    /**
     *
     * @param {number} index
     */
    _updateFocusedOption(index) {
        if (!this.opened) {
            return;
        }
        if (index >= this.filteredOptions.length) {
            index = 0;
        } else if (index < 0) {
            index = this.filteredOptions.length - 1;
        }
        if (this._focusedIndex !== index) {
            this._focusedIndex = index;
            this.filteredOptions = this.filteredOptions.map((option, i) => {
                if (index === i) {
                    return { ...option, focused: true };
                } else if (option.focused) {
                    return { ...option, focused: false };
                }
                return option;
            });
        }
        const item = this.template.querySelector(`.slds-listbox__item:nth-child(${index + 1})`);
        if (item) {
            item.scrollIntoView({ block: 'nearest' });
        }
    }

    /**
     *
     * @param {Event} event
     */
    handleSelectOption(event) {
        const el = /** @type {HTMLElement} */(event.currentTarget);
        const value = el.dataset.value || '';
        this.selectOptionFromDropdown(value);
    }

    /**
     *
     * @param {string} value
     */
    selectOptionFromDropdown(value) {
        this._value = value;
        if (this._controlledValue !== value) {
            this.dispatchEvent(new CustomEvent('change', {
                detail: { value }
            }));
        }
        this.inputText = this._calcInputText();
        this._updateErrorMessage();
        this.inputEl.focus();
        this._close();
    }

    handleInputFocus() {
        this.focused = true;
    }

    handleInputClick() {
        if (this.disabled) {
            return;
        }
        this._open();
    }

    /**
     *
     * @param {FocusEvent} event
     */
    handleInputBlur(event) {
        if (this.disabled) {
            return;
        }
        if (this.opened) {
            const el = /** @type {HTMLElement} */(event.relatedTarget);
            if (!el || !this.template.contains(el)) {
                // click outside of the combox
                this._close();
            }
        }
        if (!this.opened) {
            const inputText = this._calcInputText();
            if (this.inputText !== inputText) {
                this.inputText = inputText;
            }
            this._updateErrorMessage();
        }
    }

    /**
     * @param {KeyboardEvent} event
     */
    handleInputKeyDown(event) {
        if (event.isComposing || event.keyCode === 229) {
            return;
        }
        if (this.opened) {
            // so it's trapped in the dropdown
            event.stopPropagation();
        }
        switch (event.key) {
            case "Down": // IE/Edge specific value
            case "ArrowDown":
                // focus on next option
                this._updateFocusedOption(this._focusedIndex + 1);
                break;
            case "Up": // IE/Edge specific value
            case "ArrowUp":
                // focus on previous option
                this._updateFocusedOption(this._focusedIndex - 1);
                break;
            case "Enter":
                if (this.opened) {
                    const option = this.filteredOptions[this._focusedIndex];
                    if (option) {
                        this.selectOptionFromDropdown(option.value);
                    }
                    this._close();
                } else {
                    this._open();
                }
                break;
            case "Esc": // IE/Edge specific value
            case "Escape":
                if (this.opened) {
                    this._close();
                }
                break;
            default:
              // Quit when this doesn't handle the key event.
          }
    }

    _calcDropdownPlacementStyle() {
        const rect = this.inputEl.getBoundingClientRect();
        const { rootContainingRect, containingRect, dropdownHeight, dropdownMinWidth, direction } = this._attachParameters;
        const width = Math.max(dropdownMinWidth, rect.width);
        const inputBottomOffset = (rootContainingRect.height - containingRect.bottom) + (containingRect.height - rect.bottom);
        const inputTopOffset = containingRect.top + rect.top;
        /** @type {number} */
        let dropdownBottomOffset;
        /** @type {number} */
        let dropdownTopOffset;
        /** @type {number} */
        let top;
        if (direction === 'up') {
            dropdownBottomOffset = inputBottomOffset + rect.height;
            dropdownTopOffset = inputTopOffset - dropdownHeight;
        } else {
            dropdownBottomOffset = inputBottomOffset - dropdownHeight;
            dropdownTopOffset = inputTopOffset + rect.height;
        }
        top = direction === 'up' ? rect.top - dropdownHeight -4: rect.bottom;
        if (dropdownTopOffset < 3) {
            top += 3 - dropdownTopOffset
        } else if (dropdownBottomOffset < 3) {
            top -= 3 - dropdownBottomOffset;
        }

        const left = rect.left - containingRect.left;
        let style = `width:${width}px;left:${left}px;top:${top}px;z-index:9200;position:fixed;`;
        if (direction === 'up') {
            style += `height:${dropdownHeight}px`;
        }
        return style;
    }

    /**
     * @returns {AttachParameters}
     */
    _createAttachParameters() {
        const dropdownLength = this.dropdownLength;
        const dropdownEl = this.dropdownEl;
        const { maxHeight: maxHeightPx } = getComputedStyle(dropdownEl);
        const maxHeight = parseFloat(maxHeightPx);
        // 30 is a rough patch, but it's enough for our use case
        // it's not easy to get the exact value
        const heightPerItem = (maxHeight - 30) / dropdownLength;
        const scrollHeight = heightPerItem * this.options.length || heightPerItem;
        const height = Math.min(maxHeight, scrollHeight);

        const rect = this.inputEl.getBoundingClientRect();
        const containingParent = getFixedContainingBlock(dropdownEl);
        const containingRect = getBoundingClientRect(containingParent);
        const rootContainingRect = containingParent instanceof Window ? containingRect : getBoundingClientRect(getFixedContainingBlock(containingParent));
        /** @type {PopupDirection} */
        let direction;
        if ((rootContainingRect.height - containingRect.bottom + (containingRect.height - rect.bottom)) > height + 3) {
            // put on bottom
            direction = 'down';
        } else if (rect.top > height){
            // put on top
            direction = 'up';
        } else {
            // there is no space for it anyway, just put it in on bottom
            // ideally we could calculate a position that can contain the listbox
            direction = 'down';
        }

        const remSize = parseFloat(getComputedStyle(document.documentElement).fontSize);

        return {
            scrollParent: getScrollParent(this.template.querySelector('.slds-form-element')),
            containingParent,
            dropdownEl,
            inputEl: this.inputEl,
            direction,
            dropdownHeight: height,
            containingRect,
            rootContainingRect,
            remSize,
            dropdownMinWidth: remSize * 12,
        }
    }

    _handleContainerScroll = /** @type {() => void} */(throttle(30, () => {
        this.dropdownPlacementStyle = this._calcDropdownPlacementStyle();
    }));

    _open() {
        if (!this.opened) {
            this._updateFilteredOptions();
            if (!this._attachParameters) {
                this._attachParameters = this._createAttachParameters();
            }
            this._attachParameters.scrollParent.addEventListener('scroll', this._handleContainerScroll, { passive: true });
            this.dropdownPlacementStyle = this._calcDropdownPlacementStyle();
            this.opened = true;
            this._focusedIndex = -1;
        }
    }

    _close() {
        if (this.opened) {
            this._attachParameters.scrollParent.removeEventListener('scroll', this._handleContainerScroll);
            this._attachParameters = undefined;
            // reset the scroll
            this.dropdownEl.scrollTop = 0;
            this.opened = false;
        }
    }

    /**
     *
     * @returns {string}
     */
    _calcInputText() {
        let text = '';
        if (this.value && this.options) {
            const found = this.options.find(option => option.value === this.value);
            text = found?.label || '';
        }
        return text;
    }

    _isValueValid() {
        if (this.required && !this.value) {
            return false;
        }
        return true;
    }

    _updateErrorMessage() {
        if (this._isValueValid()) {
            this.errorMessage = '';
        } else {
            this.errorMessage = this.messageWhenValueMissing;
        }
    }
}
