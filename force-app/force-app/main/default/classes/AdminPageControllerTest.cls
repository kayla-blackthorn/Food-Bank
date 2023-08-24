@IsTest
private class AdminPageControllerTest {

    static String TIMEZONE = 'America/New_York';

    @IsTest
    private static void testAUthURL_expecteURLReturned() {
        Test.startTest();
        String url = AdminPageController.blackthornAuth();
        Test.stopTest();
        System.assertEquals(false, String.isBlank(url), 'the url should not be blank');
    }

    @IsTest
    private static void testIsSystemAdminPermission_expectSystemAdmin() {
        Test.startTest();
        Boolean isSysAdmin = AdminPageController.isSysAdmin();
        Test.stopTest();
        System.assertEquals(true, isSysAdmin, 'the user must be system admin');
    }

    @IsTest
    private static void testGetInitData_expecteMapReturned() {
        Test.startTest();
        Map<String, Object> mapInit = AdminPageController.getInitData();
        Test.stopTest();
        System.assertEquals(true, mapInit.containsKey('isSysAdmin'));
        System.assertEquals(false, mapInit.containsKey('authTime'));
        System.assertEquals(true, mapInit.containsKey('isAuthorized'));
    }

    @IsTest
    private static void testGetInitData_expecteMapReturnedWithTimeStamp() {
        Blackthorn_Base_Settings__c settings = Blackthorn_Base_Settings__c.getOrgDefaults();
        settings.OAuth_Completed__c = true;
        settings.Auth_Timestamp__c = Datetime.now();
        settings.Authorizing_User_Id__c = UserInfo.getUserId();
        upsert settings;

        Test.startTest();
        Map<String, Object> mapInit = AdminPageController.getInitData();
        Test.stopTest();
        System.assertEquals(true, mapInit.containsKey('isSysAdmin'));
        System.assertEquals(true, mapInit.containsKey('authTime'));
        System.assertEquals(true, mapInit.containsKey('isAuthorized'));
    }

    @IsTest
	private static void testAssignPermissionToUser_expectSuccess() {
		Profile profileSysAdmin = [SELECT Id FROM Profile WHERE Name = :PermissionSetService.PROFILE_SYS_ADMIN];

		User sysAdmin = new User(
			Alias = 'abcdef0',
			Email = 'test1@permset.com',
			LastName = 'Permset Admin',
			Username = 'Permset_admin_xxxx_@test.com.permset',
			Emailencodingkey = 'UTF-8',
			Languagelocalekey = 'en_US',
			Localesidkey = 'en_US',
			ProfileId = profileSysAdmin.Id,
			Timezonesidkey = TIMEZONE,
			IsActive = true
		);

		insert new List<User> {sysAdmin};
        System.runAs(sysAdmin) {
            Test.startTest();
            Boolean result = AdminPageController.assignPermissionSetToLoggedinUser();
            Test.stopTest();

            System.assertEquals(true, result ,' Permission assignment should error free');
        }
        
	}

    @IsTest
	private static void testAssignPermissionToUser_expectFailure() {
		Profile profileSysAdmin = [SELECT Id FROM Profile WHERE Name = :PermissionSetService.PROFILE_SYS_ADMIN];

		User sysAdmin = new User(
			Alias = 'abcdef0',
			Email = 'test2@permset.com',
			LastName = 'Permset Admin',
			Username = 'Permset_admin_xxxx_@test.com.permset',
			Emailencodingkey = 'UTF-8',
			Languagelocalekey = 'en_US',
			Localesidkey = 'en_US',
			ProfileId = profileSysAdmin.Id,
			Timezonesidkey = TIMEZONE,
			IsActive = true
		);

		insert new List<User> {sysAdmin};
        PermissionSetService pss = new PermissionSetService();
        pss.assignAdminPermissions(new List<User> {sysAdmin}); 
        Boolean exceptionThrown = false;
        System.runAs(sysAdmin) {
            Test.startTest();
            try{
                AdminPageController.assignPermissionSetToLoggedinUser();
            }catch(Exception e){
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(true, exceptionThrown ,' We should be getting an exception while permission set is assigned');
        }
        
	}
}
