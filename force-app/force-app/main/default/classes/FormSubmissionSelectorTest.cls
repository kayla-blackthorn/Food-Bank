@IsTest
private class FormSubmissionSelectorTest {
    
    @IsTest
    private static void testGetSObjectFieldList_expectFieldList() {
        Test.startTest();
            System.assertNotEquals(0, new FormSubmissionSelector().getSObjectFieldList().size(), 'Field list is returned from the selector');
        Test.stopTest();
    }

    @IsTest
    private static void testGetSObjectType_expectFormSubmissionObject() {
        Test.startTest();
            System.assertEquals(Form_Submission__c.SObjectType, new FormSubmissionSelector().getSObjectType(), 'It return form submission schema type');
        Test.stopTest();
    }

    @IsTest
    private static void testGetSubmissionByKey_expectRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        Form_Submission__c submission2 = new Form_Submission__c(Key__c= 'abcdefghijl');
        insert new List<Form_Submission__c> {submission, submission2};

        Test.startTest();
            List<Form_Submission__c> recordList = new FormSubmissionSelector().getSubmissionByKey(new Set<String> { 'abcdefg' });
            
        Test.stopTest();
        System.assertEquals(1, recordList.size(), 'Only one record should be returned as we passed 1 key');
        System.assertEquals(submission.Id, recordList[0].Id, 'Id needs to match the id which we passed');
    }

    @IsTest
    private static void testGetSubmissionByKey_expectNoRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        insert submission;

        Test.startTest();
            List<Form_Submission__c> recordList = new FormSubmissionSelector().getSubmissionByKey(new Set<String> { 'abcdefghijk' } );
            
        Test.stopTest();
        System.assertEquals(0, recordList.size(), 'No record should be returned as we passed wrong key');
    }

    @IsTest
    private static void testSelectSObjectsById_expectRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        insert submission;

        Test.startTest();
            List<Form_Submission__c> recordList = new FormSubmissionSelector().selectSObjectsById(new Set<Id> { submission.Id });
            
        Test.stopTest();
        System.assertEquals(1, recordList.size(), 'Only one record should be returned as we passed 1 id');
        System.assertEquals(submission.Id, recordList[0].Id, 'Id needs to match the id which we passed');
    }

    @IsTest
    private static void testSelectSObjectsById_expectNoRecordsReturned() {
        Test.startTest();
            List<Form_Submission__c> recordList = new FormSubmissionSelector().selectSObjectsById(new Set<Id> { Helpers.getFakeId(Form_Submission__c.SObjectType) });
            
        Test.stopTest();
        System.assertEquals(0, recordList.size(), 'no record should be returned as we passed invalid id');
    }
}