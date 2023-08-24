// @ts-check

/**
 * @typedef {import('../typings/geometry').Point} Point
 * @typedef {import('../typings/geometry').Rect} Rect
 * @typedef {import('../typings/geometry').Movement} Movement
 * @typedef {import('./sortableItem').default} SortableItem
 */


/**
 * @typedef {(id: string) => void} DeRegistrationCallback
 * @typedef {(item: SortableItem) => void} DraggingInitializedCallback
 * @typedef {(draggingRect: Rect, movementDelta: Movement) => void} DraggingMovedCallback
 * @typedef {() => void} DroppedCallback
 */

/**
 * @typedef SortableItemRegisterDetail
 * @property {(cb: DeRegistrationCallback) => void} setDeRegistrationCallback;
 * @property {(cb: DraggingInitializedCallback) => void} setDraggingInitializedCallback;
 * @property {(cb: DraggingMovedCallback) => void} setDraggingMovedCallback;
 * @property {(cb: DroppedCallback) => void} setDroppedCallback;
 */

/**
 * @typedef SortableItemContent
 * @property {(movement: Movement) => void} shiftPosition
 * @property {(dragging: boolean) => void} setDragging
 */

/**
 * @typedef {object} DraggingInitializationParameters
 * @property {Point} startAt
 * @property {Rect} draggingRect
 */

export {};
