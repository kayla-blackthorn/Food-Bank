import { createElement } from 'lwc';
import SortableList from 'c/sortableList';

describe('c-sortable-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-sortable-list', {
            is: SortableList
        });

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
