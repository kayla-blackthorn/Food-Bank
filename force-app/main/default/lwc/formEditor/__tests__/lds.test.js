import { findLongestDecreasingSubsequence } from '../lds';

describe('#findLongestDecreasingSubsequence', () => {
    it('Should find the longest decreasing subsequence', () => {
        const subsequence = findLongestDecreasingSubsequence([0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]);
        expect(subsequence).toEqual([
            [ 12, 3 ], [ 10, 5 ], [ 6, 6 ], [ 5, 10 ], [ 3, 12 ]
        ]);
    });

    it('Should choose the first number if there are identical numbers', () => {
        const subsequence = findLongestDecreasingSubsequence([3, 6, 5, 5, 5, 7, 2, 8]);
        expect(subsequence).toEqual([
            [ 6, 1 ], [ 5, 2 ], [ 2, 6 ]
        ]);
    });
});
