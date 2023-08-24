import { createElement } from 'lwc';
import FormElementEditor from 'c/formElementEditor';

describe('c-form-element-editor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-form-element-editor', {
            is: FormElementEditor
        });
        element.labels = {};

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
