/**
 * Create the test data needed for the form tests
 */
public with sharing class FormTestDataHelper {
    public static Form_Element__c fe1, fe2;
    public static Form__c f1;
    public static Form_Element_Condition__c fec1, fec2;

    /**
     * Create a form for testing
     */
    public static void createForm() {
        f1 = new Form__c(Name = 'Contact');
        insert new List<Form__c>{ f1 };
    }

    /**
     * Create a form with elements for testing
     */
    public static void createFormWithElements() {
        createForm();

        fe1 = new Form_Element__c(
            Form__c = f1.Id,
            Question__c = 'Where is Spiderman?',
            Type__c = 'Text',
            Maps_To_Object__c = 'Contact',
            Maps_To_Field__c = 'FirstName'
        );

        fe2 = new Form_Element__c(
            Form__c = f1.Id,
            Question__c = 'When did the Berlin Wall fall?',
            Type__c = 'Date',
            Maps_To_Object__c = 'Contact',
            Maps_To_Field__c = 'LastName'
        );
        insert new List<Form_Element__c>{ fe1, fe2 };
    }

    /**
     * Create conditions for the form elements for testing 
    */
    public static void setupConditions() {
        fec1 = new Form_Element_Condition__c(
            Form_Element__c = fe1.Id,
            Condition_Operator__c = 'Equals',
            Condition_Value__c = 'Peter Parker',
            Next_Form_Element__c = fe2.Id
        );

        fec2 = new Form_Element_Condition__c(
            Form_Element__c = fe2.Id,
            Condition_Operator__c = 'Equals',
            Condition_Value__c = '1989-11-09',
            Next_Form_Element__c = fe1.Id
        );
        insert new List<Form_Element_Condition__c>{ fec1, fec2 };
    }

    /**
     * @description  This method is used to assert the form elements and conditions from the Unit test in FormServiceTest & FormTriggerHandler Deep Clone Test
     * @param  cloneForm       form that was cloned 
     * @param  formElementSize the number of form element expected
     * @return                 list of form elements that were retrived in assert is sent back in case further asserts are needed to be done
     */
    public static List<Form_Element__c> formDeepCloneTest_assertFormElements(Form__c cloneForm, Integer formElementSize) {
        Form__c[] f = [SELECT Id, Name FROM Form__c WHERE Id = :cloneForm.Id];
        Assert.areEqual(1, f.size(), 'The form should have been cloned');
        //get form elements
        List<Form_Element__c> elementList = new FormElementSelector().getElementsWithConditionsByFormId(new Set<Id>{cloneForm.Id});
        Assert.areEqual(formElementSize, elementList.size(), 'return all the form elements with conditions for the form');    
        if ( formElementSize > 0 ) {
            String assertMessage = 'Form id must be the same as the one we passed.';
            Assert.areEqual(f[0].Id, elementList[0].Form__c, assertMessage);
            Assert.areEqual(f[0].Id, elementList[1].Form__c, assertMessage);
        }
        return elementList;
    }
}