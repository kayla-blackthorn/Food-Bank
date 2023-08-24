@IsTest
public with sharing class BrandingSettingFFHandlerTest {
	@IsTest
	static void checkDefaultBrandingSettingTest(){
		Boolean recordUpdated = true;
		Branding_Setting__c branding = new Branding_Setting__c();
		branding.Name = 'Branding Setting Test 2';
		branding.Primary_Color__c = 'Blue';
		branding.Secondary_Color_Background_Color__c = 'Red';
		branding.Logo_URL__c = 'https://google.com';
		branding.Theme__c = 'Light';
		branding.Default__c = true;
		insert branding;
		Branding_Setting__c branding2 = new Branding_Setting__c();
		branding2.Name = 'Branding Setting Test 2';
		branding2.Primary_Color__c = 'Blue';
		branding2.Secondary_Color_Background_Color__c = 'Red';
		branding2.Logo_URL__c = 'https://google.com';
		branding2.Theme__c = 'Light';
		branding2.Default__c = true;
		try {
			insert branding2;
			recordUpdated = true;
		} catch (Exception ex) {
			recordUpdated = false;
			System.assertEquals(true, ex.getMessage().contains(System.Label.Only_One_Default_Branding_Setting));
		}
		System.assertEquals(false, recordUpdated);
		branding2.Default__c = false;
		insert branding2;

		branding2.Default__c = true;
		Test.startTest();
		try {
			update branding2;
			recordUpdated = true;
		} catch (Exception ex) {
			recordUpdated = false;
			System.assertEquals(true, ex.getMessage().contains(System.Label.Only_One_Default_Branding_Setting));
		}
		Test.stopTest();
		System.assertEquals(false, recordUpdated);
	}
}