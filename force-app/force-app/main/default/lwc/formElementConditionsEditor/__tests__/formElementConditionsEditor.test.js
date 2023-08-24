import { createElement } from 'lwc';
import FormElementConditionsEditor from 'c/formElementConditionsEditor';

describe('c-form-element-conditions-editor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should support reportValidity method', () => {
        const element = createElement('c-form-element-conditions-editor', {
            is: FormElementConditionsEditor
        });

        document.body.appendChild(element);

        expect(typeof element.reportValidity === 'function').toBe(true);
    });

    it('Should render condition editors', async () => {
        const element = createElement('c-form-element-conditions-editor', {
            is: FormElementConditionsEditor
        });
        element.element = { id: 'e1', type: 'Text' };
        element.availableElements = [{ id: 'e2', type: 'Text' }]
        element.conditions = [
            { id: '1', elementId: 'e2', nextElementId: 'e1' },
            { id: '2', elementId: 'e2', nextElementId: 'e1'  },
        ];
        document.body.appendChild(element);

        const editors = Array.from(element.shadowRoot.querySelectorAll('c-form-element-condition-editor'));
        expect(editors.length).toBe(2);
    });
});
