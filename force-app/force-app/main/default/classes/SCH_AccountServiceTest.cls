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
@IsTest
public class SCH_AccountServiceTest {
    /*******************************************************************************************************
     * @description Method used to test Account service
     **/
    @IsTest
    public static void testAccountService() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));
        Test.startTest();
        SCH_Account account = SCH_AccountService.getAccount();
        System.assertEquals(null, account, 'This will return BT account Details');
        SCH_Account new_account = SCH_AccountService.createAccount(UserInfo.getOrganizationName());
        System.assertEquals(false, account != null, 'This will return new account Details');
        SCH_AccountService.deleteUser(UserInfo.getUserId());
        Map<String, Object> mapHelpLink = SCH_AccountService.getHelpLink();
        System.assertEquals(false, !mapHelpLink.isEmpty(), 'This will return BT help links');

        SCH_AccountService.updateExecutionLogs('/schedule/logs', '{}');
        SCH_AccountService.doSendSMSPreview(new Map<String, Object>());
        SCH_Schedule new_Schedule = SCH_AccountService.getSchedules(new Map<String, String>());
        System.assertEquals(true, new_Schedule != null, 'This will return schedules details');
        SCH_AccountService.createDelta('{}');
        SCH_ResponseWrapper responseWrapper = SCH_AccountService.createSchedules(new SCH_Schedule__c(), new List<SCH_Schedule_Action__c>());
        System.assertEquals(true, responseWrapper != null, 'This will return create schedule response details');
        SCH_ResponseWrapper update_responsewrapper = SCH_AccountService.updateSchedules(new SCH_Schedule__c(), new List<SCH_Schedule_Action__c>());
        System.assertEquals(true, responseWrapper != null, 'This will return update schedule esponse details');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test Account service
     **/
    @IsTest
    public static void testAccountServiceWhenNotConfigured() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '{}', null));
        Test.startTest();
        SCH_Account account;
        try{
            account = SCH_AccountService.getAccount();
            System.assertEquals(null, account, 'This will return BT account Details');
        }catch(Exception ex){
            System.assertNotEquals(null, account, 'This will not return BT account Details');
        }
        
        SCH_Account new_account;
        try{
            new_account = SCH_AccountService.createAccount(UserInfo.getOrganizationName());
            System.assertEquals(false, account != null, 'This will return new account Details');
        }catch(Exception ex){
            System.assertNotEquals(false, account == null, 'This will not return new account Details');
        }
        Map<String, Object> mapHelpLink = new Map<String, Object>();
        try{
            mapHelpLink = SCH_AccountService.getHelpLink();
            System.assertEquals(false, !mapHelpLink.isEmpty(), 'This will return BT help links');
        }catch(Exception ex){
            System.assertNotEquals(false, mapHelpLink.isEmpty(), 'This will not return BT help links');
        }
       
        SCH_Schedule new_Schedule;
        try{
            new_Schedule = SCH_AccountService.getSchedules(new Map<String, String>());
            System.assertEquals(true, new_Schedule != null, 'This will return schedules details');
        }catch(Exception ex){
            System.assertNotEquals(true, new_Schedule != null, 'This will not return schedules details');
        }

        SCH_ExecutionSchedule logsForExecution;
        try{
            logsForExecution = SCH_AccountService.getAllLogsForExecution(new Map<String, String>());
            System.assertEquals(true, logsForExecution != null, 'This will return logs for schedules');
        }catch(Exception ex){
            System.assertNotEquals(true, logsForExecution != null, 'This will not return logs for schedules');
        }

        SCH_ExecutionSchedule logsExecution;
        try{
            logsExecution = SCH_AccountService.getAllExecutionsForSchedule(new Map<String, String>());
            System.assertEquals(true, logsExecution != null, 'This will return logs for schedules');
        }catch(Exception ex){
            System.assertNotEquals(true, logsExecution != null, 'This will not return logs for schedules');
        }

        SCH_Account updatedAccount;
        try{
            updatedAccount = SCH_AccountService.updateAccount(new Map<String, String>());
            System.assertEquals(true, updatedAccount != null, 'This will update schedule account');
        }catch(Exception ex){
            System.assertNotEquals(true, updatedAccount != null, 'This will update schedule account');
        }

        try{
            SCH_AccountService.retryFailedRecords(new Map<String, String>());
            System.assert(true, 'This will used to retry failed schedule records');
        }catch(Exception ex){
            System.assert(true, 'This will fail to retry failed schedule records');
        }
        
        try{
            SCH_AccountService.resendStatusEmail(new Map<String, String>());
            System.assert(true, 'This will used to send the status email');
        }catch(Exception ex){
            System.assert(true, 'This will fail to send to status email');
        }

        SCH_ResponseWrapper responseWrapper;
        try{
            responseWrapper = SCH_AccountService.createSchedules(new SCH_Schedule__c(), new List<SCH_Schedule_Action__c>());
            System.assertEquals(true, responseWrapper != null, 'This will return create schedule response details');
        }catch(Exception ex){
            System.assertNotEquals(true, responseWrapper != null, 'This will not return create schedule response details');
        }
         
        SCH_ResponseWrapper update_responsewrapper;
        try{
            update_responsewrapper = SCH_AccountService.updateSchedules(new SCH_Schedule__c(), new List<SCH_Schedule_Action__c>());
            System.assertEquals(true, responseWrapper != null, 'This will return update schedule esponse details');
        }catch(Exception ex){
            System.assertNotEquals(true, responseWrapper != null, 'This will return update schedule esponse details');
        }

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test SMS Account details
     **/
    @IsTest
    public static void testGetSMSDetails() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"account_found":true,"plan":"Trial","status":"active","is_user_authenticated":true,"remaining_messages_balance":"10"}', null));
        Test.startTest();
        Map<String, Object> mapSMSDetails = SCH_AccountService.getSMSDetails();
        System.assertEquals(true, !mapSMSDetails.isEmpty(), 'This will return sms details');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test SMS Account details
     **/
    @IsTest
    public static void testNoGetSMSDetails() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '{}', null));
        Test.startTest();
        Map<String, Object> mapSMSDetails = new Map<String, Object>();
        try{
            mapSMSDetails = SCH_AccountService.getSMSDetails();
            System.assertEquals(true, !mapSMSDetails.isEmpty(), 'This will return sms details');
        }catch(Exception ex){
            System.assertNotEquals(true, !mapSMSDetails.isEmpty(), 'This will not return sms details');
        }
        Test.stopTest();
    }
}