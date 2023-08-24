// @ts-check

/**
 *
 * @param {Element|undefined} startElement
 * @param {(el: Element) => boolean} match
 * @returns {Element}
 */
export function traverseUpInDomTree(startElement, match) {
    if (!startElement) {
        return undefined;
    }
    if (match(startElement)) {
        return startElement;
    }

    /** @type {Node} */
    let next = startElement;
    while (next) {
        if (next instanceof ShadowRoot) {
            next = next.host;
        } else if (next instanceof Element && next.assignedSlot) {
            next = next.assignedSlot.parentNode;
        } else {
            next = next.parentNode;
        }
        if (next instanceof Element) {
            break;
        }
    }

    return traverseUpInDomTree(/** @type {Element} */(next), match);
}
