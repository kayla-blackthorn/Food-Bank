@IsTest
private class FormSubmissionAnswerSelectorTest {
    @IsTest
    private static void testGetSObjectFieldList_expectFieldList() {
        Test.startTest();
            System.assertNotEquals(0, new FormSubmissionAnswerSelector().getSObjectFieldList().size(), 'Field list is returned from the selector');
        Test.stopTest();
    }

    @IsTest
    private static void testGetSObjectType_expectFormElementObject() {
        Test.startTest();
            System.assertEquals(Form_Submission_Answer__c.SObjectType, new FormSubmissionAnswerSelector().getSObjectType(), 'It return Form_Submission_Answer__c schema type');
        Test.stopTest();
    }

    @IsTest
    private static void testGetAnswerByFormSubmissionId_expectRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        insert submission;

        Form_Submission_Answer__c answer = new Form_Submission_Answer__c( Form_Submission__c = submission.Id);
        insert answer;

        Test.startTest();
            List<Form_Submission_Answer__c> recordList = new FormSubmissionAnswerSelector().getAnswerByFormSubmissionId(new Set<Id> { submission.Id });
            
        Test.stopTest();
        System.assertEquals(1, recordList.size(), 'Only one record should be returned as we passed 1 id');
        System.assertEquals(answer.Id, recordList[0].Id, 'Id needs to match the id which we passed');
    }

    @IsTest
    private static void testGetAnswerByFormSubmissionId_expectNoRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        insert submission;

        Test.startTest();
            List<Form_Submission_Answer__c> recordList = new FormSubmissionAnswerSelector().getAnswerByFormSubmissionId(new Set<Id> { Helpers.getFakeId(Form_Submission_Answer__c.SObjectType) });
            
        Test.stopTest();
        System.assertEquals(0, recordList.size(), 'No record should be returned as we passed wrong key');
    }

    @IsTest
    private static void testSelectSObjectsById_expectRecordsReturned() {
        
        Form_Submission__c submission = new Form_Submission__c(Key__c= 'abcdefg');
        insert submission;

        Form_Submission_Answer__c answer = new Form_Submission_Answer__c( Form_Submission__c = submission.Id);
        insert answer;

        Test.startTest();
            List<Form_Submission_Answer__c> recordList = new FormSubmissionAnswerSelector().selectSObjectsById(new Set<Id> { answer.Id });
            
        Test.stopTest();
        System.assertEquals(1, recordList.size(), 'Only one record should be returned as we passed 1 id');
        System.assertEquals(answer.Id, recordList[0].Id, 'Id needs to match the id which we passed');
    }

    @IsTest
    private static void testSelectSObjectsById_expectNoRecordsReturned() {
        Test.startTest();
            List<Form_Submission_Answer__c> recordList = new FormSubmissionAnswerSelector().selectSObjectsById(new Set<Id> { Helpers.getFakeId(Form_Submission_Answer__c.SObjectType) });
            
        Test.stopTest();
        System.assertEquals(0, recordList.size(), 'no record should be returned as we passed invalid id');
    }
}