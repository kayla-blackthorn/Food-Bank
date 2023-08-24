/**
 * Blackthorn.io, ENTERPRISES CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io, Enterprises
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io, Enterprises and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io, Enterprises
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io, Enterprises.
 *
 **/
@IsTest
public class SCH_UpdateExecutionLogsQueueableTest {
    /*******************************************************************************************************
     * @description Method used to test update execution logs queueable
     **/
    @IsTest
    public static void testUpdateExecutionLogsQueueable() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        System.assertEquals(true, schedule.Id != null, 'This will return schedule record');
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleEmailAction('Test Email Schedule', 'test@test.com', 'Email', null, schedule.Id, true);
        System.assertEquals(true, scheduleAction.Id != null, 'This will return schedule Action record');
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));
        Test.startTest();
        System.enqueueJob(new SCH_UpdateExecutionLogsQueueable('/schedules/' + schedule.Id + '/actions/' + scheduleAction.Id + '/executions/' + scheduleAction.Id + '/logs', '[{"status":"success","salesforce_id":"' + schedule.Id + '"}]'));
        Test.stopTest();
    }
}