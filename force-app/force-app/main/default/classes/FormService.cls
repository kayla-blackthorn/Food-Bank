/**
 *  This is your main service class. It is used to handle all the logic of your form related tasks.
 */
public with sharing class FormService {
    /**
     * This method is used to clone a form and all its elements and conditions.
     * @param formIdWithSource - a map of parent form Id along with clone version of the form Id
     */
    public static void deepCloneForm(Map<Id, Id> formIdWithSource) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Form_Element__c.SObjectType, Form_Element_Condition__c.SObjectType }
        );

        List<Form_Element__c> formElements = new FormElementSelector()
            .getElementsWithConditionsByFormId(formIdWithSource.keySet());
        Map<Id, Form_Element__c> elementIdToCloneMap = new Map<Id, Form_Element__c>();
        for (Form_Element__c element : formElements) {
            Form_Element__c clone = element.clone(false, true);
            clone.Form__c = formIdWithSource.get(element.Form__c);
            uow.registerNew(clone);
            elementIdToCloneMap.put(element.Id, clone);
        }

        //next clone all the conditions
        for (Form_Element__c element : formElements) {
            if (element.Form_Element_Conditions__r != null && !element.Form_Element_Conditions__r.isEmpty()) {
                for (Form_Element_Condition__c condition : element.Form_Element_Conditions__r) {
                    Form_Element_Condition__c clone = condition.clone(false, true);
                    uow.registerRelationship(
                        clone,
                        Form_Element_Condition__c.Form_Element__c,
                        elementIdToCloneMap.get(condition.Form_Element__c)
                    );
                    uow.registerRelationship(
                        clone,
                        Form_Element_Condition__c.Next_Form_Element__c,
                        elementIdToCloneMap.get(condition.Next_Form_Element__c)
                    );
                    uow.registerNew(clone);
                }
            }
        }
        //finally commit the work
        uow.commitWork();
    }
}
