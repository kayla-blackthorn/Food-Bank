/**
 * @template [T=Element]
 * @typedef {object} WithTarget
 * @property {EventTarget & T} target
 */

/**
 * @template [T=Element]
 * @typedef {object} WithDetail
 * @property {EventTarget & T} detail
 */

/**
 * @template [T=Element]
 * @typedef {WithTarget<T> & WithDetail<T> & Event} ChangeEvent
 */

export {};
