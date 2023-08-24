@IsTest
private with sharing class FormBigListGroupSelectorTest {
    @IsTest
    private static void testGetSObjectFieldList_expectFieldList() {
        Test.startTest();
        System.assertNotEquals(
            0,
            new FormBigListGroupSelector().getSObjectFieldList().size(),
            'Field list is returned from the selector'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testGetSObjectType_expectFormBigListGroupObject() {
        Test.startTest();
        System.assertEquals(
            Form_Big_List_Group__c.SObjectType,
            new FormBigListGroupSelector().getSObjectType(),
            'It return form big list group schema type'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testGetBigListGroups_expectRcordReturned_allReturned() {
        Test.startTest();
        System.assertEquals(
            2,
            new FormBigListGroupSelector().getBigListGroups(5).size(),
            'It return all records since we only have 2'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testGetBigListGroups_expectRcordReturned_limit1Returned() {
        Test.startTest();
        System.assertEquals(
            1,
            new FormBigListGroupSelector().getBigListGroups(1).size(),
            'It return only 1 record since we gave it a limit of 1'
        );
        Test.stopTest();
    }

    @TestSetup
    private static void setupRecords() {
        Form_Big_List_Group__c group1 = new Form_Big_List_Group__c(Name = 'Group 1');
        Form_Big_List_Group__c group2 = new Form_Big_List_Group__c(Name = 'Group 2');

        insert new List<Form_Big_List_Group__c>{ group1, group2 };
    }
}
