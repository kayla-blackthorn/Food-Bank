public with sharing class BrandingSettingSelector extends fflib_SObjectSelector {
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Branding_Setting__c.Id,
			Branding_Setting__c.Name,
			Branding_Setting__c.Custom_CSS_URL__c,
			Branding_Setting__c.Custom_Label_1__c,
			Branding_Setting__c.Custom_Label_2__c,
			Branding_Setting__c.Custom_Label_3__c,
			Branding_Setting__c.Custom_Label_4__c,
			Branding_Setting__c.Custom_URL_1__c,
			Branding_Setting__c.Custom_URL_2__c,
			Branding_Setting__c.Custom_URL_3__c,
			Branding_Setting__c.Custom_URL_4__c,
			Branding_Setting__c.Default__c,
			Branding_Setting__c.Logo_URL__c,
			Branding_Setting__c.Primary_Color__c,
			Branding_Setting__c.Secondary_Color_Background_Color__c,
			Branding_Setting__c.Theme__c
		};
	}
	public List<Branding_Setting__c> getDefaultBrandingSettings() {
		assertIsAccessible();
		fflib_QueryFactory query = newQueryFactory();
		query.setCondition('Default__c = TRUE');
		return (List<Branding_Setting__c>) Database.query(query.toSOQL());
	}
	public Schema.SObjectType getSObjectType() {
		return Branding_Setting__c.SObjectType;
	}
}