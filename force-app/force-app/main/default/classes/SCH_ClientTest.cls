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
@IsTest
public class SCH_ClientTest {

    /*******************************************************************************************************
     * @description Method used to test client service
     **/
    @IsTest
    public static void testClientService() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);

        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));

        Test.startTest();
        SCH_Client client = new SCH_Client('1234', '1234');
        SCH_Account account = client.createAccount('test account');
        System.assertEquals(true, account != null, 'This will return Account details');
        account = client.getAccount();
        System.assertEquals(true, account != null, 'This will return Account details');
        Map<String, Object> mapHelpLink = client.getHelpLink();
        System.assertEquals(false, !mapHelpLink.isEmpty(), 'This will return help link details');
        SCH_Schedule scheduleWrapper = client.getSchedules(new Map<String, String>());
        System.assertEquals(true, scheduleWrapper != null, 'This will return Schedule details');
        SCH_ResponseWrapper oResponerCreateSchedule = client.createSchedule(schedule);
        System.assertEquals(true, oResponerCreateSchedule != null, 'This will return Schedule details');
        SCH_ResponseWrapper oResponerUpdateSchedule = client.updateSchedule(schedule);
        System.assertEquals(true, oResponerUpdateSchedule != null, 'This will return Schedule details');
        client.deleteUser(UserInfo.getUserId());
        client.createApexTrigger('Account', 'AccountTestTrigger', 'trigger AccountTestTrigger on Account (after insert, after update, after delete, after undelete) {bt_base.SCH_TriggerHandler.processRecords(trigger.operationType, trigger.new, trigger.oldMap);}');
        Map<String, Object> mapSMSDetails = client.getSMSDetails();
        System.assertEquals(false, !mapSMSDetails.isEmpty(), 'This will return Schedule details');
        Map<String, Object> data = new Map<String, Object>();
        data.put('from_number', '+918574963210');
        data.put('target_record_id', schedule.Id);
        data.put('sms_template_id', schedule.Id);
        data.put('sms_attachment_id', schedule.Id);
        data.put('sms_body', 'test demo');
        data.put('to_number', '+918574963211');
        client.doSendSMSPreview(data);
        client.createDeltaRecords('Test');
        client.updateExecutionLogs('test', '{}');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test client service
     **/
    @IsTest
    public static void testInvalidClientService() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);

        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '{}', null));

        Test.startTest();
        SCH_Client client = new SCH_Client('1234', '1234');
        

        SCH_Account account;
        try{
            account = client.createAccount('test account');
            System.assertEquals(true, account != null, 'This will return Account details');
        }catch(Exception ex){
            System.assertNotEquals(true, account != null, 'This will not return Account details');
        }
        try{
            account = client.getAccount();
            System.assertEquals(true, account != null, 'This will return Account details');
        }catch(Exception ex){
            System.assertNotEquals(true, account != null, 'This will not return Account details');
        } 
        Map<String, Object> mapHelpLink = new Map<String, Object>();
        try{
            mapHelpLink = client.getHelpLink();
            System.assertEquals(false, !mapHelpLink.isEmpty(), 'This will return help link details');
        }catch(Exception ex){
            System.assertNotEquals(false, mapHelpLink.isEmpty(), 'This will not return help link details');
        }
        SCH_Schedule scheduleWrapper;
        try{
            scheduleWrapper = client.getSchedules(new Map<String, String>());
            System.assertEquals(true, scheduleWrapper != null, 'This will return Schedule details');
        }catch(Exception ex){
            System.assertNotEquals(true, scheduleWrapper != null, 'This will not return Schedule details');
        }
        SCH_ResponseWrapper oResponerCreateSchedule;
        try{
            oResponerCreateSchedule = client.createSchedule(schedule);
            System.assertEquals(true, oResponerCreateSchedule != null, 'This will return Schedule details');
        }catch(Exception ex){
            System.assertNotEquals(true, oResponerCreateSchedule != null, 'This will not return Schedule details');
        } 
        SCH_ResponseWrapper oResponerUpdateSchedule;
        try{
            oResponerUpdateSchedule = client.updateSchedule(schedule);
            System.assertEquals(true, oResponerUpdateSchedule != null, 'This will return Schedule details');
        }catch(Exception ex){
            System.assertNotEquals(true, oResponerUpdateSchedule != null, 'This will not return Schedule details');
        } 
        
        Map<String, Object> mapSMSDetails = new Map<String, Object>();
        try{
            mapSMSDetails = client.getSMSDetails();
            System.assertEquals(false, !mapSMSDetails.isEmpty(), 'This will return Schedule details');
        }catch(Exception ex){
            System.assertNotEquals(false, mapSMSDetails.isEmpty(), 'This will not return Schedule details');
        }
        Test.stopTest();
    }

}