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
 * A library of methods used to code coverage for SCH_Account object represents Blackthorn Scheduler customer account data.
 *
 *
 **/
@IsTest
public class SCH_AccountTest {

    /*******************************************************************************************************
     * @description Method used to test Smart Schedule account config
     **/
    @IsTest
    public static void testAccountConfig() {
        SCH_Account account = new SCH_Account();
        account.setName('demo');
        account.setAccountNumber('859674');
        account.setOrgId('859674');
        account.setApiKey('859674');
        account.setStatus('new');
        account.setPlan('859674');

        String name = account.getName();
        System.assertEquals('Demo', name, 'This will return account name');
        String account_number = account.getAccountNumber();
        System.assertEquals('859674', account_number, 'This will return account number');
        String org_id = account.getOrgId();
        System.assertEquals('859674', org_id, 'This will return org id');
        String api_key = account.getApiKey();
        System.assertEquals('859674', api_key, 'This will return api key');
        String status = account.getStatus();
        System.assertEquals('New', status, 'This will return status');
        String plan = account.getPlan();
        System.assertEquals('859674', plan, 'This will return plan');
        account.is_user_authenticated = true;
        account.authenticated_user_id = UserInfo.getuserId();
        Boolean is_user_authenticated = account.getIsUserAuthenticated();
        System.assertEquals(true, is_user_authenticated, 'This will return user authenticated');
        Boolean isAuthenticatedUserActive = account.getIsAuthenticatedUserActive();
        System.assertEquals(true, isAuthenticatedUserActive, 'This will return user authenticated status');
        Map < String, Object > authenticated_user = account.getAuthenticatedUser();
        System.assertEquals(false, authenticated_user.isEmpty(), 'This will return user authenticated details');
        
        Boolean featureEnabled = account.getFeatureScheduleEmail();
        featureEnabled = account.getFeatureScheduleSMS();
        featureEnabled = account.getScheduleFeatureEnabled();
        Map<String, String> features = account.getFeaturesTocheck();
        System.assertEquals(2, features.size(), 'There are 2 features with current release');
    }

    /*******************************************************************************************************
     * @description Method used to test Smart Schedule account config
     **/
    @IsTest
    public static void testNoAccountConfig() {
        SCH_Account account = new SCH_Account();
        account.setName('demo');
        account.setAccountNumber('859674');
        account.setOrgId('859674');
        account.setApiKey('859674');
        account.setStatus('new');
        account.setPlan('859674');

        String name = account.getName();
        System.assertNotEquals('Dem', name, 'This will not return account name');
        String account_number = account.getAccountNumber();
        System.assertNotEquals('85967', account_number, 'This will not return account number');
        String org_id = account.getOrgId();
        System.assertNotEquals('85967', org_id, 'This will not return org id');
        String api_key = account.getApiKey();
        System.assertNotEquals('85967', api_key, 'This will not return api key');
        String status = account.getStatus();
        System.assertNotEquals('Draft', status, 'This will not return status');
        String plan = account.getPlan();
        System.assertNotEquals('85967', plan, 'This will not return plan');
        Map<String, String> features = account.getFeaturesTocheck();
        System.assertNotEquals(1, features.size(), 'There are 2 features with current release');
    }

}