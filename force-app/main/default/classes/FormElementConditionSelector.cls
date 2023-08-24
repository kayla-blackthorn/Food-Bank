public with sharing class FormElementConditionSelector extends fflib_SObjectSelector {
    public static List<Schema.SObjectField> FIELDS_FORM_ELEMENT_CONDITION = new List<Schema.SObjectField>{
        Form_Element_Condition__c.Name,
        Form_Element_Condition__c.Condition_Operator__c,
        Form_Element_Condition__c.Condition_Value__c,
        Form_Element_Condition__c.Form_Element__c,
        Form_Element_Condition__c.Next_Form_Element__c
    };

    public List<Schema.SObjectField> getSObjectFieldList() {
        return FIELDS_FORM_ELEMENT_CONDITION;
    }

    public Schema.SObjectType getSObjectType() {
        return Form_Element_Condition__c.SObjectType;
    }

    public List<Form_Element_Condition__c> getConditionsByFormId(Id formId, Integer limitCount) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Form_Element__r.Form__c = :formId AND Next_Form_Element__r.Form__c = :formId');
        queryFactory.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        queryFactory.setLimit(limitCount);
        return (List<Form_Element_Condition__c>) Database.query(queryFactory.toSOQL());
    }

    public List<Form_Element_Condition__c> getConditionsByControlledElement(
        Form_Element__c element,
        Integer limitCount
    ) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        Id formId = element.Form__c;
        Id elementId = element.Id;
        queryFactory.setCondition(
            'Form_Element__r.Form__c = :formId AND Next_Form_Element__r.Form__c = :formId and Next_Form_Element__c = :elementId'
        );
        queryFactory.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        queryFactory.setLimit(limitCount);
        return (List<Form_Element_Condition__c>) Database.query(queryFactory.toSOQL());
    }
}
