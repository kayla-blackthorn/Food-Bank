import { createElement } from 'lwc';
import FormElementConditionEditor from 'c/formElementConditionEditor';

describe('c-form-element-condition-editor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should support reportValidity method', () => {
        const element = createElement('c-form-element-condition-editor', {
            is: FormElementConditionEditor
        });
        element.condition = {};
        document.body.appendChild(element);

        expect(typeof element.reportValidity === 'function').toBe(true);
    });
});
