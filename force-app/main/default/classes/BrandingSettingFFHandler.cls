/**
* @author Alexandr Klachko
* @date 2022-10-24
* @description Trigger Handler on Branding Setting records
*/
public with sharing class BrandingSettingFFHandler extends fflib_SObjectDomain {
	public BrandingSettingFFHandler(List<Branding_Setting__c> records) {
		super(records);
	}
	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> records) {
			return new BrandingSettingFFHandler(records);
		}
	}

	public override void onBeforeInsert() {
		preventSecondDefaultBrandingSetting((List<Branding_Setting__c>) Records, null);
	}

	public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
		preventSecondDefaultBrandingSetting((List<Branding_Setting__c>) Records, (Map<Id,Branding_Setting__c>)existingRecords);
	}

	/**
	 * @description This method prevents creation 2 Brand Settings records with Default__c = TRUE.
	 * @param brandingSettings The brandingSettings is list of new records in trigger.
	 * @param idToBrandingSettingOld is map of old Branding Setting records
	 * @throws Add error to record with Only_One_Default_Branding_Setting label.
	 */
	public static void preventSecondDefaultBrandingSetting(List<Branding_Setting__c> brandingSettings, Map<Id, Branding_Setting__c> idToBrandingSettingOld){
		List<Branding_Setting__c> defaultBrandingSettings = new List<Branding_Setting__c>();
		for (Branding_Setting__c brandingSetting : brandingSettings) {
			if (
				(brandingSetting.Default__c && idToBrandingSettingOld == null) ||
					(
						idToBrandingSettingOld != null && brandingSetting.Default__c &&
							brandingSetting.Default__c != idToBrandingSettingOld.get(brandingSetting.Id).Default__c
					)
				) {
				defaultBrandingSettings.add(brandingSetting);
			}
		}
		if (!defaultBrandingSettings.isEmpty()) {
			if (defaultBrandingSettings.size() > 1) {
				defaultBrandingSettings[0].addError(System.Label.Only_One_Default_Branding_Setting);
			}
			List<Branding_Setting__c> brandingSettingCurrent = new BrandingSettingSelector().getDefaultBrandingSettings();
			if (brandingSettingCurrent.size() > 1) {
				defaultBrandingSettings[0].addError(System.Label.Only_One_Default_Branding_Setting);
			} else {
				for (Branding_Setting__c brandingSetting :brandingSettingCurrent) {
					if (brandingSetting.Id != defaultBrandingSettings[0].Id) {
						defaultBrandingSettings[0].addError(System.Label.Only_One_Default_Branding_Setting);
					}
				}
			}
		}
	}
}