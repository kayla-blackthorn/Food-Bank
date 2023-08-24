// @ts-check

/**
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('../formElementConditionEditor/formElementConditionEditor').ExpandedCondition} ExpandedCondition
 */

/**
 * @typedef {Partial<FormElementCondition>} CreatedMutation
 * @typedef {Partial<FormElementCondition> & { id: string }} UpdatedMutation
 * @typedef {string} DeletedMutation
 */

/**
 * @typedef {object} ConditionMutations
 * @property {CreatedMutation[]=} created
 * @property {UpdatedMutation[]=} updated
 * @property {DeletedMutation[]=} deleted
 */

import { FormElementConditionFieldNames as FieldNames } from 'c/formShared';

/**
 * @param {FormElementCondition[]} conditions
 * @param {ExpandedCondition[]} mutatedConditions
 * @returns {ConditionMutations|undefined}
 */
export function calcConditionMutations(conditions, mutatedConditions) {
    const indexedConditions = conditions.reduce((acc, cur) => {
        acc[cur.id] = cur;
        return acc;
    }, /** @type {Record<string, FormElementCondition>} */ ({}));
    const indexedMutatedConditions = mutatedConditions.reduce((acc, cur) => {
        acc[cur.id] = cur;
        return acc;
    }, /** @type {Record<string, ExpandedCondition>} */ ({}));

    /** @type {ConditionMutations} */
    const mutations = {};
    conditions.forEach(condition => {
        if (!indexedMutatedConditions[condition.id]) {
            // the condition is removed
            const deleted = mutations.deleted || [];
            deleted.push(condition.id);
            mutations.deleted = deleted;
        }
    });
    mutatedConditions.forEach(mutatedCondition => {
        const condition = indexedConditions[mutatedCondition.id];
        if (condition) {
            // the condition is updated
            const diff = FieldNames.pushable.reduce((acc, name) => {
                if (condition[name] !== mutatedCondition[name]) {
                    acc = acc || {};
                    acc[name] = mutatedCondition[name];
                }
                return acc;
            }, /** @type {Partial<FormElementCondition>|undefined} */ (undefined));
            if (diff) {
                const updated = mutations.updated || [];
                updated.push({ ...diff, id: condition.id });
                mutations.updated = updated;
            }
        } else {
            // it's a new condition
            const created = mutations.created || [];
            const newCondition = FieldNames.pushable.reduce((acc, name) => {
                if (name !== FieldNames.ID && mutatedCondition[name] !== undefined) {
                    acc[name] = mutatedCondition[name];
                }
                return acc;
            }, /** @type {Partial<FormElementCondition>} */ ({}));
            created.push(newCondition);
            mutations.created = created;
        }
    });

    return Object.keys(mutations).length > 0 ? mutations : undefined;
}
