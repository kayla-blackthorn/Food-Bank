// @ts-check

/**
 * @typedef {import('./typings').SortableListController} SortableListController
 */

/**
 * @implements {SortableListController}
 */
export class NoopSortableListController {
    canMove() {
        return true;
    }
}
