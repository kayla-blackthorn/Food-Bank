import { createElement } from 'lwc';
import FormElementDeleteConfirmation from 'c/formElementDeleteConfirmation';

describe('c-form-element-delete-confirmation', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should show cancel and delete buttons if deletable', () => {
        const element = createElement('c-form-element-delete-confirmation', {
            is: FormElementDeleteConfirmation
        });
        element.element = {};
        element.deletable = true;

        document.body.appendChild(element);

        const buttons = Array.from(element.shadowRoot.querySelectorAll('lightning-button'));
        expect(buttons[0].label).toBe('Cancel');
        expect(buttons[1].label).toBe('Delete');
    });

    it('Should show cancel and inspection buttons if not deletable and inspectable', () => {
        const element = createElement('c-form-element-delete-confirmation', {
            is: FormElementDeleteConfirmation
        });
        element.element = {};
        element.deletable = false;
        element.requireInspection = true;

        document.body.appendChild(element);

        const buttons = Array.from(element.shadowRoot.querySelectorAll('lightning-button'));
        expect(buttons[0].label).toBe('Cancel');
        expect(buttons[1].label).toBe('Inspect the Element');
    });

    it('Should show got it button if not deletable and not inspectable', () => {
        const element = createElement('c-form-element-delete-confirmation', {
            is: FormElementDeleteConfirmation
        });
        element.element = {};
        element.deletable = false;
        element.requireInspection = false;

        document.body.appendChild(element);

        const buttons = Array.from(element.shadowRoot.querySelectorAll('lightning-button'));
        expect(buttons.length).toBe(1);
        expect(buttons[0].label).toBe('Got it');
    });
});
