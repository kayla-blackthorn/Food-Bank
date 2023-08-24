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
 * A test cladd for library of static utility methods.
 *
**/
@IsTest
global class SCH_BtBaseUtilsTest {

    /*******************************************************************************************************
     * @description Method used to create common test data for all methods
     **/
    @testSetup
    static void dataSetup() {
        EmailTemplate et = new EmailTemplate(developerName = 'test' + System.now().format().replaceAll('[^\\w]+', ''), FolderId = UserInfo.getUserId(), TemplateType = 'Text', Name = 'test');
        insert et;
    }

    /*******************************************************************************************************
     * @description Method used to BT Base util methods
     **/
    @IsTest
    public static void testBtBaseUtil() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        System.assertEquals(true, schedule.Id != null, 'This will return Schedule Details');

        Test.startTest();
        String PGK_NAMESPACE = SCH_BtBaseUtils.PGK_NAMESPACE;
        System.assertEquals(true, PGK_NAMESPACE != null, 'This will return PGK_NAMESPACE');
        String PGK_API_URI = SCH_BtBaseUtils.PGK_API_URI;
        System.assertEquals(true, PGK_API_URI != null, 'This will return PGK_API_URI');
        String PGK_API_VERSION = SCH_BtBaseUtils.PGK_API_VERSION;
        System.assertEquals(true, PGK_API_VERSION != null, 'This will return PGK_API_VERSION');
        Boolean applyQueriRowsLimit = SCH_BtBaseUtils.applyQueriRowsLimit;
        System.assertEquals(true, applyQueriRowsLimit != null, 'This will return applyQueriRowsLimit');
        String nameSpacePreFix = SCH_BtBaseUtils.nameSpacePreFix;
        System.assertEquals(true, nameSpacePreFix != null, 'This will return nameSpacePreFix');
        Map<String, sObjectType> GLOBAL_SOBJECTTYPE = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE;
        System.assertEquals(true, !GLOBAL_SOBJECTTYPE.isEmpty(), 'This will return GLOBAL_SOBJECTTYPE');
        String NAME_SPACE = SCH_BtBaseUtils.NAME_SPACE;
        System.assertEquals(true, NAME_SPACE != null, 'This will return NAME_SPACE');
        Boolean PACKAGE_INSTALLABLE = SCH_BtBaseUtils.PACKAGE_INSTALLABLE;
        System.assertEquals(true, PACKAGE_INSTALLABLE != null, 'This will return PACKAGE_INSTALLABLE');
        Boolean INSTALLED_SIMPLESMS = SCH_BtBaseUtils.INSTALLED_SIMPLESMS;
        System.assertEquals(true, INSTALLED_SIMPLESMS != null, 'This will return INSTALLED_SIMPLESMS');
        Boolean INSTALLED_BTSCHEDULE = SCH_BtBaseUtils.INSTALLED_BTSCHEDULE;
        System.assertEquals(true, INSTALLED_BTSCHEDULE != null, 'This will return INSTALLED_BTSCHEDULE');
        User currentUser = SCH_BtBaseUtils.currentUser;
        System.assertEquals(true, currentUser != null, 'This will return currentUser');

        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        List<User> getUsersByIds = SCH_BtBaseUtils.getUsersByIds(new Set<Id> {
            UserInfo.getUserId()
        });
        System.assertEquals(true, getUsersByIds.size() > 0, 'This will return users');
        Map<String, Boolean> getSMSPermission = SCH_BtBaseUtils.getSMSPermission();
        System.assertEquals(true, !getSMSPermission.isEmpty(), 'This will return sms permissions');
        Map<String, Boolean> getBTSchedulePermission = SCH_BtBaseUtils.getBTSchedulePermission();
        System.assertEquals(true, !getBTSchedulePermission.isEmpty(), 'This will return BT schedule permissions');
        String getNamedFieldForsObject = SCH_BtBaseUtils.getNamedFieldForsObject('Account');
        System.assertEquals('Name', getNamedFieldForsObject, 'This will return name field for contact sobject');
        String getsObjectLabel = SCH_BtBaseUtils.getsObjectLabel('Account');
        System.assertEquals(true, String.isNotBlank(getsObjectLabel), 'This will return Account\'s  label');
        Map<String, String> getsObjectFieldDynamic = SCH_BtBaseUtils.getsObjectFieldDynamic('Account', true);
        System.assertEquals(true, !getsObjectFieldDynamic.isEmpty(), 'This will return sobject field');
        Map<String, Schema.DescribeFieldResult> getsObjectLookupFields = SCH_BtBaseUtils.getsObjectLookupFields(Account.sObjectType.getDescribe(), new Set<String>());
        System.assertEquals(true, !getsObjectLookupFields.isEmpty(), 'This will return sObject lookup fields');
        Map<String, Map<String, Schema.DescribeFieldResult >> getSobjectFieldsWithType = SCH_BtBaseUtils.getSobjectFieldsWithType(Account.sObjectType.getDescribe(), new Set<String> {
            'picklist'
        });
        System.assertEquals(true, !getSobjectFieldsWithType.isEmpty(), 'This will return sobject fields with date types');
        SCH_BtBaseUtils.maintainSObjects(new List<Schema.SObjectType> {
            SCH_Schedule__c.sObjectType.getDescribe().getSobjectType()
        }, [SELECT Id FROM SCH_Schedule__c limit 1]);

        String secureIdInjection = SCH_BtBaseUtils.secureIdInjection('test');
        System.assertEquals(true, String.isNotBlank(secureIdInjection), 'This will return secure soql');
        sObjectType objType = SCH_BtBaseUtils.getSObjectType('Account');
        System.assertEquals(((SObject) Type.forName('Account').newInstance()).getSObjectType(), objType, 'This will return sobject type');
        String soql = SCH_BtBaseUtils.prepareSObjectQuery('Account', new List<String> {
            'Name'
        }, null, null);
        System.assertEquals(true, String.isNotBlank(soql), 'This will return soql');
        String new_soql = SCH_BtBaseUtils.prepareSObjectQuery(Account.sObjectType.getDescribe().getSobjectType(), new List<String> {
            'Name'
        }, null, null);
        System.assertEquals(true, String.isNotBlank(new_soql), 'This will return soql using sObject type');
        User user = SCH_BtBaseUtils.fetchUserInfo();
        System.assertEquals(true, user != null, 'This will return user details');
        Organization org = SCH_BtBaseUtils.fetchCompanyInfo();
        System.assertEquals(true, org != null, 'This will return user details');
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = SCH_BtBaseUtils.fetchOrgWideEmailAddress();
        System.assertEquals(true, lstOrgWideEmailAddress != null, 'This will return OrgWideEmailAddress details');
        List<String> lstOrgWideEmails = SCH_BtBaseUtils.fetchOrgWidEmails();
        System.assertEquals(true, lstOrgWideEmails != null, 'This will return OrgWideEmailAddress details');
        Map<String, String> mapPicklistValues = SCH_BtBaseUtils.getPicklistValues('Account', 'Industry');
        System.assertEquals(true, !mapPicklistValues.isEmpty(), 'This will return picklist values');
        Map<String, String> mapSObjectAPINameWithSObjectLabel = SCH_BtBaseUtils.getSObjectAPINameWithSObjectLabel();
        System.assertEquals(true, !mapSObjectAPINameWithSObjectLabel.isEmpty(), 'This will return sObject API Name with Label');

        Id orgWideEmailAddressId;
        for (OrgWideEmailAddress owea: [SELECT Id FROM OrgWideEmailAddress limit 1]) {
            orgWideEmailAddressId = owea.Id;
        }
        Id emailTemplateId;
        for (EmailTemplate et: [SELECT Id FROM EmailTemplate limit 1]) {
            emailTemplateId = et.Id;
        }

        Map<String, OrgWideEmailAddress> mapOrgWideEmailAddress = SCH_BtBaseUtils.getOrgWideEmailAddresses(new List<String> {
            'test@test.com'
        });
        System.assertEquals(false, !mapOrgWideEmailAddress.isEmpty(), 'This will return Org Wide EmailAddress');

        Set<Schema.SObjectType> setSObjectType = SCH_BtBaseUtils.getActivityEnabledSObjects();
        System.assertEquals(true, setSObjectType != null, 'This will return Org Wide EmailAddress');

        List<Messaging.SendEmailResult> lstSendEmailResult = SCH_BtBaseUtils.sendMail(orgWideEmailAddressId, new List<String> {
            'test@test.com'
        }, schedule.Id, emailTemplateId, true);
        System.assertEquals(true, !lstSendEmailResult.isEmpty(), 'This will return send email results');

        List<sObject> lstObjects = SCH_BtBaseUtils.fetchSObjectByIds(SCH_BtBaseUtils.nameSpacePreFix + 'SCH_Schedule__c', new Set<String> {
            'Name'
        }, new Set<String> {
            schedule.Id
        });
        System.assertEquals(true, !lstObjects.isEmpty(), 'This will return sObject record Details');


        Map<String, Integer> mapOrgEmailLimits = SCH_BtBaseUtils.getOrgEmailLimits();
        System.assertEquals(true, !mapOrgEmailLimits.isEmpty(), 'This will return Org Email limits');
        SCH_BtBaseUtils.removeSObjects(new List<Schema.SObjectType> {
            SCH_Schedule__c.sObjectType.getDescribe().getSobjectType()
        }, [SELECT Id FROM SCH_Schedule__c limit 1]);

        String sObjectFieldLabel = SCH_BtBaseUtils.getsObjectFieldLabel('Contact', 'Name');
        System.assertEquals(true, String.isNotBlank(sObjectFieldLabel), 'This will return label of specified field');

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to BT Base util methods
     **/
    @IsTest
    public static void testNoBtBaseUtil() {
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Email Schedule', 'Account', 'Contact', true);
        System.assertEquals(true, schedule.Id != null, 'This will return Schedule Details');

        Test.startTest();
        String PGK_NAMESPACE = SCH_BtBaseUtils.PGK_NAMESPACE;
        System.assertNotEquals(true, PGK_NAMESPACE == null, 'This will not return PGK_NAMESPACE');
        String PGK_API_URI = SCH_BtBaseUtils.PGK_API_URI;
        System.assertNotEquals(true, PGK_API_URI == null, 'This will not return PGK_API_URI');
        String PGK_API_VERSION = SCH_BtBaseUtils.PGK_API_VERSION;
        System.assertNotEquals(true, PGK_API_VERSION == null, 'This will not return PGK_API_VERSION');
        Boolean applyQueriRowsLimit = SCH_BtBaseUtils.applyQueriRowsLimit;
        System.assertNotEquals(true, applyQueriRowsLimit == null, 'This will not return applyQueriRowsLimit');
        String nameSpacePreFix = SCH_BtBaseUtils.nameSpacePreFix;
        System.assertNotEquals(true, nameSpacePreFix == null, 'This will not return nameSpacePreFix');
        Map<String, sObjectType> GLOBAL_SOBJECTTYPE = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE;
        System.assertNotEquals(true, GLOBAL_SOBJECTTYPE.isEmpty(), 'This will not return GLOBAL_SOBJECTTYPE');
        String NAME_SPACE = SCH_BtBaseUtils.NAME_SPACE;
        System.assertNotEquals(true, NAME_SPACE == null, 'This will not return NAME_SPACE');
        Boolean PACKAGE_INSTALLABLE = SCH_BtBaseUtils.PACKAGE_INSTALLABLE;
        System.assertNotEquals(true, PACKAGE_INSTALLABLE == null, 'This will not return PACKAGE_INSTALLABLE');
        Boolean INSTALLED_SIMPLESMS = SCH_BtBaseUtils.INSTALLED_SIMPLESMS;
        System.assertNotEquals(true, INSTALLED_SIMPLESMS == null, 'This will not return INSTALLED_SIMPLESMS');
        Boolean INSTALLED_BTSCHEDULE = SCH_BtBaseUtils.INSTALLED_BTSCHEDULE;
        System.assertNotEquals(true, INSTALLED_BTSCHEDULE == null, 'This will not return INSTALLED_BTSCHEDULE');
        User currentUser = SCH_BtBaseUtils.currentUser;
        System.assertNotEquals(true, currentUser == null, 'This will not return currentUser');

        SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
        List<User> getUsersByIds = SCH_BtBaseUtils.getUsersByIds(new Set<Id> {
            UserInfo.getUserId()
        });
        System.assertNotEquals(true, getUsersByIds.size() == 0, 'This will not return users');
        Map<String, Boolean> getSMSPermission = SCH_BtBaseUtils.getSMSPermission();
        System.assertNotEquals(true, getSMSPermission.isEmpty(), 'This will not return sms permissions');
        Map<String, Boolean> getBTSchedulePermission = SCH_BtBaseUtils.getBTSchedulePermission();
        System.assertNotEquals(true, getBTSchedulePermission.isEmpty(), 'This will not return BT schedule permissions');
       
        String getsObjectLabel = SCH_BtBaseUtils.getsObjectLabel('Account');
        System.assertNotEquals(true, String.isBlank(getsObjectLabel), 'This will not return Account\'s  label');
        Map<String, String> getsObjectFieldDynamic = SCH_BtBaseUtils.getsObjectFieldDynamic('Account', true);
        System.assertNotEquals(true, getsObjectFieldDynamic.isEmpty(), 'This will not return sobject field');
        Map<String, Schema.DescribeFieldResult> getsObjectLookupFields = SCH_BtBaseUtils.getsObjectLookupFields(Account.sObjectType.getDescribe(), new Set<String>());
        System.assertNotEquals(true, getsObjectLookupFields.isEmpty(), 'This will not return sObject lookup fields');
        Map<String, Map<String, Schema.DescribeFieldResult >> getSobjectFieldsWithType = SCH_BtBaseUtils.getSobjectFieldsWithType(Account.sObjectType.getDescribe(), new Set<String> {
            'picklist'
        });
        System.assertNotEquals(true, getSobjectFieldsWithType.isEmpty(), 'This will not return sobject fields with date types');
        

        String secureIdInjection = SCH_BtBaseUtils.secureIdInjection('test');
        System.assertNotEquals(true, String.isBlank(secureIdInjection), 'This will not return secure soql');

        String soql = SCH_BtBaseUtils.prepareSObjectQuery('Account', new List<String> {
            'Name'
        }, null, null);
        System.assertNotEquals(true, String.isBlank(soql), 'This will not return soql');
        String new_soql = SCH_BtBaseUtils.prepareSObjectQuery(Account.sObjectType.getDescribe().getSobjectType(), new List<String> {
            'Name'
        }, null, null);
        System.assertNotEquals(true, String.isBlank(new_soql), 'This will not return soql using sObject type');
        User user = SCH_BtBaseUtils.fetchUserInfo();
        System.assertNotEquals(true, user == null, 'This will not return user details');
        Organization org = SCH_BtBaseUtils.fetchCompanyInfo();
        System.assertNotEquals(true, org == null, 'This will not return user details');
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = SCH_BtBaseUtils.fetchOrgWideEmailAddress();
        System.assertNotEquals(true, lstOrgWideEmailAddress == null, 'This will not return OrgWideEmailAddress details');
        List<String> lstOrgWideEmails = SCH_BtBaseUtils.fetchOrgWidEmails();
        System.assertNotEquals(true, lstOrgWideEmails == null, 'This will not return OrgWideEmailAddress details');
        Map<String, String> mapPicklistValues = SCH_BtBaseUtils.getPicklistValues('Account', 'Industry');
        System.assertNotEquals(true, mapPicklistValues.isEmpty(), 'This will not return picklist values');
        Map<String, String> mapSObjectAPINameWithSObjectLabel = SCH_BtBaseUtils.getSObjectAPINameWithSObjectLabel();
        System.assertNotEquals(true, mapSObjectAPINameWithSObjectLabel.isEmpty(), 'This will not return sObject API Name with Label');

        Id orgWideEmailAddressId;
        for (OrgWideEmailAddress owea: [SELECT Id FROM OrgWideEmailAddress limit 1]) {
            orgWideEmailAddressId = owea.Id;
        }
        Id emailTemplateId;
        for (EmailTemplate et: [SELECT Id FROM EmailTemplate limit 1]) {
            emailTemplateId = et.Id;
        }

        Map<String, OrgWideEmailAddress> mapOrgWideEmailAddress = SCH_BtBaseUtils.getOrgWideEmailAddresses(new List<String> {
            'test@test.com'
        });
        System.assertNotEquals(false, mapOrgWideEmailAddress.isEmpty(), 'This will not return Org Wide EmailAddress');

        Set<Schema.SObjectType> setSObjectType = SCH_BtBaseUtils.getActivityEnabledSObjects();
        System.assertNotEquals(true, setSObjectType == null, 'This will not return Org Wide EmailAddress');

        List<Messaging.SendEmailResult> lstSendEmailResult = SCH_BtBaseUtils.sendMail(orgWideEmailAddressId, new List<String> {
            'test@test.com'
        }, schedule.Id, emailTemplateId, true);
        System.assertNotEquals(true, lstSendEmailResult.isEmpty(), 'This will not return send email results');

        List<sObject> lstObjects = SCH_BtBaseUtils.fetchSObjectByIds(SCH_BtBaseUtils.nameSpacePreFix + 'SCH_Schedule__c', new Set<String> {
            'Name'
        }, new Set<String> {
            schedule.Id
        });
        System.assertNotEquals(true, lstObjects.isEmpty(), 'This will not return sObject record Details');


        Map<String, Integer> mapOrgEmailLimits = SCH_BtBaseUtils.getOrgEmailLimits();
        System.assertNotEquals(true, mapOrgEmailLimits.isEmpty(), 'This will not return Org Email limits');

        String sObjectFieldLabel = SCH_BtBaseUtils.getsObjectFieldLabel('Contact', 'Name');
        System.assertNotEquals(true, String.isBlank(sObjectFieldLabel), 'This will not return label of specified field');

        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test send message to Recipeints
     **/
    @IsTest
    public static void testSendMessage() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));

        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        System.assert(string.isNotBlank(acc.Id), 'Expected account to be created.');

        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);
        System.assert(string.isNotBlank(con.Id), 'Expected contact to be created.');

        //Schedule Record
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Schedule', 'Account', 'Contact', new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, 2, 'days', 'after', 'scheduled', true);
        System.assert(string.isNotBlank(schedule.Id), 'Expected schedule to be created.');

        //Schedule Action Record
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleSMSAction('Test SMS Schedule', '+14785963210', '+14785963211', 'test message', schedule.Id, true);
        System.assert(string.isNotBlank(scheduleAction.Id), 'Expected schedule Action to be created.');

        //Org Wide email address
        String orgWideEmailAddressId;
        for (OrgWideEmailAddress owea: [SELECT Id FROM OrgWideEmailAddress limit 1]) {
            orgWideEmailAddressId = owea.Id;
        }

        //default email template Id
        String templateId;
        for (EmailTemplate et: [SELECT Id FROM EmailTemplate limit 1]) {
            templateId = et.Id;
        }

        Test.startTest();
        SCH_BtBaseUtils s = new SCH_BtBaseUtils();
        //Prepare schedule Metadata
        s.setScheduleMetadata('{"scheduleId": "' + schedule.Id + '","actionId": "' + scheduleAction.Id + '","executionId": "' + con.Id + '"}');
        //Prepare Recipient Data
        List<SCH_BtBaseUtils.RecipientData> ss = new List<SCH_BtBaseUtils.RecipientData>();
        ss.add(new SCH_BtBaseUtils.RecipientData(con.Id, con.Email));
        //Send emails to Recipients
        s.sendEmail(ss, orgWideEmailAddressId, templateId);
        // changing class configuration only if BT Messaging is not installed
        if(!SCH_BtBaseUtils.INSTALLED_SIMPLESMS){
            SCH_SMSService.sObjectName = 'Contact';
            SCH_SMSService.displayNameField = 'Name';
            SCH_SMSService.phoneField = 'Phone';
        }
        List<SelectOption> records = SCH_SMSService.getAvailablePhoneNumbers(false);
        Test.stopTest();
    }

    /*******************************************************************************************************
     * @description Method used to test send message to Recipeints without email
     **/
    @IsTest
    public static void testSendMessageWithoutEmailValue() {
        Test.setMock(HttpCalloutMock.class, new SCH_TestUtilities.MockSingleRequest(201, 'success', '{}', null));

        // Base Object
        Account acc = SCH_TestUtilities.createAccount('Test a', true);
        System.assert(string.isNotBlank(acc.Id), 'Expected account to be created.');

        // Related Object
        Contact con = SCH_TestUtilities.createContact('Test', 'test@t.com', acc.Id, true);
        System.assert(string.isNotBlank(con.Id), 'Expected contact to be created.');

        //Schedule Record
        SCH_Schedule__c schedule = SCH_TestUtilities.createSchedule('Test Schedule', 'Account', 'Contact', new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, new Map<String, String> {
            'filterField' => 'Name',
            'filterOp' => 'contains',
            'filterValue' => 'test'
        }, 2, 'days', 'after', 'scheduled', true);
        System.assert(string.isNotBlank(schedule.Id), 'Expected schedule to be created.');
        //Schedule Action Record
        SCH_Schedule_Action__c scheduleAction = SCH_TestUtilities.createScheduleSMSAction('Test SMS Schedule', '+14785963210', '+14785963211', 'test message', schedule.Id, true);
        System.assert(string.isNotBlank(scheduleAction.Id), 'Expected schedule Action to be created.');

        //Org Wide email address
        String orgWideEmailAddressId;
        for (OrgWideEmailAddress owea: [SELECT Id FROM OrgWideEmailAddress limit 1]) {
            orgWideEmailAddressId = owea.Id;
        }

        //default email template Id
        String templateId;
        for (EmailTemplate et: [SELECT Id FROM EmailTemplate limit 1]) {
            templateId = et.Id;
        }

        Test.startTest();
        SCH_BtBaseUtils s = new SCH_BtBaseUtils();
        //Prepare schedule Metadata
        s.setScheduleMetadata('{"scheduleId": "' + schedule.Id + '","actionId": "' + scheduleAction.Id + '","executionId": "' + con.Id + '"}');
        //Prepare Recipient Data
        List<SCH_BtBaseUtils.RecipientData> ss = new List<SCH_BtBaseUtils.RecipientData>();
        ss.add(new SCH_BtBaseUtils.RecipientData(con.Id, null));
        //Send emails to Recipients
        s.sendEmail(ss, orgWideEmailAddressId, templateId);
        Test.stopTest();
    }

    static Map<String, Sobject> recMap = new Map<String, Sobject>();
    
    /*******************************************************************************************************
     * @description Method used as generic method to test triggers for different(specified) type of SObject
     **/
    @testVisible
    global static void testTrigger(SObjectType sobjType) {
        try {
            sObject rec = sobjType.newSObject(null, true);
            rec = prepareRecordWithValue(rec, sobjType.getDescribe().fields.getMap());
            Test.startTest();
            insert rec;
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Insert Exception ' + e.getMessage());
        }
    }
    static sObject prepareRecordWithValue(sObject rec, Map<String, SObjectField> fieldMap) {
        Boolean valid = true;
        Set<String> sets = new Set<String>();
        for (String fieldName: fieldMap.keySet()) {
            DescribefieldResult fr = fieldMap.get(fieldName).getDescribe();
            String fn = fr.getName();
            if (fn == 'Id' || fn == 'OwnerId') {
                continue;
            }
            if (fr.isNameField()) {
                if (fr.isAutoNumber()) {
                    continue;
                }
                try {
                    rec.put(fn, 't ' + System.now().getTime());
                } catch (Exception excp) {
                    System.debug(fn + ' is not writable');
                }
            } else if (fr.getType() == Schema.DisplayType.Boolean || fr.isAutoNumber() || fr.isCalculated()) {
                continue;
            } else if (!fr.isNillable()) {
                String ftype = (fr.getType() + '').toLowerCase();
                try {
                    switch on ftype {
                        when 'picklist', 'multipicklist' {
                            for (Schema.PicklistEntry picklist: fr.getPickListValues()) {
                                try {
                                    rec.put(fn, picklist.getValue());
                                    break;
                                } catch (Exception excp) {
                                    System.debug(fn + ' is not writable');
                                }
                            }
                        }
                        when 'currency', 'double', 'integer', 'long', 'percent' {
                            if (fn.endsWithIgnoreCase('__s')) {
                                rec.put(fn, 24);
                            } else {
                                rec.put(fn, Math.random());
                            }
                        }
                        when 'string', 'phone', 'textarea' {
                            rec.put(fn, (System.now().addSeconds(Integer.valueOf(Math.random())).getTime()) + '');
                        }
                        when 'date' {
                            rec.put(fn, System.today());
                        }
                        when 'datetime' {
                            rec.put(fn, System.now());
                        }
                        when 'time' {
                            Datetime dtn = System.now();
                            rec.put(fn, Time.newInstance(dtn.hour(), dtn.minute(), dtn.second(), 0));
                        }
                        when 'url' {
                            rec.put(fn, 'test.' + (System.now().addSeconds(Integer.valueOf(Math.random())).getTime()) + '.com');
                        }
                        when 'email' {
                            rec.put(fn, 'test@n' + (System.now().addSeconds(Integer.valueOf(Math.random())).getTime()) + '.com');
                        }
                        when 'encryptedstring' {
                            rec.put(fn, 'encryptedstring');
                        }
                        when 'reference' {
                            SObjectType psobj = fr.getReferenceTo().get(0);
                            if ((psobj + '') == 'User') {
                                rec.put(fn, UserInfo.getUserId());
                            } else {
                                DescribeSObjectResult dsr = psobj.getDescribe();
                                if (dsr.isCreateable()) {
                                    valid = false;
                                    if (!recMap.containsKey((psobj + ''))) {
                                        sObject temp = prepareRecordWithValue(psobj.newSObject(null, true), dsr.fields.getMap());
                                        insert temp;
                                        recMap.put((psobj + ''), temp);
                                    }
                                    rec.put(fn, recMap.get((psobj + '')).get('Id'));
                                }
                            }
                            sets.add(ftype + '_' + fn);
                        }
                    }
                } catch (Exception excp) {}
            }
        }
        return rec;
    }
}