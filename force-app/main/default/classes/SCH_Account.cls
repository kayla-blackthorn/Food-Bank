/**
 * Blackthorn.io ENTERPRISES CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io Enterprises, LLC
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io Enterprises, LLC and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io Enterprises, LLC
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io Enterprises, LLC.
 *
 * 
 * A SCH_Account object represents Blackthorn Scheduler customer account data.
 *
 *
 **/
public with sharing class SCH_Account {
    private String name;
    private String account_number;
    private String org_id;
    private String api_key;
    private String status;
    private String plan;

    //Feature schedule properties
    private boolean feature_schedule_sms;
    private boolean feature_schedule_email;

    @TestVisible
    private Boolean is_user_authenticated;

    private Map<String, Object> authenticated_user;
    @TestVisible
    private String authenticated_user_id;
    private Boolean isAuthenticatedUserActive;

    private Boolean create_execution_records_in_org;
    private String create_log_records_in_org_as;
    private Boolean attach_log_records_in_email;

    /**
     *  @return the name
     *
     *  Return the name of the account.
     *
     **/
    @AuraEnabled
    public String getName() {
        return name.capitalize();
    }

    /**
     *  @return the account number
     *
     *  Return the account number of the account.
     *
     **/
    @AuraEnabled
    public String getAccountNumber() {
        return account_number;
    }

    /**
     *  @return the Org Id
     *
     *  Return the Org Id of the account.
     *
     **/
    @AuraEnabled
    public String getOrgId() {
        return org_id;
    }

    /**
     *  @return the API Key
     *
     *  Return the API Key of the account.
     *
     **/
    @AuraEnabled
    public String getApiKey() {
        return api_key;
    }

    /**
     *  @return the Status
     *
     *  Return the Status of the account.
     *
     **/
    @AuraEnabled
    public String getStatus() {
        return status.capitalize();
    }

    /**
     *  @return the Plan
     *
     *  Return the Plan of the account.
     *
     **/
    @AuraEnabled
    public String getPlan() {
        return plan == null ? '' : plan.capitalize();
    }

    @AuraEnabled
    public Boolean getScheduleFeatureEnabled() {
        return SCH_BtBaseUtils.smartScheduleFeatureEnabled;
    }

    @AuraEnabled
    public Boolean getFeatureScheduleSMS() {
        return feature_schedule_sms;
    }

    @AuraEnabled
    public Boolean getFeatureScheduleEmail() {
        return feature_schedule_email;
    }

    @AuraEnabled
    public Boolean getCreateExecutionRecordsInOrg() {
        return create_execution_records_in_org;
    }

    @AuraEnabled
    public String getCreateLogInOrgAs() {
        return create_log_records_in_org_as;
    }

    @AuraEnabled
    public Boolean getAttachLogRecordsInEmail() {
        return attach_log_records_in_email;
    }

    /**
     *  @return Map<String, String> 
     *
     *  Return a Map<String, String> feature identify key with feature action label
     *
     **/
    @AuraEnabled
    public Map<String, String> getFeaturesTocheck() {
        Map<String, String> features = new Map<String, String>();
        features.put('featureScheduleEmail', 'Email');
        features.put('featureScheduleSMS', 'SMS');
        return features;
    }

    /**
     *  @param  name - the name of the Simple Account
     *
     *  Setter for the name.
     *  
     **/
    public void setName(String name) {
        this.name = name;
    }

    /**
     *  @param  accountNumber - the account number of the Simple Account
     *
     *  Setter for the account number.
     *  
     **/
    public void setAccountNumber(String accountNumber) {
        account_number = accountNumber;
    }

    /**
     *  @param  orgId - the org id of the Simple Account
     *
     *  Setter for the org id.
     *  
     **/
    public void setOrgId(String orgId) {
        org_id = orgId;
    }

    /**
     *  @param  apiKey - the api key of the Simple Account
     *
     *  Setter for the api key.
     *  
     **/
    public void setApiKey(String apiKey) {
        api_key = apiKey;
    }

    /**
     *  @param  status - the status of the Simple Account
     *
     *  Setter for the status.
     *  
     **/
    public void setStatus(String status) {
        this.status = status;
    }

    /**
     *  @param  createExecutionRecordsInOrg
     *
     *  Setter for the status.
     *  
     **/
    public void setCreateExecutionRecordsInOrg(Boolean createExecutionRecordsInOrg) {
        this.create_execution_records_in_org = createExecutionRecordsInOrg;
    }

    /**
     *  @param  createLogInOrgAs
     *
     *  Setter for the status.
     *  
     **/
    public void setCreateLogInOrgAs(String createLogInOrgAs) {
        this.create_log_records_in_org_as = createLogInOrgAs;
    }

    /**
     *  @param  attachLogRecordsInEmail
     *
     *  Setter for the status.
     *  
     **/
    public void setAttachLogRecordsInEmail(boolean attachLogRecordsInEmail) {
        this.attach_log_records_in_email = attachLogRecordsInEmail;
    }

    /**
     *  @param  plan - the plan of the Simple Account
     *
     *  Setter for the plan.
     *  
     **/
    public void setPlan(String plan) {
        this.plan = plan;
    }

    /**
     * @return Boolean indication user authenticated or not?
     **/
    @AuraEnabled
    public Boolean getIsUserAuthenticated() {
        return is_user_authenticated;
    }

    /**
     * @return authenticated user details
     **/
    @AuraEnabled
    public Map<String, Object> getAuthenticatedUser() {
        if (authenticated_user == null) {
            authenticated_user = new Map<String, Object>();
            if (is_user_authenticated == true && authenticated_user_id != null) {
                prepareAuthenticateUser();
            }
        }
        return authenticated_user;
    }

    /**
     * @return authenticated user active or not
     **/
    @AuraEnabled
    public Boolean getIsAuthenticatedUserActive() {
        if (isAuthenticatedUserActive == null && is_user_authenticated == true && authenticated_user_id != null) {
            prepareAuthenticateUser();
        }
        return isAuthenticatedUserActive;
    }
    void prepareAuthenticateUser() {
        authenticated_user = new Map<String, Object>();
        for (User u: [SELECT Id, FirstName, LastName, Email, IsActive
                FROM User
                WHERE Id =: authenticated_user_id
                WITH SECURITY_ENFORCED
            ]) {
            isAuthenticatedUserActive = u.IsActive;
            if (isAuthenticatedUserActive == true) {
                authenticated_user.put('firstName', u.FirstName);
                authenticated_user.put('lastName', u.LastName);
                authenticated_user.put('email', u.Email);
                authenticated_user.put('salesforceId', u.Id);
            }
        }

        if (authenticated_user.containsKey('salesforceId')) {
            List<Organization> orgs = [SELECT Id, IsSandbox FROM Organization WHERE Id =: UserInfo.getOrganizationId()];
            if (!orgs.isEmpty()) {
                authenticated_user.put('orgType', orgs[0].IsSandbox ? 'sandbox' : 'production');
            }
        }
    }
}