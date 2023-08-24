global with sharing class FormSubmissionProcessAnswerBatch implements Database.Batchable<SObject>, Schedulable {

    public class FormSubmissionProcessAnswerBatchException extends Exception {}

    Map<Id, Set<Id>> formUpdatingRelatedObjectIds;
    Map<Id, Boolean> formhasError;

    Map<String, Map<String, Schema.SObjectField>> fieldMap;
    Map<Schema.SObjectType, String> formSubmissionRelationFieldAPIName;
    Map<String, Schema.SObjectType> schemaMap;
    List<ContentDocumentLink> contentDocToCreate;
    @TestVisible
    String query;

    static String FILE_UPLOAD_DATATYPE= 'File Upload';
    static String NONE_VALUE = '--None--';

    public static String FORM_SUBMISSION_JOB = 'Blackthorn | Form Processing Job';

    global FormSubmissionProcessAnswerBatch() {
        initVars();
    }

    global FormSubmissionProcessAnswerBatch(String qry) {
        this.query = qry;
        initVars();
    }

    private void initVars() {
        formhasError = new Map<Id, Boolean>();
        fieldMap = new Map<String, Map<String, Schema.SObjectField>>();
        formUpdatingRelatedObjectIds = new Map<Id, Set<Id>>();
        this.schemaMap = Schema.getGlobalDescribe();
        formSubmissionRelationFieldAPIName = new Map<Schema.SObjectType, String>();
        contentDocToCreate = new List<ContentDocumentLink>();
    }

    private Boolean hasExistingJobInQueue(String jobId){
        List<String> statusList = new List<String>{ 'Queued', 'Preparing', 'Processing', 'Holding' };

        AsyncApexJob[] runningJobs = [
            SELECT Id, Status
            FROM AsyncApexJob
            WHERE
                JobType = 'BatchApex'
                AND Status IN :statusList
                AND ApexClassID IN (SELECT Id FROM ApexClass WHERE Name = 'FormSubmissionProcessAnswerBatch')
                AND Id != :jobId
        ];
        return runningJobs.size() > 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id from Form_Submission_Answer__c WHERE Name = \'i do not exist\' limit 1';
        if (!hasExistingJobInQueue(bc.getJobId()) ) {
            query = new FormSubmissionSelector().getFormProcessingBatchQuery();
        }
        return Database.getQueryLocator(query);
    }

    private Map<String, ContentVersion> getUploadedFiles(List<Form_Submission_Answer__c> objList) {
        Set<String> fileUploadKeys = new Set<String>();
        Map<String, ContentVersion> docByFileKey = new Map<String, ContentVersion>();
        for (Form_Submission_Answer__c ans : objList) {
            if (ans.Form_Element__r.Type__c == FILE_UPLOAD_DATATYPE) {
                fileUploadKeys.add((String) getAnswer(ans));
            }
        }
        if (fileUploadKeys.size() > 0) {
            //get the content version records
            List<ContentVersion> versionData = getContentVersion(fileUploadKeys);
            for (ContentVersion cv : versionData) {
                docByFileKey.put(cv.Related_Key__c, cv);
            }
        }
        return docByFileKey;
    }

    private void describeFormSubmission() {
        for (Schema.SObjectField sobjField : Form_Submission__c.SObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fldDescribe = sobjField.getDescribe();
            if (fldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                formSubmissionRelationFieldAPIName.put(fldDescribe.getReferenceTo()[0], fldDescribe.getName());
            }
        }
    }

    private Id getIdOfObjectToUpdate(Form_Element__c formElement, Form_Submission__c formSubmission) {
        if (formSubmissionRelationFieldAPIName == null || formSubmissionRelationFieldAPIName.size() == 0) {
            describeFormSubmission();
        }

        if (
            schemaMap.get(formElement.Maps_To_Object__c) != null &&
            formSubmissionRelationFieldAPIName.get(schemaMap.get(formElement.Maps_To_Object__c)) != null
        ) {
            return formSubmission.get(
                    formSubmissionRelationFieldAPIName.get(schemaMap.get(formElement.Maps_To_Object__c))
                ) != null
                ? (Id) formSubmission.get(
                      formSubmissionRelationFieldAPIName.get(schemaMap.get(formElement.Maps_To_Object__c))
                  )
                : null;
        }
        return null;
    }

    private Boolean mapAnswers(Form_Submission__c form , List<Form_Submission_Answer__c> ansList, Map<Id, SObject> objUpdateMap, fflib_SObjectUnitOfWork uow ) {
        //for file uploads
        Map<String, ContentVersion> docByFileKey = getUploadedFiles(ansList);
        Boolean isMappingSuccessFull = true;
        for (Form_Submission_Answer__c ans : ansList) {
            try{
                doMapping(form, ans, objUpdateMap, docByFileKey);

            } catch(Exception e) {
                ans.Mapping_Error__c = e.getMessage();
                ans.Answer_Mapped__c = null;
                isMappingSuccessFull = false;
            }
            uow.registerDirty(ans);
        }

        return isMappingSuccessFull;
    }

    private void doMapping(Form_Submission__c form , Form_Submission_Answer__c ans, Map<Id, SObject> objUpdateMap, Map<String, ContentVersion> docByFileKey) {
        ans.Answer_Mapped__c = Datetime.now();
        ans.Mapping_Error__c = null;
        if(!isMappingFieldsSet(ans)) {
            return;
        }
        Id objIdToUpdate = getIdOfObjectToUpdate(ans.Form_Element__r, form);
        if (ans.Form_Element__r.Type__c == FILE_UPLOAD_DATATYPE && objIdToUpdate != null) {
            ContentDocumentLink link = mapFileUpload( docByFileKey.get((String) getAnswer(ans)), objIdToUpdate );
            contentDocToCreate.add(link);
            return;
        }

        SObject objectToUpdate = getObjectInstanceForUpdate(objIdToUpdate, objUpdateMap);
        if( ans.Form_Element__r.Maps_To_Field__c == null || ans.Form_Element__r.Maps_To_Field__c == NONE_VALUE ) {
            throw new FormSubmissionProcessAnswerBatchException('The Map to field is not set on the parent Form Element record.');
        }

        if (objectToUpdate != null) {
            objectToUpdate.put('Id', objIdToUpdate);
            objectToUpdate.put(ans.Form_Element__r.Maps_To_Field__c, getAnswer(ans));
            objUpdateMap.put(objectToUpdate.Id, objectToUpdate);
        }
        if(formUpdatingRelatedObjectIds.get(objIdToUpdate) == null){
            formUpdatingRelatedObjectIds.put(objIdToUpdate, new Set<Id>());
        }
        formUpdatingRelatedObjectIds.get(objIdToUpdate).add(form.Id);
        formUpdatingRelatedObjectIds.get(objIdToUpdate).add(ans.Id);
    }

    private ContentDocumentLink mapFileUpload( ContentVersion cv, Id relatedId) {
        return new ContentDocumentLink(
            ShareType = 'V',
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = relatedId
        );
    }

    private SObject getObjectInstanceForUpdate(Id objIdToUpdate, Map<Id, SObject> objUpdateMap) {
        if (String.isBlank(objIdToUpdate)) {
            throw new FormSubmissionProcessAnswerBatchException('The  lookup is not set on the parent Form Submission record.');
        }
        return objUpdateMap.get(objIdToUpdate) != null ? objUpdateMap.get(objIdToUpdate) : objIdToUpdate.getSObjectType().newSObject();
    }

    private Boolean isMappingFieldsSet(Form_Submission_Answer__c ans ) {
        if (ans.Form_Element__r.Maps_To_Object__c == null || ans.Form_Element__r.Maps_To_Object__c == NONE_VALUE || ans.Form_Element__r.Maps_To_Field__c == NONE_VALUE ) {
            return false;
        }
        return true;
    }

    public void execute(Database.BatchableContext bc, List<Form_Submission__c> objList) {

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Form_Submission__c.SObjectType,
                Form_Submission_Answer__c.SObjectType
            },
            new fflib_SObjectUnitOfWork.PartialDML()
        );

        Map<Id, Form_Submission__c> objListMap = new Map<Id, Form_Submission__c>(objList);

        Map<Id, SObject> objUpdateMap = new Map<Id, SObject>();

        for(Form_Submission__c submission : objList) {
            Boolean isMappingSuccessFull = mapAnswers(submission, submission.Form_Submission_Answers__r, objUpdateMap, uow);
            if(!isMappingSuccessFull) {
                submission.Status__c = FormSubmissionAPIService.STATUS_ERROR;
            }else {
                submission.Processed__c = false;
                submission.Status__c = FormSubmissionAPIService.STATUS_COMPLETE;
            }
        }
        //for event id type
        for (Id soId : objUpdateMap.keySet()) {
            if(soId.getSobjectType() != Form_Submission__c.SObjectType && soId.getSobjectType() != Form_Submission_Answer__c.SObjectType) {
                uow.addNewSObjectType(soId.getSobjectType());
            }
        }
        //now lets add the records to uow
        for (SObject so : objUpdateMap.values()) {
            uow.registerDirty(so);
        }

        if(contentDocToCreate != null && !contentDocToCreate.isEmpty()){
            uow.addNewSObjectType(ContentDocumentLink.SObjectType);
            for (ContentDocumentLink record : contentDocToCreate) {
                uow.registerNew(record);
            }
        }


        //this contains all the errors that we had while updating the objects involved in mapping
        Map<Id, String> updateResults = uow.commitWorkAndReturnSaveResult();
        System.debug('updateResults=='+updateResults);
        uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Form_Submission__c.SObjectType,
                Form_Submission_Answer__c.SObjectType
            }
        );


        if(updateResults != null && updateResults.size() > 0){
            handleErrors(objListMap, updateResults, uow);
        }
        for(Form_Submission__c submission : objList) {
            uow.registerDirty(submission);
        }

        //finally commit the work
        try{
            uow.commitWork();
        } catch( Exception e) {
            //put this base log object
        }
    }

    private void handleErrors( Map<Id,Form_Submission__c> objListMap, Map<Id, String> updateResults, fflib_SObjectUnitOfWork uow ) {
        for(Id objIdWithError : updateResults.keySet()) {
            if(formUpdatingRelatedObjectIds.get(objIdWithError) != null) {
                for(Id formId : formUpdatingRelatedObjectIds.get(objIdWithError) ) {
                    if(objListMap.get(formId) != null ){
                        objListMap.get(formId).Status__c = FormSubmissionAPIService.STATUS_ERROR;
                        objListMap.get(formId).Processed__c = false;
                    }else if(formId.getSobjectType() == Form_Submission_Answer__c.SObjectType ) {
                        uow.registerDirty(new Form_Submission_Answer__c(Id=formId, Answer_Mapped__c = null, Mapping_Error__c = updateResults.get(objIdWithError)));
                    }
                }
            }
        }
    }

    public Object getAnswer(Form_Submission_Answer__c fsa) {
        Form_Element__c fe = fsa.Form_Element__r;

        switch on fe.Type__c {
            when 'Text (30,000)', 'Multi-Select Picklist' {
                return fsa.Answer_Text_Long__c;
            }
            when 'Number' {
                return fsa.Answer_Number__c;
            }
            when 'Date' {
                return fsa.Answer_Date__c;
            }
            when 'Big List Group' {
                return fsa.Form_Big_List_Option__c;
            }
            when 'File Upload' {
                return fsa.File_Upload_Key__c;
            }
            when 'Checkbox' {
                return fsa.Answer__c == 'true' || fsa.Answer__c == '1';
            }
            when 'Hidden', 'Parameter' {
                return handleHiddenType(fe, fsa);
            }
            when else {
                return fsa.Answer__c;
            }
        }
    }

    private Object handleHiddenType(Form_Element__c fe, Form_Submission_Answer__c fsa) {
        if (fsa.Answer_Date__c != null) {
            return fsa.Answer_Date__c;
        }
        if (fsa.Answer_Number__c != null) {
            return fsa.Answer_Number__c;
        }
        if (
            fe.Maps_To_Field__c != null &&
            getFieldType(fe.Maps_To_Object__c, fe.Maps_To_Field__c) == Schema.SoapType.BOOLEAN
        ) {
            return fsa.Answer__c == '1' || fsa.Answer__c == 'true';
        }
        return fsa.Answer__c;
    }

    private Schema.SoapType getFieldType(String sobjectName, String field) {
        if (sobjectName == null || field == null) {
            return Schema.SoapType.String; // default to string
        }
        if (sobjectName != null && fieldMap.get(sobjectName) == null) {
            Schema.SObjectType sobType = schemaMap.get(sobjectName);
            if (sobType != null) {
                fieldMap.put(sobjectName, sobType.getDescribe().fields.getMap());
            }
        }
        return fieldMap.get(sobjectName).get(field).getDescribe().getSOAPType();
    }

    private List<ContentVersion> getContentVersion(Set<String> fileUploadKeys) {
        return [SELECT Related_Key__c, ContentDocumentId FROM ContentVersion WHERE Related_Key__c IN :fileUploadKeys];
    }



    public void finish(Database.BatchableContext bc) {
        // determine if we need to schedule another scheduled job by seeing how many jobs exist with the webhook scheduled job name
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :FORM_SUBMISSION_JOB + '%'
        ];

        if (jobs.size() == 1 || Test.isRunningTest()) {
            // there should be the top of the hour and one other - if more than 2 for some reason, don't schedule another one so it can catch up
            try {
                System.scheduleBatch(
                    new FormSubmissionProcessAnswerBatch(),
                    FORM_SUBMISSION_JOB + Datetime.now().addMinutes(5).minute(),
                    5,
                    1
                );
            } catch (Exception e) {
                // will get an exception if we try to schedule it at the top of the hour (minutes == 0) since that one is always scheduled
            }
        }
    }


    public void execute(SchedulableContext sc) {
        Database.executeBatch(new FormSubmissionProcessAnswerBatch(), 1);
    }
}
