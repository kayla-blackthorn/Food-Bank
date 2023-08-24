// @ts-check

/**
 * @typedef {import('../../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../../formElementConditionEditor/formElementConditionEditor').ExpandedCondition} ExpandedCondition
 */

import { calcConditionMutations } from '../mutationsCalculator';

describe('#calcConditionMutations', () => {
    it('Should calculate updated conditions', () => {
        const conditions = /** @type {Partial<FormElementCondition>[]} */([{ id: 'c1', elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Equals' }]);
        const mutatedConditions = /** @type {Partial<ExpandedCondition>[]} */ ([{ id: 'c1', selectedType: 'Text', elementId: 'e3', nextElementId: 'e2', conditionOperator: null, conditionValue: 'val2'}]);
        const mutations = calcConditionMutations(/** @type {FormElementCondition[]} */(conditions), /** @type {ExpandedCondition[]} */(mutatedConditions));
        expect(mutations).toEqual({
            updated: [
                { id: 'c1',  elementId: 'e3', conditionOperator: null, conditionValue: 'val2' }
            ]
        });
    });

    it('Should calculate created conditions', () => {
        const conditions = /** @type {Partial<FormElementCondition>[]} */([]);
        const mutatedConditions = /** @type {Partial<ExpandedCondition>[]} */ ([{ id: 'temp_id1', selectedType: 'Text', elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Contains', conditionValue: null }]);
        const mutations = calcConditionMutations(/** @type {FormElementCondition[]} */(conditions), /** @type {ExpandedCondition[]} */(mutatedConditions));
        expect(mutations).toEqual({
            created: [
                { elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Contains', conditionValue: null }
            ]
        });
    });

    it('Should calculate delete conditions', () => {
        const conditions = /** @type {Partial<FormElementCondition>[]} */([{ id: 'c1', elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Equals', conditionValue: 'val'}]);
        const mutatedConditions = /** @type {Partial<ExpandedCondition>[]} */ ([]);
        const mutations = calcConditionMutations(/** @type {FormElementCondition[]} */(conditions), /** @type {ExpandedCondition[]} */(mutatedConditions));
        expect(mutations).toEqual({
            deleted: [
                'c1'
            ]
        });
    });

    it('Should calculate conditions mutations', () => {
        const conditions = /** @type {Partial<FormElementCondition>[]} */([
            { id: 'c1', elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Equals', conditionValue: 'val'},
            { id: 'c2', elementId: 'e3', nextElementId: 'e4', conditionOperator: 'Contains', conditionValue: 'val'},
        ]);
        const mutatedConditions = /** @type {Partial<ExpandedCondition>[]} */ ([
            { id: 'c1', selectedType: 'Text', elementId: 'e1', nextElementId: 'e2', conditionOperator: 'Contains', conditionValue: 'val2'},
            { id: 'temp_id1', selectedType: 'Text', elementId: 'e1', nextElementId: 'e3', conditionOperator: 'Contains', conditionValue: 'val2'}
        ]);
        const mutations = calcConditionMutations(/** @type {FormElementCondition[]} */(conditions), /** @type {ExpandedCondition[]} */(mutatedConditions));
        expect(mutations).toEqual({
            created: [
                { elementId: 'e1', nextElementId: 'e3', conditionOperator: 'Contains', conditionValue: 'val2' }
            ],
            updated: [
                { id: 'c1',  conditionOperator: 'Contains', conditionValue: 'val2' }
            ],
            deleted: [
                'c2'
            ]
        });
    });
});
