@IsTest
private class FormElementConditionSelectorTest {
    @IsTest
    private static void testGetSObjectFieldList_expectFieldList() {
        Test.startTest();
        System.assertNotEquals(
            0,
            new FormElementConditionSelector().getSObjectFieldList().size(),
            'Field list is returned from the selector'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testGetSObjectType_expectFormElementObject() {
        Test.startTest();
        Assert.areEqual(
            Form_Element_Condition__c.SObjectType,
            new FormElementConditionSelector().getSObjectType(),
            'It return form elements condition schema type'
        );
        Test.stopTest();
    }
    @IsTest
    private static void getConditionsByFormId_expectRecordReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> conditions = new FormElementConditionSelector()
            .getConditionsByFormId(form.Id, 5);
        Test.stopTest();
        Assert.areEqual(2, conditions.size(), 'It returns all conditions for the form');
        Assert.areEqual(fec1.Id, conditions[0].Id, 'It returns the first condition');
        Assert.areEqual(fec2.Id, conditions[1].Id, 'It returns the second condition');
    }

    @IsTest
    private static void getConditionsByFormId_expectNoRecordReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> conditions = new FormElementConditionSelector()
            .getConditionsByFormId(Helpers.getFakeId(Form__c.SObjectType), 5);
        Test.stopTest();
        Assert.areEqual(0, conditions.size(), 'It returns no conditions for this form');
    }

    @IsTest
    private static void getConditionsByFormId_expectRecordReturned_limit1() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> conditions = new FormElementConditionSelector()
            .getConditionsByFormId(form.Id, 1);
        Assert.areEqual(1, conditions.size(), 'It returns only one condition for the form');
        Assert.areEqual(fec1.Id, conditions[0].Id, 'It returns the first condition');
        Test.stopTest();
    }

    @IsTest
    private static void getConditionsByControlledElement_expectNoRecordReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> conditions = new FormElementConditionSelector()
            .getConditionsByControlledElement(new Form_Element__c(), 5);
        Test.stopTest();
        Assert.areEqual(0, conditions.size(), 'It returns no conditions for this form element');
    }

    @IsTest
    private static void getConditionsByControlledElement_expectRecordReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> conditions = new FormElementConditionSelector()
            .getConditionsByControlledElement(fe1, 5);

        Test.stopTest();
        Assert.areEqual(1, conditions.size(), 'It returns no conditions for this form element');
        Assert.areEqual(fec2.Id, conditions[0].Id, 'It returns the condition associated with the form element');
    }

    static Form_Element__c fe1, fe2;
    static Form__c form;
    static Form_Element_Condition__c fec1, fec2;
    private static void createData() {
        FormTestDataHelper.createFormWithElements();
        FormTestDataHelper.setupConditions();
        fe1 = FormTestDataHelper.fe1;
        fe2 = FormTestDataHelper.fe2;
        form = FormTestDataHelper.f1;
        fec1 = FormTestDataHelper.fec1;
        fec2 = FormTestDataHelper.fec2;
    }
}
