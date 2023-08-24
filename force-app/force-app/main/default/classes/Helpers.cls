public with sharing class Helpers {

    public class HelperException extends Exception {
    }

    public static String FIELD_OBJ_NS;
    public static String NAMESPACE;

    // Generate a random base 32 key that's 10 characters long - also removes some confusing characters - https://www.crockford.com/base32.html
	public static String generateKey() {
		String key = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
		// to ensure a better distribution of numbers & letters we're replacing some letters we don't want to use with numbers
		key = key.replaceAll('U', '0');
		key = key.replaceAll('u', '1');
		key = key.replaceAll('I', '2');
		key = key.replaceAll('i', '3');
		key = key.replaceAll('l', '4');
		key = key.replaceAll('L', '5');
		key = key.replaceAll('O', '6');
		key = key.replaceAll('o', '7');
		key = key.replaceAll('\\+', '8');
		key = key.replaceAll('/', '9');
		key = key.replaceAll('=', '');
		key = key.subString(0, 10); // only use 10 characters
		return key;
	}


    public static String getDomainNameForApiCall() {
        // This method will return the domain name or instance if domain is not registered
        return Url.getOrgDomainUrl().toExternalForm(); // #1768
    }



    public static Boolean isSandbox() {
        List<Organization> orgs = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        return (orgs.size() > 0 && orgs[0].IsSandbox);
    }

    public static void errorMsgLightning(Exception e) {
        logError(e); // also log it to save line in controller
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
    }
    public static void errorMsgLightning(String message) {
        AuraHandledException ahe = new AuraHandledException(message);
        ahe.setMessage(message);
        throw ahe;
    }

    public static void logError(Exception e) {
        System.debug(LoggingLevel.ERROR, e.getMessage());
        System.debug(LoggingLevel.ERROR, e.getStackTraceString());
    }

    public static void log(String msg) {
        System.debug(LoggingLevel.INFO, msg);
    }

    public static void log(SObject obj) {
        System.debug(LoggingLevel.INFO, obj);
    }
    // if in namespaced org, will return conference360__ - else ''
    public static String getFieldObjectNS() {
        //check if there is a object with the namespace
        if (FIELD_OBJ_NS == null) {
            FIELD_OBJ_NS = getNameSpacePrefix() == null ? '' : Constants.BASE_NAMESPACE + '__';
        }
        return FIELD_OBJ_NS;
    }
    // if in namespaced org, will return conference360
    public static String getNameSpacePrefix() {
        //check if there is a object with the namespace
        if (NAMESPACE == null) {
            String stripeCustomerObj = Constants.BASE_NAMESPACE + '__Translation__c';
            Map<String, Schema.SObjectType> objList = Schema.getGlobalDescribe();
            Schema.SObjectType objName = objList.get(stripeCustomerObj);
            NAMESPACE = objName == null ? null : Constants.BASE_NAMESPACE;
        }
        return NAMESPACE;
    }

    public static Boolean isLightning() {
        String theme = UserInfo.getUiThemeDisplayed();
        return (theme == 'Theme4d' || theme == 'Theme4t' || theme == 'Theme4u');
    }

    /**
     * Apex method to generate fake record ids in tests
     * Created by Stephen Willcock
     * https://foobarforce.com/2013/08/15/apex-method-of-the-day-string-repeat/
     */
	static Integer s_num = 1;
	public static String getFakeId(Schema.SObjectType sot) {
		String result = String.valueOf(s_num++);
		return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
	}

}
