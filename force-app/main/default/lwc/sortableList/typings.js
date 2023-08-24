// @ts-check

/**
 * @typedef {'before'|'after'} DropPosition
 */

/**
 * @template [T=any]
 * @typedef {object} SortableListController
 * @property {(sourceValue: T, targetValue: T, position: DropPosition) => boolean} canMove
 */

/**
 * @typedef {(id: string) => void} DeRegistrationCallback
 * @typedef {() => SortableListController} SetDraggingControllerGetter
 */

/**
 * @typedef SortableListRegisterDetail
 * @property {(cb: DeRegistrationCallback) => void} setDeRegistrationCallback;
 * @property {(getter: SetDraggingControllerGetter) => void} setDraggingControllerGetter;
 */

export {};
