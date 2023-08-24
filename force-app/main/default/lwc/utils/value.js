/**
 * Convert empty string to null, other types of values are untouched
 *
 * This is used to normalize salesforce field values before saving
 *
 * @param {any} value
 * @returns
 */
export function valueOrNull(value) {
    if (typeof value === 'string') {
        return value || null;
    }
    return value;
}
