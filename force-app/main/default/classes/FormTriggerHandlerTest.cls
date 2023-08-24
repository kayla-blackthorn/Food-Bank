@IsTest
private with sharing class FormTriggerHandlerTest {

    private static void assertConditionOutput(List<Form_Element__c> elementList, Integer conditionSize) {
       
        Form_Element__c element0 = elementList[0];
        Form_Element__c element1 = elementList[1];

        //assert conditions
        for (Form_Element__c cond : elementList) {
            Assert.areEqual(
                conditionSize,
                cond.Form_Element_Conditions__r.size(),
                'there should be '+conditionSize+' conditions for the form elements'
            );
            if (conditionSize > 0) {
                Id nextElementId = cond.Id == element0.Id ? element1.Id : element0.Id;
                Assert.areEqual(
                    nextElementId,
                    cond.Form_Element_Conditions__r[0].Next_Form_Element__c,
                    'This id must match as it child & should be set since we have data'
                );
            }
        }    
    }

    @IsTest
    private static void formDeepCloneTest_fullFormClone_expectAllRecordsCreated() {
        FormTestDataHelper.createFormWithElements();
        FormTestDataHelper.setupConditions();

        Test.startTest();
        Form__c cloneForm = FormTestDataHelper.f1.clone(false, true);
        insert cloneForm;
        Test.stopTest();

        List<Form_Element__c> elementList = FormTestDataHelper.formDeepCloneTest_assertFormElements(cloneForm, 2);
        assertConditionOutput(elementList, 1);
    }

    @IsTest
    private static void formDeepCloneTest_fullFormClone_expectFormAndElementRecordsCreated() {
        FormTestDataHelper.createFormWithElements();

        Test.startTest();
        Form__c cloneForm = FormTestDataHelper.f1.clone(false, true);
        insert cloneForm;
        Test.stopTest();

        //now assert the required data is cloned
        List<Form_Element__c> elementList = FormTestDataHelper.formDeepCloneTest_assertFormElements(cloneForm, 2);
        assertConditionOutput(elementList, 0);
    }

    @IsTest
    private static void formDeepCloneTest_fullFormClone_expectOnlyFormCreated() {
        FormTestDataHelper.createForm();
        Test.startTest();
        Form__c cloneForm = FormTestDataHelper.f1.clone(false, true);
        insert cloneForm;
        Test.stopTest();
        //now assert the required data is cloned
        FormTestDataHelper.formDeepCloneTest_assertFormElements(cloneForm, 0);
    }
}
