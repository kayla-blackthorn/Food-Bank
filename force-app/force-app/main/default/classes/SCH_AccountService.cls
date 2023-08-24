/**
 * Blackthorn.io ENTERPRISES CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io Enterprises, LLC
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io Enterprises, LLC and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io Enterprises, LLC
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io Enterprises, LLC.
 *
 * 
 * A library of service methods for performing operations on the customer's account
 * through the Blackthorn API. 
 *
 *
 **/
public with sharing class SCH_AccountService {
    private static String apiKey = SCH_BtBaseUtils.getCustomSettings().API_Key__c;
    private static String accountNumber = SCH_BtBaseUtils.getCustomSettings().Account_Number__c;

    /*******************************************************************************************************
     * @description Method used to create new account for smart schedule
     * @return SCH_Account
     * @param name: used to create account
     **/
    public static SCH_Account createAccount(String name) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.createAccount(name);
    }

    /*******************************************************************************************************
     * @description Method used to get account details for smart schedule
     * @return SCH_Account
     * @param none
     **/
    public static SCH_Account getAccount() {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return (isConfigured() ? SCH_Client.getAccount() : null);
    }

    /*******************************************************************************************************
     * @description Method used to delete account for smart schedule
     * @return none
     * @param userId
     **/
    public static void deleteUser(String userId) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.deleteUser(userId);
    }

    /*******************************************************************************************************
     * @description Method used to create schedule with schedule actions
     * @return SCH_ResponseWrapper
     * @param schedule: SCH_Schedule__c record
     * @param actions: List<SCH_Schedule_Action__c> records
     **/
    public static SCH_ResponseWrapper createSchedules(SCH_Schedule__c schedule, List<SCH_Schedule_Action__c> actions) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.createSchedule(schedule);
    }

    /*******************************************************************************************************
     * @description Method used to update schedule and schedule actions
     * @return SCH_ResponseWrapper
     * @param schedule: SCH_Schedule__c record
     * @param actions: List<SCH_Schedule_Action__c> records
     **/
    public static SCH_ResponseWrapper updateSchedules(SCH_Schedule__c schedule, List<SCH_Schedule_Action__c> actions) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.updateSchedule(schedule);
    }

    /*******************************************************************************************************
     * @description Method used to create delta records
     * @return none
     * @param deltaRequest: json data to create delta records
     **/
    public static void createDelta(String deltaRequest) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.createDeltaRecords(deltaRequest);
    }

    /*******************************************************************************************************
     * @description Method used to get schedules from API
     * @return SCH_Schedule
     * @param params: parameters to filter schedule records
     **/
    public static SCH_Schedule getSchedules(Map<String, String> params) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.getSchedules(params);
    }

    /*******************************************************************************************************
     * @description Method used to get sms account details
     * @return Map<String, Object>
     * @param none
     **/
    public static Map<String, Object> getSMSDetails() {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        Map<String, Object> smsDetails = SCH_Client.getSMSDetails();
        Map<String, Object> result = new Map<String, Object>();
        if (smsDetails != null && smsDetails.containsKey('account_found') && smsDetails.get('account_found') instanceof Boolean) {
            Boolean accountFound = (Boolean) smsDetails.get('account_found');

            String plan = smsDetails.get('plan') + '';
            String status = smsDetails.get('status') + '';
            Boolean userAuthenticated = false;
            if (smsDetails.containsKey('is_user_authenticated') && smsDetails.get('is_user_authenticated') instanceof Boolean) {
                userAuthenticated = (Boolean) smsDetails.get('is_user_authenticated');
            }

            result.put('accountRegistered', accountFound);
            // result.put('isConfigured', userAuthenticated );
            result.put('isConfigured', plan != 'Trial' && userAuthenticated && status == 'Active');
            result.put('smsBalance', smsDetails.get('remaining_messages_balance'));
            // validating BT Messaging App package version.
            String smsVersion = smsDetails.get('simple_sms_version') == null ? '' : String.valueOf(smsDetails.get('simple_sms_version'));
            String validSmsVersion = smsDetails.get('required_simple_sms_version') == null ? '' : String.valueOf(smsDetails.get('required_simple_sms_version'));
            if(accountFound == true){
                result.put('upgradeApp', !(new SCH_BtBaseUtils().validateVersion(smsVersion, validSmsVersion)));
            }
            result.put('smsDetails', smsDetails);
        }
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to send preview for SMS Message
     * @return none
     * @param data: sms message data to send preview
     **/
    public static void doSendSMSPreview(Map<String, Object> data) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.doSendSMSPreview(data);
    }

    /*******************************************************************************************************
     * @description Method used to update Execution logs
     * @return none
     * @param relativeEndPoint: API endpoint to send the data
     * @param jsonBody: List of delta records
     **/
    public static void updateExecutionLogs(String relativeEndPoint, String jsonBody) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.updateExecutionLogs(relativeEndPoint, jsonBody);
    }

    /*******************************************************************************************************
     * @description Method used to get Help Links
     * @return Map<String, String>
     * @param none
     **/
    public static Map<String, Object> getHelpLink() {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.getHelpLink();
    }

    /*******************************************************************************************************
     * @description Method used to check Bt Schedule account is configured or not
     * @return boolean
     * @param none
     **/
    public static boolean isConfigured() {
        boolean isScheduleConfigured = false;
        if (String.isNotBlank(apiKey) && String.isNotBlank(accountNumber)) {
            isScheduleConfigured = true;
        }
        return isScheduleConfigured;
    }

    /*******************************************************************************************************
     * @description Method used to get all Executions for schedule
     * @return SCH_ExecutionSchedule
     * @param params: filter the records of what we actually want
     **/
    public static SCH_ExecutionSchedule getAllLogsForExecution(Map<String, String> params) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.getAllLogsForExecution(params);
    }

    /*******************************************************************************************************
     * @description Method used to get all Executions for schedule
     * @return SCH_ExecutionSchedule
     * @param params: filter the records of what we actually want
     **/
    public static SCH_ExecutionSchedule getAllExecutionsForSchedule(Map<String, String> params) {
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.getAllExecutionsForSchedule(params);
    }

    /*******************************************************************************************************
     * @description Method used to get all Logs for schedule
     * @return SCH_ExecutionSchedule
     * @param params: filter the records of what we actually want
     **/
    public static SCH_Account updateAccount(Map<String, String> params){
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        return SCH_Client.updateAccount(params);
    }

    /*******************************************************************************************************
     * @description Method used to Retry all Failed Records
     * @return none
     * @param params: filter the records of what we actually want
     **/
    public static void retryFailedRecords(Map<String, String> params){
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.retryFailedRecords(params);
    }

    /*******************************************************************************************************
     * @description Method used to resend status email
     * @return none
     * @param params: filter the records of what we actually want
     **/
    public static void resendStatusEmail(Map<String, String> params){
        SCH_Client SCH_Client = new SCH_Client(accountNumber, apiKey);
        SCH_Client.resendStatusEmail(params);
    }

}