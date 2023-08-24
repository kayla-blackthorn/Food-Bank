import { createElement } from 'lwc';
import FormContentEditor from 'c/formContentEditor';
import { SfdcObjects } from 'c/formShared';

describe('c-form-content-editor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('render lightning-record-edit-form with given input values', () => {
        const formId = '0031700000pJRRSAA4';

        /** @type {FormContentEditor} */
        const element = createElement('c-form-content-editor', {
            is: FormContentEditor
        });

        element.formId = formId;
        document.body.appendChild(element);

        const formEl = element.shadowRoot.querySelector(
            'lightning-record-edit-form'
        );
        expect(formEl.recordId).toBe(formId);
        expect(formEl.objectApiName).toEqual(SfdcObjects.FORM_OBJECT.objectApiName);

        const buttons = element.shadowRoot.querySelectorAll('lightning-button');
        const submitButton = Array.from(buttons).find(b => b.type === 'submit');
        expect(submitButton).toBeTruthy();
    });

    it('Should render Name field only', () => {
        const fields = ['Name'];
        const formId = '0031700000pJRRSAA4';

        /** @type {FormContentEditor} */
        const element = createElement('c-form-content-editor', {
            is: FormContentEditor
        });

        element.formId = formId;
        document.body.appendChild(element);

        const inputs = element.shadowRoot.querySelectorAll('lightning-input-field');
        const outputFieldNames = Array.from(inputs).map(input => input.fieldName);
        expect(outputFieldNames).toEqual(fields);
    });
});
