/**
 * Blackthorn.io, Inc CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io, Inc
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io, Inc and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io, Inc
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io, Inc.
 *
 * 
 * A library of methods used as Test utility.
 *
 *
**/
@IsTest
global class SCH_TestUtilities {
    /*******************************************************************************************************
     * @description Method used to create Schedule Record
     **/
    public static SCH_Schedule__c createSchedule(String name, String baseObject, String relatedObject, boolean isInsert) {
        SCH_Schedule__c schedule = new SCH_Schedule__c();
        schedule.Name = name;
        schedule.Base_Object__c = baseObject;
        schedule.Related_Object__c = relatedObject;
        if (isInsert) {
            insert schedule;
        }
        return schedule;
    }
    /*******************************************************************************************************
     * @description Method used to create Schedule Record
     **/
    public static SCH_Schedule__c createSchedule(String name, String baseObject, String relatedObject, Map<String, String> baseFilter, Map<String, String> relatedFilter, Integer offsetValue, String offsetType, String offset, String status, boolean isInsert) {
        SCH_Schedule__c schedule = new SCH_Schedule__c();
        schedule.Name = name;
        schedule.Base_Object__c = baseObject;
        schedule.Related_Object__c = relatedObject;
        if (!baseFilter.isEmpty()) {
            String base_filter = '';
            if (baseFilter.get('filterOp') == 'contains') {
                base_filter = baseFilter.get('filterField') + ' like \'%' + baseFilter.get('filterValue') + '%\'';
            }
            schedule.Base_Object_Evaluate_Criteria__c = base_filter;
            schedule.Base_Object_Evaluate_Criteria_JSON__c = '{"logic_exp":"1","filters":[{"f_id":1,"f":"' + baseFilter.get('filterField') + '","op":"' + baseFilter.get('filterOp') + '","val":"' + baseFilter.get('filterValue') + '","f_type":"STRING","filter":"' + base_filter + '"}],"condition":"and"}';
        }
        if (!relatedFilter.isEmpty()) {
            String related_filter = '';
            if (relatedFilter.get('filterOp') == 'contains') {
                related_filter = relatedFilter.get('filterField') + ' like \'%' + relatedFilter.get('filterValue') + '%\'';
            }
            schedule.Related_Object_Evaluate_Criteria__c = related_filter;
            schedule.Related_Object_Evaluate_Criteria_JSON__c = '{"logic_exp":"1","filters":[{"f_id":1,"f":"' + relatedFilter.get('filterField') + '","op":"' + relatedFilter.get('filterOp') + '","val":"' + relatedFilter.get('filterValue') + '","f_type":"STRING","filter":"' + related_filter + '"}],"condition":"and"}';
        }

        schedule.Offset__c = offset;
        schedule.Offset_Type__c = offsetType;
        schedule.Offset_Value__c = offsetValue;
        schedule.Schedule_Date_Time_Field__c = 'CreatedDate';
        schedule.Status__c = status;
        schedule.Type__c = 'Object';
        if (isInsert) {
            insert schedule;
        }
        return schedule;
    }

    /*******************************************************************************************************
     * @description Method used to create Schedule Action Record
     **/
    public static SCH_Schedule_Action__c createScheduleEmailAction(String name, String emailFromAddress, String emailToAddress, String emailTemplateId, String scheduleId, boolean isInsert) {
        SCH_Schedule_Action__c scheduleAction = new SCH_Schedule_Action__c();
        scheduleAction.Name = name;
        scheduleAction.Schedule__c = scheduleId;
        scheduleAction.Action__c = 'Email';
        scheduleAction.Email_From_Address__c = emailFromAddress;
        scheduleAction.Email_To_Address_Field__c = emailToAddress;
        scheduleAction.Email_Template_Id__c = emailTemplateId;
        if (isInsert) {
            insert scheduleAction;
        }
        return scheduleAction;
    }

    /*******************************************************************************************************
     * @description Method used to create Schedule Action Record
     **/
    public static SCH_Schedule_Action__c createScheduleSMSAction(String name, String smsFromNumber, String smsToNumber, String smsmessage, String scheduleId, boolean isInsert) {
        SCH_Schedule_Action__c scheduleAction = new SCH_Schedule_Action__c();
        scheduleAction.Name = name;
        scheduleAction.Schedule__c = scheduleId;
        scheduleAction.Action__c = 'SMS';
        scheduleAction.SMS_From_Number__c = smsFromNumber;
        scheduleAction.SMS_Message__c = smsmessage;
        if (isInsert) {
            insert scheduleAction;
        }
        return scheduleAction;
    }

    /*******************************************************************************************************
     * @description Method used to create Email Template Record
     **/
    public static EmailTemplate createEmailTemplate(String name, String folderId, boolean isInsert) {
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Name = name;
        emailTemplate.isActive = true;
        emailTemplate.Name = name;
        emailTemplate.DeveloperName = name;
        emailTemplate.TemplateType = 'text';
        emailTemplate.FolderId = folderId;
        if (isInsert) {
            insert emailTemplate;
        }
        return emailTemplate;
    }

    /*******************************************************************************************************
     * @description Method used to create Account Record
     **/
    public static Account createAccount(String name, boolean isInsert) {
        Account acc = new Account();
        acc.Name = name;
        if (isInsert) {
            insert acc;
        }
        return acc;
    }

    /*******************************************************************************************************
     * @description Method used to create Contact Record
     **/
    public static Contact createContact(String name, String email, String accountId, boolean isInsert) {
        Contact con = new Contact();
        con.LastName = name;
        con.Email = email;
        con.AccountId = accountId;
        if (isInsert) {
            insert con;
        }
        return con;
    }

    /*******************************************************************************************************
     * @description Used to set dynamic mock response
     **/
    global class MockSingleRequest implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String method;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public MockSingleRequest(Integer code, String status, String body, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            method = null;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public void setMethod(String method) {
            this.method = method;
        }

        public String getMethod() {
            return method;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(code);
            response.setStatus(status);
            if (bodyAsBlob != null)
                response.setBodyAsBlob(bodyAsBlob);
            else
                response.setBody(bodyAsString);
            System.debug(loggingLevel.WARN, bodyAsString);
            if (responseHeaders != null) {
                for (String key: responseHeaders.keySet()) {
                    response.setHeader(key, responseHeaders.get(key));
                }
            }
            return response;
        }
    }
}