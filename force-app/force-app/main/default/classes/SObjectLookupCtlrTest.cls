/**
 * @name : SObjectLookupCtlrTest
 * @description Test class containing test methods for SObjectLookupCtlr
 * 
 * @author : Dharmendra Karamchandani
 */
@IsTest
private class SObjectLookupCtlrTest {
    /*******************************************************************************************************
     * @description Method used to test get data for QueueSobject
     **/
    @IsTest
    private static void testlookupNoRecords() {
        Map<String, Object> params = new Map<String, Object>();
        String objectName = 'QueueSobject';
        Map<String, String> fieldMap = new Map<String, String>();
        params.put('fields', JSON.serialize(fieldMap));
        Map<String, Object> result = SObjectLookupCtlr.getData(objectName, fieldMap, null, null, null, null, false);
        System.assertEquals(result.get('label') + '', SObjectLookupCtlr.GLOBAL_SOBJECT_TYPE.get(objectName).getDescribe().getLabel(),
            'Validating Queue Sobject label');

        System.assertEquals(result.get('records'), null, 'Validating records should be null');

    }
    /*******************************************************************************************************
     * @description Method used to test get data for User sObject
     **/
    @IsTest
    private static void testlookupUserRecords() {
        Map<String, Object> params = new Map<String, Object>();
        String objectName = 'User';
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, Object> result = SObjectLookupCtlr.getData(objectName, fieldMap, null, null, null, new List<Id> {
            Userinfo.getUserId()
        }, true);
        System.assertEquals(result.get('label') + '', SObjectLookupCtlr.GLOBAL_SOBJECT_TYPE.get(objectName).getDescribe().getLabel(),
            'Validating Queue Sobject label');

        String fieldId = 'Id';
        String fieldName = 'Name';
        String fieldSearch = 'Name';
        System.assertEquals(fieldId, result.get('fieldId') + '', 'fieldId should be ' + fieldId);
        System.assertEquals(fieldName, result.get('fieldName') + '', 'fieldName should be ' + fieldName);
        System.assertEquals(fieldSearch, result.get('fieldSearch') + '', 'fieldSearch should be ' + fieldSearch);
        System.assertNotEquals(null, result.get('records'), 'Validating records should not be null');

        List<User> records = (List<User>) result.get('records');
        System.assertEquals(1, records.size(), 'Only 1 record should in the list');
    }
    /*******************************************************************************************************
     * @description Method used to test lookup configuration for User sObject
     **/
    @IsTest
    private static void testlookupConfiguration() {
        Map<String, Object> params = new Map<String, Object>();
        String objectName = 'User';
        Map<String, String> fieldMap = new Map<String, String>();
        String fieldId = 'Id';
        String fieldName = 'LastName';
        String fieldSearch = 'FirstName';

        fieldMap.put('Id', fieldId);
        fieldMap.put('Name', fieldName);
        fieldMap.put('Search', fieldSearch);
        fieldMap.put('additionalDisplayFields', 'username,lastmodifiedById');

        Map<String, Object> result = SObjectLookupCtlr.getData(objectName, fieldMap, UserInfo.getFirstName(), null, 'email', null, false);
        System.assertEquals(fieldId, result.get('fieldId') + '', 'fieldId should be ' + fieldId);
        System.assertEquals(fieldName, result.get('fieldName') + '', 'fieldName should be ' + fieldName);
    }
}