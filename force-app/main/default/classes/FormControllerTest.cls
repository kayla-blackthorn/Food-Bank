@IsTest
private with sharing class FormControllerTest {
    static Form_Element__c fe1, fe2;
    static Form__c form;
    static Form_Element_Condition__c fec1, fec2;

    private static void createForm() {
        form = new Form__c(Name = 'Contact');
        insert new List<Form__c>{ form };
    }

    private static void createData() {
        createForm();
        fe1 = buildFormElement();
        fe2 = buildFormElement();
        insert new List<Form_Element__c>{ fe1, fe2 };

        fec1 = buildFormElementCondition(fe1.Id, fe2.Id);
        fec2 = buildFormElementCondition(fe2.Id, fe1.Id);
        insert new List<Form_Element_Condition__c>{ fec1, fec2 };
    }

    private static Form_Element__c buildFormElement() {
        Form_Element__c fe = new Form_Element__c(
            Question__c = 'Where is Spiderman?',
            Type__c = 'Text',
            Maps_To_Object__c = 'Contact',
            Maps_To_Field__c = 'FirstName',
            Form__c = form.Id
        );
        return fe;
    }

    private static Form_Element_Condition__c buildFormElementCondition(Id feId1, Id feId2) {
        Form_Element_Condition__c fec = new Form_Element_Condition__c(
            Form_Element__c = feId1,
            Condition_Operator__c = 'Equals',
            Condition_Value__c = 'Peter Parker',
            Next_Form_Element__c = feId2
        );
        return fec;
    }

    @IsTest
    private static void listMapToObjects_expectRecordsReturned() {
        createData();
        Test.startTest();
        List<FormController.MapToList> listOfObjects = FormController.listMapToObjects();
        Test.stopTest();
        Assert.isTrue(listOfObjects.size() == 3, 'There are 3 configured records');
    }

    @IsTest
    private static void loadFormElements_expectRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> formElements = FormController.loadFormElements(form.Id);
        Test.stopTest();
        Assert.areEqual(2, formElements.size(), 'Expected 2 form elements');
    }

    @IsTest
    private static void loadFormElements_expectNoRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element__c> formElements = FormController.loadFormElements(Helpers.getFakeId(Form__c.SobjectType));
        Test.stopTest();
        Assert.areEqual(0, formElements.size(), 'There are no form elements for this form');
    }

    @IsTest
    private static void loadFormElementConditions_expectNoRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> formElements = FormController.loadFormElementConditions(
            Helpers.getFakeId(Form__c.SobjectType)
        );
        Test.stopTest();
        Assert.areEqual(0, formElements.size(), 'There are no form elements conditions for this form');
    }

    @IsTest
    private static void loadFormElementConditions_expectRecordsReturned() {
        createData();
        Test.startTest();
        List<Form_Element_Condition__c> formElements = FormController.loadFormElementConditions(form.Id);
        Test.stopTest();
        Assert.areEqual(2, formElements.size(), 'It should return 2 form elements conditions');
    }

    @IsTest
    private static void loadBigListGroups_expectRecordsReturned() {
        Form_Big_List_Group__c group1 = new Form_Big_List_Group__c(Name = 'Group 1');
        Form_Big_List_Group__c group2 = new Form_Big_List_Group__c(Name = 'Group 2');

        insert new List<Form_Big_List_Group__c>{ group1, group2 };
        Test.startTest();
        List<Form_Big_List_Group__c> groups = FormController.loadBigListGroups();
        Test.stopTest();
        Assert.areEqual(2, groups.size(), 'It should return all groups');
    }

    @IsTest
    private static void saveElementAndConditions_expectRecordsSaved() {
        createForm();
        fe1 = buildFormElement();
        fec1 = buildFormElementCondition(null, null);
        insert fec1;
        Test.startTest();
        FormController.FormElementAndConditions response = FormController.saveElementAndConditions(
            fe1,
            new List<Form_Element_Condition__c>{ buildFormElementCondition(null, null) },
            new List<Form_Element_Condition__c>{ fec1 }
        );
        Test.stopTest();

        Assert.areEqual(fe1.Id, response.element.Id, 'The save element should be returned');

        List<Form_Element__c> formElements = [SELECT Id FROM Form_Element__c];
        List<Form_Element_Condition__c> formElementConditions = [SELECT Id FROM Form_Element_Condition__c];
        Assert.areEqual(1, formElements.size(), 'It should save 1 form element');
        Assert.areEqual(1, formElementConditions.size(), 'It should save 1 form element condition');

        formElementConditions = [SELECT Id, Form_Element__c FROM Form_Element_Condition__c WHERE Id = :fec1.Id];
        Assert.areEqual(0, formElementConditions.size(), 'This condition should be deleted');
    }

    @IsTest
    private static void saveElementAndConditions_expectError() {
        createForm();
        fe1 = buildFormElement();
        fec1 = buildFormElementCondition(null, null);
        insert fec1;
        Boolean hasError = false;
        FormController.MAX_LIMIT = 1;
        Test.startTest();
        try {
            FormController.FormElementAndConditions response = FormController.saveElementAndConditions(
                fe1,
                new List<Form_Element_Condition__c>{ buildFormElementCondition(null, null) },
                new List<Form_Element_Condition__c>{ fec1 }
            );
        } catch (AuraHandledException e) {
            hasError = true;
            Assert.isTrue(e.getMessage().contains(Label.Form_Builder_Max_Limit), 'It should throw an error');
        }
        Test.stopTest();
        Assert.isTrue(hasError, 'There should be an error thrown for max limit');
    }

    @IsTest
    private static void saveFormElements_expectRecordsSaved() {
        createForm();
        fe1 = buildFormElement();
        fe2 = buildFormElement();
        fe2.Question__c = 'Where is Batman?';
        Test.startTest();
        FormController.saveFormElements(new List<Form_Element__c>{ fe1, fe2 });
        Test.stopTest();

        List<Form_Element__c> formElements = [SELECT Id FROM Form_Element__c];
        Assert.areEqual(2, formElements.size(), 'It should save 2 form element');
    }

    @IsTest
    private static void saveFormElements_expectError() {
        createForm();
        fe1 = buildFormElement();
        fe2 = buildFormElement();
        fe2.Question__c = 'Where is Batman?';
        FormController.MAX_LIMIT = 1;
        Boolean hasError = false;
        Test.startTest();
        try {
            FormController.saveFormElements(new List<Form_Element__c>{ fe1, fe2 });
        } catch (AuraHandledException e) {
            hasError = true;
            Assert.isTrue(e.getMessage().contains(Label.Form_Builder_Max_Limit), 'It should throw an error');
        }
        Test.stopTest();
        Assert.isTrue(hasError, 'There should be an error thrown for max limit');
    }

    @IsTest
    private static void deleteFormElements_expectRecordsSaved() {
        createData();
        Test.startTest();
        FormController.deleteFormElements(new List<Form_Element__c>{ fe1, fe2 });
        Test.stopTest();

        List<Form_Element__c> formElements = [SELECT Id FROM Form_Element__c];
        Assert.areEqual(0, formElements.size(), 'Both of the form elements should be deleted');
    }

    @IsTest
    private static void deleteFormElements_expectError() {
        createData();

        FormController.MAX_LIMIT = 1;
        Boolean hasError = false;
        Test.startTest();
        try {
            FormController.deleteFormElements(new List<Form_Element__c>{ fe1, fe2 });
        } catch (Exception e) {
            hasError = true;
            Assert.isTrue(e.getMessage().contains(Label.Form_Builder_Max_Limit), 'It should throw an error');
        }
        Test.stopTest();
        Assert.isTrue(hasError, 'There should be an error thrown for max limit');
    }
}
