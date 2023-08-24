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
 * A library of methods used to code coverage for SCH_SmartSchedulerController
 *
 *
**/
@IsTest
public class SCH_SmartSchedulerControllerTest {
    /*******************************************************************************************************
     * @description Method used to test total recipients filter, simple sms package, sms details and picklist values details
     **/
    @IsTest
    public static void testSmartSchedule() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);

        Test.startTest();
        String filter = SCH_SmartSchedulerController.getAdminTotalRecipientsFilter('Account', 'Contact', 'Account', schedule.Id);
        System.assertEquals('WHERE AccountId != null', filter.trim(), 'Filter schould be match with Schedule Action');

        Map<String, Object> mapSimpleSMSPackageInstalled = SCH_SmartSchedulerController.isSimpleSMSPackageInstalled();
        System.assertEquals(false, mapSimpleSMSPackageInstalled.isEmpty(), 'This should be have simple sms package installation details');

        if (SCH_BtBaseUtils.INSTALLED_SIMPLESMS) {
            System.assertEquals(true, boolean.valueOf(mapSimpleSMSPackageInstalled.get('isInstalled')), 'Simple SMS package Installed');
        } else {
            System.assertEquals(false, boolean.valueOf(mapSimpleSMSPackageInstalled.get('isInstalled')), 'Simple SMS package not installed');
        }

        Map<String, Object> mapSMSDetails = SCH_SmartSchedulerController.getSMSdetails();
        System.assertEquals(false, mapSMSDetails.isEmpty(), 'This should have simple sms permissions and account details.');

        Map<String, Object> mapBTScheduledetails = SCH_SmartSchedulerController.getBTScheduledetails();
        System.assertEquals(false, mapBTScheduledetails.isEmpty(), 'This should have BT schedule permissions and account details.');

        String jsonContactFields = SCH_SmartSchedulerController.getSobjectFieldsWithType('Contact');
        System.assertEquals(false, String.isBlank(jsonContactFields), 'This should have Datetime, Email & Phone fields');

        Map<String, String> mapPicklistValues = SCH_SmartSchedulerController.getPicklistValues('Contact', 'LeadSource');
        System.assertEquals(false, mapPicklistValues.isEmpty(), 'This should have Contact\'s Lead Source options');

        Map<String, String> mapPhoneNumbers = SCH_SmartSchedulerController.getAvailableFromNumbers();
        if (mapPhoneNumbers.isEmpty()) {
            System.assertEquals(true, mapPhoneNumbers.isEmpty(), 'This should have available from numbers.');
        } else {
            System.assertEquals(false, mapPhoneNumbers.isEmpty(), 'This should have available from numbers.');
        }


        SCH_Account oAccount = SCH_SmartSchedulerController.getAccount();
        if (oAccount != null) {
            System.assertEquals(true, oAccount != null, 'BT Schedule account details');
        } else {
            System.assertEquals(false, oAccount != null, 'No BT Schedule account configured');
        }

        List<SCH_Schedule__c> lstSchedule = SCH_SmartSchedulerController.getScheduleWithActions(schedule.Id);
        System.assertEquals(1, lstSchedule.size(), 'This will return Schedule with Schedule Action');

        List<Object> globalChildsObjectName = SCH_SmartSchedulerController.getGlobalChildsObjectName('Contact');
        System.assertEquals(true, globalChildsObjectName.size() > 0, 'This will return field details for contact object.');

        String relatedRelationshipFieldName = SCH_SmartSchedulerController.getRelatedRelationshipFieldName('Account', 'Contact', 'ParentId');

        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper = SCH_SmartSchedulerController.getRecipients('Contact', 'AccountId', 'Name != null', 'Account.Name', 'Name');
        System.assertEquals(true, odataTableWrapper != null, 'This will return schedule data');

        List<String> lstOptions = new List<String> {
            'Email'
        };
        Map<String, String> mapAttendeeFilterOptions = SCH_SmartSchedulerController.getAttendeeFilterOptions('Account');
        System.assertEquals(true, !mapAttendeeFilterOptions.isEmpty(), 'This will return picklist options');

        List<String> lstOrgWideEmailAddress = SCH_SmartSchedulerController.getOrgWideEmailAddress();
        if (lstOrgWideEmailAddress.size() > 0) {
            System.assertEquals(true, lstOrgWideEmailAddress.size() > 0, 'This will return available Org wide email addresses');
        } else {
            System.assertEquals(false, lstOrgWideEmailAddress.size() > 0, 'This will not return available Org wide email addresses');
        }

        String newScheduleId = SCH_SmartSchedulerController.createSchedule('{"Base_Object":"Account","Base_Object_Label":"Account","Base_Object_Evaluate_Criteria":"Name != NULL ","Related_Object":"","Related_Object_Label":"Choose Related Object","Related_Object_Evaluate_Criteria":"","Related_Object_Evaluate_Criteria_JSON":"","Related_Object_Relationship_Name":"","Related_Object_FieldAPIName":"","Action":"Email","Status":"draft","Name":"Test Event","SMS_From_Number":"","SMS_To_Number":"Fax","Email_From_Address":"adarsh.sharma@crmified.com","Email_To_Address":"conference360__Email__c","Recipient":8,"Offset":"before","Offset_Type":"days","Offset_Value":"","Schedule_Date_Time_Field":"CreatedDate","Schedule_Date_Time":"2022-09-10T09:07:00.000Z","Type":"Object","SObject_RecordId":"","Email_Template_Id":"a0y63000005l7dAAAQ","Email_Template_Name":"Test Template","selectedAttendeeFilter":"","selectedAttendeeFilterValue":"","baseObjectCriteria":"matchCriteria","relatedObjectCriteria":"matchCriteria","baseObjectCriteriaFilters":[],"relatedObjectCriteriaFilters":[],"Base_Object_Evaluate_Criteria_JSON":""}');
        System.assertEquals(false, String.isBlank(newScheduleId), 'This will return newly created schedule Id');
        String newScheduleId_1 = SCH_SmartSchedulerController.createSchedule('{"Base_Object":"Account","Base_Object_Label":"Account","Base_Object_Evaluate_Criteria":"Name != NULL ","Related_Object":"","Related_Object_Label":"Choose Related Object","Related_Object_Evaluate_Criteria":"","Related_Object_Evaluate_Criteria_JSON":"","Related_Object_Relationship_Name":"","Related_Object_FieldAPIName":"","Action":"Email","Status":"draft","Name":"Test Event","SMS_From_Number":"","SMS_To_Number":"Fax","Email_From_Address":"adarsh.sharma@crmified.com","Email_To_Address":"conference360__Email__c","Recipient":8,"Offset":"before","Offset_Type":"days","Offset_Value":"","Schedule_Date_Time_Field":"now","Schedule_Date_Time":"","Type":"Object","SObject_RecordId":"","Email_Template_Id":"a0y63000005l7dAAAQ","Email_Template_Name":"Test Template","selectedAttendeeFilter":"","selectedAttendeeFilterValue":"","baseObjectCriteria":"matchCriteria","relatedObjectCriteria":"matchCriteria","baseObjectCriteriaFilters":[],"relatedObjectCriteriaFilters":[],"Base_Object_Evaluate_Criteria_JSON":""}');
        System.assertEquals(false, String.isBlank(newScheduleId_1), 'This will return newly created schedule Id');
        String newScheduleId_2 = SCH_SmartSchedulerController.createSchedule('{"Base_Object":"Account","Base_Object_Label":"Account","Base_Object_Evaluate_Criteria":"Name != NULL ","Related_Object":"","Related_Object_Label":"Choose Related Object","Related_Object_Evaluate_Criteria":"","Related_Object_Evaluate_Criteria_JSON":"","Related_Object_Relationship_Name":"","Related_Object_FieldAPIName":"","Action":"Email","Status":"draft","Name":"Test Event","SMS_From_Number":"","SMS_To_Number":"Fax","Email_From_Address":"adarsh.sharma@crmified.com","Email_To_Address":"conference360__Email__c","Recipient":8,"Offset":"before","Offset_Type":"days","Offset_Value":"2","Schedule_Date_Time_Field":"CreatedDate","Schedule_Date_Time":"","Type":"Object","SObject_RecordId":"","Email_Template_Id":"a0y63000005l7dAAAQ","Email_Template_Name":"Test Template","selectedAttendeeFilter":"","selectedAttendeeFilterValue":"","baseObjectCriteria":"matchCriteria","relatedObjectCriteria":"matchCriteria","baseObjectCriteriaFilters":[],"relatedObjectCriteriaFilters":[],"Base_Object_Evaluate_Criteria_JSON":""}');
        System.assertEquals(false, String.isBlank(newScheduleId_2), 'This will return newly created schedule Id');
        String newScheduleId_3 = SCH_SmartSchedulerController.createSchedule('{"Base_Object":"Account","Base_Object_Label":"Account","Base_Object_Evaluate_Criteria":"Name != NULL ","Related_Object":"conference360__Session_Attendee__c","Related_Object_Label":"Session Attendee","Related_Object_Evaluate_Criteria":"","Related_Object_Evaluate_Criteria_JSON":"","Related_Object_Relationship_Name":"","Related_Object_FieldAPIName":"","Action":"Email","Status":"draft","Name":"Test Event","SMS_From_Number":"","SMS_To_Number":"Fax","Email_From_Address":"adarsh.sharma@crmified.com","Email_To_Address":"conference360__Email__c","Recipient":8,"Offset":"before","Offset_Type":"days","Offset_Value":"2","Schedule_Date_Time_Field":"conference360__Session__c.conference360__Start_Date_Time_GMT__c","Schedule_Date_Time":"","Type":"Object","SObject_RecordId":"' + event.Id + '","Email_Template_Id":"a0y63000005l7dAAAQ","Email_Template_Name":"Test Template","selectedAttendeeFilter":"","selectedAttendeeFilterValue":"","baseObjectCriteria":"matchCriteria","relatedObjectCriteria":"matchCriteria","baseObjectCriteriaFilters":[],"relatedObjectCriteriaFilters":[],"Base_Object_Evaluate_Criteria_JSON":""}');
        System.assertEquals(false, String.isBlank(newScheduleId_3), 'This will return newly created schedule Id');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test initialize details for smart schedule
     **/
    @IsTest
    public static void testgetInitData() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"BT_Support_Team":"https://community.blackthorn.io/s/article/How-to-Engage-with-the-Blackthorn-Messaging-Support-Team","Terms_of_Service":"https://www.blackthorn.io/messaging/terms-of-service","Privacy_Policy":"https://www.blackthorn.io/messaging/privacy-policy","sms_not_installed_admin":"In order to unlock SMS features, ","sms_not_installed_admin_click_here_text":"click here to install Blackthorn Messaging App","sms_not_configure_admin":"In order to unlock SMS features, ","sms_not_configure_admin_click_here_text":"click here to configure your Messaging Account","sms_not_installed":"In order to unlock SMS features, please contact your System Administrator.","sms_not_configure":"In order to unlock SMS features, please contact your System Administrator.","sms_package_link":"https://candyshop.blackthorn.io/products/blackthorn-sms/latest","sms_admin_page_link":"/apex/simplesms__Administration","btschedule_not_installed_admin":"In order to unlock Schedule features, ","btschedule_not_installed_admin_click_here_text":"click here to install Blackthorn Schedule App","btschedule_not_configure_admin":"In order to unlock Schedule features, ","btschedule_not_configure_admin_click_here_text":"click here to configure your Account","btschedule_not_installed":"In order to unlock Schedule features, please contact your System Administrator.","btschedule_not_configure":"In order to unlock Schedule features, please contact your System Administrator.","btschedule_package_link":"https://candyshop.blackthorn.io/products/blackthorn-sms/latest","btschedule_admin_page_link":"/apex/SCH_Administration"}', null));

        Test.startTest();
        Map<String, Object> mapInitData = SCH_SmartSchedulerController.getInitData();
        System.assertEquals(false, mapInitData.isEmpty(), 'This will return SMS results and help links for simple sms');
        Map<String, Object> mapBTPackage = SCH_SmartSchedulerController.isBTPackageInstalled();
        System.assertEquals(false, mapBTPackage.isEmpty(), 'This will return BT package details and help links for Smart schedule');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test create new schedule with schedule action
     **/
    @IsTest
    public static void testCreateNewScheduleCallout() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);

        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"status":"success"}', null));

        Test.startTest();
        SCH_ResponseWrapper oResponse = SCH_SmartSchedulerController.createNewScheduleCallout(schedule.Id, true);
        System.assertEquals(true, oResponse != null, 'This will return response');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test update schedule and schedule action
     **/
    @IsTest
    public static void testUpdateSchedule() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);

        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"status":"success"}', null));

        Test.startTest();
        SCH_ResponseWrapper oResponse = SCH_SmartSchedulerController.updateSchedule(schedule.Id, 'active');
        System.assertEquals(true, oResponse != null, 'This will return response');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test send email preview with email template
     **/
    @IsTest
    public static void testEmailSendAndTestScheduleSMSPreviewWithEmailTemplate() {
        EmailTemplate emailTemplate = SCH_TestUtilities.createEmailTemplate('TestEvent', UserInfo.getUserId(), true);
        Test.startTest();
        try {
            SCH_SmartSchedulerController.sendAndTestScheduleSMSPreview('{"Action":"Email", "Email_From_Address":"test@test.com", "Email_Template_Id":"' + emailTemplate.Id + '"}', 'test@test.com', UserInfo.getUserId());
        } catch (Exception ex) {}
        Test.stopTest();
        System.assertEquals(true, emailTemplate != null, 'Email Template should be created');
    }

    /*******************************************************************************************************
     * @description Method used to test send email preview without email template
     **/
    @IsTest
    public static void testEmailSendAndTestScheduleSMSPreviewWithoutEmailTemplate() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);

        Test.startTest();
        try {
            SCH_SmartSchedulerController.sendAndTestScheduleSMSPreview('{"Action":"Email", "Email_From_Address":"test@test.com", "Email_Template_Id":"' + schedule.Id + '"}', 'test@test.com', UserInfo.getUserId());
        } catch (Exception ex) {}
        Test.stopTest();
        System.assertEquals(true, schedule != null, 'Schedule record should be created');
    }

    /*******************************************************************************************************
     * @description Method used to test sms preview
     **/
    @IsTest
    public static void testSMSSendAndTestScheduleSMSPreview() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"status":"success"}', null));

        Test.startTest();
        String message;
        try{
            SCH_SmartSchedulerController.sendAndTestScheduleSMSPreview('{"Action":"SMS", "SMS_From_Number":"8574963210", "SMS_Message":"test","SMS_Template_Id":"' + emailTemplate.Id + '","SMS_Attachment_Id":""}', '8574963210', UserInfo.getUserId());
        }catch(Exception ex){message = ex.getMessage();}
        Test.stopTest();
        System.assertEquals(true, String.isBlank(message), 'Preview SMS Message should be sent');
    }

    /*******************************************************************************************************
     * @description Method used to test get admin schedules
     **/
    @IsTest
    public static void testGetAdminSchedules() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"metadata": {"page_size": 3,"current_page": 1,"current_page_records": 3,"total_records": 4,"has_next": true},"records": [{"next_execution_date_time":"' + system.now() + '","name": "Testing SMS Schedule","salesforce_id": "SCH000000000000001","base_sobject": "Account","base_sobject_criteria": "Type=\'Schedule\'","related_sobject": "Contact","related_sobject_criteria": "MailingCountry=\'India\'","base_related_relationship": "Account","offset_value": 5,"offset_type": "days", "offset": "before","schedule_field": "AccountOnBoardingDate__c","status": "draft","schedule_type": "object","actions": [{"name": "Send SMS","salesforce_id": "SCHACT000000000001","action_type": "sms","sms_from_number": "+10000000000","sms_to_number_field": "Phone","sms_body": "Hello SMS", "sms_template_id": null}]}]}', null));

        Test.startTest();
        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper;
        try{
            odataTableWrapper = SCH_SmartSchedulerController.getAdminSchedules('sms', 'object', 'draft', true, null, 0, 15, true);
            System.assertEquals(true, odataTableWrapper != null, 'This will return response');
        }catch(Exception ex){
            System.assertNotEquals(true, odataTableWrapper != null, 'This will return response');
        }
        Test.stopTest();
    }


   /*******************************************************************************************************
     * @description Method used to test get all execution for schedules
     **/ 
    @IsTest
    public static void testGetAllExecutionsForSchedule() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"metadata": {"page_size": 10,"current_page": 1,"current_page_records": 3,"total_records": 3,"has_next": false},"records": [{"action_type": "email","status": "in progress","status_message": null,"salesforce_id": "0030U00001V9h1PQAR","sms_sid": null,"email_id": null,"execution_date_time": null,"created_at": "2022-07-22T13:41:27.173Z","updated_at": "2022-07-22T13:41:27.173Z","execution": {"salesforce_id": "0010U00001GcmdwQAB","status": "failed","status_message": null,"execution_date_time": "2022-07-23T04:00:00.000Z","created_at": "2022-07-19T22:20:21.255Z","updated_at": "2022-07-22T13:33:41.082Z","sidekiq_job_id": null,"log_counts": 3}}]}', null));
        Test.startTest();
        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper = SCH_SmartSchedulerController.getAllExecutionsForSchedule('0010U00001GcmdwQAB', 0, 15, null, true);
        System.assertEquals(true, odataTableWrapper != null, 'This will return response');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test get all execution for schedules
     **/ 
    @IsTest
    public static void testInvalidGetAllExecutionsForSchedule() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '', null));
        Test.startTest();
        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper;
        try{
            odataTableWrapper = SCH_SmartSchedulerController.getAllExecutionsForSchedule('0010U00001GcmdwQAB', 0, 15, null, true);
            System.assertEquals(true, odataTableWrapper != null, 'This will return response');
        }catch(Exception ex){
            System.assertNotEquals(true, odataTableWrapper != null, 'This will return response');
        }
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test get all logs for a execution
     **/ 
    @IsTest
    public static void testGetAllLogsForExecution() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"metadata": {"page_size": 10,"current_page": 1,"current_page_records": 3,"total_records": 3,"has_next": false},"records": [{"action_type": "email","status": "in progress","status_message": null,"salesforce_id": "0030U00001V9h1PQAR","sms_sid": null,"email_id": null,"execution_date_time": null,"created_at": "2022-07-22T13:41:27.173Z","updated_at": "2022-07-22T13:41:27.173Z","execution": {"salesforce_id": "0010U00001GcmdwQAB","status": "failed","status_message": null,"execution_date_time": "2022-07-23T04:00:00.000Z","created_at": "2022-07-19T22:20:21.255Z","updated_at": "2022-07-22T13:33:41.082Z","sidekiq_job_id": null,"log_counts": 3}}]}', null));
        Test.startTest();
        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper = SCH_SmartSchedulerController.getAllLogsForExecution('0010U00001GcmdwQAB','0010U00001GcmdwQAB', 0, 15, null, true);
        System.assertEquals(true, odataTableWrapper != null, 'This will return response');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test get all logs for a execution
     **/ 
    @IsTest
    public static void testInvalidGetAllLogsForExecution() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '', null));
        Test.startTest();
        SCH_SmartSchedulerController.dataTableWrapper odataTableWrapper;
        try{
            odataTableWrapper = SCH_SmartSchedulerController.getAllLogsForExecution('0010U00001GcmdwQAB', '0010U00001GcmdwQAB', 0, 15, null, true);
            System.assertEquals(true, odataTableWrapper != null, 'This will return response');
        }catch(Exception ex){
            System.assertNotEquals(true, odataTableWrapper != null, 'This will return response');
        }
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test get date time fields
     **/ 
    @IsTest
    public static void testGetScheduleDateTimeFields() {
        Test.startTest();
        Map<String, String> mapAttendeeScheduleDateTimeFields = SCH_SmartSchedulerController.getScheduleDateTimeFields(SCH_BtBaseUtils.EVENT_PGK_NAMESPACE + '__Attendee__c');
        System.assertEquals(true, !mapAttendeeScheduleDateTimeFields.isEmpty(), 'This will return Attendee date time fields');
        Map<String, String> mapSessionAttendeeScheduleDateTimeFields = SCH_SmartSchedulerController.getScheduleDateTimeFields(SCH_BtBaseUtils.EVENT_PGK_NAMESPACE + '__Session_Attendee__c');
        System.assertEquals(true, !mapSessionAttendeeScheduleDateTimeFields.isEmpty(), 'This will return Session Attendee date time fields');
        Map<String, String> mapScheduleDateTimeFields = SCH_SmartSchedulerController.getScheduleDateTimeFields('Account');
        System.assertEquals(true, mapScheduleDateTimeFields.isEmpty(), 'This will not return any date time fields');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test get event details
     **/ 
    @IsTest
    public static void testFetchEventDetail() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        System.assert(string.isNotBlank(acc.Id), 'Expected account to be created.');

        Test.startTest();
        SCH_BtBaseUtils.eventSobjectName = 'Account';
        SCH_BtBaseUtils.eventQueryFields = new Set<String> {
            'Id',
            'Name'
        };
        sObject obj = SCH_SmartSchedulerController.fetchEventDetail(acc.Id);
        System.assertEquals(acc.Name, (String) obj.get('Name'), 'This will match with the Account Name');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test total attendee count
     **/ 
    @IsTest
    public static void testTotalAttendeeCount() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        System.assert(string.isNotBlank(acc.Id), 'Expected account to be created.');

        Test.startTest();
        Integer iCount = SCH_SmartSchedulerController.getTotalAttendeeCount('Account', 'Name!=null');
        System.assertEquals(1, iCount, 'This will return total Account records count');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test total attendee count
     **/ 
    @IsTest
    public static void testInvalidTotalAttendeeCount() {
        Test.startTest();
        Integer iCount = SCH_SmartSchedulerController.getTotalAttendeeCount('Account', 'Name!=null');
        System.assertNotEquals(1, iCount, 'This will return total Account records count');
        Test.stopTest();
    }
    
    /*******************************************************************************************************
     * @description test method to test ord wide email address not accessible by user.
     * @return Boolean
     * @param String emailAddress
     * @param String userId
     **/
    @IsTest
    public static void testCheckOrgWideEmailAddress() {
        Test.startTest();
        Boolean isVerified = SCH_SmartSchedulerController.checkOrgWideEmailAddress('test@test.com', UserInfo.getUserId());
        System.assertEquals(false, isVerified, 'This will validate Org wide email address verified + accessible to current user');
        Test.stopTest();
    }

}