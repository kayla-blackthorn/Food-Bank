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
 * This is used as apex controller which used for admin page
 *
 *
 **/
public with sharing class SCH_CtrlLtngAdmin {

    /*******************************************************************************************************
     * @description Method used to check Schedule Configuration 
     * @return Boolean
     * @param none
     **/
    @AuraEnabled
    public static Boolean hasAccountCredentials() {
        SCH_Schedule_Config__c protectedConfig = SCH_BtBaseUtils.getCustomSettings();
        return (protectedConfig.API_Key__c != null && protectedConfig.Account_Number__c != null && protectedConfig.Account_Number__c.length()> 2);
    }

    /*******************************************************************************************************
     * @description Method used to get Current user's first name
     * @return String
     * @param none
     **/
    @AuraEnabled
    public static String getUserFirstName() {
        return UserInfo.getFirstName();
    }

    /*******************************************************************************************************
     * @description Method used to get Current user's first name
     * @return User
     * @param userId: User sObject record Id
     **/
    @AuraEnabled
    public static User getUser(Id userId) {
        // Security Review fixes
        userId = SCH_BtBaseUtils.secureIdInjection(userId);
        // always user if Id is not null
        if (userId != NULL) {
            userId = SCH_BtBaseUtils.secureIdInjection(userId);
            List<User> users = SCH_BtBaseUtils.getUsersByIds(new Set<Id> {
                userId
            });
            if (users.size() > 0) {
                return users[0];
            }
        }
        return new User();
    }

    /*******************************************************************************************************
     * @description Method used to check current salesforce environment either sandbox or production
     * @return Boolean
     * @param none
     **/
    @AuraEnabled
    public static Boolean getIsSandbox() {
        Organization org = SCH_BtBaseUtils.fetchCompanyInfo();
        // PKG Org id.
        return (org.IsSandbox || org.OrganizationType == 'Developer Edition') && org.Id != '00D5j00000Agi3eEAB';
    }

    /*******************************************************************************************************
     * @description Method used to check current salesforce environment either sandbox or production
     * @return none
     * @param accountNumber: Smart Schedule API's account number
     * @param apiKey: Smart Schedule API's key
     **/
    @AuraEnabled
    public static void updateProtectedCustomSettings(String accountNumber, String apiKey) {
        try {
            SCH_Schedule_Config__c protectedConfig = SCH_BtBaseUtils.getCustomSettings();
            protectedConfig.Account_Number__c = accountNumber;
            protectedConfig.API_Key__c = apiKey;
            upsert protectedConfig;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to create new api account
     * @return SCH_Account
     * @param none
     **/
    @AuraEnabled
    public static SCH_Account activateNewAccount() {
        SCH_Schedule_Config__c protectedConfig = SCH_BtBaseUtils.getCustomSettings();
        try {
            SCH_Account account = SCH_AccountService.createAccount(UserInfo.getOrganizationName());
            protectedConfig.Account_Number__c = account.getAccountNumber();
            protectedConfig.API_Key__c = account.getApiKey();
            upsert protectedConfig;
            return account;
        } catch (Exception e) {
            system.debug('============================= e.getMessage() ' + e.getMessage());
            system.debug('============================= e.getStackTraceString() ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to return the Org Level Configuration Settings with all default values
     * @return SCH_Schedule_Config__c
     * @param none
     **/
    @AuraEnabled
    public static SCH_Schedule_Config__c getCustomSettings() {
        return SCH_BtBaseUtils.getCustomSettings();
    }

    /*******************************************************************************************************
     * @description Method used to update the Schedule Config custom setting data
     * @return SCH_Schedule_Config__c
     * @param none
     **/
    @AuraEnabled
    public static Object saveSettings(String settingsStr) {
        // Deserialize into a custom setting
        SCH_Schedule_Config__c settings = (SCH_Schedule_Config__c) JSON.deserialize(settingsStr, SCH_Schedule_Config__c.class);

        try {
            upsert settings;
            return settings;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to delete account for smart schedule
     * @return none
     * @param userId
     **/
    @AuraEnabled
    public static void deleteUser(String userId) {
        // Security Review fixes
        userId = SCH_BtBaseUtils.secureIdInjection(userId);
        try {
            SCH_AccountService.deleteUser(userId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     *  @return the oauth authentication URL
     *
     *  Getter method for the Oauth authentication url
     *
     **/
    @AuraEnabled
    public static String getAuthenticationLink(String retUrl) {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Boolean isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;

        String uri = EncodingUtil.urlEncode(config.URL__c, 'UTF-8');
        String apiVersion = EncodingUtil.urlEncode(config.API_Version__c, 'UTF-8');

        String baseUrl = String.format('https://{0}/{1}', new List<String> {
            uri,
            apiversion
        });
        String state = isSandbox ? 'sandbox' : 'production';
        String instance = isSandbox ? 'test' : 'login';
        Map<String, String> stateData = new Map<String, String>();
        stateData.put('org_type', state);
        if (String.isNotBlank(retUrl)) {
            // preparing lightning instance URL dynamically
            stateData.put('return_url', prepareReturnURL(retUrl));
        }
        String authenticateMeURL = String.format('https://{0}.salesforce.com/services/oauth2/authorize' +
            '?response_type=code&client_id=' +
            '3MVG9pRzvMkjMb6kiDCTptiSqupKgT07GAyLL0dixVQEnePvWzh6muVhXTp4spRAObMUJZNlhZ1LaLF9XlTnt' +
            '&redirect_uri={1}/oauth_callback',
            new List<String> {
                instance,
                baseUrl
            });
        authenticateMeURL += '&state=' + JSON.serialize(stateData);
        return authenticateMeURL;
    }

    /*******************************************************************************************************
     * @description Method used to get account details for smart schedule
     * @return SCH_Account
     * @param none
     **/
    @AuraEnabled
    public static SCH_Account getAccount() {
        try {
            return SCH_AccountService.getAccount();
        } catch (Exception e) {
            System.debug('> ' + e.getStacktraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to get all admin info on page load
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> getAdminInfoOnPageLoad() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('hasAccountCredentials', hasAccountCredentials());
        result.put('userFirstName', getUserFirstName());
        result.put('isSandbox', getIsSandbox());
        result.put('isScheduleFeatureEnabled', SCH_BtBaseUtils.smartScheduleFeatureEnabled);
        result.put('btSchedulePermissions', SCH_BtBaseUtils.getBTSchedulePermission());
        try {
            result.put('helpLinks', SCH_AccountService.getHelpLink());
            if (SCH_BtBaseUtils.smartScheduleFeatureEnabled && hasAccountCredentials()) {
                result.put('account', SCH_AccountService.getAccount());
            }
            result.put('isValid', true);
        } catch (Exception e) {
            result.put('isValid', false);
            String errorMessage = e.getMessage();
            if (errorMessage.tolowerCase().indexof('not authorized') >= 0) {
                errorMessage = System.Label.SCH_Acc_Invalid_Credentials;
            }
            result.put('errorMessage', errorMessage);
        }
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to get all admin info on page load
     * @return SCH_Account
     * @param jsonBody
     **/
    @AuraEnabled
    public static SCH_Account updateAccount(String jsonBody){
        Map<String, String> mapBody = new Map<String, String>();
        mapBody.put('body', jsonBody);
        return SCH_AccountService.updateAccount(mapBody);
    }

    /*******************************************************************************************************
     * @description Method used to get smart schedule admin page
     * @return String
     * @param none
     **/
    static String prepareReturnURL(String retUrl) {
        List<String> uParts = retUrl.split('\\?');
        if (uParts.size() == 2) {
            uParts = uParts[1].split('&');
            for (String uPart: uParts) {
                List<String> params = uPart.split('=');
                if (params.size() == 2 && params[0] == 'sfdcIFrameOrigin' && String.isNotBlank(params[1])) {
                    return params[1].split('.com')[0] + '.com/lightning/n/bt_base__SCH_Administration';
                }
            }
        }
        return retUrl;
    }
}