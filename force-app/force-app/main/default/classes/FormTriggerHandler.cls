public with sharing class FormTriggerHandler extends fflib_SObjectDomain {
    public FormTriggerHandler(List<Branding_Setting__c> records) {
        super(records);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new FormTriggerHandler(records);
        }
    }

    public override void onAfterInsert() {
        //check if this cloned forms then handle the deepclone
        handleFormClone((List<Form__c>) Records);
    }

    private static void handleFormClone(List<Form__c> sObjectList) {
        Map<Id, Id> sourceIdSet = new Map<Id, Id>();
        for (Form__c form : (Form__c[]) sObjectList) {
            if (form.isClone()) {
                sourceIdSet.put(form.getCloneSourceId(), form.Id);
            }
        }
        if (!sourceIdSet.isEmpty()) {
            FormService.deepCloneForm(sourceIdSet);
        }
    }
}
