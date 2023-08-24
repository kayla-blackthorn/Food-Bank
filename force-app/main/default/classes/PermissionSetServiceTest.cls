@IsTest
private class PermissionSetServiceTest {
	static String TIMEZONE = 'America/New_York';
    @IsTest
	private static void testAssignPermissionToUser_expectSuccess() {
		Profile profileStandard = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
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

		User standard = new User(
			Alias = 'abcdef1',
			Email = 'test2@permset.com',
			LastName = 'Permset Standard',
			UserName = 'Permset_standard_xxxx_@test.com.permset',
			Emailencodingkey = 'UTF-8',
			Languagelocalekey = 'en_US',
			Localesidkey = 'en_US',
			ProfileId = profileStandard.Id,
			Timezonesidkey = TIMEZONE,
			IsActive = true
		);

		insert new List<User> {sysAdmin, standard};

        Test.startTest();
        PermissionSetService pss = new PermissionSetService();
        Map<String, Object> response = pss.assignAdminPermissions(new List<User> {sysAdmin});
        Test.stopTest();

        System.assertEquals(true, (Boolean)response.get('status') ,' Permission assignment should error free');
	}

    @IsTest
	private static void testAssignPermissionToUser_expectError() {
		Profile profileSysAdmin = [SELECT Id FROM Profile WHERE Name = :PermissionSetService.PROFILE_SYS_ADMIN];

		User sysAdmin = new User(
			Alias = 'abcdef0',
			Email = 'test3@permset.com',
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
        Map<String, Object> response = pss.assignAdminPermissions(new List<User> {sysAdmin}); 
        Test.startTest();
        response = pss.assignAdminPermissions(new List<User> {sysAdmin});
        Test.stopTest();

        System.assertEquals(false, (Boolean)response.get('status'), 'Assignment will fail since user already has the same permission set assigned');
        System.assertEquals(false, ((String)response.get('errorsMessages')).contains('already assigned'), 'Assignment failed error message should be thrown');
	}

    @IsTest
    private static void testGetAdminPermission_returnRecords(){
        Test.startTest();
        PermissionSetService pss = new PermissionSetService();
        List<PermissionSet> records = pss.getAdminPermissionSets();
        Test.stopTest();  
        System.assertEquals(1, records.size(), 'Should atleast return 1 record for base admin permission set'); 
    }

}