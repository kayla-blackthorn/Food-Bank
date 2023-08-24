import { NumberSequencer } from '../numberSequencer';

describe('calcSequenceUpdates', () => {
    it('Should calculate the minimal updates (1)', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 1 });
        // Scenario: move the last item to the first
        const { values, updates } = sequencer.calcSequenceUpdates([1, 8, 7, 6, 5, 4, 3, 2]);
        expect(values).toEqual([
            9, 8, 7, 6,
            5, 4, 3, 2
        ]);
        expect(updates).toEqual([
            { index: 0, value: 9 }
        ]);
    });

    it('Should calculate the minimal updates (2)', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 1 });
        // Scenario: move the items arround randomly
        const { values, updates } = sequencer.calcSequenceUpdates([3, 6, 1, 5, 4, 7, 2, 8]);
        expect(values).toEqual([
            8, 7, 6, 5,
            4, 3, 2, 1
        ]);
        expect(updates).toEqual([
            { index: 7, value: 1 },
            { index: 5, value: 3 },
            { index: 2, value: 6 },
            { index: 1, value: 7 },
            { index: 0, value: 8 }
        ]);
    });

    it('Should calculate the minimal updates (4)', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 1 });
        // Scenario: swap two items
        const { values, updates } = sequencer.calcSequenceUpdates([8, 7, 6, 4, 5, 3, 2, 1]);
        expect(values).toEqual([
            8, 7, 6, 5,
            4, 3, 2, 1
        ]);
        expect(updates).toEqual([
            { index: 3, value: 5 },
            { index: 4, value: 4 }
        ]);
    });

    it('Should have no updates if it is in order already', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 1 });
        const { values, updates } = sequencer.calcSequenceUpdates([8, 7, 6, 5, 4, 3, 2, 1]);
        expect(values).toEqual([
            8, 7, 6, 5,
            4, 3, 2, 1
        ]);
        expect(updates).toEqual([]);
    });

    it('Should calculate the minimal updates when some values are equal', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 1 });
        const { values, updates } = sequencer.calcSequenceUpdates([3, 6, 5, 5, 5, 7, 2, 8]);
        expect(values).toEqual([
            8, 7, 6, 5,
            4, 3, 2, 1
        ]);
        expect(updates).toEqual([
            { index: 7, value: 1 },
            { index: 5, value: 3 },
            { index: 4, value: 4 },
            { index: 2, value: 6 },
            { index: 1, value: 7 },
            { index: 0, value: 8 }
        ]);
    });

    it('Should normalize the values before calculate the minimal updates', () => {
        const sequencer = new NumberSequencer({ baseValue: 100, sequenceStep: 10, resetUpdatesRate: 1 });
        const { updates, values } = sequencer.calcSequenceUpdates([150, 6, 1, 5, 4, 7, 2, 8]);
        expect(values).toEqual([
            150, 140, 130, 120,
            110, 100,  90,  80
        ]);
        expect(updates).toEqual([
            { index: 1, value: 140 },
            { index: 2, value: 130 },
            { index: 3, value: 120 },
            { index: 4, value: 110 },
            { index: 5, value: 100 },
            { index: 6, value: 90 },
            { index: 7, value: 80 }
        ]);
    });

    it('Should calculate full updates if the update rate exceeds the resetUpdatesRate (1)', () => {
        const sequencer = new NumberSequencer({ baseValue: 1, sequenceStep: 1, resetUpdatesRate: 0.8 });
        const { values, updates } = sequencer.calcSequenceUpdates([3, 6, 5, 5, 5, 7, 2, 8]);
        expect(values).toEqual([
            8, 7, 6, 5,
            4, 3, 2, 1
        ]);
        expect(updates).toEqual([
            { index: 7, value: 1 },
            { index: 5, value: 3 },
            { index: 4, value: 4 },
            { index: 2, value: 6 },
            { index: 1, value: 7 },
            { index: 0, value: 8 }
        ]);
    });

    it('Should calculate full updates if the update rate exceeds the resetUpdatesRate (2)', () => {
        const sequencer = new NumberSequencer({ baseValue: 100, sequenceStep: 10, resetUpdatesRate: 0.8 });
        const { updates, values } = sequencer.calcSequenceUpdates([150, 6, 1, 5, 4, 7, 2, 8]);
        expect(values).toEqual([
            170, 160, 150,
            140, 130, 120,
            110, 100
        ]);
        expect(updates).toEqual([
            { index: 7, value: 100 },
            { index: 6, value: 110 },
            { index: 5, value: 120 },
            { index: 4, value: 130 },
            { index: 3, value: 140 },
            { index: 2, value: 150 },
            { index: 1, value: 160 },
            { index: 0, value: 170 }
        ]);
    });
});
