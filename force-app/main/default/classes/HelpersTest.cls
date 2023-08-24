@IsTest
private class HelpersTest {

    @IsTest
    private static void testGetDomainNameForApiCall() {
        Test.startTest();
        String apiCall = Helpers.getDomainNameForApiCall();
        Test.stopTest();

        System.assertEquals(false, String.isBlank(apiCall), 'The domain name should be returned');
    }

    @IsTest
    private static void testIsSandbox() {
        Test.startTest();
		Organization org =[Select Id, IsSandbox, OrganizationType FROM Organization LIMIT 1];
        System.assertEquals(org.IsSandbox, Helpers.isSandbox(), 'This test will return true in scratch orgs & false in production');
        Test.stopTest(); 
    }

    @IsTest
    private static void testLogHelper() {
        Boolean error = false;

        Test.startTest();
        try {
            Helpers.log('This is a Log Test :)');
            Helpers.log(new Account());
            Helpers.logError(new Helpers.HelperException('Opps I did it again'));
        } catch (Exception e) {
            error = true;
        }
        Test.stopTest();
        System.assertEquals(false, error, 'we should not encounter any error while passing different kind of objects to helper');
    }

    @IsTest
    private static void test_errorMsgLightning() {
        Helpers.HelperException he = new Helpers.HelperException('test exception type');
        try {
            Helpers.errorMsgLightning(he);
        } catch (Exception e) {
            System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
        }
    }

    @IsTest
    private static void test_getFieldObjectNS() {
        Test.startTest();
		String ns = Helpers.getFieldObjectNS();
        Test.stopTest();
		if(ns == '') {
			//this means we are in normal developer orgs hence this value will be blank
			System.assertEquals('', ns, 'Since we are dev org without namespace we cannot have this value set');
		} else {
			System.assertEquals(Constants.BASE_NAMESPACE + '__', ns, 'The namespace should match to value configure in constant string');
		}
        
    }

    @IsTest
    private static void test_isLightning() {
        Test.startTest();
        Boolean isLightning = Helpers.isLightning();
        Test.stopTest();
        System.assertEquals(false, isLightning, 'In test this value is false');
    }
}
