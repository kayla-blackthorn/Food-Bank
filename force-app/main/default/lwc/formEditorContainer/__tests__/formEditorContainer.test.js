import { createElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import loadFormElements from '@salesforce/apex/FormController.loadFormElements';
import loadFormElementConditions from '@salesforce/apex/FormController.loadFormElementConditions';
import { FormElementConditionFields } from 'c/formShared';
import FormEditorContainer from 'c/formEditorContainer';

jest.mock(
    "@salesforce/apex/FormController.loadFormElements",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/FormController.loadFormElementConditions",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe('c-form-editor-container', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    async function flushPromises() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        return new Promise(resolve => setTimeout(() => resolve()));
    }

    it('Shoud show loading spinner if the form and elements are not loaded', () => {
        const element = createElement('c-form-editor-container', {
            is: FormEditorContainer
        });

        document.body.appendChild(element);
        const spinnerEl = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinnerEl).toBeTruthy();
        expect(spinnerEl.alternativeText).toBe('Loading');
    });

    it('Shoud show error if there is error', () => {
        const element = createElement('c-form-editor-container', {
            is: FormEditorContainer
        });

        const errorMessage = 'load error';
        getRecord.error(new Error(errorMessage))

        document.body.appendChild(element);
        const errorMessageEl = element.shadowRoot.querySelector('.error-message');
        expect(errorMessageEl).toBeTruthy();
        expect(errorMessageEl.textContent).toBe(errorMessage);
    });

    it('Shoud pass form and elements to form editor if the data is loaded', async () => {
        const element = createElement('c-form-editor-container', {
            is: FormEditorContainer
        });

        const formData = { fields: { Id: { value: 'f1' }, Name: { value: 'I am a form' } } };
        const elementsData = [{ Id: 'e1' }, { Id: 'e2' }];
        const conditionsData = [{ Id: 'c1', [FormElementConditionFields.ELEMENT_FIELD.fieldApiName]: 'e1', [FormElementConditionFields.NEXT_ELEMENT_FIELD.fieldApiName]: 'e2' }];
        getRecord.emit(formData);
        loadFormElements.mockResolvedValue(elementsData);
        loadFormElementConditions.mockResolvedValue(conditionsData);
        document.body.appendChild(element);

        await flushPromises();

        const formEditor = element.shadowRoot.querySelector('c-form-editor');
        expect(formEditor.form).toEqual({ id: formData.fields.Id.value, name: formData.fields.Name.value });
        expect(formEditor.elementsAndConditions).toEqual({
            elements: elementsData.map(e => ({ id: e.Id })),
            conditions: conditionsData.map(c => ({ id: c.Id, elementId: c[FormElementConditionFields.ELEMENT_FIELD.fieldApiName], nextElementId: c[FormElementConditionFields.NEXT_ELEMENT_FIELD.fieldApiName] }))
        });
    });
});
