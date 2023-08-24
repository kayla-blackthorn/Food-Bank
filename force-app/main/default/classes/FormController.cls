public with sharing class FormController {
    public static Integer MAX_LIMIT = 10000;

    public class FormElementAndConditions {
        @AuraEnabled
        public Form_Element__c element { get; set; }
        @AuraEnabled
        public List<Form_Element_Condition__c> conditions { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Form_Element__c> loadFormElements(Id formId) {
        FormElementSelector selector = new FormElementSelector();
        return selector.getElementsByFormId(formId, 2000);
    }

    @AuraEnabled(cacheable=true)
    public static List<Form_Element_Condition__c> loadFormElementConditions(Id formId) {
        FormElementConditionSelector selector = new FormElementConditionSelector();
        return selector.getConditionsByFormId(formId, 2000);
    }

    @AuraEnabled(cacheable=true)
    public static List<Form_Big_List_Group__c> loadBigListGroups() {
        FormBigListGroupSelector selector = new FormBigListGroupSelector();
        return selector.getBigListGroups(2000);
    }

    @AuraEnabled(cacheable=true)
    public static List<MapToList> listMapToObjects() {
        List<Form_Question_Map_To_Object__mdt> mcs = Form_Question_Map_To_Object__mdt.getAll().values();
        List<MapToList> mapToObjects = new List<MapToList>();
        for(Form_Question_Map_To_Object__mdt mc : mcs) {
            mapToObjects.add(new MapToList(mc.label, mc.Object_API_Name__c));
        }
        return mapToObjects;
    }

    @AuraEnabled
    public static FormElementAndConditions saveElementAndConditions(
        Form_Element__c element,
        List<Form_Element_Condition__c> conditions,
        List<Form_Element_Condition__c> conditionsToRemove
    ) {
        if (conditions.size() + conditionsToRemove.size() + 1 > MAX_LIMIT) {
            Helpers.errorMsgLightning(System.label.Form_Builder_Max_Limit);
        }
        if (String.isBlank(element.Id) || element.getPopulatedFieldsAsMap().size() > 1) {
            // The element need to be created or updated
            upsert element;
        }
        if (conditions.size() > 0) {
            for (Form_Element_Condition__c condition : conditions) {
                condition.Next_Form_Element__c = element.Id;
            }
            upsert conditions;
        }
        if (conditionsToRemove.size() > 0) {
            delete conditionsToRemove;
        }

        FormElementSelector elementSelector = new FormElementSelector();
        Form_Element__c freshElement = elementSelector.selectById(element.Id);
        FormElementConditionSelector conditionSelector = new FormElementConditionSelector();
        List<Form_Element_Condition__c> freshConditions = conditionSelector.getConditionsByControlledElement(
            freshElement,
            2000
        );
        FormElementAndConditions ec = new FormElementAndConditions();
        ec.element = freshElement;
        ec.conditions = freshConditions;
        return ec;
    }

    @AuraEnabled
    public static void saveFormElements(List<Form_Element__c> elements) {
        if (elements.size() > MAX_LIMIT) {
            Helpers.errorMsgLightning(System.label.Form_Builder_Max_Limit);
        } else if (elements.size() > 0) {
            upsert elements;
        }
    }

    @AuraEnabled
    public static void deleteFormElements(List<Form_Element__c> elements) {
        if (elements.size() > MAX_LIMIT) {
            Helpers.errorMsgLightning(System.label.Form_Builder_Max_Limit);
        } else if (elements.size() > 0) {
            delete elements;
        }
    }


    public class MapToList {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public MapToList(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
