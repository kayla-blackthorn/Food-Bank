// @ts-check

/**
 * Find the longest decreasing subsequence in a list of numbers
 *
 * @example
 * // returns [ [ 6, 1 ], [ 5, 3 ], [ 4, 4 ], [ 2, 6 ] ]
 * findLongestDecreasingSubsequence([3, 6, 1, 5, 4, 7, 2, 8])
 *
 * @param {number[]} nums
 * @returns {number[][]}
 */
export function findLongestDecreasingSubsequence(nums) {
    if (!nums || nums.length === 0) {
        return [];
    }

    const items = nums.map((num, index) => [num, index]);
    const lds = items.map(() => /** @type {number[][]} */([]));
    lds[0].push(items[0]);
    for (let i = 1; i < items.length; i++) {
        let foundIndex = -1;
        let foundLength = lds[i].length;
        for (let j = 0; j < i; j++) {
            if (items[j][0] > items[i][0] && lds[j].length > foundLength) {
                foundIndex = j;
                foundLength = lds[j].length;
            }
        }
        if (foundIndex !== -1) {
            lds[i] = [...lds[foundIndex]];
        }
        lds[i].push(items[i]);
    }

    let j = 0;
    for (let i = 0; i < items.length; i++)
    {
        if (lds[j].length < lds[i].length) {
            j = i;
        }
    }

    return lds[j];
}
