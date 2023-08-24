public with sharing class FormBigListGroupSelector extends fflib_SObjectSelector {
    public static List<Schema.SObjectField> FIELDS_FORM_BIG_LIST_GROUP = new List<Schema.SObjectField> {
		Form_Big_List_Group__c.Name
	};

	public List<Schema.SObjectField> getSObjectFieldList() {
		return FIELDS_FORM_BIG_LIST_GROUP;
	}

    public Schema.SObjectType getSObjectType() {
		return Form_Big_List_Group__c.SObjectType;
	}

    public List<Form_Big_List_Group__c> getBigListGroups(Integer limitCount) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setLimit(limitCount);
        return (List<Form_Big_List_Group__c>) Database.query(queryFactory.toSOQL());
    }
}
