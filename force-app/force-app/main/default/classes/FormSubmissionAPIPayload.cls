global with sharing class FormSubmissionAPIPayload {
    global String key;
    global String sobjectKey; //set this to make relation to sobject record in the caller
    global String formId;
    global String formSubmissionId; // Id of Form_Submission__c record if processing in edit mode
    global List<FormElement> formElements;
    //form submissionrelatedIds
    global Set<String> relatedIds = new Set<String>();

    global class FormElement {
        global String answer;
        global String formElementId;
        global Set<String> relatedIds = new Set<String>();
    }
    
}
