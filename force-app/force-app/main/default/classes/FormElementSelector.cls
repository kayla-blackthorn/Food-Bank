public with sharing class FormElementSelector extends fflib_SObjectSelector {

	public static List<Schema.SObjectField> FIELDS_FORM_ELEMENT = new List<Schema.SObjectField> {
		Form_Element__c.Name,
		Form_Element__c.Default_Checkbox_Value__c,
        Form_Element__c.Default_Value__c,
		Form_Element__c.Form__c,
		Form_Element__c.Hint__c,
		Form_Element__c.Maps_To_Field__c,
		Form_Element__c.Maps_To_Object__c,
		Form_Element__c.Picklist_Values__c,
		Form_Element__c.Question__c,
		Form_Element__c.Question_RT__c,
		Form_Element__c.Required__c,
		Form_Element__c.Sort_Order__c,
		Form_Element__c.Type__c,
		Form_Element__c.Form_Big_List_Group__c
	};

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return FIELDS_FORM_ELEMENT;
	}

    public Schema.SObjectType getSObjectType() {
		return Form_Element__c.SObjectType;
	}

    public List<Form_Element__c> getElementsByFormId(String formId, Integer limitCount) {
        return getElementsByFormId(new Set<Id> {formId}, limitCount);
    }

	public List<Form_Element__c> getElementsByFormId(Set<Id> formId, Integer limitCount) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Form__c = :formId');
        queryFactory.addOrdering('Sort_Order__c', fflib_QueryFactory.SortOrder.DESCENDING);
        queryFactory.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
		if(limitCount != null){
			queryFactory.setLimit(limitCount);
		}
        return (List<Form_Element__c>) Database.query(queryFactory.toSOQL());
    }

	public List<Form_Element__c> getElementsWithConditionsByFormId(Set<Id> formId) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Form__c = :formId');
        queryFactory.addOrdering('Sort_Order__c', fflib_QueryFactory.SortOrder.DESCENDING);
        queryFactory.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
		
		FormElementConditionSelector rs = new FormElementConditionSelector();
        fflib_QueryFactory conditionQueryFactory = rs.newQueryFactory(false);
        rs.addQueryFactorySubselect(queryFactory, Helpers.getFieldObjectNS()+'Form_Element_Conditions__r'); 
        return (List<Form_Element__c>) Database.query(queryFactory.toSOQL());
    }

    public Form_Element__c selectById(Id recordId){
        Set<Id> recordIds = new Set<Id>{recordId};
        List<Form_Element__c> elements = selectSObjectsById(recordIds);
        return elements.isEmpty() ? null : elements.get(0);
    }
}
