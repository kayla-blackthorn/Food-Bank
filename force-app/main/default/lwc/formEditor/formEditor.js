// @ts-check

/**
 * @typedef {import('../formElementList/typings').FormElementListRegisterDetail} FormElementListRegisterDetail
 * @typedef {import('../formElementList/typings').SetDraggingControllerGetter} SetDraggingControllerGetter
 * @typedef {import('../formShared/typings').Form} Form
 * @typedef {import('../formShared/typings').FormElement} FormElement
 * @typedef {import('../formShared/typings').FormElementsAndConditions} FormElementsAndConditions
 * @typedef {import('../formShared/typings').FormElementLeveled} FormElementLeveled
 * @typedef {import('../formShared/typings').FormElementCondition} FormElementCondition
 * @typedef {import('./formComposer').SortOrderUpdate} SortOrderUpdate
 * @typedef {import('./formComposer').DropPosition} DropPosition
 */

/**
 * @typedef {object} SaveFormElementsOptions
 * @property {boolean=} silent whether to skip notification, default to false
 */

import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FormElementEditorContainer from 'c/formElementEditorContainer';
import FormElementDeleteConfirmation from 'c/formElementDeleteConfirmation';
import { isVirtualFormElement } from 'c/formShared';
import { FormComposer } from './formComposer';
import { FormElementListController } from './formElementListController';
import { ElementNotFoundError, BeDependedOnError } from './errors';

export default class FormEditor extends LightningElement {
    static collapseCountThreshold = 50;

    /** @type {Form} */
    @api form;

    /** @type {FormElementsAndConditions} */
    _elementsAndConditions;
    @api get elementsAndConditions() {
        return this._elementsAndConditions;
    }
    set elementsAndConditions(val) {
        const elements = val.elements || [];
        const conditions = val.conditions || [];
        this._elementsAndConditions = { elements, conditions };
        this.setElementsAndConditions(elements, conditions);
    }

    _saving = false;
    @api get saving() {
        return this._saving;
    }
    set saving(val) {
        if (this._saving && !val) {
            this.dirty = false;
        }
        this._saving = val;
    }

    _maxHeight = '60vh';
    @api get maxHeight() {
        return this._maxHeight;
    }
    set maxHeight(val) {
        this._maxHeight = val;
    }

    /** @type {FormElementLeveled[]} */
    @track leveledElements = [];

    /** the sort orders may need to change if true */
    @track dirty = false;

    @track expanable = false;

    @track expanded = true;

    /** a save operation is scheduled if true */
    _saveScheduled = false;

    get saveButtonLabel() {
        return this.saving ? 'Saving' : 'Save';
    }

    /** @type {boolean} */
    get hasElements() {
        return this.leveledElements.length > 0;
    }

    _formComposer = new FormComposer();

    _formElementListController = new FormElementListController(this._formComposer);

    /** @type {string} */
    _inspectingElementId;

    get isInspectionMode() {
        return !!this._inspectingElementId;
    }

    get computedExpandedIcon() {
        return this.expanded ? 'utility:collapse_all' : 'utility:expand_all'
    }

    get computedExpandedLabel() {
        return this.expanded ? 'Collapse all' : 'Expand all';
    }

    connectedCallback() {
        this._collapseElementsIfNeeded();
    }

    @api getUpdates() {
        return this._formComposer.calcSortOrderUpdates();
    }

    /**
     *
     * @param {SortOrderUpdate[]} updates
     * @returns
     */
    @api commitUpdates(updates) {
        updates.forEach(update => {
            const { id, sortOrder } = update;
            this._formComposer.updateFormElementValue(id, { sortOrder });
        });
    }

    /**
     *
     * @param {FormElement[]} elements
     * @param {FormElementCondition[]} conditions
     */
    setElementsAndConditions(elements, conditions) {
        this._formComposer.setElementsAndConditions(elements, conditions);
        this._updateFormState();
    }

    /**
     *
     * @param {CustomEvent<FormElementListRegisterDetail>} event
     */
    handleFormElementListRegister(event) {
        event.stopPropagation();
        const {
            setDraggingControllerGetter,
        } = event.detail;
        setDraggingControllerGetter(this.getFormElementListController);
    }

    getFormElementListController = () => {
        return this._formElementListController;
    }

    handleEditForm() {
        this.dispatchEvent(new CustomEvent('editform', {
            detail: { value: this.form }
        }));
    }

    handleToggleExpanded() {
        if (this.expanded) {
            this._formComposer.expandSubHierarchy(FormComposer.rootElementId, 1);
        } else {
            this._formComposer.expandSubHierarchy(FormComposer.rootElementId, Infinity);
        }
        this._updateFormState();
    }

    handleExpandOneLevel() {
        this._formComposer.expandSubHierarchy(FormComposer.rootElementId, 2);
        this._updateFormState();
    }

    handleExitInspectionMode() {
        this._inspectingElementId = undefined;
        this._updateFormState();
    }

    async handleAddNewQuestion() {
        const result = await FormElementEditorContainer.open({
            size: 'small',
            description: 'Add new question',
            formId: this.form.id,
            availableElements: this._formComposer.getControllingElementCandidates(),
        });
        if (result) {
            const { element, conditions } = result;
            this._formComposer.addFormElement(element, conditions);
            this._updateFormState();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Form Element ${element.name} saved successfully`,
                    variant: 'success'
                })
            );
            this.dirty = true;
            this._saveFormElementSortOrders({ silent: true });
        }
    }

    handleSaveClick() {
        this._saveFormElementSortOrders();
    }

    /**
     *
     * @param {CustomEvent} event
     */
    handleFormElementsChange(event) {
        if (event.detail.changed) {
            const { sourceItem, targetItem, position } = event.detail.operation;
            if (!isVirtualFormElement(targetItem)) {
                const { mutated } = this._formComposer.moveElement(sourceItem.id, targetItem.id, position);
                if (mutated) {
                    this.dirty = true;
                }
            }
        }
        // need to get a fresh form state no matter whether the order changes or not
        // in case there are messages attached to the element during the dragging
        this._updateFormState();
    }

    /**
     *
     * @param {CustomEvent<{ value: FormElement }>} event
     */
    async handleEditElement(event) {
        const elementToEdit = event.detail.value;
        const result = await FormElementEditorContainer.open({
            size: 'small',
            description: 'Edit new question',
            formId: this.form.id,
            element: elementToEdit,
            conditions: this._formComposer.getElementConditions(elementToEdit.id),
            availableElements: this._formComposer.getControllingElementCandidates(elementToEdit.id),
        });
        if (result) {
            const { element, conditions } = result;
            this._formComposer.addFormElement(element, conditions);
            this._updateFormState();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Form Element ${element.name} saved successfully`,
                    variant: 'success'
                })
            );
            this.dirty = true;
            this._saveFormElementSortOrders({ silent: true });
        }
    }

    /**
     *
     * @param {CustomEvent<{ value: FormElement }>} event
     */
    async handleDeleteElement(event) {
        const element = event.detail.value;
        let title = '';
        let message = '';
        let actionMessage = '';
        let requireInspection = false;
        let deletable = false;
        const { error } = this._formComposer.removeFormElement(element.id, { dryRun: true });
        if (error) {
            if (error instanceof ElementNotFoundError) {
                title = `Form Element ${element.name} not found`;
                this.dispatchEvent(
                    new ShowToastEvent({ title, message, variant: 'warning'})
                );
                return;
            }
            if (error instanceof BeDependedOnError) {
                title = `Unable to delete Form Element`;
                message = `Form Element ${element.name} is required by other element(s)`;
                const affectedElementIds = error.context.affectedElementIds;
                const subHierarchyElementIds = error.context.subHierarchyElementIds;
                actionMessage = 'You need to either delete the controlled elements or change the related conditions to remove the dependencies before deleting the element.'
                if (affectedElementIds.length !== subHierarchyElementIds.length) {
                    actionMessage += ' But not all of the elements that depend on the element are on the element\'s sub tree,';
                    actionMessage += ' do you want to switch to inspection mode for the element to see all the related elements?'
                    requireInspection = true;
                }
            } else {
                title = `Unable to delete Form Element ${element.name}`;
                message = error.message;
            }
        } else {
            title = 'Delete Form Element';
            deletable = true;
            message = 'Are you sure you want to delete this Form Element?';
        }
        /** @type {{ deleted: boolean, inspectionMode: boolean }} */
        const { deleted, inspectionMode } = await FormElementDeleteConfirmation.open({
            size: 'small',
            element,
            description: title,
            message,
            deletable,
            actionMessage,
            requireInspection,
        });
        if (deleted) {
            this._formComposer.removeFormElement(element.id);
            if (element.id === this._inspectingElementId) {
                this._inspectingElementId = undefined;
            }
            this._updateFormState();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Form Element "${element.name}" was deleted`,
                    variant: 'success'
                })
            );
        }
        if (inspectionMode) {
            this._inspectingElementId = element.id;
            this._updateFormState();
        }
    }

    /**
     *
     * @param {CustomEvent<{draggingItem: FormElement, hoveringItem: FormElement; position: DropPosition}>} event
     */
    handleHoveringElement(event) {
        const { draggingItem, hoveringItem, position } = event.detail;
        /** @type {string} */
        let message;
        if (!hoveringItem || draggingItem === hoveringItem) {
            message = undefined;
        } else if (isVirtualFormElement(hoveringItem)) {
            message = 'Cannot reorder with a virtual element';
        } else {
            const { error } = this._formComposer.moveElement(draggingItem.id, hoveringItem.id, position, { dryRun: true });
            if (error) {
                message = error.message;
            }
        }
        const element = this.leveledElements.find(e => e.element.id === draggingItem.id);
        if (element.message === message) {
            return;
        }
        this.leveledElements = this.leveledElements.map(e => {
            if (e.element.id === draggingItem.id) {
                return { ...e, message };
            }
            return e;
        });
    }

    _collapseElementsIfNeeded() {
        if (this._formComposer.elementCount <= FormEditor.collapseCountThreshold) {
            return;
        }
        if (!this._formComposer.isRootHierarchyExpandable) {
            return;
        }
        this._formComposer.expandSubHierarchy(FormComposer.rootElementId, 1);
        this._updateFormState();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Some questions are collapsed for better experience',
                variant: 'info'
            })
        );
    }

    _updateFormState() {
        if (this._inspectingElementId) {
            this.leveledElements = this._formComposer.getFormElementsHierarchy(this._inspectingElementId, {
                mode: 'inspection'
            });
        } else {
            this.leveledElements = this._formComposer.getFormElementsHierarchy();
        }

        this.expanable = this._formComposer.isRootHierarchyExpandable();
        if (this.expanable) {
            this.expanded = this._formComposer.isRootHierarchyExpanded();
        } else {
            this.expanded = false;
        }
    }

    /**
     *
     * @param {SaveFormElementsOptions=} options
     */
    _saveFormElementSortOrders(options) {
        this.dispatchEvent(new CustomEvent('save', {
            detail: { options }
        }));
    }

    /**
     *
     * @param {CustomEvent<{value: FormElement, depth: number}>} event
     */
    handleExpandChange(event) {
        const id = event.detail.value.id;
        const depth = event.detail.depth;
        this._formComposer.expandSubHierarchy(id, depth);
        this._updateFormState();
    }
}
