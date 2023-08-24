// @ts-check

/**
 * @typedef {import('../typings/geometry').Rect} Rect
 */

import { traverseUpInDomTree } from './domTraverse';

/**
 * Returns true if element is transformed, false if not. In practice the
 * element's display value must be anything else than "none" or "inline" as
 * well as have a valid transform value applied in order to be counted as a
 * transformed element.
 *
 * @private
 * @param {Element} element
 * @returns {boolean}
 */
function isTransformed(element) {
    const computedStyle = window.getComputedStyle(element);
    const display = computedStyle.display;
    const transform = computedStyle.transform || computedStyle.webkitTransform;

    return transform !== 'none' && display !== 'inline' && display !== 'none';
}

/**
 * Returns true if element is scrollable, false if not.
 *
 * @private
 * @param {Element} element
 * @returns {boolean}
 */
function isScrollable(element) {
    const { overflowY } = window.getComputedStyle(element);
    const scrollable = overflowY !== 'visible' && overflowY !== 'hidden';

    if (scrollable && element.scrollHeight >= element.clientHeight) {
        return true;
    }
    return false;
}

/**
 *
 * @param {Element} startElement
 * @returns {Window|Element}
 */
export function getFixedContainingBlock(startElement) {
    const found = /** @type {Element} */(traverseUpInDomTree(startElement, el => {
        if (el === document.documentElement) {
            return true;
        }
        if (isTransformed(el)) {
            return true;
        }
        return false;
    }));
    return found === document.documentElement ? window : found || window;
}

/**
 * @param {Element} startElement
 * @returns {Element|Document}
 */
export function getScrollParent(startElement) {
    const found = /** @type {Element} */(traverseUpInDomTree(startElement, el => {
        if (el === document.documentElement) {
            return true;
        }

        if (isScrollable(el)) {
            return true;
        }

        return false;
    }));
    return found === document.documentElement ? document : found || document;
}

/**
 *
 * @param {Element|Window} el
 * @returns {Rect}
 */
export function getBoundingClientRect(el) {
    if (el instanceof Window) {
        const clientWidth = document.documentElement.clientWidth;
        const clientHeight = document.documentElement.clientHeight;
        return {
            width: clientWidth,
            height: clientHeight,
            top: 0,
            left: 0,
            right: clientWidth,
            bottom: clientHeight,
        };
    }
    return el.getBoundingClientRect();
}
