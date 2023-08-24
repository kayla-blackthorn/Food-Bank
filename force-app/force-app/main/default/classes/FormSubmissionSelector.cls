public with sharing class FormSubmissionSelector extends fflib_SObjectSelector {

	public static List<Schema.SObjectField> FIELDS_FORMSUBMISSION = new List<Schema.SObjectField> {
		Form_Submission__c.Name,
		Form_Submission__c.Form__c,
		Form_Submission__c.Key__c,
		Form_Submission__c.Contact__c,
		Form_Submission__c.Lead__c,
		Form_Submission__c.Account__c,
		Form_Submission__c.User__c,
		Form_Submission__c.Payload__c,
		Form_Submission__c.Status__c
	};

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return FIELDS_FORMSUBMISSION;
	}

	public String getFormProcessingBatchQuery(){

		FIELDS_FORMSUBMISSION = Form_Submission__c.SObjectType.getDescribe().fields.getMap().values();

		fflib_QueryFactory formQueryFactory = newQueryFactory();
		formQueryFactory.setCondition('Status__c = \''+FormSubmissionAPIService.STATUS_TOPROCESS+'\' AND Processed__c = false');

		fflib_QueryFactory formAnswersSubSelectQuery = new 
		FormSubmissionAnswerSelector().addQueryFactorySubselect(formQueryFactory).setCondition('Form_Submission__c != null AND Form_Element__r.Maps_To_Object__c != null');
		formAnswersSubSelectQuery.selectField('Form_Element__r.Type__c');
		formAnswersSubSelectQuery.selectField('Form_Element__r.Maps_To_Field__c');
		formAnswersSubSelectQuery.selectField('Form_Element__r.Maps_To_Object__c');
		formAnswersSubSelectQuery.selectField('Form_Element__r.Form__c');
		return formQueryFactory.toSOQL();
	}

	public List<Form_Submission__c> getSubmissionByKey(Set<String> keys){
		keys.remove(null);
		fflib_QueryFactory formQueryFactory = newQueryFactory();
		formQueryFactory.setCondition('Key__c in :keys');
		fflib_QueryFactory formAnswersSubSelectQuery = new FormSubmissionAnswerSelector().addQueryFactorySubselect(formQueryFactory);
		return (List<Form_Submission__c>) Database.query(formQueryFactory.toSOQL());
	}

	public Schema.SObjectType getSObjectType() {
		return Form_Submission__c.SObjectType;
	}
}
