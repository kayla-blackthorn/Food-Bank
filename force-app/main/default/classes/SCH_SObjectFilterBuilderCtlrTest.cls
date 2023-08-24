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
 * This is used as test class for sObject filter builder apex class
 *
**/
@IsTest
public class SCH_SObjectFilterBuilderCtlrTest {
    /*******************************************************************************************************
     * @description Method used to test sObject Filter Builder
     **/
    @IsTest
    public static void testsObjectFilterBuilder(){
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        
        Test.startTest();
        Map<String, sObjectType> mapsObjectType = SCH_SObjectFilterBuilderCtlr.GLOBAL_SOBJECTTYPE;
        System.assertEquals(true, !mapsObjectType.isEmpty());

        Map<String, Object> mapInitData = SCH_SObjectFilterBuilderCtlr.getInitData(schedule.Id, 'SCH_Schedule__c', new List<String>{'Name'});
        System.assertEquals(true, !mapInitData.isEmpty());

        Map<String, Object> mapPreparesObjectFields = SCH_SObjectFilterBuilderCtlr.preparesObjectFields('Contact', 'Parent');
        System.assertEquals(true, !mapPreparesObjectFields.isEmpty());

        Map<String,String> mapReferenceFieldsForObject = SCH_SObjectFilterBuilderCtlr.getReferenceFieldsForObject('Contact', 'Parent');
        System.assertEquals(true, !mapReferenceFieldsForObject.isEmpty());

        List<String> referenceFieldDetails = SCH_SObjectFilterBuilderCtlr.getReferenceFieldDetails('Contact', 'AccountId');
        System.assertEquals(true, referenceFieldDetails.size()>0);

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test sObject Filter Builder
     **/
    @IsTest
    public static void testInvalidsObjectFilterBuilder(){
        Test.startTest();
        Map<String, Object> mapInitData = SCH_SObjectFilterBuilderCtlr.getInitData(null, 'SCH_Schedule__c', new List<String>{'Name'});
        System.assertNotEquals(true, !mapInitData.isEmpty());

        Map<String, Object> mapPreparesObjectFields = SCH_SObjectFilterBuilderCtlr.preparesObjectFields('Contact', 'Admin');
        System.assertNotEquals(true, mapPreparesObjectFields.isEmpty());

        Map<String,String> mapReferenceFieldsForObject = SCH_SObjectFilterBuilderCtlr.getReferenceFieldsForObject('Contact', 'Admin');
        System.assertNotEquals(true, mapReferenceFieldsForObject.isEmpty());

        Test.stopTest();
    }

}