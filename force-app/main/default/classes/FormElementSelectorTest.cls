@IsTest
private class FormElementSelectorTest {
    @IsTest
    private static void testGetSObjectFieldList_expectFieldList() {
        Test.startTest();
        System.assertNotEquals(
            0,
            new FormElementSelector().getSObjectFieldList().size(),
            'Field list is returned from the selector'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testGetSObjectType_expectFormElementObject() {
        Test.startTest();
        Assert.areEqual(
            Form_Element__c.SObjectType,
            new FormElementSelector().getSObjectType(),
            'It return form elements schema type'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testSelectSObjectsById_expectRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> recordList = new FormElementSelector().selectSObjectsById(new Set<Id>{ fe1.Id });

        Test.stopTest();
        Assert.areEqual(1, recordList.size(), 'Only one record should be returned as we passed 1 id');
        Assert.areEqual(fe1.Id, recordList[0].Id, 'Id needs to match the id which we passed');
    }

    @IsTest
    private static void testSelectSObjectsById_expectNoRecordsReturned() {
        Test.startTest();
        List<Form_Element__c> recordList = new FormElementSelector()
            .selectSObjectsById(new Set<Id>{ Helpers.getFakeId(Form_Element__c.SObjectType) });

        Test.stopTest();
        Assert.areEqual(0, recordList.size(), 'no record should be returned as we passed invalid id');
    }

    @IsTest
    private static void selectById_expectNoRecordsReturned() {
        Test.startTest();
        Form_Element__c element = new FormElementSelector().selectById(Helpers.getFakeId(Form_Element__c.SObjectType));

        Test.stopTest();
        Assert.areEqual(null, element, 'no record should be returned as we passed invalid id');
    }

    @IsTest
    private static void selectById_expectNoRecordsReturned_passNull() {
        Test.startTest();
        Form_Element__c element = new FormElementSelector().selectById(null);
        Test.stopTest();
        Assert.areEqual(null, element, 'no record should be returned as we passed invalid id');
    }

    @IsTest
    private static void selectById_expectRecordReturned() {
        createData();
        Test.startTest();
        Form_Element__c element = new FormElementSelector().selectById(fe1.Id);
        Test.stopTest();
        Assert.areEqual(fe1.Id, element.Id, 'Id needs to match the id which we passed to method selectById');
    }

    @IsTest
    private static void getElementsByFormId_expectNoRecordsReturned() {
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector()
            .getElementsByFormId(Helpers.getFakeId(Form__c.SObjectType), 5);
        Test.stopTest();
        Assert.areEqual(0, elementList.size(), 'no record should be returned as we passed invalid id');
    }

    @IsTest
    private static void getElementsByFormId_expectRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector().getElementsByFormId(f1.Id, 5);
        Test.stopTest();
        Assert.areEqual(2, elementList.size(), 'return all form elements for the form');
    }

    @IsTest
    private static void getElementsByFormId_expect1RecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector().getElementsByFormId(f1.Id, 1);
        Test.stopTest();
        Assert.areEqual(1, elementList.size(), 'return 1 form elements for the form since we add a limit of 1');
        Assert.areEqual(
            fe1.Id,
            elementList[0].Id,
            'the first record that was created should be returned as we sort by ascending order'
        );
    }

    @IsTest
    private static void getElementsWithConditionsByFormId_expectRecordsWithConditionReturned() {
        createData();
        FormTestDataHelper.setupConditions();
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector()
            .getElementsWithConditionsByFormId(new Set<Id>{ f1.Id });
        Test.stopTest();
        getElementsWithConditionsByFormId_assertFormElements(elementList);
        //assert conditions
        for (Form_Element__c cond : elementList) {
            Assert.areEqual(
                1,
                cond.Form_Element_Conditions__r.size(),
                'return all the form elements with conditions It will return 1 record'
            );
        }
    }

    @IsTest
    private static void getElementsWithConditionsByFormId_expectRecordsWithNoConditionReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector()
            .getElementsWithConditionsByFormId(new Set<Id>{ f1.Id });
        Test.stopTest();
        getElementsWithConditionsByFormId_assertFormElements(elementList);
        //assert conditions
        for (Form_Element__c cond : elementList) {
            Assert.areEqual(
                0,
                cond.Form_Element_Conditions__r.size(),
                'there should be no conditions for the form elements'
            );
        }
    }

    private static void getElementsWithConditionsByFormId_assertFormElements(List<Form_Element__c> elementList) {
        Assert.areEqual(2, elementList.size(), 'return all the form elements with conditions for the form');
        Assert.areEqual(f1.Id, elementList[0].Form__c, 'Form id must be the same as the one we passed.');
        Assert.areEqual(f1.Id, elementList[1].Form__c, 'Form id must be the same as the one we passed.');
    }

    @IsTest
    private static void getElementsWithConditionsByFormId_expectNoRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> elementList = new FormElementSelector()
            .getElementsWithConditionsByFormId(new Set<Id>{ Helpers.getFakeId(Form__c.SObjectType) });
        Test.stopTest();
        Assert.areEqual(0, elementList.size(), 'no form elements exist for this passed form id');
    }

    static Form_Element__c fe1, fe2;
    static Form__c f1;
    static Form_Element_Condition__c fec1, fec2;
    private static void createData() {
        FormTestDataHelper.createFormWithElements();
        fe1 = FormTestDataHelper.fe1;
        fe2 = FormTestDataHelper.fe2;
        f1 = FormTestDataHelper.f1;
    }
}
