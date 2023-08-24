public with sharing class FormSubmissionAnswerSelector extends fflib_SObjectSelector {
    public static List<Schema.SObjectField> FIELDS_FORM_ANSWER = new List<Schema.SObjectField>{
        Form_Submission_Answer__c.Name,
        Form_Submission_Answer__c.Answer__c,
        Form_Submission_Answer__c.Answer_Text_Long__c,
        Form_Submission_Answer__c.Answer_Date__c,
        Form_Submission_Answer__c.Answer_Number__c,
        Form_Submission_Answer__c.File_Upload_Key__c,
        Form_Submission_Answer__c.Form_Big_List_Option__c,
        Form_Submission_Answer__c.Form_Element__c,
        Form_Submission_Answer__c.Answer_Mapped__c,
        Form_Submission_Answer__c.Form_Submission__c,
        Form_Submission_Answer__c.Question__c
    };

    public List<Schema.SObjectField> getSObjectFieldList() {
        return FIELDS_FORM_ANSWER;
    }

    public Schema.SObjectType getSObjectType() {
        return Form_Submission_Answer__c.SObjectType;
    }

    public List<Form_Submission_Answer__c> getAnswerByFormSubmissionId(Set<Id> formSubmissionIds) {
        return [
            SELECT
                Name,
                Answer__c,
                Answer_Text_Long__c,
                Answer_Date__c,
                Answer_Number__c,
                File_Upload_Key__c,
                Form_Big_List_Option__c,
                Form_Element__c,
                Answer_Mapped__c,
                Form_Submission__c,
                Question__c,
                Form_Submission__r.Form__c,
                Form_Submission__r.Key__c
            FROM Form_Submission_Answer__c
            WHERE Form_Submission__c IN :formSubmissionIds
            WITH SECURITY_ENFORCED
        ];
    }
}
