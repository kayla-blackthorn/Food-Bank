// @ts-check

/**
 * @typedef {import('../typings/geometry').Rect} Rect
 * @typedef {import('../typings/geometry').Point} Point
 * @typedef {import('../typings/geometry').Movement} Movement
 * @typedef {import('./typings').DeRegistrationCallback} DeRegistrationCallback
 * @typedef {import('./typings').DraggingInitializedCallback} DraggingInitializedCallback
 * @typedef {import('./typings').DraggingMovedCallback} DraggingMovedCallback
 * @typedef {import('./typings').DroppedCallback} DroppedCallback
 * @typedef {import('./typings').SortableItemRegisterDetail} SortableItemRegisterDetail
 * @typedef {import('./typings').SortableItemContent} SortableItemContent
 * @typedef {import('./typings').DraggingInitializationParameters} DraggingInitializationParameters
 */

import { api, LightningElement, track } from 'lwc';

/**
 * @typedef {object} DraggingState
 * @property {Point} startAt
 * @property {Rect} draggingRect
 * @property {boolean} dragging
 */

export default class SortableItem extends LightningElement {
    /** @type {any} */
    @api value;

    /** @type {string|undefined} */
    @track shiftedStyle;

    /** @type {DraggingState|undefined} */
    _draggingState;

    /** @type {SortableItemContent|undefined} */
    _contentElement;

    /** @type {DeRegistrationCallback} */
    _deRegistrationCallback;

    /** @type {DraggingInitializedCallback} */
    _draggingInitializedCallback;

    /** @type {DraggingMovedCallback} */
    _draggingMovedCallback;

    /** @type {DroppedCallback} */
    _droppedCallback;

    connectedCallback() {
        /** @type {CustomEvent<SortableItemRegisterDetail>} */
        const event = new CustomEvent('privatesortableitemregister', {
            cancelable: true,
            bubbles: true,
            composed: true,
            detail: {
                /**
                 *
                 * @param {DeRegistrationCallback} cb
                 */
                setDeRegistrationCallback: (cb) => {
                    this._deRegistrationCallback = cb;
                },

                /**
                 *
                 * @param {DraggingInitializedCallback} cb
                 */
                setDraggingInitializedCallback: (cb) => {
                    this._draggingInitializedCallback = cb;
                },

                /**
                 *
                 * @param {DraggingMovedCallback} cb
                 */
                setDraggingMovedCallback: (cb) => {
                    this._draggingMovedCallback = cb;
                },

                /**
                 *
                 * @param {DroppedCallback} cb
                 */
                setDroppedCallback: (cb) => {
                    this._droppedCallback = cb;
                },
            }
        });
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        if (this._deRegistrationCallback) {
            this._deRegistrationCallback(this.id);
        }
    }

    /**
     *
     * @param {Movement|undefined} movement
     */
    @api
    shiftPosition(movement) {
        /** @type {string|undefined} */
        let nextStyle;
        if (!movement || (!movement.x && !movement.y && !this.shiftedStyle)) {
            nextStyle = undefined;
        } else {
            nextStyle = `transform: translate3d(${movement.x}px, ${movement.y}px, 0px); transition: transform 300ms ease;`;
        }
        if (this.shiftedStyle !== nextStyle) {
            this.shiftedStyle = nextStyle;
        }
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleContentRegister(event) {
        event.stopPropagation();
        this._contentElement = /** @type {SortableItemContent} */(/** @type {unknown} */(event.target));
    }

    /**
     *
     * @param {CustomEvent<DraggingInitializationParameters>} event
     */
    initializeDragging(event) {
        const { startAt, draggingRect } = event.detail;
        this._draggingState = {
            startAt,
            draggingRect,
            dragging: false,
        };
        document.addEventListener('pointerup', this.handleDragPointerUp);
        document.addEventListener('pointermove', this.handleDragPointerMove);
    }

    /**
     *
     * @param {PointerEvent} event
     */
    handleDragPointerMove = (event) => {
        const { pageX, pageY } = event;
        if (!this._draggingState.dragging) {
            this._draggingState.dragging = true;
            this._contentElement.setDragging(true);
            if (this._draggingInitializedCallback) {
                this._draggingInitializedCallback(this);
            }
        }

        const { startAt, draggingRect: rect } = this._draggingState;
        const deltaX = pageX - startAt.x;
        const deltaY = pageY - startAt.y;
        const viewportOffsetX = rect.left + deltaX;
        const viewportOffsetY = rect.top + deltaY;
        this._contentElement.shiftPosition({ x: viewportOffsetX, y: viewportOffsetY });
        if (this._draggingMovedCallback) {
            this._draggingMovedCallback(rect, { x: deltaX, y: deltaY });
        }
    };

    handleDragPointerUp = () => {
        document.removeEventListener('pointerup', this.handleDragPointerUp);
        document.removeEventListener('pointermove', this.handleDragPointerMove);
        if (this._draggingState.dragging) {
            this._contentElement.setDragging(false);
            if (this._droppedCallback) {
                this._droppedCallback();
            }
        }
        this._draggingState = undefined;
    };
}
