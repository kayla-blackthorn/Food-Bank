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
 * This is the main interface between Salesforce and the BT API.
 *
 *
 **/
public with sharing class SCH_Client {
    private String accountNumber;
    private SCH_RequestBuilder SCH_RequestBuilder;
    private Map < String, String > params;

    /**
     *  @param  accountNumber - the Blackthorn Scheduler account number
     *  @param  apiKey        - the Blackthorn Scheduler api key
     *
     *  Constructor
     *
     **/
    public SCH_Client(String accountNumber, String apiKey) {
        this.accountNumber = accountNumber;
        params = new Map < String, String > ();

        SCH_RequestBuilder = new SCH_RequestBuilder();
        SCH_RequestBuilder.setApiToken(accountNumber);
        SCH_RequestBuilder.setApiKey(apiKey);
    }

    /*******************************************************************************************************
     * @description Method used to create new account for smart schedule
     * @return SCH_Account
     * @param name: used to create account
     **/
    public SCH_Account createAccount(String name) {
        Organization org = SCH_BtBaseUtils.fetchCompanyInfo();

        params.put('name', name);
        params.put('org_type', org.IsSandbox ? 'sandbox' : 'production');
        params.put('org_id', UserInfo.getOrganizationId());
        params.put('primary_email_address', UserInfo.getUserEmail());

        return SCH_RequestBuilder.post('/accounts', params).getAccount();
    }

    /*******************************************************************************************************
     * @description Method used to get account details for smart schedule
     * @return SCH_Account
     * @param none
     **/
    public SCH_Account getAccount() {
        return SCH_RequestBuilder.get('/accounts/' + accountNumber, params).getAccount();
    }

    /*******************************************************************************************************
     * @description Method used to get Help Links
     * @return Map<String, String>
     * @param none
     **/
    public Map < String, Object > getHelpLink() {
        return SCH_RequestBuilder.get('/help_links?include_picklist=true', params).getHelpLink(); 
    }

     /*******************************************************************************************************
     * @description Method used to get schedules from API
     * @return SCH_Schedule
     * @param params: parameters to filter schedule records
     **/
    public SCH_Schedule getSchedules(Map < String, String > params) {
        return SCH_RequestBuilder.get('/accounts/' + accountNumber + '/schedules', params).getSchedules();
    }

    /*******************************************************************************************************
     * @description Method used to create schedule with schedule actions
     * @return SCH_ResponseWrapper
     * @param schedule: SCH_Schedule__c record
     **/
    public SCH_ResponseWrapper createSchedule(SCH_Schedule__c schedule) {
        params.put('schedule_body', JSON.serialize(new SCH_Schedule.Schedule(schedule)));
        return SCH_RequestBuilder.post('/accounts/' + accountNumber + '/schedules', params);
    }

    /*******************************************************************************************************
     * @description Method used to update schedule and schedule actions
     * @return SCH_ResponseWrapper
     * @param schedule: SCH_Schedule__c record
     **/
    public SCH_ResponseWrapper updateSchedule(SCH_Schedule__c schedule) {
        params.put('schedule_body', JSON.serialize(new SCH_Schedule.Schedule(schedule)));
        return SCH_RequestBuilder.put('/accounts/' + accountNumber + '/schedules/' + schedule.Id, params);
    }

    /*******************************************************************************************************
     * @description Method used to get all Logs for a Execution
     * @return SCH_ExecutionSchedule
     * @param params: filter the records of what we actually want
     **/
    public SCH_ExecutionSchedule getAllLogsForExecution(Map < String, String > params) {
        return SCH_RequestBuilder.get('/accounts/' + accountNumber + '/schedules/' + params.remove('salesforce_id') + '/executions/' + params.remove('execution_id') + '/logs', params).getExecutionSchedules();
    }

    /*******************************************************************************************************
     * @description Method used to Retry all Failed Records
     * @return none
     * @param params: filter the records of what we actually want
     **/
    public void retryFailedRecords(Map < String, String > params) {
        SCH_RequestBuilder.post('/accounts/' + accountNumber + '/executions/retry_failed_records', params);
    }

    /*******************************************************************************************************
     * @description Method used to resend status email
     * @return none
     * @param params: filter the records of what we actually want
     **/
    public void resendStatusEmail(Map < String, String > params) {
        SCH_RequestBuilder.post('/accounts/' + accountNumber + '/executions/resend_status_email', params);
    }

    /*******************************************************************************************************
     * @description Method used to get all Executions for schedule
     * @return SCH_ExecutionSchedule
     * @param params: filter the records of what we actually want
     **/
    public SCH_ExecutionSchedule getAllExecutionsForSchedule(Map < String, String > params) {
        return SCH_RequestBuilder.get('/accounts/' + accountNumber + '/schedules/' + params.remove('salesforce_id') + '/executions', params).getExecutionSchedules();
    }

    /**
     *  @param  userId - the salesforce id of the user to delete.
     *
     *  Delete a user from this account.
     *
     **/
    public void deleteUser(String userId) {
        SCH_RequestBuilder.del('/accounts/' + accountNumber + '/users/' + userId, params);
    }

    /*******************************************************************************************************
     * @description Method used to create dynamic sObject apex trigger
     * @return none
     * @param sObjectName: sObject API Name which used to create sObject apex trigger
     * @param triggerName: sObject apex trigger name
     * @param body: sObject apex trigger body
     **/
    public void createApexTrigger(String sObjectName, String triggerName, String body) {
        params.put('sobject_name', sObjectName);
        params.put('trigger_name', triggerName);
        params.put('trigger_body', body);
        SCH_RequestBuilder.post('/sfdc/' + accountNumber + '/callout-trigger', params);
    }

     /*******************************************************************************************************
     * @description Method used to get sms account details
     * @return Map<String, Object>
     * @param none
     **/
    public Map < String, Object > getSMSDetails() {
        return SCH_RequestBuilder.get('/accounts/' + accountNumber + '/sms_availability', params).getSMSDetails();
    }

    /*******************************************************************************************************
     * @description Method used to send preview for SMS Message
     * @return none
     * @param data: sms message data to send preview
     **/
    public void doSendSMSPreview(Map < String, Object > data) {
        params.put('from_number', data.get('from_number') + '');
        if (data.get('target_record_id') != null) {
            params.put('target_record_id', data.get('target_record_id') + '');
        }
        if (data.get('sms_template_id') != null) {
            params.put('sms_template_id', data.get('sms_template_id') + '');
        }
        if (data.get('sms_attachment_id') != null) {
            params.put('sms_attachment_id', data.get('sms_attachment_id') + '');
        }
        String message = data.get('sms_body') + '';
        params.put('sms_body', message);
        params.put('to_number', data.containsKey('to_number') ? JSON.serialize(data.get('to_number')) : '[]');
        SCH_RequestBuilder.post('/accounts/' + accountNumber + '/send_sms_and_preview', params);
    }

    /*******************************************************************************************************
     * @description Method used to create delta records
     * @return none
     * @param deltaRequest: json data to create delta records
     **/
    public void createDeltaRecords(String deltaRequest) {
        params.put('direct_request_body', deltaRequest);
        SCH_RequestBuilder.post('/accounts/' + accountNumber + '/schedules/delta_records_async', params);
    }

    /*******************************************************************************************************
     * @description Method used to update Execution logs
     * @return none
     * @param relativeEndPoint: API endpoint to send the data
     * @param jsonBody: List of delta records
     **/
    public void updateExecutionLogs(String relativeEndPoint, String jsonBody) {
        params.put('direct_request_body', jsonBody);
        SCH_RequestBuilder.post('/accounts/' + accountNumber + relativeEndPoint,
            params);
    }

    /*******************************************************************************************************
     * @description Method used to update Execution logs
     * @return none
     * @param params: filter the records of what we actually want
     **/
    public SCH_Account updateAccount(Map<String, String> bParams){
        return SCH_RequestBuilder.put('/accounts/' + accountNumber, bParams).updateAccount();
    } 

}