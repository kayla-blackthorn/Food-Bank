import { createElement } from 'lwc';
import FormElementList from 'c/formElementList';

describe('c-form-element-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-form-element-list', {
            is: FormElementList
        });

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
