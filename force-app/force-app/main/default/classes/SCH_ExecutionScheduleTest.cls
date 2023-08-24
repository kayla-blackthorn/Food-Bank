@IsTest
public class SCH_ExecutionScheduleTest {
    /*******************************************************************************************************
     * @description Method used to test execution schedule wrapper
     **/
    @IsTest
    public static void testExecutionScheduleRecord() {
        Test.startTest();
        SCH_ExecutionSchedule es = new SCH_ExecutionSchedule();
        System.assertEquals(null, es.getMetadata());
        System.assertEquals(null, es.getRecords());

        SCH_ExecutionSchedule.MetadataConfig esmc = new SCH_ExecutionSchedule.MetadataConfig();
        System.assertEquals(null, esmc.getPageSize());
        System.assertEquals(null, esmc.getCurrentPage());
        System.assertEquals(null, esmc.getCurrentPageRecords());
        System.assertEquals(null, esmc.getCurrentPageExecutionRecords());
        System.assertEquals(null, esmc.getCurrentPageLogRecords());
        System.assertEquals(null, esmc.getTotalExecutionRecords());
        System.assertEquals(null, esmc.getTotalLogRecords());
        System.assertEquals(null, esmc.getTotalRecords());
        System.assertEquals(null, esmc.getHasNext());

        SCH_ExecutionSchedule.Logs esLogs = new SCH_ExecutionSchedule.Logs();
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

        SCH_ExecutionSchedule.Execution esExecution = new SCH_ExecutionSchedule.Execution();
        System.assertEquals(null, esExecution.getSalesforceId());
        System.assertEquals(null, esExecution.getStatus());
        System.assertEquals(null, esExecution.getStatusMessage());
        System.assertEquals(null, esExecution.getExecutionDateTime());
        System.assertEquals(null, esExecution.getCreatedAt());
        System.assertEquals(null, esExecution.getUpdatedAt());
        System.assertEquals(null, esExecution.getSidekiqJobId());

        SCH_ExecutionSchedule.Schedule esSchedule = new SCH_ExecutionSchedule.Schedule();
        System.assertEquals(null, esSchedule.getActionType());
        System.assertEquals(null, esSchedule.getSalesforceId());
        System.assertEquals(null, esSchedule.getStatus());
        System.assertEquals('', esSchedule.getStatusMessage());
        System.assertEquals(null, esSchedule.getEmailId());
        System.assertEquals(null, esSchedule.getSMSSId());
        System.assertEquals(null, esSchedule.getExecutionDateTime());
        System.assertEquals(null, esSchedule.getCreatedAt());
        System.assertEquals(null, esSchedule.getUpdatedAt());
        System.assertEquals(null, esSchedule.getSidekiqJobId());
        System.assertEquals(null, esSchedule.getLogCounts());
        System.assertEquals(null, esSchedule.getLogs());
        System.assertEquals(null, esSchedule.getExecution());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test execution schedule wrapper
     **/
    @IsTest
    public static void testValidExecutionScheduleRecord() {
        Test.startTest();
        SCH_ExecutionSchedule es = (SCH_ExecutionSchedule)JSON.deserialize('{"metadata": {"page_size": 10,"current_page": 1,"current_page_records": 3,"total_records": 3,"has_next": false},"records": [{"action_type": "email","status": "in progress","status_message": null,"salesforce_id": "0030U00001V9h1PQAR","sms_sid": null,"email_id": null,"execution_date_time": null,"created_at": "2022-07-22T13:41:27.173Z","updated_at": "2022-07-22T13:41:27.173Z","execution": {"salesforce_id": "0010U00001GcmdwQAB","status": "failed","status_message": null,"execution_date_time": "2022-07-23T04:00:00.000Z","created_at": "2022-07-19T22:20:21.255Z","updated_at": "2022-07-22T13:33:41.082Z","sidekiq_job_id": null,"log_counts": 3}}]}',SCH_ExecutionSchedule.class);
        System.assertNotEquals(null, es.getMetadata());
        System.assertNotEquals(null, es.getRecords());

        SCH_ExecutionSchedule.MetadataConfig esmc = es.getMetadata();
        System.assertNotEquals(null, esmc.getPageSize());
        System.assertNotEquals(null, esmc.getCurrentPage());
        System.assertNotEquals(null, esmc.getCurrentPageRecords());
        System.assertNotEquals(null, esmc.getTotalRecords());
        System.assertNotEquals(null, esmc.getHasNext());

        List<SCH_ExecutionSchedule.Schedule> lstSchedule = es.getRecords();
        System.assertNotEquals(null, lstSchedule);

        for(SCH_ExecutionSchedule.Schedule esSchedule: lstSchedule){
            System.assertNotEquals(null, esSchedule.getActionType());
            System.assertNotEquals(null, esSchedule.getSalesforceId());
            System.assertNotEquals(null, esSchedule.getStatus());
            System.assertNotEquals(null, esSchedule.getCreatedAt());
            System.assertNotEquals(null, esSchedule.getUpdatedAt());
            System.assertNotEquals(null, esSchedule.getExecution());
        }
        
        Test.stopTest();
    }
}