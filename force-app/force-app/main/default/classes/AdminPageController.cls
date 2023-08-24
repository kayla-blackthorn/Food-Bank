public with sharing class AdminPageController {
    public String getNameSpacePrefix() {
        return Helpers.getNameSpacePrefix();
    }

    // putting this here since it needs to be global. we'll call it from one-click install
    @TestVisible
    private static String getAuthURL() {
        String authUrl = 'https://auth.blackthorn.io/salesforce';
        authUrl += '?organization=' + UserInfo.getOrganizationId();
        String env = Helpers.isSandbox() ? 'sandbox' : 'production';
        authUrl += '&environment=' + env;

        // finish the url with the package id and the redirect url
        String redirectParam =
            '&redirect=' +
            Helpers.getDomainNameForApiCall() +
            '/apex/' +
            Helpers.getFieldObjectNS() +
            'AuthCallback';
        authUrl += '&packages=' + Constants.BASE_PACKAGE_ID + redirectParam;
        return authUrl;
    }

    @AuraEnabled
    public static Map<String, Object> getInitData() {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isSysAdmin', AdminPageController.isSysAdmin());
        Blackthorn_Base_Settings__c settings = Blackthorn_Base_Settings__c.getOrgDefaults();
        returnMap.put('isAuthorized', settings.OAuth_Completed__c);
        if (settings.Auth_Timestamp__c != null) {
            returnMap.put('authTime', settings.Auth_Timestamp__c.format('EEEE MMMM d, y'));
        }
        return returnMap;
    }

    @AuraEnabled
    public static Boolean assignPermissionSetToLoggedinUser() {
        PermissionSetService service = new PermissionSetService();
        Map<String, Object> response = service.assignAdminPermissions(
            [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]
        );
        if (response.get('status') == false) {
            //we have an error
            Helpers.errorMsgLightning(new AdminException((String) response.get('errorsMessages')));
        }
        return (Boolean) response.get('status');
    }

    public class AdminException extends Exception {
    }

    @AuraEnabled
    public static String blackthornAuth() {
        String authUrl;
        try {
            authUrl = getAuthURL();
        } catch (Exception e) {
            if (e.getMessage().contains('Unauthorized endpoint')) {
                Helpers.errorMsgLightning(
                    new AdminException(
                        'Unauthorized endpoint. Please make sure the My Domain feature is enabled in Salesforce.'
                    )
                );
            }
            Helpers.errorMsgLightning(e); // raise the error to the lightning component so the user can see it
        }
        return authUrl;
    }

    @TestVisible
    private static Boolean isSysAdmin() {
        Set<String> permissionsToCheck = new Set<String>{ Constants.ADMIN_PERMISSION };
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (gd.get('bt_stripe__Transaction__c') != null) {
            permissionsToCheck.add(Constants.PAYMENT_ADMIN_PERMISSION);
        }
        if (gd.get('conference360__Event__c') != null) {
            permissionsToCheck.add(Constants.EVENT_ADMIN_PERMISSION);
        }
        if (gd.get('btstorefront__Store__c') != null) {
            permissionsToCheck.add(Constants.STOREFRONT_ADMIN_PERMISSION);
        }
        List<PermissionSetAssignment> permissions = [
            SELECT Id, PermissionSet.Name, AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN :permissionsToCheck
        ];
        return (permissions.size() > 0);
    }

    public PageReference processCallback() {
        // look for the status parameter
        if (ApexPages.currentPage().getParameters().get('status') == 'success') {
            Blackthorn_Base_Settings__c settings = Blackthorn_Base_Settings__c.getOrgDefaults();
            settings.OAuth_Completed__c = true;
            settings.Auth_Timestamp__c = Datetime.now();
            settings.Authorizing_User_Id__c = UserInfo.getUserId();
            upsert settings;

            PageReference pr = new PageReference('/lightning/n/' + Helpers.getFieldObjectNS() + 'Blackthorn_App_Admin');
            pr.setRedirect(true);
            return pr;
        } else {
            // failed - show error message
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured while try to authorize the app.')
            );
            return null;
        }
    }
}
