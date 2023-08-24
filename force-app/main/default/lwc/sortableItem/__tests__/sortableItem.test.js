import { createElement } from 'lwc';
import SortableItem from 'c/sortableItem';

describe('c-sortable-item', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-sortable-item', {
            is: SortableItem
        });

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
