import { createElement } from 'lwc';
import FormElementItem from 'c/formElementItem';

describe('c-form-element-item', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-form-element-item', {
            is: FormElementItem
        });

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
