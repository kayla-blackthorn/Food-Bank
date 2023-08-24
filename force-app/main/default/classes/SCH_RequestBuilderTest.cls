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
 * A Test class for library of methods used to construct HTTP requests.
 *
 *
**/
@IsTest
public class SCH_RequestBuilderTest {
    /*******************************************************************************************************
     * @description Method used to test request builder service for account config, get schedules and help links
     **/
    @IsTest
    public static void testRequestBuilderService() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();

        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"name":"Test"}', null));

        Test.startTest();
        SCH_RequestBuilder oRequestBuilder = new SCH_RequestBuilder();
        oRequestBuilder.setApiKey('test');
        System.assertEquals('test', oRequestBuilder.apiKey);
        oRequestBuilder.setApiToken('test');
        System.assertEquals('test', oRequestBuilder.apiToken);

        SCH_Account oAccount = oRequestBuilder.get('/schedule', new Map < String, String > {
            'content-type' => 'application/json'
        }).getAccount();
        System.assertEquals('Test', oAccount.getName());

        Map < String, Object > mapSMSDetails = new SCH_ResponseWrapper('{"name":"test"}').getSMSDetails();
        System.assertEquals('test', mapSMSDetails.get('name') + '');

        Map < String, Object > mapArticleHelpLink = new SCH_ResponseWrapper('{"name":"demo article"}').getHelpLink();
        System.assertEquals('demo article', mapArticleHelpLink.get('name') + '');
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test exception scenario for get schedules
     **/
    @IsTest
    public static void testScheduleGetException() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'failed', '{"error":"failed"}', null));

        Test.startTest();
        try {
            SCH_Account oAccount = new SCH_RequestBuilder().get('/schedule', new Map < String, String > {
                'content-type' => 'application/json'
            }).getAccount();
            System.assertEquals(null, oAccount);
        } catch (System.Exception e) {
            System.assertEquals('failed', e.getMessage());
        }

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test create schedule and schedule action at api side
     **/
    @IsTest
    public static void testSchedulePost() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"records":[{"name":"Test"}]}', null));
        Test.startTest();
        SCH_Schedule oSchedule = new SCH_RequestBuilder().get('/schedule', new Map < String, String > {
            'content-type' => 'application/json'
        }).getSchedules();
        System.assertEquals('Test', oSchedule.getRecords()[0].getName());

        SCH_ExecutionSchedule oExecutionSchedule = new SCH_RequestBuilder().get('/logs', new Map < String, String > {
            'content-type' => 'application/json'
        }).getExecutionSchedules();
        System.assertEquals(1, oExecutionSchedule.getRecords().size());

        SCH_Schedule newSchedule = new SCH_RequestBuilder().post('/schedules', new Map < String, String > {
            'content-type' => 'application/json',
            'body' => '{"name":"Test"}'
        }).getSchedules();
        System.assertEquals(1, newSchedule.getRecords().size());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test exception scenario for create schedule and schedule action at api side
     **/
    @IsTest
    public static void testSchedulePostException() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'failed', '{"error":"failed"}', null));

        Test.startTest();
        try {
            SCH_Schedule newSchedule = new SCH_RequestBuilder().post('/schedules', new Map < String, String > {
                'content-type' => 'application/json',
                'body' => '{"name":"Test"}'
            }).getSchedules();
            System.assertEquals(null, newSchedule);
        } catch (System.Exception e) {
            System.assertEquals('failed', e.getMessage());
        }

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test update schedule scenario
     **/
    @IsTest
    public static void testSchedulePut() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"records":[{"name":"Test"}]}', null));
        Test.startTest();
        SCH_Schedule newSchedule = new SCH_RequestBuilder().put('/schedules', new Map < String, String > {
            'content-type' => 'application/json',
            'body' => '{"name":"Test"}'
        }).getSchedules();
        System.assertEquals(1, newSchedule.getRecords().size());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test exception scenario for update schedule scenario
     **/
    @IsTest
    public static void testSchedulePutException() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'failed', '{"error":"failed"}', null));

        Test.startTest();
        try {
            SCH_Schedule newSchedule = new SCH_RequestBuilder().put('/schedules', new Map < String, String > {
                'content-type' => 'application/json',
                'body' => '{"name":"Test"}'
            }).getSchedules();
            System.assertEquals(null, newSchedule);
        } catch (System.Exception e) {
            System.assertEquals('failed', e.getMessage());
        }

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test update schedule scenario with schedule body
     **/
    @IsTest
    public static void testSchedulePutScheduleBody() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"records":[{"name":"Test"}]}', null));
        Test.startTest();
        SCH_Schedule newSchedule = new SCH_RequestBuilder().put('/schedules', new Map < String, String > {
            'content-type' => 'application/json',
            'schedule_body' => '{"name":"Test"}'
        }).getSchedules();
        System.assertEquals(1, newSchedule.getRecords().size());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test update schedule scenario with direct request body
     **/
    @IsTest
    public static void testSchedulePutDirectRequestBody() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"records":[{"name":"Test"}]}', null));
        Test.startTest();
        SCH_Schedule newSchedule = new SCH_RequestBuilder().put('/schedules', new Map < String, String > {
            'content-type' => 'application/json',
            'direct_request_body' => '{"name":"Test"}'
        }).getSchedules();
        System.assertEquals(1, newSchedule.getRecords().size());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test delete schedule scenario
     **/
    @IsTest
    public static void testScheduleDelete() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{"records":[]}', null));
        Test.startTest();
        SCH_Schedule newSchedule = new SCH_RequestBuilder().del('/schedules', new Map < String, String > {
            'content-type' => 'application/json',
            'body' => '{"name":"Test"}'
        }).getSchedules();
        System.assertEquals(0, newSchedule.getRecords().size());
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test exception scneario for delete schedule scenario
     **/
    @IsTest
    public static void testScheduleDelException() {
        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(400, 'failed', '{"error":"failed"}', null));

        Test.startTest();
        try {
            SCH_Schedule newSchedule = new SCH_RequestBuilder().del('/schedules', new Map < String, String > {
                'content-type' => 'application/json',
                'body' => '{"name":"Test"}'
            }).getSchedules();
            System.assertEquals(0, newSchedule.getRecords().size());
        } catch (System.Exception e) {
            System.assertEquals('failed', e.getMessage());
        }

        Test.stopTest();
    }

}