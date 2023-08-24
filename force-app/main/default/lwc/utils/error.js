// @ts-check

/**
 *
 * @param {any} o
 * @param {object | null} proto
 */
function setPrototypeOf(o, proto) {
    if (Object.setPrototypeOf) {
        Object.setPrototypeOf(o, proto);
    } else {
        // eslint-disable-next-line no-proto
        o.__proto__ = proto;
    }
}

/**
 * @template [T=any]
 */
export class ApplicationError extends Error {
    /** @type {string} */
    code;

    /** @type {T} */
    context;

    /**
     *
     * @param {string} message
     * @param {string} code
     * @param {T=} context
     */
    constructor(message, code, context) {
        super(message);
        setPrototypeOf(this, new.target.prototype);
        this.code = code;
        this.context = context;
    }
}
