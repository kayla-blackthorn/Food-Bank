/**
 *
 * @param {value: any} value
 * @returns {boolean}
 */
export function coerceBooleanProperty(value) {
    return value != null && `${value}` !== 'false';
}
