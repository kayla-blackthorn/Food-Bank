import { createElement } from 'lwc';
import FormElementEditorContainer from 'c/formElementEditorContainer';

describe('c-form-element-editor-container', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render', () => {
        const element = createElement('c-form-element-editor-container', {
            is: FormElementEditorContainer
        });

        document.body.appendChild(element);

        expect(1).toBe(1);
    });
});
