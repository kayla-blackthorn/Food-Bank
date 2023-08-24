// @ts-check

import { api, LightningElement, track } from 'lwc';
import { classSet } from 'c/utils';

/**
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').VirtualFormElement} VirtualFormElement
 * @typedef {import('../typings/geometry').Rect} Rect
 * @typedef {import('../typings/geometry').Movement} Movement
 * @typedef {import('../sortableItem/typings').SortableItemContent} SortableItemContent
 * @typedef {import('../sortableItem/typings').DraggingInitializationParameters} DraggingInitializationParameters
 */

/**
 * @implements {SortableItemContent}
 */
export default class FormElementItem extends LightningElement {
    /** @type {FormElement|VirtualFormElement} */
    @api value;

    /** @type {number} */
    @api level;

    /** @type {boolean} */
    @api expandable;

    /** @type {boolean} */
    @api expanded;

    /** @type {string} */
    @api message;

    /** @type {string} */
    @track shiftedStyle;

    /** @type {string} */
    @track placeholderStyle;

    /** @type {boolean} */
    @track dragging;

    /** @type {HTMLElement} */
    _dragContainer;

    /** @type {DraggingInitializationParameters|undefined} */
    _draggingParameters;

    get label() {
        return this.value?.question;
    }

    get virtual() {
        return /** @type {VirtualFormElement} */(this.value)?.virtual;
    }

    get computedClass() {
        return classSet('drag-container')
            .add({
                dragging: this.dragging
            })
            .toString();
    }

    get computedElementClass() {
        return classSet('content slds-theme_default slds-box slds-box_x-small')
            .add({
                'is-virtual': this.virtual,
            })
            .toString();
    }

    get computedWrapperClass() {
        const classes = classSet('wrapper');
        const level = this.level || 0;
        if (level > 0) {
            classes.add(`level-${level}`);
        }
        return classes.toString();
    }

    get computedExpandedIcon() {
        return this.expanded ? 'utility:collapse_all' : 'utility:expand_all'
    }

    get computedExpandedLabel() {
        return this.expanded ? 'Collapse all' : 'Expand all';
    }

    connectedCallback() {
        this.dispatchEvent(
            new CustomEvent('registersortableitemcontent', {
                cancelable: true,
                bubbles: true,
                composed: true,
            })
        );
    }

    renderedCallback() {
        if (!this._dragContainer) {
            this._dragContainer = this.template.querySelector('.drag-container');
        }
    }

    /**
     * @param {PointerEvent} event
     */
    initializeDragging(event) {
        const { pageX, pageY } = event;
        const rect = this._dragContainer.getBoundingClientRect();
        this._draggingParameters = {
            startAt: { x: pageX, y: pageY },
            draggingRect: rect,
        };
        /** @type {CustomEvent<DraggingInitializationParameters>} */
        const initializationEvent = new CustomEvent('dragginginitialized', {
            cancelable: true,
            bubbles: true,
            composed: true,
            detail: this._draggingParameters
        });
        this.dispatchEvent(initializationEvent);
    }

    /**
     * @param {Movement|undefined} movement
     */
    @api
    shiftPosition(movement) {
        /** @type {string|undefined} */
        let nextStyle;
        const rect = this._draggingParameters.draggingRect;
        if (!movement || (!movement.x && !movement.y && !this.shiftedStyle)) {
            nextStyle = undefined;
        } else {
            nextStyle = `transform: translate3d(${movement.x}px, ${movement.y}px, 0px); width: ${rect.width}px; height: ${rect.height}px`;
        }
        if (this.shiftedStyle !== nextStyle) {
            this.shiftedStyle = nextStyle;
        }
    }

    /**
     * @param {boolean} dragging
     */
    @api
    setDragging(dragging) {
        this.dragging = dragging;
        if (dragging) {
            const rect = this._draggingParameters.draggingRect;
            this.placeholderStyle = `width: ${rect.width}px; height: ${rect.height}px`;
        } else {
            this.placeholderStyle = '';
        }
        this.shiftPosition(undefined);
    }

    handleEditClicked() {
        this.dispatchEvent(
            new CustomEvent('editclicked', {
                bubbles: true,
                detail: { value: this.value }
            })
        );
    }

    handleDeleteClicked() {
        this.dispatchEvent(
            new CustomEvent('deleteclicked', {
                bubbles: true,
                detail: { value: this.value }
            })
        );
    }

    handleToggleExpanded() {
        if (this.expanded) {
            this._notifyExpandChange(0);
        } else {
            this._notifyExpandChange(Infinity);
        }
    }

    handleExpandOneLevel() {
        this._notifyExpandChange(1);
    }

    /**
     *
     * @param {number=} depth
     */
    _notifyExpandChange(depth) {
        this.dispatchEvent(
            new CustomEvent('expandchange', {
                bubbles: true,
                detail: { value: this.value, depth }
            })
        );
    }
}
