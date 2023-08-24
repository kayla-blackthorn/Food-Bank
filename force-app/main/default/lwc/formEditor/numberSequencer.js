// @ts-check

/**
 * @typedef {object} NumberSequencerOptions
 * @property {number=} sequenceStep
 * @property {number=} baseValue
 * @property {number=} resetUpdatesRate
 */

import { findLongestDecreasingSubsequence } from './lds';

/**
 * Given an list of numbers, NumberSequencer is able to calculate the minimal updates
 * needed to make the input numbers a descreasing sequence, this can be used to calculate
 * the sort order values.
 *
 * Notice that NumberSequencer does not always return the optimal result due to the
 * algorithm complexity, but it can returns a quite good result generally.
 */
export class NumberSequencer {
    static DefaultSequenceStep = 10;
    static DefaultBaseValue = 100;
    static DefaultResetUpdatesRate = 0.8;

    /** @type {number} */
    sequenceStep;

    /** @type {number} */
    baseValue;

    /** @type {number} */
    resetUpdatesRate

    /**
     * @param {NumberSequencerOptions} options
     */
    constructor(options = {}) {
        this.sequenceStep = options.sequenceStep || NumberSequencer.DefaultSequenceStep;
        this.baseValue = options.baseValue || NumberSequencer.DefaultBaseValue;
        this.resetUpdatesRate = options.resetUpdatesRate || NumberSequencer.DefaultResetUpdatesRate;
    }

    /**
     * Calculate the minimal updates needed to make the input numbers a descreasing sequence
     *
     * @param {number[]} values
     */
    calcSequenceUpdates(values) {
        const normalized = this._normalizeValues(values);
        const subsequence = findLongestDecreasingSubsequence(normalized);
        return this._calcSequenceUpdates(subsequence, values);
    }

    /**
     *
     * Calculate the minimal updates needed to make the input numbers a descreasing sequence
     *
     * @param {number[][]} subsequence Longest decreasing subsequence
     * @param {number[]} values The original list of numbers
     * @returns
     */
    _calcSequenceUpdates(subsequence, values) {
        if (values.length === 0) {
            return { values: [], updates: [] };
        }
        let parsingIndex = values.length - 1;
        let parsedValue = 0;
        let parsedCount = 0;
        let outputValues = [...values];
        let outputUpdates = [];
        for (let i = subsequence.length - 1; i >= 0; i--) {
            const [value, index] = subsequence[i];
            const spaceRequired = parsingIndex - index;
            const spaceOwned = value - parsedValue - 1;
            if (spaceRequired > spaceOwned) {
                continue;
            } else {
                if (spaceRequired > 0) {
                    /** @type {number} */
                    let step;
                    const min = this._calcMinValue();
                    if (spaceOwned - min > spaceRequired) {
                        step = Math.floor((spaceOwned - min) / spaceRequired);
                    } else {
                        step = Math.floor(spaceOwned / spaceRequired);
                    }
                    step = step > this.sequenceStep ? this.sequenceStep : step;

                    for (let j = index + 1; j <= parsingIndex; j++) {
                        const nextValue = value - (j - index) * step;
                        outputValues[j] = nextValue;
                        if (values[j] !== nextValue) {
                            outputUpdates.push({
                                index: j,
                                value: nextValue,
                            });
                        }
                    }
                }
                parsingIndex = index - 1;
                parsedValue = value;
                parsedCount = values.length - index;
            }
        }

        if (parsedCount < values.length) {
            const expectedValue = this.baseValue + parsedCount * this.sequenceStep;
            if (parsedValue < expectedValue) {
                parsedValue = expectedValue;
            } else {
                parsedValue += this.sequenceStep;
            }
            for (let i = parsingIndex; i >= 0; i--) {
                const nextValue = parsedValue + (parsingIndex - i) * this.sequenceStep;
                outputValues[i] = nextValue;
                if (values[i] !== nextValue) {
                    outputUpdates.push({
                        index: i,
                        value: nextValue,
                    });
                }
            }
        }

        const updatesRate = outputUpdates.length / values.length;
        // Reset all values if the update rate exceeds the resetUpdatesRate
        if (updatesRate < 1 && updatesRate > this.resetUpdatesRate) {
            outputValues = [];
            outputUpdates = [];
            for (let i = 0; i < values.length; i++) {
                const value = this.baseValue + this.sequenceStep * i;
                const index = values.length - 1 - i;
                outputValues[index] = value;
                if (values[index] !== value) {
                    outputUpdates.push({ index, value });
                }
            }
        }
        return { values: outputValues, updates: outputUpdates };
    }

    /**
     * Limit the sequence numbers in a certern range
     *
     * The purpose is to avoid making too large number and
     * leave enough space on the bottom for inserting numbers
     *
     * @param {number[]} values
     * @returns {number[]}
     */
    _normalizeValues(values) {
        const maxValue = this._calcMaxValue(values.length);
        const minValue = this._calcMinValue();
        return values.map(v => {
            v = v || 0;
            if (v > maxValue) {
                return 0;
            } else if (v < minValue) {
                return 0;
            }
            return v;
        });
    }

    /**
     * Calculate the max sequence number for a list
     *
     * Note: this is a reference but not a hard limit
     *
     * @param {number} count
     * @returns {number}
     */
    _calcMaxValue(count) {
        return this.baseValue + count * this.sequenceStep;
    }

    /**
     * Calculate the min sequence number for a list
     *
     * Note: this is a reference but not a hard limit
     *
     * @returns {number}
     */
    _calcMinValue() {
        return Math.ceil(this.baseValue / 2);
    }

    /**
     * Number compare function for Array.prototype.sort, in descending order
     *
     * @param {number} a
     * @param {number} b
     * @returns
     */
    _compareNumber(a, b) {
        if (a > b) {
            return -1;
        } else if (a < b) {
            return 1;
        }
        return 0;
    }
}
