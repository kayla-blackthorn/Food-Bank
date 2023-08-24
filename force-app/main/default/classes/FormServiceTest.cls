@IsTest
private with sharing class FormServiceTest {
    static Form__c cloneForm;
    private static Map<Id, Id>  getCloneFormData() {
        cloneForm = new Form__c(Name = 'Form Test 2');
        insert cloneForm;

        Map<Id, Id> mapData = new Map<Id, Id>();
        mapData.put(FormTestDataHelper.f1.Id, cloneForm.Id);    
        return mapData;
    }

    @IsTest
    private static void formDeepCloneTest_fullFormClone_expectAllRecordsCreated() {
        FormTestDataHelper.createFormWithElements();
        FormTestDataHelper.setupConditions();
        Map<Id, Id> mapData = getCloneFormData();

        Test.startTest();
        FormService.deepCloneForm(mapData);
        Test.stopTest();

        //get form elements
        List<Form_Element__c> elementList = FormTestDataHelper.formDeepCloneTest_assertFormElements(cloneForm, 2);
        Form_Element__c element0 = elementList[0];
        Form_Element__c element1 = elementList[1];

        //assert conditions
        for (Form_Element__c cond : elementList) {
            Assert.areEqual(
                1,
                cond.Form_Element_Conditions__r.size(),
                'there should be no conditions for the form elements'
            );
            Id nextElementId = cond.Id == element0.Id ? element1.Id : element0.Id;
            Assert.areEqual(
                nextElementId,
                cond.Form_Element_Conditions__r[0].Next_Form_Element__c,
                'This id must match as it child & should be set since we have data'
            );
        }
    }

    @IsTest
    private static void formDeepCloneTest_fullFormClone_expectOnlyFormCreated() {
        FormTestDataHelper.createForm();
        Map<Id, Id> mapData = getCloneFormData();
        Test.startTest();
        FormService.deepCloneForm(mapData);
        Test.stopTest();
        FormTestDataHelper.formDeepCloneTest_assertFormElements(cloneForm, 0);
    }
}
