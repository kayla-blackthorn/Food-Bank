/**
 * @name : SCH_TriggerHandlerTest
 * @description : Test class containing test methods for SCH_TriggerHandler
 * 
 * @author : Dharmendra Karamchandani
**/
@IsTest
private with sharing class SCH_TriggerHandlerTest {

    /*******************************************************************************************************
     * @description Method used to test create schedule and schedule action 
     **/
    @testSetup
    static void setupData() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Schedule', 'Account', 'Contact', new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, 2, 'days', 'after', 'scheduled', true);
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleSMSAction('Test SMS Schedule', '+14785963210', '+14785963211', 'test message', schedule.Id, true);
    }

    /*******************************************************************************************************
     * @description Method used to test create schedule and schedule action 
     **/
    @IsTest
    static void testProcessRecords() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        System.assert(string.isNotBlank(acc.Id), 'Expected account to be created.');

        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);
        System.assert(string.isNotBlank(con.Id), 'Expected contact to be created.');

        Map<Id, sObject> tMap = new Map<Id, sObject>();
        tMap.put(acc.Id, acc);
        List<sObject> records = new List<sObject>();
        records.add(acc);

        SCH_TriggerHandler.processrecords(System.TriggerOperation.AFTER_INSERT, records, tMap);

        //Update Text field
        Account accClone = acc.Clone(true, true, true, true);
        accClone.Name = 'test a1';
        tMap.put(acc.Id, accClone);
        SCH_TriggerHandler.processrecords(System.TriggerOperation.AFTER_UPDATE, records, tMap);
    }

    /*******************************************************************************************************
     * @description Method used to test filter strucuture for text data type
     **/
    @IsTest
    static void testTextDataTypeStructure() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        acc = [SELECT Id, Name, NumberOfEmployees, CreatedDate, IsDeleted FROM Account WHERE Id =: acc.Id];
        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);

        //Used for text data type
        SCH_DeltaRecordWrapper oDeltaRecordWrapper = new SCH_DeltaRecordWrapper();
        oDeltaRecordWrapper.logic_exp = 'or';

        List<SCH_DeltaRecordWrapper.Filters> lstFilters = new List<SCH_DeltaRecordWrapper.Filters>();

        Map<String, String> opVal = new Map<String, String>();
        opVal.put('contains', 'test');
        opVal.put('=', acc.name);
        opVal.put('!=', 'test');
        opVal.put('starts_with', 'test');
        opVal.put('ends_with', 't a');
        opVal.put('is_null', 'false');
        opVal.put('is_not_null', 'true');
        for (String op: opVal.keySet()) {
            SCH_DeltaRecordWrapper.Filters oFilter = new SCH_DeltaRecordWrapper.Filters();
            oFilter.f_id = '1';
            oFilter.f = 'Name';
            oFilter.f_type = 'STRING';
            oFilter.op = op;
            oFilter.val = opVal.get(op);
            lstFilters.add(oFilter);
        }

        oDeltaRecordWrapper.filters = lstFilters;
        System.assert(SCH_TriggerHandler.evalExpression(acc, oDeltaRecordWrapper, true), 'Expected the evaluate Expression should be true.');
    }

    /*******************************************************************************************************
     * @description Method used to test filter strucuture for number data type
     **/
    @IsTest
    static void testNumberDataTypeStructure() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        acc = [SELECT Id, Name, NumberOfEmployees, CreatedDate, IsDeleted FROM Account WHERE Id =: acc.Id];
        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);

        //Used for text data type
        SCH_DeltaRecordWrapper oDeltaRecordWrapper = new SCH_DeltaRecordWrapper();
        oDeltaRecordWrapper.logic_exp = 'or';

        List<SCH_DeltaRecordWrapper.Filters> lstFilters = new List<SCH_DeltaRecordWrapper.Filters>();
        Map<String, String> opVal = new Map<String, String>();
        opVal.put('=', '0');
        opVal.put('!=', '0');
        opVal.put('>', '0');
        opVal.put('<', '0');
        opVal.put('>=', '0');
        opVal.put('<=', '0');
        opVal.put('is_not_null', 'false');
        opVal.put('is_null', 'true');
        for (String op: opVal.keySet()) {
            SCH_DeltaRecordWrapper.Filters oFilter = new SCH_DeltaRecordWrapper.Filters();
            oFilter.f_id = '1';
            oFilter.f = 'NumberOfEmployees';
            oFilter.f_type = 'number';
            oFilter.op = op;
            oFilter.val = opVal.get(op);
            lstFilters.add(oFilter);
        }

        oDeltaRecordWrapper.filters = lstFilters;
        System.assert(SCH_TriggerHandler.evalExpression(acc, oDeltaRecordWrapper, true), 'Expected the evaluate Expression should be true.');
    }

    /*******************************************************************************************************
     * @description Method used to test filter strucuture for date data type
     **/
    @IsTest
    static void testDateDataTypeStructure() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        acc = [SELECT Id, Name, NumberOfEmployees, CreatedDate, IsDeleted FROM Account WHERE Id =: acc.Id];
        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);

        //Used for text data type
        SCH_DeltaRecordWrapper oDeltaRecordWrapper = new SCH_DeltaRecordWrapper();
        oDeltaRecordWrapper.logic_exp = 'or';

        List<SCH_DeltaRecordWrapper.Filters> lstFilters = new List<SCH_DeltaRecordWrapper.Filters>();
        Map<String, String> opVal = new Map<String, String>();
        opVal.put('is_not_null', 'true');
        opVal.put('is_not_null', 'true');
        opVal.put('is_null', 'false');
        opVal.put('=', System.now() + '');
        opVal.put('<>', System.now() + '');
        for (String op: opVal.keySet()) {
            SCH_DeltaRecordWrapper.Filters oFilter = new SCH_DeltaRecordWrapper.Filters();
            oFilter.f_id = '1';
            oFilter.f = 'CreatedDate';
            oFilter.f_type = 'date';
            oFilter.op = op;
            oFilter.val = opVal.get(op);
            lstFilters.add(oFilter);
        }

        oDeltaRecordWrapper.filters = lstFilters;
        System.assert(SCH_TriggerHandler.evalExpression(acc, oDeltaRecordWrapper, true), 'Expected the evaluate Expression should be true.');
    }

    /*******************************************************************************************************
     * @description Method used to test filter strucuture for boolean data type
     **/
    @IsTest
    static void testBooleanDataTypeStructure() {
        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        acc = [SELECT Id, Name, NumberOfEmployees, CreatedDate, IsDeleted FROM Account WHERE Id =: acc.Id];
        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);

        //Used for text data type
        SCH_DeltaRecordWrapper oDeltaRecordWrapper = new SCH_DeltaRecordWrapper();
        oDeltaRecordWrapper.logic_exp = 'or';

        List<SCH_DeltaRecordWrapper.Filters> lstFilters = new List<SCH_DeltaRecordWrapper.Filters>();
        Map<String, String> opVal = new Map<String, String>();
        opVal.put('is_not_null', 'true');
        opVal.put('=', 'false');
        opVal.put('<>', 'true');
        opVal.put('is_null', 'false');
        for (String op: opVal.keySet()) {
            SCH_DeltaRecordWrapper.Filters oFilter = new SCH_DeltaRecordWrapper.Filters();
            oFilter.f_id = '1';
            oFilter.f = 'IsDeleted';
            oFilter.f_type = 'checkbox';
            oFilter.op = op;
            oFilter.val = opVal.get(op);
            lstFilters.add(oFilter);
        }

        oDeltaRecordWrapper.filters = lstFilters;
        System.assert(SCH_TriggerHandler.evalExpression(acc, oDeltaRecordWrapper, true), 'Expected the evaluate Expression should be true.');
    }
}