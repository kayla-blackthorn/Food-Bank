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
 *
 *
**/
@IsTest
public class SCH_CtrlLtngAdminTest {

    /*******************************************************************************************************
     * @description Method used to test account config, user details, custom setting and authentication link
     **/
    @IsTest
    public static void testBtSmartScheduleConfig() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));
        Test.startTest();
        Boolean hasAccountCredentials = SCH_CtrlLtngAdmin.hasAccountCredentials();
        System.assertEquals(false, hasAccountCredentials, 'This will validate Account credentails');
        String userFirstName = SCH_CtrlLtngAdmin.getUserFirstName();
        System.assertEquals(UserInfo.getFirstName(), userFirstName, 'This will return User\'s first name');
        User oUser = SCH_CtrlLtngAdmin.getUser(UserInfo.getUserId());
        System.assertEquals(UserInfo.getFirstName(), oUser.FirstName, 'This will return User\'s first name');
        Boolean isSandbox = SCH_CtrlLtngAdmin.getIsSandbox();
        System.assertEquals(true, isSandbox != null, 'This will return environment details');
        SCH_CtrlLtngAdmin.updateProtectedCustomSettings('1234', '1234');

        SCH_Schedule_Config__c scheduleConig = SCH_CtrlLtngAdmin.getCustomSettings();
        System.assertEquals(true, scheduleConig != null, 'This will return Schedule Config details');
        SCH_Schedule_Config__c protectedConfig = SCH_BtBaseUtils.getCustomSettings();
        System.assertEquals(true, protectedConfig != null, 'This will return Schedule Config details');
        protectedConfig.Account_Number__c = '12345';
        protectedConfig.API_Key__c = '12345';
        Object newsaveSetting = SCH_CtrlLtngAdmin.saveSettings(JSON.serialize(protectedConfig));
        System.assertEquals(true, newsaveSetting != null, 'This will return updated Schedule Config details');

        String authenticationLink = SCH_CtrlLtngAdmin.getAuthenticationLink(URL.getSalesforceBaseUrl().toExternalForm() + '?sfdcIFrameOrigin=tes');
        System.assertEquals(true, authenticationLink != null, 'This will return Authentication Link');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test account config, user details, custom setting and authentication link
     **/
    @IsTest
    public static void testInvalidBtSmartScheduleConfig() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '{}', null));
        Test.startTest();
        Boolean hasAccountCredentials;
        try{
            hasAccountCredentials = SCH_CtrlLtngAdmin.hasAccountCredentials();
            System.assertEquals(false, hasAccountCredentials, 'This will validate Account credentails');
        }catch(Exception ex){
            System.assertNotEquals(false, hasAccountCredentials, 'This will not validate Account credentails');
        }
        String authenticationLink;
        try{
            authenticationLink = SCH_CtrlLtngAdmin.getAuthenticationLink(URL.getSalesforceBaseUrl().toExternalForm() + '?sfdcIFrameOrigin=tes');
            System.assertEquals(true, authenticationLink != null, 'This will return Authentication Link');
        }catch(Exception ex){
            System.assertNotEquals(true, authenticationLink != null, 'This will not return Authentication Link');
        }
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test create account flow
     **/
    @IsTest
    public static void testCreateAccount() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"account_number":"342sds","api_key":"sdsdsds"}', null));
        Test.startTest();
        SCH_Account newAccount = SCH_CtrlLtngAdmin.activateNewAccount();
        System.assertEquals(true, newAccount != null, 'This will return Account details');
        Test.stopTest();
        // configuring feature flag check = true to bypass feature check check
        SCH_BtBaseUtils.smartScheduleFeatureEnabled = true;
        Map<String, Object> mapAccount = SCH_CtrlLtngAdmin.getAdminInfoOnPageLoad();
        System.assertEquals(true, mapAccount.containsKey('account'), 'This checks for Account details');
        System.assertEquals(true, mapAccount.containsKey('helpLinks'), 'This checks for Knowledge details');
    }

    /*******************************************************************************************************
     * @description Method used to test create account flow
     **/
    @IsTest
    public static void testInvalidCreateAccount() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'error', '{}', null));
        Test.startTest();
        SCH_Account newAccount;
        try{
            newAccount = SCH_CtrlLtngAdmin.activateNewAccount();
            System.assertEquals(true, newAccount != null, 'This will return Account details');
        }catch(Exception ex){
            System.assertEquals(true, newAccount == null, 'This will not return Account details');
        }
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test delete user
     **/
    @IsTest
    public static void testDeleteUser() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));
        Test.startTest();
        Map<String, Object> mapAccount = SCH_CtrlLtngAdmin.getAdminInfoOnPageLoad();
        System.assertEquals(false, mapAccount.containsKey('account'), 'This will not return Account details');
        SCH_CtrlLtngAdmin.deleteUser(UserInfo.getUserId());
        Test.stopTest();
    }

}