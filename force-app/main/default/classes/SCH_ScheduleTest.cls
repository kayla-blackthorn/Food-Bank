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
 * This is used as test class for wrapper class to show the schedules
 *
**/
@IsTest
public class SCH_ScheduleTest {
    /*******************************************************************************************************
     * @description Method used to test schedule and schedule action details
     **/
    @IsTest
    public static void testScheduleAndScheduleAction() {
        Test.startTest();
        SCH_Schedule es = new SCH_Schedule();
        System.assertEquals(null, es.getMetadata());
        System.assertEquals(null, es.getRecords());

        SCH_Schedule.MetadataConfig esmc = new SCH_Schedule.MetadataConfig();
        System.assertEquals(null, esmc.getPageSize());
        System.assertEquals(null, esmc.getCurrentPage());
        System.assertEquals(null, esmc.getCurrentPageRecords());
        System.assertEquals(null, esmc.getTotalRecords());
        System.assertEquals(null, esmc.getHasNext());

        SCH_Schedule.Logs esLogs = new SCH_Schedule.Logs();
        System.assertEquals(null, esLogs.getActionType());
        System.assertEquals(null, esLogs.getStatus());
        System.assertEquals(null, esLogs.getStatusMessage());
        System.assertEquals(null, esLogs.getSalesforceId());
        System.assertEquals(null, esLogs.getRecipient());
        System.assertEquals(null, esLogs.getSmsSId());
        System.assertEquals(null, esLogs.getEmailId());
        System.assertEquals(null, esLogs.getExecutionDateTime());
        System.assertEquals(null, esLogs.getCreatedAt());
        System.assertEquals(null, esLogs.getUpdatedAt());

        SCH_Schedule.ScheduleAction scheduleAction = new SCH_Schedule.ScheduleAction(new SCH_Schedule_Action__c());
        System.assertEquals(null, scheduleAction.getSalesforceId());
        System.assertEquals(null, scheduleAction.getName());
        System.assertEquals(null, scheduleAction.getActionType());
        System.assertEquals(null, scheduleAction.getSmsFromNumber());
        System.assertEquals(null, scheduleAction.getSmsToNumberField());
        System.assertEquals(null, scheduleAction.getSmsBody());
        System.assertEquals(null, scheduleAction.getSmsTemplateId());
        System.assertEquals(null, scheduleAction.getSmsAttachmentId());
        System.assertEquals(null, scheduleAction.getEmailFromAddress());
        System.assertEquals(null, scheduleAction.getEmailToAddressField());
        System.assertEquals(null, scheduleAction.getEmailCCAddress());
        System.assertEquals(null, scheduleAction.getEmailBccAddress());
        System.assertEquals(null, scheduleAction.getEmailSubject());
        System.assertEquals(null, scheduleAction.getEmailBody());

        SCH_Schedule.Schedule esSchedule = new SCH_Schedule.Schedule(new SCH_Schedule__c());
        System.assertEquals(null, esSchedule.getName());
        System.assertEquals(null, esSchedule.getSalesforceId());
        System.assertEquals(null, esSchedule.getBaseSobject());
        System.assertEquals(null, esSchedule.getBaseSobjectCriteria());
        System.assertEquals(null, esSchedule.getRelatedSobject());
        System.assertEquals(null, esSchedule.getRelatedSobjectCriteria());
        System.assertEquals(null, esSchedule.getBaseRelatedRelationship());
        System.assertEquals(null, esSchedule.getOffsetValue());
        System.assertEquals(null, esSchedule.getoffset_type());
        System.assertEquals(null, esSchedule.getoffset());
        System.assertEquals(null, esSchedule.getschedule_field());
        System.assertEquals(null, esSchedule.getScheduleDateTime());
        System.assertEquals(null, esSchedule.getstatus());
        System.assertEquals(null, esSchedule.getschedule_type());
        System.assertEquals(null, esSchedule.getRecordId());
        System.assertEquals(null, esSchedule.getactions());
        Test.stopTest();
    }
    /*******************************************************************************************************
     * @description Method used to test schedule and schedule action details
     **/
    @IsTest
    public static void testValidScheduleAndScheduleAction() {
        Test.startTest();
        SCH_Schedule es = (SCH_Schedule)JSON.deserialize('{"metadata": {"page_size": 3,"current_page": 1,"current_page_records": 3,"total_records": 4,"has_next": true},"records": [{"next_execution_date_time":"' + system.now() + '","name": "Testing SMS Schedule","salesforce_id": "SCH000000000000001","base_sobject": "Account","base_sobject_criteria": "Type=\'Schedule\'","related_sobject": "Contact","related_sobject_criteria": "MailingCountry=\'India\'","base_related_relationship": "Account","offset_value": 5,"offset_type": "days", "offset": "before","schedule_field": "AccountOnBoardingDate__c","status": "draft","schedule_type": "object","actions": [{"name": "Send SMS","salesforce_id": "SCHACT000000000001","action_type": "sms","sms_from_number": "+10000000000","sms_to_number_field": "Phone","sms_body": "Hello SMS", "sms_template_id": null}]}]}',SCH_Schedule.class);
        System.assertNotEquals(null, es.getMetadata());
        System.assertNotEquals(null, es.getRecords());

        SCH_Schedule.MetadataConfig esmc = es.getMetadata();
        System.assertNotEquals(null, esmc.getPageSize());
        System.assertNotEquals(null, esmc.getCurrentPage());
        System.assertNotEquals(null, esmc.getCurrentPageRecords());
        System.assertNotEquals(null, esmc.getTotalRecords());
        System.assertNotEquals(null, esmc.getHasNext());

        List<SCH_Schedule.Schedule> lstSchedule = es.getRecords();
        System.assertNotEquals(null, lstSchedule);

        for(SCH_Schedule.Schedule esSchedule : lstSchedule){
            System.assertNotEquals(null, esSchedule.getName());
            System.assertNotEquals(null, esSchedule.getSalesforceId());
            System.assertNotEquals(null, esSchedule.getBaseSobject());
            System.assertNotEquals(null, esSchedule.getBaseSobjectCriteria());
            System.assertNotEquals(null, esSchedule.getRelatedSobject());
            System.assertNotEquals(null, esSchedule.getRelatedSobjectCriteria());
            System.assertNotEquals(null, esSchedule.getBaseRelatedRelationship());
            System.assertNotEquals(null, esSchedule.getOffsetValue());
            System.assertNotEquals(null, esSchedule.getoffset_type());
            System.assertNotEquals(null, esSchedule.getoffset());
            System.assertNotEquals(null, esSchedule.getschedule_field());
            System.assertNotEquals(null, esSchedule.getstatus());
            System.assertNotEquals(null, esSchedule.getschedule_type());
            System.assertNotEquals(null, esSchedule.getactions());
        }
        Test.stopTest();
    }

    

}