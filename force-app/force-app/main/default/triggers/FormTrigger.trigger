trigger FormTrigger on Form__c (after insert) {
    fflib_SObjectDomain.triggerHandler(FormTriggerHandler.class);
}