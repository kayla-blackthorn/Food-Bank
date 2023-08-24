// @ts-check

import { FormElementNode } from '../formElementNode';

describe('FormElementNode', () => {
    describe('#insertSubElementNode', () => {
        /** @type {FormElementNode} */
        let parentNode;
        /** @type {FormElementNode} */
        let node1;
        /** @type {FormElementNode} */
        let node2;
        /** @type {FormElementNode} */
        let node3;
        beforeEach(() => {
            parentNode = new FormElementNode(/** @type {any} */({ id: 'root' }));
            node1 = new FormElementNode(/** @type {any} */({ id: 'e1' }));
            node2 = new FormElementNode(/** @type {any} */({ id: 'e2' }));
            node3 = new FormElementNode(/** @type {any} */({ id: 'e3' }));
            parentNode.appendSubElementNode(node1);
            parentNode.appendSubElementNode(node2);
            parentNode.appendSubElementNode(node3);
        });

        it('should do nothing if insert into the same parent and the same index', () => {
            parentNode.insertSubElementNode(node1, 0);
            expect(node1.index).toEqual(0);
            expect(node2.index).toEqual(1);
            expect(node3.index).toEqual(2);
        });

        it('should insert to the right position and set the parent to the target parent for a new node', () => {
            const node4 = new FormElementNode(/** @type {any} */({ id: 'e4' }));
            parentNode.insertSubElementNode(node4, 1);
            expect(node1.index).toEqual(0);
            expect(node4.index).toEqual(1);
            expect(node2.index).toEqual(2);
            expect(node3.index).toEqual(3);
            expect(node4.parentNode === parentNode).toEqual(true);
        });

        it('should insert to the right relative position if insert into the same parent but different index(1)', () => {
            parentNode.insertSubElementNode(node1, 1);
            expect(node1.index).toEqual(0);
            expect(node2.index).toEqual(1);
            expect(node3.index).toEqual(2);
        });

        it('should insert to the right relative position if insert into the same parent but different index(2)', () => {
            parentNode.insertSubElementNode(node2, 0);
            expect(node2.index).toEqual(0);
            expect(node1.index).toEqual(1);
            expect(node3.index).toEqual(2);
        });

        it('should insert to the right relative position if insert into the same parent but different index(3)', () => {
            parentNode.insertSubElementNode(node1, 2);
            expect(node2.index).toEqual(0);
            expect(node1.index).toEqual(1);
            expect(node3.index).toEqual(2);
        });

        it('should insert to the different parent', () => {
            const newParentNode = new FormElementNode(/** @type {any} */({ id: 'new' }));
            newParentNode.insertSubElementNode(node1, 0);
            expect(parentNode.subElementNodes.length).toEqual(2);
            expect(newParentNode.subElementNodes.length).toEqual(1);
            expect(node2.index).toEqual(0);
            expect(node1.index).toEqual(0);
            expect(node1.parentNode === newParentNode).toEqual(true);
        });
    });
});
