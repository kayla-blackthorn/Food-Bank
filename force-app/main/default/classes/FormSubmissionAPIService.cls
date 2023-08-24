global with sharing class FormSubmissionAPIService {
    global class FormSubmissionAPIServiceException extends Exception {
    }

    public static final String STATUS_TOPROCESS = 'To Process';
    public static final String STATUS_ERROR = 'Error';
    public static final String STATUS_COMPLETE = 'Completed';

    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    Schema.DescribeSObjectResult formSubmissionDescribeResult;
    Schema.DescribeSObjectResult formAnsSubmissionDescribeResult;
    Map<Schema.SObjectType, String> objFieldAPIName = new Map<Schema.SObjectType, String>();

    Map<Id, Form_Element__c> formElementMap = new Map<Id, Form_Element__c>();
    Map<String, Form_Submission_Answer__c> answerMap = new Map<String, Form_Submission_Answer__c>();
    Map<String, Map<String, Schema.SObjectField>> fieldMap = new Map<String, Map<String, Schema.SObjectField>>();

    /**
     * @description       This method create form submission record & mark it for processing
     * @param  inputForms Payload to create the record
     * @return            Payload with form submission id set
     */
    global FormSubmissionAPIPayload[] createFormSubmission(FormSubmissionAPIPayload[] inputForms) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Form_Submission__c.SObjectType, Form_Submission_Answer__c.SObjectType }
        );
        for (FormSubmissionAPIPayload payload : inputForms) {
            if (String.isBlank(payload.key)) {
                payload.key = Helpers.generateKey();
            }
        }
        Map<String, Form_Submission__c> formSubResponse = processFormSubmission(inputForms, uow);
        uow.commitWork();
        for (FormSubmissionAPIPayload payload : inputForms) {
            payload.formSubmissionId = formSubResponse.get(
                    payload.sobjectKey != null ? payload.sobjectKey : payload.key
                )
                .Id;
        }

        return inputForms;
    }

    private Map<String, Form_Submission__c> getExistingSubmissions(Set<String> submissionKeys) {
        Map<String, Form_Submission__c> existingSubmission = new Map<String, Form_Submission__c>();
        if (submissionKeys.size() > 0) {
            for (Form_Submission__c sub : new FormSubmissionSelector().getSubmissionByKey(submissionKeys)) {
                existingSubmission.put(sub.Key__c, sub);
            }
        }
        return existingSubmission;
    }

    private void getExistingAnswers(Set<Id> submissionIds) {
        //for existing form submission build the answer map
        if (submissionIds != null && !submissionIds.isEmpty()) {
            for (
                Form_Submission_Answer__c fsa : new FormSubmissionAnswerSelector()
                    .getAnswerByFormSubmissionId(submissionIds)
            ) {
                answerMap.put(fsa.Form_Submission__r.Key__c + '-' + fsa.Form_Element__c, fsa);
            }
        }
    }

    private Map<Id, Form_Element__c> getFormElementMap(Set<Id> formElementIds) {
        formElementIds.remove(null);
        return formElementIds.size() > 0
            ? new Map<Id, Form_Element__c>(
                  (List<Form_Element__c>) new FormElementSelector().selectSObjectsById(formElementIds)
              )
            : new Map<Id, Form_Element__c>();
    }

    /**
     * @description processFormSubmission This method process the form that comes in as part of the checkout api from events/commerce it will build a list of form submissions & map the answers
     * @param  inputForms List of form Payload for processing the form answer to create form submission & answers
     * @param  uow        Unit of work to register the data so that commit work could be called by the caller
     * @return            Map of key => form submission record so that caller can match the record
     */
    public Map<String, Form_Submission__c> processFormSubmission(
        FormSubmissionAPIPayload[] inputForms,
        fflib_SObjectUnitOfWork uow
    ) {
        Map<String, Form_Submission__c> response = new Map<String, Form_Submission__c>();

        Set<Id> formElementIds = new Set<Id>();
        Set<String> submissionKeys = new Set<String>();

        for (FormSubmissionAPIPayload payload : inputForms) {
            if (String.isNotBlank(payload.key)) {
                submissionKeys.add(payload.key);
            }

            if (payload.formElements != null && !payload.formElements.isEmpty()) {
                for (FormSubmissionAPIPayload.FormElement element : payload.formElements) {
                    formElementIds.add(element.formElementId);
                }
            }
        }

        Map<String, Form_Submission__c> existingSubmission = getExistingSubmissions(submissionKeys);
        getExistingAnswers(new Map<Id, Form_Submission__c>(existingSubmission.values()).keySet());
        //build the form element map
        formElementMap = getFormElementMap(formElementIds);

        for (FormSubmissionAPIPayload payload : inputForms) {
            Form_Submission__c existing = existingSubmission.get(payload.key) != null
                ? existingSubmission.get(payload.key)
                : null;
            Form_Submission__c submission = processFormSubmission(payload, existing, uow);
            response.put(payload.sobjectKey != null ? payload.sobjectKey : submission.Key__c, submission);
        }
        return response;
    }

    private Form_Submission__c processFormSubmission(
        FormSubmissionAPIPayload inputForm,
        Form_Submission__c formSub,
        fflib_SObjectUnitOfWork uow
    ) {
        if (formSub == null) {
            formSub = new Form_Submission__c(
                Key__c = inputForm.key != null ? inputForm.key : Helpers.generateKey(),
                Status__c = STATUS_TOPROCESS
            );
        }
        formSub.Payload__c = JSON.serialize(inputForm);
        formSub.Form__c = inputForm.formId;
        formSub.Error__c = '';
        setFormLookupRelation(formSub, inputForm.relatedIds);
        //now we need to set the information regarding the related ids that has been passed overs
        uow.registerUpsert(formSub);

        processFormAnswers(inputForm, formSub, uow);
        return formSub;
    }

    private void processFormAnswers(
        FormSubmissionAPIPayload inputForm,
        Form_Submission__c formSub,
        fflib_SObjectUnitOfWork uow
    ) {
        if (inputForm.formElements == null || inputForm.formElements.isEmpty()) {
            return;
        }

        for (FormSubmissionAPIPayload.FormElement ele : inputForm.formElements) {
            if (String.isBlank(ele.formElementId)) {
                continue;
            }

            Form_Submission_Answer__c fsa = answerMap.get(inputForm.key + '-' + ele.formElementId) != null
                ? answerMap.get(inputForm.key + '-' + ele.formElementId)
                : new Form_Submission_Answer__c();
            try {
                validateAnswer(ele, formElementMap.get(ele.formElementId));
                buildFormSubmissionAnswer(ele, formElementMap.get(ele.formElementId), fsa);
                setFormAnswerLookupRelation(fsa, ele.relatedIds);
                //associate this with parent
            } catch (Exception e) {
                fsa.Mapping_Error__c = e.getMessage();
            }
            if (formSub.Form__c == null) {
                formSub.Form__c = formElementMap.get(ele.formElementId).Form__c;
            }

            fsa.Form_Element__c = ele.formElementId;
            fsa.Question__c = formElementMap.get(ele.formElementId).Question__c;

            uow.registerUpsert(fsa);
            uow.registerRelationship(fsa, Form_Submission_Answer__c.Form_Submission__c, formSub);
        }
    }

    private void buildFormSubmissionAnswer(
        FormSubmissionAPIPayload.FormElement ele,
        Form_Element__c fe,
        Form_Submission_Answer__c fsa
    ) {
        if (fe.Maps_To_Object__c != null && fieldMap.get(fe.Maps_To_Object__c) == null && schemaMap.get(fe.Maps_To_Object__c) != null) {
            fieldMap.put(fe.Maps_To_Object__c, schemaMap.get(fe.Maps_To_Object__c).getDescribe().fields.getMap());
        }

        switch on fe.Type__c {
            when 'Text (30,000)', 'Multi-Select Picklist' {
                fsa.Answer_Text_Long__c = ele.answer?.unescapeHtml4();
            }
            when 'Number' {
                fsa.Answer_Number__c = ele.answer != null ? Decimal.valueOf(ele.answer) : null;
            }
            when 'Date' {
                if (ele.answer != null) {
                    parseDate(ele.answer, fsa);
                }
            }
            when 'Big List Group' {
                fsa.Form_Big_List_Option__c = ele.answer;
            }
            when 'File Upload' {
                fsa.File_Upload_Key__c = ele.answer;
            }
            when 'Hidden', 'Parameter' {
                handleHiddenType(ele.answer, fe, fsa);
            }
            when else {
                fsa.Answer__c = ele.answer?.unescapeHtml4();
            }
        }
    }

    private void handleHiddenType(String ans, Form_Element__c fe, Form_Submission_Answer__c fsa) {
        Schema.SObjectField fld = fieldMap.get(fe.Maps_To_Object__c)?.get(fe.Maps_To_Field__c);
        Schema.SoapType dtType = fld?.getDescribe().getSOAPType();
        if (ans != null && dtType != null) {
            if ((dtType == Schema.SoapType.DOUBLE || dtType == Schema.SoapType.Integer)) {
                getAnswerAsNumber(ans, fsa);
            } else if (dtType == Schema.SoapType.Date || dtType == Schema.SoapType.DateTime) {
                parseDate(ans, fsa);
            }
            fsa.Answer__c =ans?.unescapeHtml4();
        }
    }

    private void getAnswerAsNumber(String ans, Form_Submission_Answer__c fsa) {
        try{
            fsa.Answer_Number__c = Decimal.valueOf(ans);
        }catch(Exception e) {
            fsa.Mapping_Error__c ='Incorrect value provided for number datatype';
        }
    }

    @TestVisible
    private void validateAnswer(FormSubmissionAPIPayload.FormElement ele, Form_Element__c fe) {
        // if it's a number type, isn't null, and is not numeric
        if (fe.Type__c == 'Number' && ele.answer != null && !ele.answer.isNumeric()) {
            // try to convert it into a decimal to see if it's actually a number
            // the reason for the extra check is that isNumerc doesn't handle negatives or decimal points
            try {
                Decimal finalVal = Decimal.valueOf(ele.answer);
            } catch (Exception e) {
                throw new FormSubmissionAPIServiceException(
                    'Invalid data provided for Form Element "' +
                        ele.formElementId +
                        '", expected a numeric value, received a string. Value: ' +
                        ele.answer
                );
            }
        }

        if (fe.Type__c == 'Date' && ele.answer != null && !isValidDate(ele.answer)) {
            throw new FormSubmissionAPIServiceException(
                'Invalid Date provided for Form Element "' + ele.formElementId + '". Value: ' + ele.answer
            );
        }

        if (
            fe.Type__c == 'Big List Group' &&
            ele.answer != null &&
            !isValidSalesforceId(ele.answer, Form_Big_List_Option__c.SObjectType)
        ) {
            throw new FormSubmissionAPIServiceException(
                'The Big List Option provided for Form Element "' +
                    ele.formElementId +
                    '" is invalid. Value: ' +
                    ele.answer
            );
        }
    }

    @TestVisible
    private Boolean isValidDate(String dateValue) {
        try {
            // platform will pass in this format: 2015-09-13
            Date d = Date.valueOf(dateValue);
        } catch (TypeException e) {
            return false;
        }
        return true;
    }

    @TestVisible
    private Boolean isValidSalesforceId(String sfdcId, Schema.SObjectType objType) {
        // id.valueOf will throw exception if this is not an id
        if (sfdcId instanceof Id && objType == Id.valueof(sfdcId).getSObjectType()) {
            return true;
        }
        return false; // ID is not valid
    }

    @TestVisible
    private void setFormLookupRelation(Form_Submission__c formSub, Set<String> relatedIds) {
        if (relatedIds == null || relatedIds.isEmpty()) {
            //we need to set all the related data here
            return;
        }
        if (formSubmissionDescribeResult == null) {
            describeFormSubmission();
        }

        for (String relatedId : relatedIds) {
            if (String.isNotBlank(relatedId)) {
                Id idValue = Id.valueOf(relatedId);
                if (objFieldAPIName.get(idValue.getSobjectType()) != null) {
                    formSub.put(objFieldAPIName.get(idValue.getSobjectType()), relatedId);
                }
            }
        }
    }

    @TestVisible
    private void setFormAnswerLookupRelation(Form_Submission_Answer__c formSub, Set<String> relatedIds) {
        if (relatedIds == null || relatedIds.isEmpty()) {
            //we need to set all the related data here
            return;
        }
        if (formAnsSubmissionDescribeResult == null) {
            describeFormAnswerSubmission();
        }

        for (String relatedId : relatedIds) {
            if (String.isNotBlank(relatedId)) {
                Id idValue = Id.valueOf(relatedId);
                if (objFieldAPIName.get(idValue.getSobjectType()) != null) {
                    formSub.put(objFieldAPIName.get(idValue.getSobjectType()), relatedId);
                }
            }
        }
    }

    private void parseDate(String ans, Form_Submission_Answer__c fsa) {
        try {
            fsa.Answer_Date__c = Date.valueOf(ans);
        } catch (Exception e) {
            parseDateStr(ans, fsa);
            fsa.Mapping_Error__c = 'Unable to parse date.Incorrect format provided.';
        }
    }

    @TestVisible
    private void parseDateStr(String ans, Form_Submission_Answer__c fsa) {
        List<String> dt = ans.split('-');
        if (dt.size() == 3) {
            Date d = Date.newInstance(Integer.valueof(dt[0]), Integer.valueof(dt[1]), Integer.valueof(dt[2]));
            fsa.Answer_Date__c = d;
            fsa.Mapping_Error__c = null;
        }
    }

    private void describeFormSubmission() {
        formSubmissionDescribeResult = Form_Submission__c.SObjectType.getDescribe();
        for (Schema.SObjectField sobjField : formSubmissionDescribeResult.fields.getMap().values()) {
            Schema.DescribeFieldResult fldDescribe = sobjField.getDescribe();
            if (fldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                objFieldAPIName.put(fldDescribe.getReferenceTo()[0], fldDescribe.getName());
            }
        }
    }
    private void describeFormAnswerSubmission() {
        formAnsSubmissionDescribeResult = Form_Submission_Answer__c.SObjectType.getDescribe();
        for (Schema.SObjectField sobjField : formAnsSubmissionDescribeResult.fields.getMap().values()) {
            Schema.DescribeFieldResult fldDescribe = sobjField.getDescribe();
            if (fldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                objFieldAPIName.put(fldDescribe.getReferenceTo()[0], fldDescribe.getName());
            }
        }
    }
    
}
