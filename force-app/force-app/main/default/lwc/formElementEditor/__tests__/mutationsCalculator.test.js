// @ts-check

/**
 * @typedef {import('../../formShared/typings').FormElement} FormElement
 * @typedef {import('../typings').ExpandedElement} ExpandedElement
 */

import { calcElementMutations } from '../mutationsCalculator';

describe('#calcElementMutations', () => {
    it('Should calculate updated element', () => {
        const element = /** @type {Partial<FormElement>} */({ id: 'e1', type: 'Text', question: 'Where', hint: 'some hint' });
        const mutatedElement = /** @type {Partial<ExpandedElement>} */ ({ id: 'e1', type: 'Date', question: 'Where', hint: null, mapsToObject: 'obj' });
        const mutations = calcElementMutations(/** @type {FormElement} */(element), /** @type {ExpandedElement} */(mutatedElement));
        expect(mutations).toEqual({
            updated: { id: 'e1',  hint: null, mapsToObject: 'obj', type: 'Date' }
        });
    });

    it('Should calculate created element', () => {
        const mutatedElement = /** @type {Partial<ExpandedElement>} */ ({ id: 'temp_e1', type: 'Date', question: 'Where', mapsToObject: 'obj' });
        const mutations = calcElementMutations(undefined, /** @type {FormElement} */ (mutatedElement));
        expect(mutations).toEqual({
            created: { type: 'Date', question: 'Where', mapsToObject: 'obj', sortOrder: 0 }
        });
    });
});
