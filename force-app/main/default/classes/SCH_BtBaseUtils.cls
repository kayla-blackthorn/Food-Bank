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
 * A library of static utility methods.
 *
**/
global with sharing class SCH_BtBaseUtils {
    public final static Set<String> SCH_STANDARD_SOBJECTS = new Set<String> {
        'Account',
        'Contact',
        'Campaign',
        'Opportunity',
        'Lead',
        'User'
    };
    public final static String SS_FEATURE_TOGGLE_LABEL = 'Smart Scheduler Activation Record';
    public final static String PGK_NAMESPACE = 'bt_base';
    public final static String EVENT_PGK_NAMESPACE = 'conference360';
    public final static String SMS_PGK_NAMESPACE = 'simplesms';
    public final static String PGK_API_URI = 'api.blackthorncloud.io';
    public final static String PGK_API_VERSION = 'v1';
    public static String eventTimeZone = EVENT_PGK_NAMESPACE + '__Time_Zone__c';
    public static Boolean applyQueriRowsLimit = true;
    public final static String CURRENT_USER_TIMEZONE = UserInfo.getTimeZone().getDisplayName();
    public final static String CURRENT_USER_TIMEZONE_ID = UserInfo.getTimeZone().getID();
    // conference360 Event PKG sObject Name
    public static String eventSobjectName = 'conference360__Event__c';
    public static String attendeeSobjectName = 'conference360__Attendee__c';
    public static String sessionSobjectName = 'conference360__Session__c';
    public static String sessionAttendeeSobjectName = 'conference360__Session_Attendee__c';
    public static String sessionRelationShipName = 'conference360__Session__r';

    /**
     * returning smart schedule feature activated or not
     * 
     **/
    public static Boolean smartScheduleFeatureEnabled {
        get {
            if (smartScheduleFeatureEnabled == null) {
                smartScheduleFeatureEnabled = FeatureToggleService.isFeatureActive(SS_FEATURE_TOGGLE_LABEL);
            }
            return smartScheduleFeatureEnabled;
        }
        set;
    }

    /**
     * returning Events field to query sObject
     * 
     **/
    public static Set<String> eventQueryFields = new Set<String> {
        'Id',
        'Name',
        EVENT_PGK_NAMESPACE + '__Time_Zone__c'
    };

    /**
     * returning namespace prefix for smart schedule
     * 
     **/
    public static String nameSpacePreFix {
        get {
            if (nameSpacePreFix == null) {
                nameSpacePreFix = '';
                if (INSTALLED_BTSCHEDULE) {
                    nameSpacePreFix = PGK_NAMESPACE + '__';
                }
            }
            return nameSpacePreFix;
        }
        set;
    }

    /**
     * returning SCH_Schedule_Config__c custom setting with API version and URL
     * 
     **/
    static SCH_Schedule_Config__c config {
        get {
            if (config == null) {
                config = SCH_Schedule_Config__c.getOrgDefaults();
                config.URL__c = config.URL__c == null ? PGK_API_URI : config.URL__c;
                config.API_Version__c = config.API_Version__c == null ? PGK_API_VERSION : config.API_Version__c;
            }
            return config;
        }
        set;
    }

    /**
     * returning Map<String, sObjectType> the result of Schema.getGlobalDescribe
     * 
     **/
    public static Map<String, sObjectType> GLOBAL_SOBJECTTYPE {
        get {
            if (GLOBAL_SOBJECTTYPE == null) {
                GLOBAL_SOBJECTTYPE = Schema.getGlobalDescribe();
            }
            return GLOBAL_SOBJECTTYPE;
        }
        set;
    }

    /**
     * returning NamespacePrefix of the package
     **/
    public static String NAME_SPACE {
        get {
            if (NAME_SPACE == null) {
                NAME_SPACE = '';
                List<ApexClass> classes = [SELECT NamespacePrefix
                    FROM ApexClass
                    WHERE Name = 'SCH_BtBaseUtils'
                    AND NamespacePrefix =: PGK_NAMESPACE
                ];
                if (!classes.isEmpty()) {
                    NAME_SPACE = classes[0].NamespacePrefix;
                }
            }
            return NAME_SPACE;
        }
        set;
    }

    /**
     * validating User can install package or not.
     **/
    public static Boolean PACKAGE_INSTALLABLE {
        get {
            if (PACKAGE_INSTALLABLE == null) {
                Integer permissionCount = [SELECT count() FROM PermissionSetAssignment
                    WHERE IsActive = true AND AssigneeId =: UserInfo.getUserId()
                    AND PermissionSetId IN(SELECT Id FROM PermissionSet WHERE PermissionsInstallPackaging = true)
                ];
                PACKAGE_INSTALLABLE = permissionCount > 0;
            }
            return PACKAGE_INSTALLABLE;
        }
        set;
    }

    /**
     * validating simplesms installed or not.
     **/
    public static Boolean INSTALLED_SIMPLESMS {
        get {
            if (INSTALLED_SIMPLESMS == null) {
                INSTALLED_SIMPLESMS = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.containsKey(SMS_PGK_NAMESPACE + '__SMS_Message__c');
                if (!INSTALLED_SIMPLESMS || Test.isRunningTest()) {
                    List<ApexClass> classes = [SELECT NamespacePrefix
                        FROM ApexClass
                        WHERE NamespacePrefix =: SMS_PGK_NAMESPACE
                        LIMIT 1
                    ];
                    INSTALLED_SIMPLESMS = !classes.isEmpty();
                }
            }
            return INSTALLED_SIMPLESMS;
        }
        set;
    }

    /**
     * validating conference360 installed or not.
     **/
    public static Boolean INSTALLED_EVENTS {
        get {
            if (INSTALLED_EVENTS == null) {
                INSTALLED_EVENTS = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.containsKey(eventSobjectName);
                if (!INSTALLED_EVENTS || Test.isRunningTest()) {
                    List<ApexClass> classes = [SELECT NamespacePrefix
                        FROM ApexClass
                        WHERE NamespacePrefix =: EVENT_PGK_NAMESPACE
                        LIMIT 1
                    ];
                    INSTALLED_EVENTS = !classes.isEmpty();
                }
            }
            return INSTALLED_EVENTS;
        }
        set;
    }
    /**
     * validating simplesms installed or not.
     **/
    public static Boolean INSTALLED_BTSCHEDULE {
        get {
            if (INSTALLED_BTSCHEDULE == null) {
                INSTALLED_BTSCHEDULE = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.containsKey(PGK_NAMESPACE + '__SCH_Schedule__c');
                if (!INSTALLED_BTSCHEDULE || Test.isRunningTest()) {
                    List<ApexClass> classes = [SELECT NamespacePrefix
                        FROM ApexClass
                        WHERE NamespacePrefix =: PGK_NAMESPACE
                        LIMIT 1
                    ];
                    INSTALLED_BTSCHEDULE = !classes.isEmpty();
                }
            }
            return INSTALLED_BTSCHEDULE;
        }
        set;
    }

    /**
     * Record Level Filter Options
     **/
    public static Map<String, Set<String>> mapFilterOptions {
        get {
            if (mapFilterOptions == null) {
                mapFilterOptions = new Map<String, Set<String>>();
                mapFilterOptions.put(EVENT_PGK_NAMESPACE + '__attendee__c', new Set<String> {
                    EVENT_PGK_NAMESPACE + '__Registration_Status__c',
                    EVENT_PGK_NAMESPACE + '__Attendance_Status__c'
                });
                mapFilterOptions.put(EVENT_PGK_NAMESPACE + '__session_attendee__c', new Set<String> {
                    EVENT_PGK_NAMESPACE + '__Registration_Status__c',
                    EVENT_PGK_NAMESPACE + '__Attendance_Status2__c'
                });
                if (Test.isRunningTest()) {
                    mapFilterOptions.put('account', new Set<String> {
                        'Industry'
                    });
                }
            }
            return mapFilterOptions;
        }
        set;
    }

    /**
     *  Return the Org Level Configuration Settings with all default values
     **/
    public static SCH_Schedule_Config__c getCustomSettings() {
        return config;
    }

    /**
     *  Return the Current Logged in user record
     **/
    public static User currentUser {
        get {
            if (currentUser == null) {
                currentUser = new User();
                List<User> users = getUsersByIds(new Set<Id> {
                    UserInfo.getUserId()
                });
                if (users.size() > 0) {
                    currentUser = users[0];
                }
            }
            return currentUser;
        }
        set;
    }

    /*******************************************************************************************************
     * @description Used prepare CustomPermission and SetupEntityAccess wrapper to check Custom Permissions are assigned to current user or not.
     * @return List<User>
     * @param String - recordIds: Set of user's Id
     * 
     * @author Dharmendra Karamchandani
     **/
    public static List<User> getUsersByIds(Set<Id> recordIds) {
        List<String> qFields = new List<String>();
        // include more fields those are required to be needed
        qFields.add('Id');
        qFields.add('FirstName');
        qFields.add('LastName');
        qFields.add('Email');
        String filters = 'Id in :recordIds';
        String soql = SCH_BtBaseUtils.prepareSObjectQuery('User', qFields, null, filters);
        return (List<User> ) Database.query(soql);
    }
    /**
     * Used as Data Wrapper class to hold data related to Custom Permissions and their assignments
     **/
    public class CustomPermissionData {
        @AuraEnabled
        public Map<Id, CustomPermission> customPermissionsMap;

        @AuraEnabled
        public List<SetupEntityAccess> setupEntities;

        public CustomPermissionData(Map<Id, CustomPermission> customPermissionsMap, List<SetupEntityAccess> setupEntities) {
            this.customPermissionsMap = customPermissionsMap;
            this.setupEntities = setupEntities;
        }
    }

    /*******************************************************************************************************
     * @description Used prepare CustomPermission and SetupEntityAccess wrapper to check Custom Permissions are assigned to current user or not.
     * @return CustomPermissionData
     * @param Set<String> - permissionNames: Custom Permission Name(s)
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static CustomPermissionData getCustomPermissions(String namespacePrefix, Set<String> permissionNames) {

        Map<Id, CustomPermission> customPermissionsMap = new Map<Id, CustomPermission>([
            SELECT Id, DeveloperName, NamespacePrefix
            FROM CustomPermission
            WHERE DeveloperName in: permissionNames AND NamespacePrefix =: namespacePrefix
        ]);

        List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
            FROM SetupEntityAccess
            WHERE SetupEntityId in: customPermissionsMap.keySet()
            AND ParentId IN(SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId())
        ];
        return new CustomPermissionData(customPermissionsMap, setupEntities);
    }

    /*******************************************************************************************************
     * @description Used prepare Permission data of simplesms package.
     * @return Map<String, Boolean>
     * 
     * @author Dharmendra Karamchandani
     **/
    public static Map<String, Boolean> getSMSPermission() {
        Map<String, Boolean> permissionIds = new Map<String, Boolean>();
        permissionIds.put('Textey_Administrator', false);
        permissionIds.put('Send_Textey_SMS', false);
        permissionIds.put('Send_Textey_Bulk_SMS', false);
        CustomPermissionData cData = getCustomPermissions(SMS_PGK_NAMESPACE, permissionIds.keySet());
        for (SetupEntityAccess access: cData.setupEntities) {
            if (cData.customPermissionsMap.containsKey(access.SetupEntityId)) {
                permissionIds.put(cData.customPermissionsMap.get(access.SetupEntityId).DeveloperName, true);
            }
        }

        permissionIds.put('isSmsAdmin', permissionIds.remove('Textey_Administrator'));
        permissionIds.put('isSmsAllow', permissionIds.remove('Send_Textey_SMS'));
        permissionIds.put('isSmsAllowBulkProcess', permissionIds.remove('Send_Textey_Bulk_SMS'));
        return permissionIds;
    }
    /*******************************************************************************************************
     * @description Used prepare Permission data of BT Schedule package.
     * @return Map<String, Boolean>
     * 
     * @author Adarsh Sharma
     **/
    public static Map<String, Boolean> getBTSchedulePermission() {
        Map<String, Boolean> permissionIds = new Map<String, Boolean>();
        permissionIds.put('Blackthorn_Base_Admin', false);
        CustomPermissionData cData = getCustomPermissions(PGK_NAMESPACE, permissionIds.keySet());
        for (SetupEntityAccess access: cData.setupEntities) {
            if (cData.customPermissionsMap.containsKey(access.SetupEntityId)) {
                permissionIds.put(cData.customPermissionsMap.get(access.SetupEntityId).DeveloperName, true);
            }
        }

        permissionIds.put('isBTScheduleAdmin', permissionIds.remove('Blackthorn_Base_Admin'));
        return permissionIds;
    }
    /*******************************************************************************************************
     * @description Used to get named field for specified sObjectType
     * @return String
     * @param String sObjectType type of sObject
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static String getNamedFieldForsObject(String sObjectType) {
        String nameField = getNamedFieldFromFieldMap(SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(sObjectType).getDescribe().fields.getMap());
        if(String.isBlank(nameField)){
            Map<String, Object> helpLink = SCH_AccountService.getHelpLink();
            if(!helpLink.isEmpty() && helpLink.containskey('sfdc_sobject_replace_name_field') && helpLink.get('sfdc_sobject_replace_name_field') != null){
                Map<String, Object> sfdcsObjectReplaceNameField = (Map<String, Object>)helpLink.get('sfdc_sobject_replace_name_field');
                if(!sfdcsObjectReplaceNameField.isEmpty() && sfdcsObjectReplaceNameField.containsKey(sObjectType) && sfdcsObjectReplaceNameField.get(sObjectType) != null){
                    nameField = String.valueOf(sfdcsObjectReplaceNameField.get(sObjectType));
                }
            }
        }
        return nameField;
    }
    /*******************************************************************************************************
     * @description Used to get sObject label for specified sObjectType
     * @return String
     * @param String sObjectType type of sObject
     * @note Don't change value of this property.
     * 
     **/
    public static String getsObjectLabel(String sObjectType) {
        return SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(sObjectType.toLowerCase()).getDescribe().getLabel();
    }
    /**
     * returning sObject map with field details
     **/
    static Map<String, Map<String, SObjectField>> sobjectWithFieldMap {
        get {
            if (sobjectWithFieldMap == null) {
                sobjectWithFieldMap = new Map<String, Map<String, SObjectField>>();
            }
            return sobjectWithFieldMap;
        }
        set;
    }
    /*******************************************************************************************************
     * @description Used to get field label for specified sObjectType's field
     * @return String
     * @param objectName sObjectType type of sObject
     * @param fieldName API name for sObject field
     **/
    public static String getsObjectFieldLabel(String objectName, String fieldName) {
        if (!SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.containsKey(objectName)) {
            return '';
        }
        if (!sobjectWithFieldMap.containsKey(objectName)) {
            sobjectWithFieldMap.put(objectName, SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName).getDescribe().fields.getMap());
        }
        String fieldLabel = '';
        if (sobjectWithFieldMap.get(objectName).containsKey(fieldName)) {
            fieldLabel = sobjectWithFieldMap.get(objectName).get(fieldName).getDescribe().getLabel();
            if (fieldLabel.indexof('(do not use)') != -1) {
                fieldLabel = fieldLabel.replace('GMT (do not use)', '').replace('(do not use)', '').trim();
            }
        }
        return fieldLabel;
    }

    /*******************************************************************************************************
     * @description Used to get map of field label and API name for specified sObjectType
     * @return Map<String, String>
     * @param sObjectType sObjectType type of sObject
     * @param isApiName Used to return Field API Name / Field label
     **/
    public static Map<String, String> getsObjectFieldDynamic(String sObjectType, boolean isApiName) {
        Map<String, String> mapFieldAPINameWithLabel = new Map<String, String>();
        for (Schema.SObjectField field: SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(sObjectType).getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fResult = field.getDescribe();
            mapFieldAPINameWithLabel.put((isApiName ? fResult.getName() : fResult.getLabel()), (isApiName ? fResult.getLabel() : fResult.getName()));
        }
        return mapFieldAPINameWithLabel;
    }

    /*******************************************************************************************************
     * @description Used to get named field for specified sObjectType
     * @return String
     * @param Map<String, Schema.sobjectfield> fsMap Map of field,SObjectField
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static String getNamedFieldFromFieldMap(Map<String, Schema.SObjectField> fsMap) {
        for (String f: FsMap.keySet()) {
            Schema.DescribeFieldResult fR;
            try {
                // checking field is accessible or not
                fR = FsMap.get(f).getDescribe();
            } catch (Exception excp) {
                System.debug('Exception> SCH_BtBaseUtils> getNamedFieldFromFieldMap: ' + excp.getMessage());
                System.debug('Exception> SCH_BtBaseUtils> getNamedFieldFromFieldMap: ' + excp.getStackTraceString()); 
            }
            if (fR != null && fR.isAccessible() && fR.isNameField()) {
                return fR.getName();
            }
        }
        return null;
    }

    /*******************************************************************************************************
     * @description Used to get map of lookup field details for specified sObjectType
     * @return Map<String, Schema.DescribeFieldResult>
     * @param dsr sObjectType type of sObject
     * @param fieldsToExclude Used to execlude fields
     **/
    public static Map<String, Schema.DescribeFieldResult> getsObjectLookupFields(DescribeSObjectResult dsr, Set<String> fieldsToExclude) {
        Map<String, Schema.DescribeFieldResult> msgFieldWithType = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField field: dsr.fields.getMap().values()) {
            Schema.DescribeFieldResult fResult = field.getDescribe();
            if (!fieldsToExclude.contains(fResult.getName()) && fResult.getReferenceTo().size()> 0) {
                msgFieldWithType.put(fResult.getName(), fResult);
            }
        }
        return msgFieldWithType;
    }

    /*******************************************************************************************************
     * @description Used to get field label for specified sObjectType
     * @return String
     * @param objectName sObjectType type of sObject
     * @param relationshipName sObjectType relationship name
     * @param fieldName sObject field API Name
     **/
    public static String getParentsObjectFieldLabel(String objectName, String relationshipName, String fieldName) {
        String fieldLabel = fieldName;
        for (Schema.SObjectField field: SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName).getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fResult = field.getDescribe();
            if (fResult.getRelationshipName() != null && fResult.getRelationshipName() == relationshipName) {
                Map<String, String> mapFieldAPIName = SCH_BtBaseUtils.getsObjectFieldDynamic(fResult.getReferenceTo()[0] + '', true);
                if (mapFieldAPIName.containsKey(fieldName)) {
                    fieldLabel = mapFieldAPIName.get(fieldName);
                    break;
                }
            }
        }
        return fieldLabel;
    }
    /*******************************************************************************************************
     * @description Used to get sObject fields for specified sObjectType
     * @return Map<String, Map<String, Schema.DescribeFieldResult>>
     * @param dsr sObjectType type of sObject
     * @param fieldTypes sObject Field types
     **/
    public static Map<String, Map<String, Schema.DescribeFieldResult>> getSobjectFieldsWithType(DescribeSObjectResult dsr, Set<String> fieldTypes) {
        return getSobjectFieldsWithOrderedType(getSobjectFieldsWithAPIName(dsr, fieldTypes), getSobjectFieldsWithUnOrderedType(dsr, fieldTypes));
    }
    /*******************************************************************************************************
     * @description Used to get sObject fields for specified sObjectType
     * @return Map<String, String>
     * @param dsr sObjectType type of sObject
     * @param fieldTypes sObject Field types
     **/
    public static Map<String, String> getSobjectFieldsWithAPIName(DescribeSObjectResult dsr, Set<String> fieldTypes) {
        Map<String, String> mapFieldApiNameWithLabel = new Map<String, String>();
        for (Schema.SObjectField field: dsr.fields.getMap().values()) {
            Schema.DescribeFieldResult fResult = field.getDescribe();
            String fieldType = String.valueOf(fResult.getType()).toLowerCase();
            if (fieldTypes.contains(fieldType)) {
                mapFieldApiNameWithLabel.put(fResult.getName(), fResult.getLabel());
            }
        }
        return mapFieldApiNameWithLabel;
    }
    /*******************************************************************************************************
     * @description Used to get sObject fields for specified sObjectType
     * @return Map<String, Map<String, Schema.DescribeFieldResult>>
     * @param dsr sObjectType type of sObject
     * @param fieldTypes sObject Field types
     **/
    public static Map<String, Map<String, Schema.DescribeFieldResult>> getSobjectFieldsWithUnOrderedType(DescribeSObjectResult dsr, Set<String> fieldTypes) {
        Map<String, Map<String, Schema.DescribeFieldResult>> msgFieldWithTypes = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        for (Schema.SObjectField field: dsr.fields.getMap().values()) {
            Schema.DescribeFieldResult fResult = field.getDescribe();
            String fieldType = String.valueOf(fResult.getType()).toLowerCase();
            if (fieldTypes.contains(fieldType)) {
                if (!msgFieldWithTypes.containsKey(fieldType)) {
                    msgFieldWithTypes.put(fieldType, new Map<String, Schema.DescribeFieldResult>());
                }
                msgFieldWithTypes.get(fieldType).put(fResult.getName(), fResult);
            }
        }
        return msgFieldWithTypes;
    }
    /*******************************************************************************************************
     * @description Used to sort sObject field label
     * @return List<String>
     * @param lstFieldLabel field label of sObject's field
     **/
    public static List<String> getSobjectSortedFieldsLabel(List<String> lstFieldLabel) {
        lstFieldLabel.sort();
        return lstFieldLabel;
    }

    /*******************************************************************************************************
     * @description Used to get sObject fields for specified sObjectType
     * @return Map<String, Map<String, Schema.DescribeFieldResult>>
     * @param mapFieldApiNameWithLabel field label of sObject's field with field API Name
     * @param msgTFieldWithTypes sObject's fields
     **/
    public static Map<String, Map<String, Schema.DescribeFieldResult>> getSobjectFieldsWithOrderedType(Map<String, String> mapFieldApiNameWithLabel, Map<String, Map<String, Schema.DescribeFieldResult>> msgTFieldWithTypes) {
        Map<String, Map<String, Schema.DescribeFieldResult>> msgFieldWithTypes = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        List<String> lstFieldLabel = getSobjectSortedFieldsLabel(mapFieldApiNameWithLabel.values());
        for (String fieldLabel: lstFieldLabel) {
            for (String fieldAPIName: mapFieldApiNameWithLabel.keySet()) {
                if (fieldLabel == mapFieldApiNameWithLabel.get(fieldAPIName)) {
                    for (String fieldType: msgTFieldWithTypes.keySet()) {
                        Map<String, Schema.DescribeFieldResult> mapDescribeField = msgTFieldWithTypes.get(fieldType);
                        if (mapDescribeField.containsKey(fieldAPIName)) {
                            if (!msgFieldWithTypes.containsKey(fieldType)) {
                                msgFieldWithTypes.put(fieldType, new Map<String, Schema.DescribeFieldResult>());
                            }
                            msgFieldWithTypes.get(fieldType).put(fieldAPIName, mapDescribeField.get(fieldAPIName));
                        }
                    }
                }
            }
        }
        return msgFieldWithTypes;
    }

    /*******************************************************************************************************
     * @description Used to update SObject records into the database.
     * @return 
     * @param serviceSOjects : a List SObjectType that is being used to DML action
     * @param records - a List of SObject type of records to create/update.
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static void maintainSObjects(List<Schema.SObjectType> serviceSOjects, List<SObject> records) {
        fflib_SObjectUnitofWork uow = new fflib_SObjectUnitofWork(serviceSOjects);

        for (SObject record: records) {
            if (record.get('Id') != null) {
                uow.registerDirty(record);
            } else {
                uow.registerNew(record);
            }
        }
        uow.commitWork();
    }

    /*******************************************************************************************************
     * @description Used to delete SObject records into the database.
     * @return 
     * @param serviceSOjects : a List SObjectType that is being used to DML action
     * @param  records - a List of SObject type of records to delete.
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static void removeSObjects(List<Schema.SObjectType> serviceSOjects, List<SObject> records) {
        fflib_SObjectUnitofWork uow = new fflib_SObjectUnitofWork(serviceSOjects);

        for (SObject record: records) {
            uow.registerDeleted(record);
        }
        uow.commitWork();
    }

    /*******************************************************************************************************
     * @description Used to delete SObject records into the database.
     * @return String: secured Id value
     * @param source : Id value that needs to be pass secure SOQL SOSL Injection
     * @note Don't change value of this property.
     * 
     * @author Dharmendra Karamchandani
     **/
    public static String secureIdInjection(String source) {
        if (String.isNotEmpty(source)) {
            //Escaping Single Quotes
            source = String.escapeSingleQuotes(source);
            //Replacing white space Characters
            source = source.replaceAll('[^\\w]', '');
        }
        return source;
    }

    /*******************************************************************************************************
     * @description Used to get sObject type using sObject API Name
     * @return sObjectType
     * @param sObjectName sObjectType type of sObject
     **/
    public static sObjectType getSObjectType(String sObjectName) {
        return ((SObject) Type.forName(sObjectName).newInstance()).getSObjectType();
    }

    /*******************************************************************************************************
     * @description Used to get soql query for sObject
     * @return String
     * @param sobjTypeName sObjectType type of sObject
     * @param qFields sObjectType fields to query the record
     * @param orders Order the records
     * @param filters filter the records
     **/
    public static String prepareSObjectQuery(String sobjTypeName, List<String> qFields,
        List<fflib_QueryFactory.Ordering> orders, String filters) {
        sobjTypeName = secureIdInjection(sobjTypeName);
        if (String.isNotEmpty(sobjTypeName)) {
            sobjTypeName = sobjTypeName.toLowerCase();
            if (GLOBAL_SOBJECTTYPE.containsKey(sobjTypeName)) {
                return prepareSObjectQuery(GLOBAL_SOBJECTTYPE.get(sobjTypeName), qFields, orders, filters);
            }
        }
        return '';
    }
    /*******************************************************************************************************
     * @description Used to get soql query for sObject
     * @return String
     * @param sobjTypeName sObjectType type of sObject
     * @param qFields sObjectType fields to query the record
     **/
    public static String prepareSObjectQuery(SObjectType sobjType, List<String> qFields,
        List<fflib_QueryFactory.Ordering> orders, String filters) {
        System.debug(sobjType);
        System.debug(qFields);
        fflib_QueryFactory qf = new fflib_QueryFactory(sobjType);
        qf.setEnforceFLS(true);
        qf.selectFields(qFields);
        if (String.isNotEmpty(filters)) {
            qf.setCondition(filters);
        }
        if (orders != null) {
            for (fflib_QueryFactory.Ordering order: orders) {
                qf.addOrdering(order);
            }
        }
        if (SCH_BtBaseUtils.applyQueriRowsLimit) {
            qf.setLimit(Limits.getLimitQueryRows() - Limits.getQueryRows());
        }
        String query = qf.toSOQL();
        System.debug(query);
        return query;
    }
    /*******************************************************************************************************
     * @description Used to get total count of sObject records
     * @return String
     * @param queryRowsLimit query limits
     **/
    static Integer getQueryRows(Integer queryRowsLimit) {
        Integer queryRows = Limits.getLimitQueryRows() - Limits.getQueryRows();

        if (queryRowsLimit != null && queryRowsLimit<queryRows) {
            queryRows = queryRowsLimit;
        }
        return queryRows;
    }

    /**
     *  @return Current Logged in User Info
     *
     *  Return the Current Logged in User Info.
     *
     **/
    public static User fetchUserInfo() {
        List<String> qFields = new List<String>();
        qFields.add('Id');
        qFields.add('Name');
        qFields.add('FirstName');
        qFields.add('LastName');
        qFields.add('Title');
        qFields.add('Email');
        qFields.add('Phone');
        qFields.add('SmallPhotoUrl');
        String filters = 'Id = \'' + UserInfo.getUserId() + '\'';
        String soql = SCH_BtBaseUtils.prepareSObjectQuery(User.getSObjectType(), qFields, null, filters);

        return ((List<User> ) Database.query(soql)).get(0);
    }

    /**
     *  @return Organization/Company Info
     *
     *  Return the Organization/Company Info
     *
     **/
    public static Organization fetchCompanyInfo() {
        List<String> qFields = new List<String>();
        qFields.add('Id');
        qFields.add('Name');
        qFields.add('Street');
        qFields.add('City');
        qFields.add('State');
        qFields.add('PostalCode');
        qFields.add('Country');
        qFields.add('Phone');
        qFields.add('IsSandbox');
        qFields.add('OrganizationType');
        String soql = SCH_BtBaseUtils.prepareSObjectQuery(Organization.getSObjectType(), qFields, null, null);

        return ((List<Organization> ) Database.query(soql)).get(0);
    }

    /**
     * @description fetchSObjectByIds - this method returns List<SObject>
     * @param sObjectName: SObject API Name
     * @param fields: Set of Field API Names that needs to be query
     * @param recordIds: Set of record Ids  
     * @return List<SObject>: List of SObject
     * 
     * @author Dharmendra@CRMified
     **/
    public static List<sObject> fetchSObjectByIds(String sObjectName, Set<String> fields, Set<String> recordIds) {
        List<String> qFields = new List<String>(fields);
        String filters = 'Id IN :recordIds';
        String soql = SCH_BtBaseUtils.prepareSObjectQuery(sObjectName, qFields, null, filters);
        return Database.query(soql);
    }

     /*******************************************************************************************************
     * @description Used to get Org wide email address
     * @return List<OrgWideEmailAddress>
     * @param none
     **/
    public static List<OrgWideEmailAddress> fetchOrgWideEmailAddress() {
        List<String> qFields = new List<String>();
        qFields.add('Id');
        qFields.add('DisplayName');
        qFields.add('Address');
        String filters = ' IsVerified = true ';
        List<fflib_QueryFactory.Ordering> orders = new List<fflib_QueryFactory.Ordering>();
        orders.add(new fflib_QueryFactory.Ordering('OrgWideEmailAddress', 'IsAllowAllProfiles', fflib_QueryFactory.SortOrder.DESCENDING));
        String soql = SCH_BtBaseUtils.prepareSObjectQuery(OrgWideEmailAddress.getSObjectType(), qFields, orders, filters);
        return ((List<OrgWideEmailAddress> ) Database.query(soql));
    }

    /*******************************************************************************************************
     * @description Used to get Org wide email address
     * @return List<String>
     * @param none
     **/
    public static List<String> fetchOrgWidEmails() {
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = fetchOrgWideEmailAddress();
        List<String> lstEmailAddress = new List<String>();
        if (lstOrgWideEmailAddress != null) {
            for (OrgWideEmailAddress owea: lstOrgWideEmailAddress) {
                lstEmailAddress.add(owea.Address);
            }
        }
        return lstEmailAddress;
    }

    /*******************************************************************************************************
     * @description Method used to validate that specified emailAddress and accessible by either all profile or specified userId + verified
     * @return Boolean
     * @param String emailAddress
     * @param String userId
     **/
    public static Boolean checkOrgWideEmailAddress(String emailAddress, String userId){
        Boolean isVerified = false;
        OrgWideEmailAddress oea;
        for (OrgWideEmailAddress oweas: [SELECT Id, IsAllowAllProfiles, IsVerified FROM OrgWideEmailAddress WHERE Address =: emailAddress]) {
            oea = oweas;
        }
        if (oea != null) {
            if (oea.IsVerified) {
                if (oea.IsAllowAllProfiles) {
                    isVerified = true;
                } else {
                    String profileId;
                    for (User user: [SELECT Id, ProfileId FROM User WHERE Id =: userId]) {
                        profileId = user.ProfileId;
                    }
                    if (String.isNotBlank(profileId)) {
                        for (OrgEmailAddressSecurity owas: [SELECT Id FROM OrgEmailAddressSecurity WHERE ParentId =: profileId AND OrgWideEmailAddressId =: oea.Id]) {
                            isVerified = true;
                        }
                    }
                }
            }
        }
        return isVerified;
    }

    /*******************************************************************************************************
     * @description Used to get picklist values for sObject type
     * @return Map<String, String>
     * @param objectName sObjectType type of sObject
     * @param fieldName sObject field api name
     **/
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        objectName = objectName.toLowerCase();
        Map<String, String> mapPicklistValues = new Map<String, String>();
        for (Schema.PicklistEntry entry: SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                mapPicklistValues.put(entry.getValue(), entry.getLabel());
            }
        }
        return mapPicklistValues;
    }

    /*******************************************************************************************************
     * @description Used to get sObject with details
     * @return Map<String, String>
     * @param none
     **/
    public static Map<String, String> getSObjectAPINameWithSObjectLabel() {
        Map<String, sObjectType> mapObjectType = SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE;

        Map<String, String> mapSObjectAPINameWithSObjectLabel = new Map<String, String>();
        for (String fieldApiName: mapObjectType.keySet()) {
            DescribeSObjectResult sobjectResult = mapObjectType.get(fieldApiName).getDescribe();
            if (sobjectResult.isAccessible() && sobjectResult.isUpdateable() && sobjectResult.isCustomSetting() == false) {
                if (sobjectResult.isCustom()) {
                    mapSObjectAPINameWithSObjectLabel.put(fieldApiName, JSON.serialize(sobjectResult));
                } else {
                    String standObj = sobjectResult.getName();
                    if (SCH_STANDARD_SOBJECTS.contains(standObj)) {
                        mapSObjectAPINameWithSObjectLabel.put(fieldApiName, JSON.serialize(sobjectResult));
                    }
                }
            }
        }
        return mapSObjectAPINameWithSObjectLabel;
    }

    /*******************************************************************************************************
     * @description Used to prepare attendee filters options to record page
     * @param objectName = sObject APIName
     * @return Map<String, String>
     * 
     * @author Adarsh Sharma
     **/
    public static Map<String, String> getFilters(String objectName) {
        Map<String, String> filters = new Map<String, String>();
        if (mapFilterOptions.containsKey(objectName.toLowerCase())) {
            for (String fieldAPIName: mapFilterOptions.get(objectName.toLowerCase())) {
                filters.put(fieldAPIName, SCH_BtBaseUtils.getsObjectFieldLabel(objectName, fieldAPIName));
            }
        }
        return filters;
    }

    /**
     * Need to use to Send Email
     */
    public static List<Messaging.SendEmailResult> sendMail(String orgWideEmailAddressId, List<String> toAddresses, Id recordId, String emailtemplateId, Boolean logActivity) {
        Set<Schema.SObjectType> activityEnabledSObjects = getActivityEnabledSObjects();

        Id whatId = null, whoId = null;
        sObjectType sObjType = recordId.getSObjectType();
        Boolean activitiesEnabled = (logActivity && activityEnabledSObjects.contains(sObjType));
        if (sObjType == Contact.sObjectType || sObjType == Lead.sObjectType || sObjType == User.sObjectType) {
            whoId = recordId;
        } else {
            whatId = recordId;
        }
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailtemplateId, whoId, whatId);
        email.setSaveAsActivity(activitiesEnabled);
        email.setToAddresses(toAddresses);
        if (String.isNotBlank(orgWideEmailAddressId)) {
            email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        }

        List<Messaging.SingleEmailmessage> emails = new List<Messaging.SingleEmailmessage>();
        emails.add(email);


        List<Messaging.SendEmailResult> emailResult = null;
        emailResult = Messaging.sendEmail(emails, false);

        return emailResult;
    }

    /**
     * Need to use to get Org Wide Email Address Id
     */
    private static String getOrgWideEmailAddress(String fromAddress) {
        String orgWideEmailAddressId;
        for (OrgWideEmailAddress owea: [SELECT Id FROM OrgWideEmailAddress WHERE Address =: fromAddress limit 1]) {
            orgWideEmailAddressId = owea.Id;
        }
        return orgWideEmailAddressId;
    }

    /**
     * Need to use to get Org Wide Email Address Id
     */
    public static Map<String, OrgWideEmailAddress> getOrgWideEmailAddresses(List<String> emailAddresses) {
        Map<String, OrgWideEmailAddress> emailWiseOrgWiseAddress = new Map<String, OrgWideEmailAddress>();
        for (List<OrgWideEmailAddress> oweas: [SELECT Id, DisplayName, Address, IsAllowAllProfiles
                FROM OrgWideEmailAddress WHERE Address IN: emailAddresses
            ]) {
            for (OrgWideEmailAddress owea: oweas) {
                emailWiseOrgWiseAddress.put(owea.Address.toLowerCase(), owea);
            }
        }
        return emailWiseOrgWiseAddress;
    }
    /**
     * @description getActivityEnabledSObjects - This method returns set of all activity enabled sObject Types
     * @param none
     * @return Set<Schema.SObjectType>: Set of sObjectTypes
     * 
     * @author Basant@CRMified
     **/
    public static Set<Schema.SObjectType> getActivityEnabledSObjects() {
        Set<Schema.SObjectType> objectsWithActivitiesEnabled = new Set<Schema.SObjectType>();
        // indentifying sObjects from WhatId
        for (Schema.SObjectType objectType: Task.WhatId.getDescribe().getReferenceTo()) {
            objectsWithActivitiesEnabled.add(objectType);
        }
        // indentifying sObjects from WhoId
        for (Schema.SObjectType objectType: Task.WhoId.getDescribe().getReferenceTo()) {
            objectsWithActivitiesEnabled.add(objectType);
        }
        return objectsWithActivitiesEnabled;
    }

    /**
     * @description getsObjectDetails - This method returns a sObject record with all requested fields
     * @param objectName: sObject API Name
     * @param fieldName: fields to query, can be multiple coma seperated
     * @param recordId: sObject Record Id
     * @return sObject: Salesforce sObject Record
     **/
    public static sObject getsObjectDetails(String objectName, String fieldName, String recordId) {
        sObject obRec = null;
        if (String.isNotBlank(objectName) && String.isNotBlank(fieldName) && String.isNotBlank(recordId)) {
            List<String> qFields = new List<String>();
            for (String fld: fieldName.split(',')) {
                qFields.add(fld.trim());
            }
            String filter = 'Id = :recordId';
            List<sObject> obRecords = database.query(prepareSObjectQuery(objectName, qFields, null, filter));
            obRec = obRecords.isEmpty() ? null : obRecords.get(0);
        }
        return obRec;
    }
    public static Map<String, Integer> getOrgEmailLimits() {
        Map<String, Integer> emailLimits = new Map<String, Integer>();
        Map<String, System.OrgLimit> limitsMap = OrgLimits.getMap();
        // another key email balance is MassEmail
        System.OrgLimit orgLimit = limitsMap.get('SingleEmail');
        emailLimits.put('usage', orgLimit.getValue());
        emailLimits.put('maximum', orgLimit.getLimit());
        return emailLimits;
    }

    /**
     * @description extractFieldValue - This method extracting single, multiple level field value from record, record would be queried with multi level field.
     * @param record: sObject Record
     * @param field: fields to pull value from sObject record 
     * @return Object: sObject field value
     **/
    public static Object extractFieldValue(SObject record, String field) {
        if (field.indexOf('.')> -1) {
            List<String> fieldParts = field.split('\\.');
            while (fieldParts.size()> 1) {
                field = fieldParts.remove(0);
                record = record.getSObject(field);
                if (record == null) {
                    break;
                }
            }
            field = fieldParts.remove(0);
        }
        return record == null ? null : record.get(field);
    }

    /**
     * @description This method return related sObject API name
     * @param sObjectName: sObject API Name
     * @param relationshipName: Related field relationship name
     * @return String: Related sObject API name
     **/
    public static String getRelatedsObjectName(String sObjectName, String relationshipName){
        String objName = sObjectName;
        Schema.DescribeSObjectResult obj = SCH_SObjectFilterBuilderCtlr.GLOBAL_SOBJECTTYPE.get(sObjectName).getDescribe();
        for (Schema.SObjectField f: obj.fields.getMap().values()) {
            DescribeFieldResult fr = f.getDescribe();
            if(String.valueOf(fr.getType()).toLowerCase() == 'reference' && fr.getRelationshipName() == relationshipName){
                objName = fr.getReferenceTo().get(0).getDescribe().getName();
                break;
            }
        }
        return objName;
    }

    /**
     * @description This method return related sObject details
     * @param sObjectName: sObject API Name
     * @param relationshipName: Related field relationship name
     * @return Object: Related sObject details
     **/
    public static Object getAssociateReference(String sObjectName, String relationshipName) {
        Map<String, String> associateReferences = new Map<String, String>();
        String associateReference = '['+sObjectName+']';
        String lastObjectName = sObjectName;
        List<String> lstRelationshipName = relationshipName.split('\\.');
        for(String rname : lstRelationshipName){
            lastObjectName = getRelatedsObjectName(lastObjectName, rname);
            associateReference += '.'+lastObjectName;
        }
        associateReferences.put('sObjectName', sObjectName);
        associateReferences.put('relationshipName', relationshipName);
        associateReferences.put('associateReference', associateReference);
        return associateReferences;
    }

    /**
     * 
     * 
     */
    public Class UpdateLogWrapper {
        public String salesforce_id {
            get;
            set;
        }
        public String status {
            get;
            set;
        }
        public String status_message {
            get;
            set;
        }
        // public String email_id {get; set;}
        public Datetime processed_at {
            get;
            set;
        }
    }

    public Class MetadataWrapper {
        public String scheduleId {
            get;
            set;
        }
        public String actionId {
            get;
            set;
        }
        public String executionId {
            get;
            set;
        }
        public Boolean isUpdateExecutionLogs {
            get {
                return (String.isNotBlank(scheduleId) && String.isNotBlank(actionId) && String.isNotBlank(executionId));
            }
            protected set;
        }

        public String getEndpoint() {
            return '/schedules/' + scheduleId + '/actions/' + actionId + '/executions/' + executionId + '/logs';
        }
    }

    private MetadataWrapper metadata;
    /**
     * exported global methods
     * @param scheduleMetadata - sets the value of that wants to send BT Scheduler server
     **/
    global void setScheduleMetadata(String scheduleMetadata) {
        this.metadata = (MetadataWrapper) JSON.deserializeStrict(scheduleMetadata, MetadataWrapper.class);
    }
    global class RecipientData {
        global String id;
        global String emailValue;
        global RecipientData() {}
        global RecipientData(String id, String emailValue) {
            this.id = id;
            this.emailValue = emailValue;
        }
    }
    /*******************************************************************************************************
     * @description Used via API to send Email(s)
     * @return void
     * @param records List<RecipientData> having Recipient data like record's Id, email address
     * @param orgWideEmailAddressId orgwide email registered email address Id
     * @param templateId Email template Id
     * 
     * @author Dharmendra Karamchandani
     * @note DO NOT CHANGE THE STRUCTURE As this is bind within API
     **/
    global void sendEmail(List<RecipientData> records, String orgWideEmailAddressId, String templateId) {
        System.debug('records: ' + records);
        System.debug('orgWideEmailAddressId: ' + orgWideEmailAddressId);
        System.debug('templateId: ' + templateId);
        System.debug('scheduleMetadata: ' + metadata);
        // getting valid Email Template Id
        templateId = SCH_EmailService.getEmailTemplateId(templateId);
        System.debug('templateId: ' + templateId);
        List<UpdateLogWrapper> logsToUpdate = new List<UpdateLogWrapper>();
        if (records != null && !records.isEmpty()) {
            // Preparing list of recipient with emails
            List<RecipientData> recipients = new List<RecipientData>();
            for (Integer ind = 0, len = records.size(); ind<len; ind++) {
                RecipientData record = records.remove(0);
                // if Email is blank, preparing log
                if (String.isBlank(record.emailValue)) {
                    prepareLogsDetails(logsToUpdate, record.id, 'failed', 'Email is blank.');
                } else {
                    recipients.add(record);
                }
            }
            String errorMessage = '';
            if (recipients.size() > 0 && String.isNotBlank(orgWideEmailAddressId) && String.isNotBlank(templateId)) {
                List<Messaging.SingleEmailmessage> emails = new List<Messaging.SingleEmailmessage>();
                Set<Schema.SObjectType> activityEnabledSObjects = getActivityEnabledSObjects();
                // ensuring org is having capacity to send email
                try {
                    Messaging.reserveSingleEmailCapacity(records.size());
                } catch (Exception excp) {
                    errorMessage = excp.getMessage();
                }
                // didn't get capacity error then only proceeding for email sending
                if (errorMessage == '') {
                    for (RecipientData record: recipients) {
                        //build the email message
                        List<String> toAddresses = new List<String>();
                        toAddresses.add(record.emailValue);
                        Id whatId = null, whoId = null;
                        Id recordId = (Id) record.Id;
                        sObjectType obj = recordId.getSObjectType();
                        Boolean activitiesEnabled = activityEnabledSObjects.contains(obj);
                        if (obj == Contact.sObjectType || obj == Lead.sObjectType || obj == User.sObjectType) {
                            whoId = recordId;
                        } else {
                            whatId = recordId;
                        }
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
                        email.setSaveAsActivity(activitiesEnabled);
                        email.setToAddresses(toAddresses);
                        if (String.isNotBlank(orgWideEmailAddressId)) {
                            email.setOrgWideEmailAddressId(orgWideEmailAddressId);
                        }
                        emails.add(email);
                    }
                    List<Messaging.SendEmailResult> emailResult = Messaging.sendEmail(emails, false);
                    Integer i = 0;
                    for (RecipientData obj: recipients) {
                        Messaging.SendEmailResult res = emailResult.get(i);
                        UpdateLogWrapper log = new UpdateLogWrapper();
                        log.salesforce_id = obj.id;
                        log.status = res.isSuccess() ? 'sent' : 'failed';
                        log.status_message = res.isSuccess() ? null : res.getErrors().get(0).getMessage();
                        log.processed_at = System.now();
                        logsToUpdate.add(log);
                        i++;
                    }
                }
            } else {
                errorMessage = 'A Template Id, From Address and Metadata should be provided to send email';
            }
            if (String.isNotBlank(errorMessage)) {
                prepareLogsDetails(logsToUpdate, recipients, 'failed', errorMessage);
            }
        }
        System.debug('logsToUpdate: ' + logsToUpdate);
        if (metadata != null && metadata.isUpdateExecutionLogs && !logsToUpdate.isEmpty()) {
            System.enqueueJob(new SCH_UpdateExecutionLogsQueueable(metadata.getEndpoint(), JSON.serialize(logsToUpdate)));
        }
    }

    static void prepareLogsDetails(List<UpdateLogWrapper> logsDetails, List<RecipientData> records, String status, String statusMessage) {
        for (RecipientData record: records) {
            prepareLogsDetails(logsDetails, record.id, status, statusMessage);
        }
    }
    static void prepareLogsDetails(List<UpdateLogWrapper> logsDetails, String recordId, String status, String statusMessage) {
        UpdateLogWrapper log = new UpdateLogWrapper();
        log.salesforce_id = recordId;
        log.status = status;
        log.status_message = statusMessage;
        logsDetails.add(log);
    }
    /*******************************************************************************************************
     * @description Used prepare Version instance wiht passed String value.
     * @return Version
     * @param String - version number as string
     * 
     * @author Dharmendra Karamchandani
     **/
    Version prepareVersion(String ver) {
        List<String> vParts = ver.split('\\.');
        if (vParts.size() == 1) {
            vParts.add('0');
        }
        if (vParts.size() == 2) {
            vParts.add('0');
        }
        return new Version(
            Integer.valueOf(vParts[0]),
            Integer.valueOf(vParts[1]),
            Integer.valueOf(vParts[2]));
    }
    /*******************************************************************************************************
     * @description Used compare two versions and validate that curVer is equals or higher to matchVer
     * @return Boolean return TRUE if curVer is equals or higher to matchVer
     * @param String - curVer current version number as string
     * @param String - matchVer matching/base version number as string
     * 
     * @author Dharmendra Karamchandani
     **/
    public Boolean validateVersion(String curVer, String matchVer) {
        if (String.isBlank(curVer) || String.isBlank(matchVer)) {
            return false;
        }
        Version cVer = prepareVersion(curVer);
        Version mVer = prepareVersion(matchVer);
        return cVer.compareTo(mVer)> -1;
    }

    /*******************************************************************************************************
     * @description Method used to format date time value
     * @return String
     * @param dtVal: Datetime
     **/
    public static String getFormatDateTime(String dtVal, String timeZone) {
        if (String.isBlank(dtVal)) {
            return '';
        }
        try {
            List<String> dtParts = dtVal.split('T');
            System.debug(dtParts);
            List<String> dateParts = dtParts[0].split('-');
            System.debug(dateParts);
            List<String> timeParts = dtParts[1].split('\\.')[0].split(':');
            System.debug(timeParts);
            Datetime dt = Datetime.newInstanceGMT(
                Integer.valueOf(dateParts[0]),
                Integer.valueOf(dateParts[1]),
                Integer.valueOf(dateParts[2]),
                Integer.valueOf(timeParts[0]),
                Integer.valueOf(timeParts[1]),
                Integer.valueOf(timeParts[2])
            );
            return dt.format('MM/dd/yyyy\', \'hh:mm a', timeZone);
        } catch (Exception excp) {
            return dtVal;
        }
    }
}