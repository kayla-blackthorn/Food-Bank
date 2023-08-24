/**
 * Blackthorn.io, Inc CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io, Inc
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io, Inc and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io, Inc
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io, Inc.
 *
 * 
 * This is used as service class for SMS
 *
**/
public with sharing class SCH_SMSService {
    @testVisible
    static String sObjectName = 'simplesms__PhoneNumber__c';
    @testVisible
    static String displayNameField = 'simplesms__Display_Name__c';
    @testVisible
    static String phoneField = 'simplesms__PhoneNumber__c';

     /*******************************************************************************************************
     * @description Method used to get available phone numbers
     * @return List<SelectOption>
     * @param isCampaign: Used to filter Available for Campaign
     **/
    public static List<SelectOption> getAvailablePhoneNumbers(Boolean isCampaign) {
        List<SelectOption> options = new List<SelectOption>();

        if (SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.containsKey(sObjectName)) {
            fflib_QueryFactory qf = new fflib_QueryFactory(SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(sObjectName));
            qf.setEnforceFLS(true);
            qf.selectField(displayNameField);
            qf.selectField(phoneField);

            if (SCH_BtBaseUtils.INSTALLED_SIMPLESMS) {
                qf.setCondition('simplesms__IsActive__c = true and simplesms__Available_for_Campaign__c = ' + isCampaign);
                qf.addOrdering(new fflib_QueryFactory.Ordering('simplesms__PhoneNumber__c', 'simplesms__Display_Name__c', fflib_QueryFactory.SortOrder.ASCENDING));
            }
            String query = qf.toSOQL();

            Map<Id, SObject> phoneNumbers = new Map<Id, SObject>(Database.query(query));

            Set<Id> accessiblePhoneNumberIds = new Set<Id>();
            for (UserRecordAccess ura: [SELECT RecordId
                    FROM UserRecordAccess
                    WHERE UserId =: UserInfo.getUserId()
                    AND RecordId IN: phoneNumbers.keySet()
                    AND HasReadAccess = true
                ]) {
                accessiblePhoneNumberIds.add(ura.RecordId);
            }

            for (SObject num: phoneNumbers.values()) {
                // skip if this number is not accessible to the current User.
                if (!accessiblePhoneNumberIds.contains(num.Id) || num.get(phoneField) == null) {
                    continue;
                }

                // if Display_Name is not specified to picking number as label
                String label = num.get(displayNameField) == null ? (num.get(phoneField) + '') : (num.get(displayNameField) + '');
                options.add(new SelectOption((num.get(phoneField) + ''), label));
            }
        }
        return options;
    }

    /*******************************************************************************************************
     * @description Method used to preview SMS
     * @return none
     * @param mapSMSParameters: sms & phone details
     **/
    public static void sendTestSMS(Map<String, Object> mapSMSParameters) {
        SCH_AccountService.doSendSMSPreview(mapSMSParameters);
    }
}