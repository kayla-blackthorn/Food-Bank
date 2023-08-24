// @ts-check

/**
 * @typedef {import('../sortableItem/sortableItem').default} SortableItem
 * @typedef {import('../sortableItem/typings').SortableItemRegisterDetail} SortableItemRegisterDetail
 * @typedef {import('../sortableItem/typings').DraggingMovedCallback} DraggingMovedCallback
 * @typedef {import('../typings/geometry').Rect} Rect
 * @typedef {import('../typings/geometry').Movement} Movement
 * @typedef {import('./typings').DropPosition} DropPosition
 * @typedef {import('./typings').SortableListController} SortableListController
 * @typedef {import('./typings').SortableListRegisterDetail} SortableListRegisterDetail
 * @typedef {import('./typings').DeRegistrationCallback} DeRegistrationCallback
 * @typedef {import('./typings').SetDraggingControllerGetter} SetDraggingControllerGetter
 */

import { api, LightningElement, track } from 'lwc';
import { classSet, generateUniqueId, throttle } from 'c/utils';
import { NoopSortableListController } from './noopSortableListController';

/**
 * @typedef {object} CancelableThrottle
 * @property {(options?: { upcomingOnly?: true }) => void} cancel
 */

/**
 * @typedef {object} ContainerState
 * @property {boolean} hasScrollBar
 * @property {Rect} rect
 */

/**
 * @typedef {object} DroppingOperation
 * @property {SortableItem} sourceItem
 * @property {SortableItem} targetItem
 * @property {DropPosition} position
 */

/**
 * @typedef {object} DraggingState
 * @property {string[]} sortableItemIds
 * @property {number} insertIndex
 * @property {SortableItem} draggingItem
 * @property {SortableItem} hoveredItem the current hovering item or last hovered item if not hovering on any item
 * @property {DropPosition} dropPosition
 */

/**
 * @typedef {object} HoveringState
 * @property {SortableItem} draggingItem
 * @property {SortableItem} hoveringItem
 * @property {DropPosition} position
 */

/**
 * @typedef {object} RearrangedValue
 * @property {any[]} value
 * @property {boolean} changed
 */

export default class SortableList extends LightningElement {
    /** @type {number|string} */
    @api maxHeight;

    @track disableScroll = false;

    get computedClass() {
        return classSet('scroll-container slds-p-horizontal_x-small')
            .add({
                'slds-scrollable_none': this.disableScroll,
                'slds-scrollable_y': !this.disableScroll
            })
            .toString();
    }

    get computedStyle() {
        if (!this.maxHeight) {
            return '';
        }
        if (typeof this.maxHeight === 'string') {
            return `max-height: ${this.maxHeight}`;
        }
        return `max-height: ${this.maxHeight}px`;
    }

    /** @type {HTMLElement} */
    _scrollContainer;

    /** @type {ContainerState|undefined} */
    _containerState;

    /** @type {any} */
    _keepScrollTimer;

    /** @type {Record<string, SortableItem>} */
    _sortableItems = {};

    /** @type {DraggingState|undefined} */
    _draggingState;

    /** @type {HoveringState} */
    _lastHoveringState;

    /** @type {DeRegistrationCallback} */
    _deRegistrationCallback;

    /** @type {SetDraggingControllerGetter} */
    _getDraggingController = () => new NoopSortableListController();

    connectedCallback() {
        /** @type {CustomEvent<SortableListRegisterDetail>} */
        const event = new CustomEvent('sortablelistregister', {
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
                 * @param {SetDraggingControllerGetter} getter
                 */
                setDraggingControllerGetter: (getter) => {
                    this._getDraggingController = getter;
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

    renderedCallback() {
        if (!this._scrollContainer) {
            this._scrollContainer = this.template.querySelector('.scroll-container');
        }
    }

    /**
     *
     * @param {CustomEvent<SortableItemRegisterDetail>} event
     */
    handleItemRegister(event) {
        event.stopPropagation();
        const item = /** @type {SortableItem} */ (event.target);
        item.role = 'listitem';

        if (!item.id) {
            item.id = generateUniqueId('sortable');
        }

        this._sortableItems[item.id] = item;

        const {
            setDeRegistrationCallback,
            setDraggingInitializedCallback,
            setDraggingMovedCallback,
            setDroppedCallback
        } = event.detail;
        setDeRegistrationCallback(this.handleDeRegistration);
        setDraggingInitializedCallback(this.handleDragStart);
        setDraggingMovedCallback(this.handleDraggingThrottled);
        setDroppedCallback(this.handleDrop);
    }

    /**
     *
     * @param {string} id
     */
    handleDeRegistration = (id) => {
        delete this._sortableItems[id];
    };

    /**
     *
     * @param {SortableItem} element
     */
    handleDragStart = (element) => {
        this._containerState = {
            hasScrollBar: this._canScroll(this._scrollContainer),
            rect: this._scrollContainer.getBoundingClientRect()
        };
        if (!this._containerState.hasScrollBar) {
            this.disableScroll = true;
        }

        const items = this.querySelectorAll('c-sortable-item');
        const sortableItemIds = Array.from(items).map(item => item.id);
        this._draggingState = {
            draggingItem: element,
            hoveredItem: element,
            sortableItemIds,
            insertIndex: sortableItemIds.findIndex(id => id === element.id),
            dropPosition: 'before',
        };
        this._droppingOperation = { sourceItem: element.value, targetItem: element.value, position: 'before' };
    };

    /**
     *
     * @param {Rect} draggingRect
     * @param {Movement} movementDelta
     * @returns
     */
    handleDragging = (draggingRect, movementDelta) => {
        const rect = this._shiftRect(draggingRect, movementDelta);
        if (this._containerState.hasScrollBar && movementDelta.y !== 0) {
            this._stopScroll();
            const direction = movementDelta.y > 0 ? 'down' : 'up';
            if (direction === 'up') {
                const diff = rect.top - this._containerState.rect.top;
                if (diff < 0) {
                    this._keepScrollY(-rect.height, true);
                } else if (diff < rect.height) {
                    this._scrollContainer.scrollBy({
                        top: -rect.height,
                        behavior: 'smooth'
                    });
                }
            } else if (direction === 'down') {
                const diff = this._containerState.rect.bottom - rect.bottom;
                if (diff < 0) {
                    this._keepScrollY(rect.height, true);
                } else if (diff < rect.height) {
                    this._scrollContainer.scrollBy({
                        top: rect.height,
                        behavior: 'smooth'
                    });
                }
            }
        }

        const testPointLeft = {
            x: rect.left + 1,
            y: rect.top + rect.height / 2
        };
        const testPointRight = {
            x: rect.right - 1,
            y: rect.top + rect.height / 2
        };

        /** @type {SortableItem|undefined} */
        let sortableItemEl;
        for (let p of [testPointLeft, testPointRight]) {
            const el = this.template.elementFromPoint(p.x, p.y);
            sortableItemEl = /** @type {any} */(el?.closest('c-sortable-item'));
            if (sortableItemEl) {
                break;
            }
        }

        this._handleHoverItem(sortableItemEl, rect);
    };

    handleDraggingThrottled = /** @type {DraggingMovedCallback & CancelableThrottle} */(throttle(50, this.handleDragging));

    handleDrop = () => {
        this.handleDraggingThrottled.cancel({ upcomingOnly: true });
        this._containerState = undefined;
        this.disableScroll = false;

        this._unshiftListItems();
        const { value, changed } = this._rearrangeListItems();
        /** @type {DroppingOperation} */
        const operation = {
            sourceItem: this._draggingState.draggingItem.value,
            targetItem: this._draggingState.hoveredItem.value,
            position: this._draggingState.dropPosition,
        };

        this._draggingState = undefined;
        this._lastHoveringState = undefined;
        this._stopScroll();
        this.dispatchEvent(
            new CustomEvent('datachange', {
                detail: {
                    operation,
                    value,
                    changed
                }
            })
        );
    };

    /**
     *
     * @param {Rect} rect
     * @param {Movement} movementDelta
     *
     * @returns {Rect}
     */
    _shiftRect(rect, movementDelta) {
        const roundedMovementX = Math.round(movementDelta.x) || 0;
        const roundedMovementY = Math.round(movementDelta.y) || 0;
        const left = rect.left + roundedMovementX;
        const top = rect.top + roundedMovementY;
        return {
            top,
            left,
            bottom: rect.bottom + roundedMovementY,
            right: rect.right + roundedMovementX,
            width: rect.width,
            height: rect.height
        };
    }

    /**
     * @returns {RearrangedValue}
     */
    _rearrangeListItems() {
        const draggingItemId = this._draggingState.draggingItem.id;
        const { sortableItemIds, insertIndex } = this._draggingState;
        const originalIndex = sortableItemIds.findIndex(id => id === draggingItemId);
        const shiftedInsertIndex = insertIndex + 1;
        if (originalIndex === shiftedInsertIndex) {
            return { value: sortableItemIds, changed: false };
        }

        const rearrangedIds = [];
        for (let i = 0; i < sortableItemIds.length + 1; i++) {
            const id = sortableItemIds[i];
            if (id === draggingItemId) {
                continue;
            }
            if (i === shiftedInsertIndex) {
                rearrangedIds.push(draggingItemId);
            }
            if (id) {
                rearrangedIds.push(id);
            }
        }
        const value = rearrangedIds.map(id => this._sortableItems[id].value);
        return { value, changed: true };
    }

    _shiftListItems() {
        const draggingItemId = this._draggingState.draggingItem.id;
        const { sortableItemIds: itemIds, draggingItem, hoveredItem, insertIndex } = this._draggingState;
        const origionalIndex = itemIds.findIndex(id => id === draggingItemId);
        const canMove = this._getDraggingController().canMove(draggingItem.value, hoveredItem.value, 'before');

        /** @type {Record<string, Movement>} */
        const shiftPositions = {};
        const sortableItems = itemIds.map(id => this._sortableItems[id]);
        if (origionalIndex > insertIndex && origionalIndex > 0) {
            // move up
            const upSiblingItem = this._sortableItems[itemIds[origionalIndex - 1]];
            const rect = upSiblingItem.getBoundingClientRect();
            const draggingRect = draggingItem.getBoundingClientRect();
            const offsetY = draggingRect.bottom - rect.bottom;
            sortableItems.forEach((item, index) => {
                if (item.id === draggingItemId) {
                    return;
                }
                if (index < origionalIndex && index > insertIndex && canMove) {
                    shiftPositions[item.id] = { x: 0, y: offsetY };
                } else {
                    shiftPositions[item.id] = { x: 0, y: 0 };
                }
            });
        } else if (origionalIndex < insertIndex && origionalIndex < itemIds.length - 1) {
            // move down
            const downSiblingItem = this._sortableItems[itemIds[origionalIndex + 1]];
            const rect = downSiblingItem.getBoundingClientRect();
            const draggingRect = draggingItem.getBoundingClientRect();
            const offsetY = draggingRect.top - rect.top;
            sortableItems.forEach((item, index) => {
                if (item.id === draggingItemId) {
                    return;
                }
                if (index > origionalIndex && index <= insertIndex && canMove) {
                    shiftPositions[item.id] = { x: 0, y: offsetY };
                } else {
                    shiftPositions[item.id] = { x: 0, y: 0 };
                }
            });
        } else {
            // it's not moved
            sortableItems.forEach(item => {
                if (item.id === draggingItemId) {
                    return;
                }
                shiftPositions[item.id] = { x: 0, y: 0 };
            });
        }
        sortableItems.forEach(item => {
            if (item.id === draggingItemId) {
                return;
            }
            item.shiftPosition(shiftPositions[item.id]);
        })
    }

    _unshiftListItems() {
        const draggingItemId = this._draggingState.draggingItem.id;
        const itemIds = this._draggingState.sortableItemIds;
        const items = itemIds.map(id => this._sortableItems[id]);
        items.forEach(item => {
            if (item.id === draggingItemId) {
                return;
            }
            item.shiftPosition(undefined);
        })
    }

    /**
     *
     * @param {SortableItem|undefined} hoveredItem
     * @param {Rect} draggingRect
     */
    _handleHoverItem(hoveredItem, draggingRect) {
        if (!hoveredItem) {
            return;
        }

        const hoveredRect = hoveredItem.getBoundingClientRect();
        const draggingMiddle = draggingRect.top + draggingRect.height / 2;
        const hoveredMiddle = hoveredRect.top + hoveredRect.height / 2;
        const hoveredIndex = this._draggingState.sortableItemIds.findIndex(id => id === hoveredItem.id);
        /** @type {DropPosition} */
        let dropPosition;
        /** @type {number} */
        let insertIndex;
        if (draggingMiddle <= hoveredMiddle) {
            // on the top half
            insertIndex = hoveredIndex - 1;
            dropPosition = 'before';
        } else if (draggingMiddle > hoveredMiddle) {
            // on the bottom half
            insertIndex = hoveredIndex;
            dropPosition = 'after';
        }
        this._draggingState.hoveredItem = hoveredItem;
        this._draggingState.insertIndex = insertIndex;
        this._draggingState.dropPosition = dropPosition;
        this._shiftListItems();
        this._emitHoverEvent();
    }

    _emitHoverEvent() {
        /** @type {HoveringState} */
        const state = {
            draggingItem: this._draggingState.draggingItem.value,
            hoveringItem: this._draggingState.hoveredItem.value,
            position: this._draggingState.dropPosition,
        };
        const lastState = this._lastHoveringState;
        this._lastHoveringState = state;
        if (lastState &&
            lastState.draggingItem === state.draggingItem &&
            lastState.hoveringItem === state.hoveringItem &&
            lastState.position === state.position
        ) {
            return;
        }
        this.dispatchEvent(
            new CustomEvent('hovering', {
                detail: state,
            })
        );
    }

    /**
     *
     * @param {HTMLElement} el
     */
    _canScroll(el) {
        const canScrollY = el.scrollHeight > el.offsetHeight;
        const canScrollX = el.scrollWidth > el.offsetWidth;
        return canScrollY || canScrollX;
    }

    /**
     *
     * @param {HTMLElement} el
     */
    _hasScrolledToBottom(el) {
        return el.scrollHeight - el.scrollTop - el.clientHeight < 1;
    }

    /**
     *
     * @param {number} step
     * @param {boolean} immediate
     */
    _keepScrollY(step, immediate = true) {
        if (this._keepScrollTimer) {
            clearTimeout(this._keepScrollTimer);
        }
        if (this._hasScrolledToBottom(this._scrollContainer)) {
            return;
        }
        if (immediate) {
            this._scrollContainer.scrollBy({ top: step, behavior: 'smooth' });
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._keepScrollTimer = setTimeout(() => {
            this._keepScrollTimer = undefined;
            this._scrollContainer.scrollBy({ top: step, behavior: 'smooth' });
            this._keepScrollY(step, false);
        }, 50);
    }

    _stopScroll() {
        if (this._keepScrollTimer) {
            clearTimeout(this._keepScrollTimer);
            this._keepScrollTimer = undefined;
        }
    }
}
