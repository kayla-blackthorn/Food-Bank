trigger BrandingSettingTrigger on Branding_Setting__c (before insert, before update) {
	fflib_SObjectDomain.triggerHandler(BrandingSettingFFHandler.class);
}