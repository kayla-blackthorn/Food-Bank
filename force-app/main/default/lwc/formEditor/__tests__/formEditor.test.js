import { createElement } from 'lwc';
import FormEditor from 'c/formEditor';

describe('c-form-editor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Should render form name in editor bar', () => {
        const element = createElement('c-form-editor', {
            is: FormEditor
        });
        const formName = 'Hello Form';
        element.form = { name: formName };
        element.elementsAndConditions = {};

        document.body.appendChild(element);

        const titleEl = element.shadowRoot.querySelector('.form-editor-bar h2');
        expect(titleEl.textContent).toBe(formName);
    });

    it('Should render empty state when there is no elements', () => {
        const element = createElement('c-form-editor', {
            is: FormEditor
        });
        element.form = {};
        element.elementsAndConditions = {};

        document.body.appendChild(element);

        const elementListEl = element.shadowRoot.querySelector('.form-element-list');
        const emptyPlaceholderEl = element.shadowRoot.querySelector('.list-empty-placeholder');
        expect(elementListEl).toBeFalsy()
        expect(emptyPlaceholderEl).toBeTruthy();
    });

    it('Should render element list when there are elements', () => {
        const element = createElement('c-form-editor', {
            is: FormEditor
        });
        const formElements = [ { id: 'e1' } ];
        const formElementsLeveled = formElements.map(e => ({ element: e, level: 1, expanded: true, expandable: false}));
        element.form = {};
        element.elementsAndConditions = {
            elements: formElements
        };

        document.body.appendChild(element);

        const elementListEl = element.shadowRoot.querySelector('c-form-element-list');
        const emptyPlaceholderEl = element.shadowRoot.querySelector('.list-empty-placeholder');
        expect(elementListEl).toBeTruthy()
        expect(emptyPlaceholderEl).toBeFalsy();
        expect(elementListEl.elements).toEqual(formElementsLeveled);
    });
});
