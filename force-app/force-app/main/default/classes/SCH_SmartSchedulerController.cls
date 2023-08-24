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
 * A library of methods for performing operations on the smart schedule
 * through the Blackthorn API. 
**/
public with sharing class SCH_SmartSchedulerController {

    /*******************************************************************************************************
     * @description Method used to prepare smsResult, global ObjectDescribe and help links
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> getInitData() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('smsResult', isSimpleSMSPackageInstalled());
        result.put('globalsObjectDescribe', SCH_BtBaseUtils.getSObjectAPINameWithSObjectLabel());
        result.put('helpLinks', SCH_AccountService.getHelpLink());
        result.putAll(getEmailDetails());
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to prepare smsPermissions, smsAccount and installation details to check SMS Permissions and account configuration details
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> isSimpleSMSPackageInstalled() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('isInstalled', SCH_BtBaseUtils.INSTALLED_SIMPLESMS);
        if (SCH_BtBaseUtils.INSTALLED_SIMPLESMS) {
            Map<String, Object> smsData = getSMSdetails();
            result.putAll(smsData);
        } else {
            result.put('allowInstall', SCH_BtBaseUtils.PACKAGE_INSTALLABLE);
        }
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to prepare smsPermissions and smsAccount to check SMS Permissions are assigned to current user or not.
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> getSMSdetails() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('smsPermissions', SCH_BtBaseUtils.getSMSPermission());
        try {
            result.put('smsAccount', SCH_AccountService.getSMSdetails());
        } catch (Exception excp) {
            System.debug('Exception> SCH_SmartSchedulerController> getSMSdetails: ' + excp.getMessage());
            System.debug('Exception> SCH_SmartSchedulerController> getSMSdetails: ' + excp.getStackTraceString()); 
        }
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to prepare email balance details
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> getEmailDetails() {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Integer> emailLimits = SCH_BtBaseUtils.getOrgEmailLimits();
        result.put('emailBalance', emailLimits.get('maximum') - emailLimits.get('usage'));
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to prepare schedule permission, account and help link details
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> isBTPackageInstalled() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('isInstalled', SCH_BtBaseUtils.INSTALLED_BTSCHEDULE);
        result.put('isScheduleFeatureEnabled', SCH_BtBaseUtils.smartScheduleFeatureEnabled);
        if (SCH_BtBaseUtils.INSTALLED_BTSCHEDULE) {
            Map<String, Object> smsData = getBTScheduledetails();
            result.putAll(smsData);
        } else {
            result.put('allowInstall', SCH_BtBaseUtils.PACKAGE_INSTALLABLE);
        }
        result.put('helpLinks', SCH_AccountService.getHelpLink());
        result.put('userTimeZone', SCH_BtBaseUtils.CURRENT_USER_TIMEZONE);
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to prepare schedule permission and account details
     * @return Map<String, Object>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, Object> getBTScheduledetails() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('btSchedulePermissions', SCH_BtBaseUtils.getBTSchedulePermission());
        try {
            result.put('btScheduleAccount', SCH_AccountService.getAccount());
        } catch (Exception excp) {
            System.debug('Exception> SCH_SmartSchedulerController> getBTScheduledetails: ' + excp.getMessage());
            System.debug('Exception> SCH_SmartSchedulerController> getBTScheduledetails: ' + excp.getStackTraceString());  
        }
        return result;
    }

     /*******************************************************************************************************
     * @description Method used to prepare email, phone and datetime
     * @return String
     * @param objectName: sObject API name that is being used to get email, phone and datetime fields
     **/
    @AuraEnabled
    public static String getSobjectFieldsWithType(String objectName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        return JSON.serialize(SCH_BtBaseUtils.getSobjectFieldsWithType(SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName.toLowerCase()).getDescribe(), new Set<String> {
            'email',
            'phone',
            'datetime'
        }));
    }

    /*******************************************************************************************************
     * @description Method used to prepare picklist options for selected sobject
     * @return Map<String, String>
     * @param objectName: sObject API name that is being used to get picklist options
     * @param fieldName: sObject's field API name that is being used to get picklist options
     **/
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        fieldName = SCH_BtBaseUtils.secureIdInjection(fieldName);
        return SCH_BtBaseUtils.getPicklistValues(objectName, fieldName);
    }

    /*******************************************************************************************************
     * @description Method used to prepare phone numbers which configured in sms package
     * @return Map<String, String>
     * @param none
     **/
    @AuraEnabled
    public static Map<String, String> getAvailableFromNumbers() {
        Map<String, String> availableFromNumbers = new Map<String, String>();
        // getting phone number with dynamic binding/checks of sms package
        for (SelectOption so: SCH_SMSService.getAvailablePhoneNumbers(false)) {
            availableFromNumbers.put(so.getValue(), so.getLabel());
        }
        return availableFromNumbers;
    }

    /*******************************************************************************************************
     * @description Method used to get total records count for specific sobject and criteria
     * @return Integer
     * @param objName: sObject API Name which used to query total records
     * @param filter: criteria which used to alter the sObject records
     **/
    @AuraEnabled
    public static Integer getTotalAttendeeCount(String objName, String filter) {
        // Security Review fixes
        objName = SCH_BtBaseUtils.secureIdInjection(objName);
        filter = (String.isBlank(filter) ? '' : filter).replaceAll('WHERE', '').replace('undefined', '');
        
        filter = (String.isNotBlank(filter) ? ' WHERE ' + filter : '');
        String sSOQL = 'SELECT count() FROM ' + objName + filter;
        return Database.countQuery(sSOQL);
    }

    /*******************************************************************************************************
     * @description Method used to get Account details
     * @return SCH_Account
     * @param none
     **/
    @AuraEnabled
    public static SCH_Account getAccount() {
        try {
            return SCH_AccountService.getAccount();
        } catch (Exception e) {
            System.debug('> ' + e.getStacktraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to get Schedule records with Schedule Action
     * @return List<SCH_Schedule__c> : List of Schedule records
     * @param recordId: Schedule sObject record Id
     **/
    @AuraEnabled
    public static List<SCH_Schedule__c> getScheduleWithActions(String recordId) {
        try {
            return new SCH_ScheduleSelector().getScheduleWithActions(new Set<Id> {
                recordId
            });
        } catch (Exception e) {
            throw new AuraException(e.getMessage());
        }
    }

    /********************************************************************************************************
     * @description This method return related sObject details
     * @param sObjectName: sObject API Name
     * @param relationshipName: Related field relationship name
     * @return Object: Related sObject details
     **/
    @AuraEnabled
    public static Object getAssociateReference(String sObjectName, String relationshipName) {
        // Security Review fixes
        sObjectName = SCH_BtBaseUtils.secureIdInjection(sObjectName);
        
        try {
            return SCH_BtBaseUtils.getAssociateReference(sObjectName, relationshipName);
        } catch (Exception e) {
            system.debug('Exception>getAssociateReference:'+e.getMessage());
            return null;
        }
    }

     /*******************************************************************************************************
     * @description Method used to get Event record details
     * @return sObject : Event sObject details
     * @param recordId: Event sObject record Id
     **/
    @AuraEnabled
    public static sObject fetchEventDetail(String recordId) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);

        List<SObject> records = SCH_BtBaseUtils.fetchSObjectByIds(SCH_BtBaseUtils.eventSobjectName, SCH_BtBaseUtils.eventQueryFields, new Set<String> {
            recordId
        });
        if (records.isEmpty()) {
            return null;
        }
        return records[0];
    }

    /*******************************************************************************************************
     * @description Method used to get Event time zone details
     * @return sObject : Time Zone Name
     * @param recordId: Event sObject record Id
     **/
    @AuraEnabled
    public static String fetchTimeZoneName(String recordId) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        String timeZoneDisplayName = SCH_BtBaseUtils.CURRENT_USER_TIMEZONE;
        sObject obj = fetchEventDetail(recordId);
        if (obj != null && obj.get(SCH_BtBaseUtils.eventTimeZone) != null) {
            timeZoneDisplayName = Timezone.getTimeZone(String.valueOf(obj.get(SCH_BtBaseUtils.eventTimeZone))).getID();
        }
        return timeZoneDisplayName;
    }

    /*******************************************************************************************************
     * @description Method used to get related sObject names 
     * @return Map<String, String>
     * @param objectName: sObject API Name which used to get related sObject Names
     **/
    @AuraEnabled
    public static List<Object> getGlobalChildsObjectName(String objectName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);

        List<Object> globalChildsObjectNames = new List<Object>();
        for (Schema.ChildRelationship cr: SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName.toLowerCase()).getDescribe().getChildRelationships()) {
            Schema.DescribeSObjectResult fr = cr.getChildSObject().getDescribe();
            String relationshipName = cr.getField().getDescribe().getRelationshipName();
            if (String.isNotBlank(relationshipName)) {
                Map<String, String> mapChildDate = new Map<String, String>();
                mapChildDate.put('label', fr.getLabel());
                mapChildDate.put('value', cr.getChildSObject() + '');
                mapChildDate.put('field_api_name', cr.getField() + '');
                mapChildDate.put('relationship_name', relationshipName);
                globalChildsObjectNames.add(mapChildDate);
            }
        }
        return globalChildsObjectNames;
    }

    /*******************************************************************************************************
     * @description Method used to build sObject filter criteria for Related sObject to show Total Recipients
     * @return String
     * @param objectName: sObject API Name which used to get total recipient filter
     * @param relatedObject: Related sObject API Name which used to get Related field API Name
     * @param relatedRelationshipName: Related sObject Relationship Name 
     * @param scheduleId: Schedule record Id
     **/
    @AuraEnabled
    public static String getAdminTotalRecipientsFilter(String objectName, String relatedObject, String relatedRelationshipName, String scheduleId) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        
        String filter = '';
        String fieldName = getRelatedRelationshipFieldName(objectName, relatedObject, relatedRelationshipName);
        List<SCH_Schedule__c> lstSchedule = new SCH_ScheduleSelector().getSchedule(new Set<Id> {
            scheduleId
        });
        for (SCH_Schedule__c schedule: lstSchedule) {
            if (String.isNotBlank(schedule.Related_Object_Evaluate_Criteria__c)) {
                filter = ' WHERE ( ' + schedule.Related_Object_Evaluate_Criteria__c + ' ) ';
            }
            if (String.isNotBlank(schedule.Base_Object_Evaluate_Criteria__c) && String.isNotBlank(schedule.Base_Object_Evaluate_Criteria_JSON__c)) { //Used to add Relationship Name in fiter crieria
                Map<String, Object> mapBaseObjectCriteriaJSON = (Map<String, Object> ) JSON.deserializeUntyped(schedule.Base_Object_Evaluate_Criteria_JSON__c);
                if (mapBaseObjectCriteriaJSON.containsKey('filters') && mapBaseObjectCriteriaJSON.get('filters') != null) {
                    //Add relationship with each field
                    for (Object filterObj: (List<Object> ) mapBaseObjectCriteriaJSON.get('filters')) {
                        Map<String, Object> mapFilter = (Map<String, Object> ) filterObj;
                        String filterValue = relatedRelationshipName + '.' + String.valueOf(mapFilter.get('f'));
                        if (mapFilter.containsKey('f') && relatedRelationshipName != null && schedule.Base_Object_Evaluate_Criteria__c.indexof(filterValue) == -1) {
                            schedule.Base_Object_Evaluate_Criteria__c = schedule.Base_Object_Evaluate_Criteria__c.replaceAll('(?<!\\S)' + String.valueOf(mapFilter.get('f')) + '(?!\\S)', filterValue);
                        }
                    }
                    filter += (String.isBlank(filter) ?' WHERE ':' AND ') + '( ' + schedule.Base_Object_Evaluate_Criteria__c + ' ) ';
                }
            } else if (String.isNotBlank(schedule.Base_Object_Evaluate_Criteria__c)) {
                if (String.isNotBlank(relatedRelationshipName)) {
                    // migrating relationship name to API Name
                    if (relatedRelationshipName != SCH_BtBaseUtils.sessionRelationShipName) {
                        relatedRelationshipName = relatedRelationshipName.endsWithIgnoreCase('__r') ? (relatedRelationshipName.substring(0, relatedRelationshipName.lastIndexOf('__r'))+'__c') : relatedRelationshipName + 'Id';
                    }else{
                        relatedRelationshipName = relatedRelationshipName+'.'+SCH_BtBaseUtils.eventSobjectName;
                    }
                    // making sure field is not ending with IdId
                    relatedRelationshipName = relatedRelationshipName.endsWithIgnoreCase('IdId') ? relatedRelationshipName.replace('IdId', 'Id') : relatedRelationshipName;
                    if (schedule.Base_Object_Evaluate_Criteria__c.indexOf('.') == -1 && schedule.Base_Object_Evaluate_Criteria__c.indexOf(relatedRelationshipName) == -1) {
                        schedule.Base_Object_Evaluate_Criteria__c = schedule.Base_Object_Evaluate_Criteria__c.replaceAll('\\b'+SCH_BtBaseUtils.eventSobjectName+'\\b', relatedRelationshipName);
                    }
                    //Replace with Relationship name
                    schedule.Base_Object_Evaluate_Criteria__c = schedule.Base_Object_Evaluate_Criteria__c.replace('Id', relatedRelationshipName);
                }
                filter += (String.isBlank(filter)?' WHERE ':' AND ') + '( ' + schedule.Base_Object_Evaluate_Criteria__c + ' ) ';
            }
        }
        //Add Related Field Name
        if (String.isNotBlank(fieldName)) {
            filter += (String.isBlank(filter) ?' WHERE ':' AND ') + fieldName + ' != null ';
        }
        return filter;
    }

    /*******************************************************************************************************
     * @description Method used to get Related relationship field api name
     * @return String
     * @param objectName: sObject API Name which used to get total recipient filter
     * @param relatedObject: Related sObject API Name which used to get Related field API Name
     * @param relatedRelationshipName: Related sObject Relationship Name 
     **/
    @AuraEnabled
    public static String getRelatedRelationshipFieldName(String objectName, String relatedObject, String relatedRelationshipName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        relatedObject = SCH_BtBaseUtils.secureIdInjection(relatedObject);
        String fieldName = '';
        for (Schema.ChildRelationship cr: SCH_BtBaseUtils.GLOBAL_SOBJECTTYPE.get(objectName.toLowerCase()).getDescribe().getChildRelationships()) {
            Schema.DescribeSObjectResult fr = cr.getChildSObject().getDescribe();
            String relationshipName = cr.getField().getDescribe().getRelationshipName();
            if (String.isNotBlank(relationshipName) && fr.getName() == relatedObject && relatedRelationshipName == relationshipName) {
                fieldName = cr.getField() + '';
                break;
            }
        }
        return fieldName;
    }

    /*******************************************************************************************************
     * @description Method used to create Schedule and Schedule Action sObject records
     * @return String
     * @param scheduleJSON: used to create Schedule and Schedule Action reocrd
     **/
    @AuraEnabled
    public static String createSchedule(String scheduleJSON) {
        try {
            Map<String, Object> mapScheduleData = (Map<String, Object> ) JSON.deserializeUntyped(scheduleJSON);

            Boolean isExistingSchedule = false;
            SCH_Schedule__c oScheduler = new SCH_Schedule__c();
            if (mapScheduleData.containskey('Schedule_Id') && mapScheduleData.get('Schedule_Id') != null) {
                oScheduler.Id = String.valueOf(mapScheduleData.get('Schedule_Id'));
                isExistingSchedule = true;
            }
            oScheduler.Name = String.valueOf(mapScheduleData.get('Name'));
            oScheduler.Base_Object__c = String.valueOf(mapScheduleData.get('Base_Object'));
            oScheduler.Base_Object_Evaluate_Criteria__c = String.valueOf(mapScheduleData.get('Base_Object_Evaluate_Criteria'));
            oScheduler.Base_Object_Evaluate_Criteria_JSON__c = String.valueOf(mapScheduleData.get('Base_Object_Evaluate_Criteria_JSON'));
            oScheduler.Related_Object__c = String.valueOf(mapScheduleData.get('Related_Object'));
            if (String.isBlank(oScheduler.Related_Object__c)) {
                oScheduler.Related_Object__c = oScheduler.Base_Object__c;
            }
            String relatedObjectEvaluateCriteria = String.valueOf(mapScheduleData.get('Related_Object_Evaluate_Criteria'));
            if (String.isNotBlank(relatedObjectEvaluateCriteria)) {
                oScheduler.Related_Object_Evaluate_Criteria__c = relatedObjectEvaluateCriteria;
            }
            oScheduler.Related_Object_Evaluate_Criteria_JSON__c = String.valueOf(mapScheduleData.get('Related_Object_Evaluate_Criteria_JSON'));
            oScheduler.Related_Object_Relationship_Name__c = String.valueOf(mapScheduleData.get('Related_Object_Relationship_Name'));
            oScheduler.SObject_Record_Id__c = String.valueOf(mapScheduleData.get('SObject_RecordId'));
            oScheduler.Status__c = String.valueOf(mapScheduleData.get('Status'));
            oScheduler.Type__c = String.valueOf(mapScheduleData.get('Type'));
            String scheduleTime = String.valueOf(mapScheduleData.get('Schedule_Date_Time_Field'));
            String days = String.valueOf(mapScheduleData.get('Offset_Value'));
            oScheduler.Execute_Now__c = false;
            if (String.isNotBlank(scheduleTime) && scheduleTime == 'now') {
                oScheduler.Schedule_Date_Time__c = System.now().addMinutes(2);
                oScheduler.Execute_Now__c = true;
                oScheduler.Offset__c = null;
                oScheduler.Offset_Type__c = null;
                oScheduler.Offset_Value__c = null;
                oScheduler.Schedule_Date_Time_Field__c = null;
            } else if (String.isNotBlank(scheduleTime) && String.isNotBlank(days)) {
                oScheduler.Offset__c = String.valueOf(mapScheduleData.get('Offset'));
                oScheduler.Offset_Type__c = String.valueOf(mapScheduleData.get('Offset_Type'));
                oScheduler.Offset_Value__c = Double.valueOf(mapScheduleData.get('Offset_Value'));
                oScheduler.Schedule_Date_Time_Field__c = scheduleTime;
                oScheduler.Schedule_Date_Time__c = null;
            }

            if (oScheduler.Schedule_Date_Time__c == null && oScheduler.Offset__c == null && mapScheduleData.containsKey('Schedule_Date_Time') && mapScheduleData.get('Schedule_Date_Time') != null) {
                String sdateTime = (mapScheduleData.containsKey('Schedule_Date_Time') ? (mapScheduleData.get('Schedule_Date_Time') + '') : '');
                if (String.isNotBlank(sdateTime) && sdateTime != null) {
                    oScheduler.Schedule_Date_Time__c = (DateTime) JSON.deserialize('"' + sdateTime + '"', DateTime.class);
                    oScheduler.Offset__c = null;
                    oScheduler.Offset_Type__c = null;
                    oScheduler.Offset_Value__c = null;
                    oScheduler.Schedule_Date_Time_Field__c = null;
                }
            }

            if (String.isNotBlank(oScheduler.SObject_Record_Id__c) &&
                String.isNotBlank(oScheduler.Related_Object__c) &&
                oScheduler.Related_Object__c == 'conference360__Session_Attendee__c' &&
                oScheduler.Base_Object__c != 'conference360__Session__c') {
                oScheduler.Base_Object__c = 'conference360__Session__c';
                oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('Id', SCH_BtBaseUtils.eventSobjectName);
                oScheduler.Related_Object_Relationship_Name__c = 'conference360__Session__r';
            }

            if (String.isNotBlank(oScheduler.Schedule_Date_Time_Field__c) &&
                String.isNotBlank(oScheduler.SObject_Record_Id__c) &&
                oScheduler.Schedule_Date_Time_Field__c.indexof('.') != -1) {
                List<String> baseobjectDetails = oScheduler.Schedule_Date_Time_Field__c.split('\\.');
                oScheduler.Schedule_Date_Time_Field__c = baseobjectDetails[1];
                oScheduler.Base_Object__c = baseobjectDetails[0].trim();
                if (oScheduler.Base_Object__c == 'conference360__Attendee__c') {
                    oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('Id', SCH_BtBaseUtils.eventSobjectName);
                    oScheduler.Related_Object_Relationship_Name__c = null;
                } else if (oScheduler.Base_Object__c == 'conference360__Session__c') {
                    oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('Id', SCH_BtBaseUtils.eventSobjectName);
                    oScheduler.Related_Object_Relationship_Name__c = 'conference360__Session__r';
                } else if (oScheduler.Base_Object__c == 'conference360__Session_Attendee__c' && oScheduler.Related_Object__c == 'conference360__Session_Attendee__c') {
                    oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('conference360__Session__r.conference360__Event__c', 'Id');
                    oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('conference360__Event__c', 'Id');
                    oScheduler.Base_Object_Evaluate_Criteria__c = oScheduler.Base_Object_Evaluate_Criteria__c.replace('Id', 'conference360__Session__r.conference360__Event__c');
                    oScheduler.Related_Object_Relationship_Name__c = null;
                } else {
                    oScheduler.Related_Object_Relationship_Name__c = 'conference360__Event__r';
                }
            }
            upsert oScheduler;

            SCH_Schedule_Action__c oSchedulerAction = new SCH_Schedule_Action__c();
            if (mapScheduleData.containskey('Schedule_Action_Id') && mapScheduleData.get('Schedule_Action_Id') != null) {
                oSchedulerAction.Id = String.valueOf(mapScheduleData.get('Schedule_Action_Id'));
            } else {
                oSchedulerAction.Schedule__c = oScheduler.Id;
            }
            String action = String.valueOf(mapScheduleData.get('Action'));
            oSchedulerAction.Action__c = action;
            oSchedulerAction.Name = String.valueOf(mapScheduleData.get('Name'));
            oSchedulerAction.Recipient__c = Integer.valueOf(mapScheduleData.get('Recipient'));
            if (String.isNotBlank(action) && action.toLowerCase() == 'email') {
                oSchedulerAction.Email_From_Address__c = String.valueOf(mapScheduleData.get('Email_From_Address'));
                oSchedulerAction.Email_From_Address_Id__c = SCH_EmailService.getOrgWideEmailAddressId(oSchedulerAction.Email_From_Address__c);
                oSchedulerAction.Email_To_Address_Field__c = String.valueOf(mapScheduleData.get('Email_To_Address'));
                oSchedulerAction.Email_Template_Id__c = String.valueOf(mapScheduleData.get('Email_Template_Id'));
            } else {
                oSchedulerAction.SMS_From_Number__c = String.valueOf(mapScheduleData.get('SMS_From_Number'));
                oSchedulerAction.SMS_To_Number_Field__c = String.valueOf(mapScheduleData.get('SMS_To_Number'));
                oSchedulerAction.SMS_Template_Id__c = String.valueOf(mapScheduleData.get('SMS_Template_Id'));
                oSchedulerAction.SMS_Attachment_Id__c = String.valueOf(mapScheduleData.get('SMS_Attachment_Id'));
                oSchedulerAction.SMS_Message__c = String.valueOf(mapScheduleData.get('SMS_Message'));
            }
            if (mapScheduleData.containskey('Associate_With_Referenced_Record')) {
                oSchedulerAction.Associate_With_Referenced_Record__c = Boolean.valueOf(mapScheduleData.get('Associate_With_Referenced_Record'));
            }
            upsert oSchedulerAction;
            return oScheduler.Id;
        } catch (DMLException dmlex) {
            throw new AuraException(dmlex.getDMLMessage(0));
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to create Schedule at API Side
     * @return SCH_ResponseWrapper
     * @param recordId: schedule record Id which used to create schedule at api side
     * @param isSchedule: used to schedule the schedule record
     **/
    @AuraEnabled
    public static SCH_ResponseWrapper createNewScheduleCallout(String recordId, Boolean isSchedule) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);

        try {
            SCH_ResponseWrapper oResponseWrapper;
            List<SCH_Schedule__c> lstSchedule = new SCH_ScheduleSelector().getScheduleWithActions(new Set<Id> {
                recordId
            });
            if (lstSchedule != null && lstSchedule.size() > 0) {
                if (isSchedule) {
                    lstSchedule[0].Status__c = 'active';
                }
                oResponseWrapper = SCH_AccountService.createSchedules(lstSchedule[0], null);
            }
            if (oResponseWrapper != null && isSchedule) {
                lstSchedule = new List<SCH_Schedule__c>{new SCH_Schedule__c(Id = recordId, Status__c = 'scheduled')};
                SCH_BtBaseUtils.maintainSObjects(new Schema.SObjectType[] { SCH_Schedule__c.SObjectType }, lstSchedule);
            }
            return oResponseWrapper;
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }

     /*******************************************************************************************************
     * @description Method used to update Schedule at API Side
     * @return SCH_ResponseWrapper
     * @param recordId: schedule record Id which used to create schedule at api side
     * @param isSchedule: used to schedule the schedule record
     **/
    @AuraEnabled
    public static SCH_ResponseWrapper updateSchedule(String recordId, String status) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        try {
            SCH_ResponseWrapper oResponseWrapper;
            List<SCH_Schedule__c> lstSchedule = new SCH_ScheduleSelector().getScheduleWithActions(new Set<Id> {
                recordId
            });
            if (lstSchedule != null && lstSchedule.size() > 0) {
                lstSchedule[0].Status__c = status;
                oResponseWrapper = SCH_AccountService.updateSchedules(lstSchedule[0], null);
                if (oResponseWrapper != null) {
                    if (lstSchedule[0].Status__c == 'active') {
                        lstSchedule[0].Status__c = 'scheduled';
                    } else if (lstSchedule[0].Status__c == 'archived') {
                        lstSchedule[0].Status__c = 'canceled';
                    }
                    SCH_BtBaseUtils.maintainSObjects(new Schema.SObjectType[] { SCH_Schedule__c.SObjectType }, lstSchedule);
                }
            }
            return oResponseWrapper;
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to preview sms and email
     * @return none
     * @param scheduleJSON: schedule and schedule action details
     * @param phoneOrEmailValues: multiple phone number/email addresses
     * @param targetRecordId: sObject record Id
     **/
    @AuraEnabled
    public static void sendAndTestScheduleSMSPreview(String scheduleJSON, String phoneOrEmailValues, String targetRecordId) {
        // Security Review fixes
        targetRecordId = SCH_BtBaseUtils.secureIdInjection(targetRecordId);
        try {
            Map<String, Object> mapScheduleData = (Map<String, Object> ) JSON.deserializeUntyped(scheduleJSON);
            String action = String.valueOf(mapScheduleData.get('Action'));
            if (String.isNotBlank(action) && action.toLowerCase() == 'email') {
                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put('fromEmailAddress', mapScheduleData.get('Email_From_Address'));
                mapParams.put('toEmailAddress', new List<String>(phoneOrEmailValues.split(',')));
                mapParams.put('targetRecordId', targetRecordId);
                mapParams.put('emailTemplateId', String.valueOf(mapScheduleData.get('Email_Template_Id')));
                SCH_EmailService.sendTestEmails(mapParams);
            } else {
                //These following parameters used with blackthron api
                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put('from_number', mapScheduleData.get('SMS_From_Number'));
                mapParams.put('to_number', new List<String>(phoneOrEmailValues.split(',')));
                mapParams.put('target_record_id', targetRecordId);
                mapParams.put('sms_body', String.valueOf(mapScheduleData.get('SMS_Message')));
                mapParams.put('sms_template_id', mapScheduleData.get('SMS_Template_Id'));
                mapParams.put('sms_attachment_id', mapScheduleData.get('SMS_Attachment_Id'));
                SCH_SMSService.sendTestSMS(mapParams);
            }
        } catch (DMLException dmlex) {
            throw new AuraException(dmlex.getDMLMessage(0));
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to get Recipients records
     * @return DataTableWrapper
     * @param objectName: sObject API Name which used to get records
     * @param relatedObjectFieldAPIName: used to pull sObject related field name
     * @param filter: used to filter sObject record
     * @param fieldsToShow: sObject API Name to show additional information
     * @param fieldNameToReplace: Field API Name to replace Name field
     **/
    @AuraEnabled
    public static DataTableWrapper getRecipients(String objectName, String relatedObjectFieldAPIName, String filter, String fieldsToShow, String fieldNameToReplace) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        fieldsToShow = String.isBlank(fieldsToShow) ? '' : String.escapeSingleQuotes(fieldsToShow);
        relatedObjectFieldAPIName = String.isBlank(relatedObjectFieldAPIName) ? '' : String.escapeSingleQuotes(relatedObjectFieldAPIName);
        
        DataTableWrapper oDataTableWrapper = new DataTableWrapper();
        oDataTableWrapper.columns = new List<ColumnsWrapper>();
        if (String.isBlank(fieldNameToReplace)) {
            oDataTableWrapper.nameField = SCH_BtBaseUtils.getNamedFieldForsObject(objectName);
        } else {
            oDataTableWrapper.nameField = String.escapeSingleQuotes(fieldNameToReplace);
        }
        oDataTableWrapper.sObjectLabel = SCH_BtBaseUtils.getsObjectLabel(objectName);
        Map<String, String> mapFieldAPIName = SCH_BtBaseUtils.getsObjectFieldDynamic(objectName, true);
        String nameFieldLabel = (mapFieldAPIName.containsKey(oDataTableWrapper.nameField) ? mapFieldAPIName.get(oDataTableWrapper.nameField) : oDataTableWrapper.nameField);
        if (nameFieldLabel.indexof('.') != -1) {
            List<String> lstNameFieldLabel = nameFieldLabel.split('\\.');
            if (lstNameFieldLabel != null && lstNameFieldLabel.size() > 0) {
                nameFieldLabel = SCH_BtBaseUtils.getParentsObjectFieldLabel(objectName, lstNameFieldLabel[0], lstNameFieldLabel[1]);
            }
        }
        
        oDataTableWrapper.columns.add(new ColumnsWrapper(nameFieldLabel, oDataTableWrapper.nameField + 'link', 'url', new DatatypeAttributes(new Attribute(oDataTableWrapper.nameField), '_blank')));
        if (String.isNotBlank(fieldsToShow)) {
            String fieldsToShowLabel = (mapFieldAPIName.containsKey(fieldsToShow) ? mapFieldAPIName.get(fieldsToShow) : fieldsToShow);
            if (fieldsToShow.indexof('.') != -1) {
                List<String> lstFieldsToShow = fieldsToShow.split('\\.');
                if (lstFieldsToShow != null && lstFieldsToShow.size() > 0) {
                    Integer totalIndex = lstFieldsToShow.size();
                    fieldsToShowLabel = SCH_BtBaseUtils.getParentsObjectFieldLabel(objectName, lstFieldsToShow[(totalIndex-2)], lstFieldsToShow[(totalIndex-1)]);
                }
            }
            fieldsToShowLabel = fieldsToShowLabel.replace('(Deprecated)', '');
            
            ColumnsWrapper addColumnsWrapper = new ColumnsWrapper(fieldsToShowLabel, fieldsToShow, 'text', null);
            addColumnsWrapper.iconLabel = fieldsToShow;
            addColumnsWrapper.iconName = 'utility:info';
            oDataTableWrapper.columns.add(addColumnsWrapper);
        }
        oDataTableWrapper.data = new List<SObject>();
        String sWhereClause = '';
        String operator = '';
        if (String.isNotBlank(filter)) {
            sWhereClause += operator + ' ' + filter;
            operator = ' AND ';
        }
        if (String.isNotBlank(relatedObjectFieldAPIName)) {
            sWhereClause += operator + ' ' + relatedObjectFieldAPIName + ' != null ';
        }
        if (String.isNotBlank(sWhereClause) && !sWhereClause.contains('WHERE')) {
            sWhereClause = ' WHERE ' + sWhereClause;
        }
        String sSOQL = 'SELECT Id, ' + oDataTableWrapper.nameField + (String.isNotBlank(fieldsToShow) ? (', ' + fieldsToShow) : '') + ' FROM ' + objectName + sWhereClause;
        System.debug('===soql===' + sSOQL);
        for (sObject obj: Database.query(sSOQL)) {
            oDataTableWrapper.data.add(obj);
        }
        return oDataTableWrapper;
    }

    /*******************************************************************************************************
     * @description Method used to get Schedule records from API
     * @return DataTableWrapper
     * @param actionType: Use this to filter by their action's type such as sms or email
     * @param scheduleType: Use this to filter by schedule's schedule_types
     * @param status: Use this to filter by schedule's status
     * @param isIncludeArchived: Use this flag with all in status parameter. The api will return archive records as well
     * @param recordId: Schedule record Id
     * @param currentPage: Request a specific page when records are more then one page.
     * @param pageSize: Define a page size of your choice
     **/
    @AuraEnabled
    public static DataTableWrapper getAdminSchedules(String actionType, String scheduleType, String status, Boolean isIncludeArchived, String recordId, Integer currentPage, Integer pageSize, Boolean isGlobal) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        Map<String, String> mapParams = new Map<String, String>();
        //These parameters used for Blackthron API
        if (String.isNotBlank(scheduleType)) {
            mapParams.put('schedule_type', scheduleType);
        }
        if (String.isNotBlank(status)) {
            mapParams.put('status', status);
        }
        if (String.isNotBlank(actionType)) {
            mapParams.put('action_type', actionType);
        }
        if (isIncludeArchived) {
            if (mapParams.containsKey('status')) {
                mapParams.put('status', mapParams.get('status') + ',archived');
            } else {
                mapParams.put('status', 'archived');
            }
            mapParams.put('include_archived', isIncludeArchived + '');
        }
        if (String.isNotBlank(recordId)) {
            mapParams.put('record_id', recordId);
        }

        if (currentPage != null) {
            mapParams.put('current_page', currentPage + '');
        }
        if (pageSize != null) {
            mapParams.put('page_size', pageSize + '');
        }

        SCH_Schedule oSchedule;
        try {
            oSchedule = SCH_AccountService.getSchedules(mapParams);
        } catch (Exception excp) {
            throw new AuraHandledException(excp.getMessage());
        }

        DataTableWrapper oDataTableWrapper = new DataTableWrapper();
        oDataTableWrapper.columns = new List<ColumnsWrapper>();
        oDataTableWrapper.columns.add(new ColumnsWrapper('Action', 'ScheduleType', 'text', 90, null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Name', 'ScheduleActionName', 'text', null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Recipients', 'Recipients', 'button', 90, new DatatypeAttributes(new Attribute('Recipients'), '', 'ActionName', 'base', null, null, null, null, new Attribute('bClass')), new DatacellAttributes()));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Schedule Time', 'ScheduleDateTimeField', 'text', null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Status', 'Status', 'text', 90, null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Next Execution Date/Time', 'NextExecutionDateTimeStatus', 'text', 250, null));
        if (String.isBlank(recordId)) {
            oDataTableWrapper.columns.add(new ColumnsWrapper('Related Details', 'RelatedDetails', 'text', null));
        }
        oDataTableWrapper.scheduleData = new List<ScheduleData>();

        Set<String> setRecordId = new Set<String>();
        Map<String, SObject> mapRecords = new Map<String, SObject>();
        if (isGlobal == null) {
            isGlobal = false;
        }
        if (!isGlobal) {
            for (SCH_Schedule.Schedule sch: oSchedule.getRecords()) {
                setRecordId.add(sch.getRecordId());
            }
            if (setRecordId.size() > 0) {
                mapRecords = new Map<String, SObject>(SCH_BtBaseUtils.fetchSObjectByIds(SCH_BtBaseUtils.eventSobjectName, SCH_BtBaseUtils.eventQueryFields, setRecordId));
            }
        }

        for (SCH_Schedule.Schedule sch: oSchedule.getRecords()) {
            if (sch.getactions() != null) {
                for (SCH_Schedule.ScheduleAction schAction: sch.getactions()) {
                    ScheduleData oScheduleData = new ScheduleData();
                    oScheduleData.salesforce_id = sch.getSalesforceId();
                    String timeZone = SCH_BtBaseUtils.CURRENT_USER_TIMEZONE_ID;
                    if (sch.getRecordId() != null && mapRecords.containskey(sch.getRecordId()) && mapRecords.get(sch.getRecordId()).get(SCH_BtBaseUtils.eventTimeZone) != null) {
                        timeZone = String.valueOf(mapRecords.get(sch.getRecordId()).get(SCH_BtBaseUtils.eventTimeZone));
                    }
                    oScheduleData.ScheduleType = (schAction.getactionType() == 'sms' ? 'SMS' : schAction.getactionType().capitalize());
                    oScheduleData.ScheduleActionName = schAction.getname();
                    oScheduleData.Status = sch.getstatus().capitalize();
                    oScheduleData.Recipients = 'View';
                    if (String.isBlank(sch.getScheduleDateTime())) {
                        oScheduleData.ScheduleDateTimeField = sch.getoffsetValue() + ' ' + (sch.getoffset_type() == 'minutes' ? 'mins' : (sch.getoffset_type() == 'hours' ? 'hrs' : sch.getoffset_type())) + ' ' + sch.getoffset() + ' ' + (String.isNotBlank(sch.getschedule_field()) ? '[' + SCH_BtBaseUtils.getsObjectFieldLabel(sch.getBaseSobject(), sch.getschedule_field()) + ']' : '');
                    }else{
                        oScheduleData.ScheduleDateTimeField = SCH_BtBaseUtils.getFormatDateTime(sch.getScheduleDateTime(), timeZone);
                    }
                    
                    oScheduleData.NextExecutionDateTime = SCH_BtBaseUtils.getFormatDateTime(sch.getNextExecutionDateTime(), timeZone);
                    oScheduleData.NextExecutionStatus = sch.getNextExecutionStatus();
                    if (String.isNotBlank(oScheduleData.NextExecutionStatus) && oScheduleData.NextExecutionStatus == 'scheduled') {
                        oScheduleData.NextExecutionStatus = 'Scheduled';
                    } else if (String.isNotBlank(oScheduleData.NextExecutionStatus) && (oScheduleData.NextExecutionStatus == 'pending' || oScheduleData.NextExecutionStatus == 'queued')) {
                        oScheduleData.NextExecutionStatus = 'Queued';
                    } else if (String.isNotBlank(oScheduleData.NextExecutionStatus) && (oScheduleData.NextExecutionStatus == 'in_progress' || oScheduleData.NextExecutionStatus == 'in progress')) {
                        oScheduleData.NextExecutionStatus = 'In Progress';
                    } else if (String.isNotBlank(oScheduleData.NextExecutionStatus)) {
                        oScheduleData.NextExecutionStatus = oScheduleData.NextExecutionStatus.capitalize();
                    }
                    oScheduleData.RelatedDetails = (sch.getschedule_type() == 'record' ? (schAction.getname() + '-' + sch.getbaseSobject()) : (sch.getbaseSobject() == sch.getrelatedSobject() && String.isBlank(sch.getBaseRelatedRelationship()) ? sch.getbaseSobject() : sch.getbaseSobject() + '-' + sch.getrelatedSobject()));
                    oScheduleData.base_object = sch.getbaseSobject();
                    oScheduleData.related_object = sch.getrelatedSobject();
                    oScheduleData.sms_to_number_field = schAction.getSmsToNumberField();
                    oScheduleData.email_to_address_field = schAction.getEmailToAddressField();
                    oScheduleData.base_sobject_criteria = sch.getBaseSobjectCriteria();
                    oScheduleData.related_sobject_criteria = sch.getRelatedSobjectCriteria();
                    oScheduleData.first_activated_at = SCH_BtBaseUtils.getFormatDateTime(sch.getFirstActivatedAt(), timeZone);
                    oScheduleData.base_related_relationship = sch.getBaseRelatedRelationship();
                    oScheduleData.bClass = ' ' + oScheduleData.salesforce_id;
                    oDataTableWrapper.scheduleData.add(oScheduleData);
                }
            }
        }
        SCH_Schedule.MetadataConfig oMetadataConfig = oSchedule.getMetadata();
        oDataTableWrapper.page_size = oMetadataConfig.getPageSize();
        oDataTableWrapper.current_page = oMetadataConfig.getCurrentPage();
        oDataTableWrapper.has_next = oMetadataConfig.getHasNext();
        oDataTableWrapper.current_page_records = oMetadataConfig.getCurrentPageRecords();
        oDataTableWrapper.total_records = oMetadataConfig.getTotalRecords();
        return oDataTableWrapper;
    }

    /*******************************************************************************************************
     * @description Method used to Retrieve the information of all the Executions records from a Schedule with the matching salesforce_id
     * @return DataTableWrapper
     * @param record_id: Schedule record Id
     * @param current_page: Request a specific page when records are more then one page.
     * @param page_size: Define a page size of your choice
     * @param nameFieldToReplace: used to replace name field
     * @param isDisplayFailedOnly: Used to get Failed records only
     **/
    @AuraEnabled
    public static DataTableWrapper getAllExecutionsForSchedule(String recordId, Integer currentPage, Integer pageSize, String nameFieldToReplace, Boolean isDisplayFailedOnly) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        Map<String, String> mapParams = new Map<String, String>();
        //These parameters used for Blackthron API
        mapParams.put('salesforce_id', recordId);
        if (currentPage != null) {
            mapParams.put('current_page', currentPage + '');
        }
        if (pageSize != null) {
            mapParams.put('page_size', pageSize + '');
        }
        if (isDisplayFailedOnly) {
            mapParams.put('error_only', 'true');
        }

        //Get All Execute for schedule - API
        SCH_ExecutionSchedule oSchedule = SCH_AccountService.getAllExecutionsForSchedule(mapParams);
        SCH_ExecutionSchedule.MetadataConfig oMetadataConfig = oSchedule.getMetadata();

        DataTableWrapper oDataTableWrapper = new DataTableWrapper();
        oDataTableWrapper.columns = new List<ColumnsWrapper>();
        oDataTableWrapper.logsData = new List<ScheduleLogsData>();

        Map<String, sObject> mapexeSfdcIds = new Map<String, sObject>();
        Map<String, sObject> maplogSfdcIds = new Map<String, sObject>();

        for (SCH_ExecutionSchedule.Schedule sch: oSchedule.getRecords()) {
            maplogSfdcIds.put(sch.getSalesforceId(), null);
        }

        String parentColumnName = 'Parent';
        String logNameField = 'Name';
        if (!maplogSfdcIds.isEmpty()) {
            Set<String> logSfdcIds = maplogSfdcIds.keyset();
            String objectName = Id.valueOf(new List<String>(logSfdcIds)[0]).getsObjectType() + '';
            parentColumnName = SCH_BtBaseUtils.getsObjectLabel(objectName);
            if (String.isBlank(nameFieldToReplace)) {
                logNameField = SCH_BtBaseUtils.getNamedFieldForsObject(objectName);
            } else {
                logNameField = String.escapeSingleQuotes(nameFieldToReplace);
            }
            if (logNameField == null) {
                logNameField = 'Id';
            }
            // Getting query with CURD Checks
            String sSOQL = SCH_BtBaseUtils.prepareSObjectQuery(objectName, new List<String> {
                logNameField
            }, null, 'Id IN:logSfdcIds');
            for (sObject obj: Database.query(sSOQL)) {
                maplogSfdcIds.put((String) obj.get('Id'), obj);
            }
        }

        if (String.isBlank(nameFieldToReplace)) {
            oDataTableWrapper.columns.add(new ColumnsWrapper(parentColumnName, 'salesforce_id', 'url', new DatatypeAttributes(new Attribute('parent_log_name'), '_blank', null, null)));
        }
        //oDataTableWrapper.columns.add(new ColumnsWrapper('Recipient', 'recipient_salesforce_id', 'url', new DatatypeAttributes(new Attribute('recipient_name'), '_blank', null, null)));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Total Recipient', 'totalCounts', 'number', 150, null, new DatacellAttributes('center')));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Schedule Date/Time', 'scheduleDateTime', 'text', 190, null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Status', 'btitle', 'tooltip', 85,
            new DatatypeAttributes(new Attribute('Status'), '', null, 'bare',
                new Attribute('bdisable'), new Attribute('btitle'), new Attribute('bIcon'),
                new Attribute('bAlt'), new Attribute('bClass')),
            new DatacellAttributes()));

        

        for (SCH_ExecutionSchedule.Schedule sch: oSchedule.getRecords()) {
            ScheduleLogsData data = new ScheduleLogsData();
            data.salesforce_id = '/' + sch.getSalesforceId();
            data.parent_log_name = sch.getSalesforceId();
            if ((maplogSfdcIds.containsKey(sch.getSalesforceId()) && maplogSfdcIds.get(sch.getSalesforceId()) != null)) {
                if (logNameField.indexOf('.') != -1) {
                    List<String> sfFieldNames = logNameField.split('\\.');
                    sObject obj = maplogSfdcIds.get(sch.getSalesforceId());
                    for (Integer i = 0; i < sfFieldNames.size(); i++) {
                        if (i + 1 == sfFieldNames.size()) {
                            data.recipient_name = obj.get(sfFieldNames[i])+'';
                        }else{
                            obj = obj.getSObject(sfFieldNames[i]);
                        }
                    }
                }else{
                    data.parent_log_name = maplogSfdcIds.get(sch.getSalesforceId()).get(logNameField)+'';
                }
            }
            //data.recipient_salesforce_id = '/' + sch.getSalesforceId();
            //data.recipient_name = ((maplogSfdcIds.containsKey(sch.getSalesforceId()) && maplogSfdcIds.get(sch.getSalesforceId()) != null) ? maplogSfdcIds.get(sch.getSalesforceId()).get(logNameField) : sch.getSalesforceId()) + '';
            String timeZone = SCH_BtBaseUtils.CURRENT_USER_TIMEZONE_ID;
            if (maplogSfdcIds.containsKey(sch.getSalesforceId()) && maplogSfdcIds.get(sch.getSalesforceId()) != null && maplogSfdcIds.get(SCH_BtBaseUtils.eventTimeZone) != null) {
                timeZone = String.valueOf(maplogSfdcIds.get(SCH_BtBaseUtils.eventTimeZone));
            }
            data.scheduleDateTime = SCH_BtBaseUtils.getFormatDateTime(sch.getExecutionDateTime(), timeZone);
            data.Status = sch.getstatus().capitalize();
            data.totalCounts = sch.getLogCounts();
            data.bdisable = false;
            data.bVar = 'bare';
            data.bClass = 'icon-success slds-icon-text-success';
            data.btitle = sch.getStatusMessage();
            if (sch.getstatus() == 'success' || sch.getstatus() == 'sent') {
                data.bIcon = 'utility:success';
                data.btitle = 'success';
                data.bdisable = true;
            } else if (sch.getstatus() == 'failed') {
                data.bIcon = 'utility:warning';
                data.bClass = 'icon-warning slds-icon-text-warning';
            } else if (sch.getstatus() == 'blocked') {
                data.bIcon = 'utility:error';
                data.bClass = 'icon-error slds-icon-text-error';
            } else if (sch.getstatus() == 'in progress' || sch.getstatus() == 'in_progress') {
                data.bIcon = 'utility:clock';
                data.bClass = 'icon-info slds-icon-text-info';
            } else {
                data.bIcon = 'utility:info';
                data.bClass = 'icon-info slds-icon-text-info';
            }
            if (String.isBlank(data.btitle)) {
                data.bdisable = true;
            } else {
                data.btitle = data.Status + (String.isBlank(sch.getStatusMessage()) ? '' : +': ' + sch.getStatusMessage());
            }
            data.bClass += ' ' + data.salesforce_id + ' ' + data.recipient_salesforce_id + ' ' + data.Status;
            oDataTableWrapper.logsData.add(data);
        }

        oDataTableWrapper.page_size = oMetadataConfig.getPageSize();
        oDataTableWrapper.current_page = oMetadataConfig.getCurrentPage();
        oDataTableWrapper.has_next = oMetadataConfig.getHasNext();
        oDataTableWrapper.current_page_records = oMetadataConfig.getCurrentPageExecutionRecords();
        oDataTableWrapper.total_records = oMetadataConfig.getTotalExecutionRecords();
        return oDataTableWrapper;
    }

    /*******************************************************************************************************
     * @description Method used to Retrieve the information of all the logs records from a Execution with the matching salesforce_id and execution_id
     * @return DataTableWrapper
     * @param record_id: Schedule record Id
     * @param execution_id: Execution record Id
     * @param current_page: Request a specific page when records are more then one page.
     * @param page_size: Define a page size of your choice
     * @param nameFieldToReplace: used to replace name field
     * @param isDisplayFailedOnly: Used to get Failed records only
     **/
    @AuraEnabled
    public static DataTableWrapper getAllLogsForExecution(String recordId, String executionId, Integer currentPage, Integer pageSize, String nameFieldToReplace, Boolean isDisplayFailedOnly) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        executionId = SCH_BtBaseUtils.secureIdInjection(executionId);
        Map<String, String> mapParams = new Map<String, String>();
        //These parameters used for Blackthron API
        mapParams.put('salesforce_id', recordId);
        mapParams.put('execution_id', executionId);
        if (currentPage != null) {
            mapParams.put('current_page', currentPage + '');
        }
        if (pageSize != null) {
            mapParams.put('page_size', pageSize + '');
        }
        if (isDisplayFailedOnly) {
            mapParams.put('error_only', 'true');
        }

        //Get All Execute for schedule - API
        SCH_ExecutionSchedule oSchedule = SCH_AccountService.getAllLogsForExecution(mapParams);
        SCH_ExecutionSchedule.MetadataConfig oMetadataConfig = oSchedule.getMetadata();

        DataTableWrapper oDataTableWrapper = new DataTableWrapper();
        oDataTableWrapper.columns = new List<ColumnsWrapper>();
        oDataTableWrapper.logsData = new List<ScheduleLogsData>();

        Map<String, sObject> maplogSfdcIds = new Map<String, sObject>();

        String phoneOrEmailFieldLabel = 'Email';
        for (SCH_ExecutionSchedule.Schedule sch: oSchedule.getRecords()) {
            maplogSfdcIds.put(sch.getSalesforceId(), null);
            if (sch.getActionType() == 'sms') {
                phoneOrEmailFieldLabel = 'Phone';
            }
        }

        String logRecipientLabel = 'Recipient';
        String logNameField = 'Name';
        if (!maplogSfdcIds.isEmpty()) {
            Set<String> logSfdcIds = maplogSfdcIds.keyset();
            String objectName = Id.valueOf(new List<String>(logSfdcIds)[0]).getsObjectType() + '';
            logRecipientLabel = SCH_BtBaseUtils.getsObjectLabel(objectName);
            if (String.isBlank(nameFieldToReplace)) {
                logNameField = SCH_BtBaseUtils.getNamedFieldForsObject(objectName);
            } else {
                logNameField = String.escapeSingleQuotes(nameFieldToReplace);
            }
            if (logNameField == null) {
                logNameField = 'Id';
            }
            // Getting query with CURD Checks
            String sSOQL = SCH_BtBaseUtils.prepareSObjectQuery(objectName, new List<String> {
                logNameField
            }, null, 'Id IN:logSfdcIds');
            for (sObject obj: Database.query(sSOQL)) {
                maplogSfdcIds.put((String) obj.get('Id'), obj);
            }
        }

        oDataTableWrapper.columns.add(new ColumnsWrapper(logRecipientLabel, 'recipient_salesforce_id', 'url', new DatatypeAttributes(new Attribute('recipient_name'), '_blank', null, null)));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Schedule Date/Time', 'scheduleDateTime', 'text', 190, null));
        oDataTableWrapper.columns.add(new ColumnsWrapper(phoneOrEmailFieldLabel, 'emailOrPhone', 'text', 190, null));
        oDataTableWrapper.columns.add(new ColumnsWrapper('Status', 'btitle', 'tooltip', 85,
            new DatatypeAttributes(new Attribute('Status'), '', null, 'bare',
                new Attribute('bdisable'), new Attribute('btitle'), new Attribute('bIcon'),
                new Attribute('bAlt'), new Attribute('bClass')),
            new DatacellAttributes()));

        for (SCH_ExecutionSchedule.Schedule sch: oSchedule.getRecords()) {
            SCH_ExecutionSchedule.Execution oExecution = sch.getExecution();
            ScheduleLogsData data = new ScheduleLogsData();
            data.recipient_salesforce_id = '/' + sch.getSalesforceId();
            data.recipient_name = sch.getSalesforceId();
            if ((maplogSfdcIds.containsKey(sch.getSalesforceId()) && maplogSfdcIds.get(sch.getSalesforceId()) != null)) {
                if (logNameField.indexOf('.') != -1) {
                    List<String> sfFieldNames = logNameField.split('\\.');
                    sObject obj = maplogSfdcIds.get(sch.getSalesforceId());
                    for (Integer i = 0; i < sfFieldNames.size(); i++) {
                        if (i + 1 == sfFieldNames.size()) {
                            data.recipient_name = obj.get(sfFieldNames[i])+'';
                        }else{
                            obj = obj.getSObject(sfFieldNames[i]);
                        }
                    }
                }else{
                    data.recipient_name = maplogSfdcIds.get(sch.getSalesforceId()).get(logNameField)+'';
                }
            }
            String timeZone = SCH_BtBaseUtils.CURRENT_USER_TIMEZONE_ID;
            if (maplogSfdcIds.containsKey(sch.getSalesforceId()) && maplogSfdcIds.get(sch.getSalesforceId()) != null && maplogSfdcIds.get(SCH_BtBaseUtils.eventTimeZone) != null) {
                timeZone = String.valueOf(maplogSfdcIds.get(SCH_BtBaseUtils.eventTimeZone));
            }
            data.scheduleDateTime = SCH_BtBaseUtils.getFormatDateTime(sch.getExecutionDateTime(), timeZone);
            data.Status = sch.getstatus().capitalize();
            data.emailOrPhone = sch.getEmailOrPhone();
            data.bdisable = false;
            data.bVar = 'bare';
            data.bClass = 'icon-success slds-icon-text-success';
            data.btitle = sch.getStatusMessage();
            if (sch.getstatus() == 'success' || sch.getstatus() == 'sent') {
                data.bIcon = 'utility:success';
                data.btitle = 'success';
                data.bdisable = true;
            } else if (sch.getstatus() == 'failed') {
                data.bIcon = 'utility:warning';
                data.bClass = 'icon-warning slds-icon-text-warning';
            } else if (sch.getstatus() == 'blocked') {
                data.bIcon = 'utility:error';
                data.bClass = 'icon-error slds-icon-text-error';
            } else if (sch.getstatus() == 'in progress' || sch.getstatus() == 'in_progress') {
                data.bIcon = 'utility:clock';
                data.bClass = 'icon-info slds-icon-text-info';
            } else {
                data.bIcon = 'utility:info';
                data.bClass = 'icon-info slds-icon-text-info';
            }
            if (String.isBlank(data.btitle)) {
                data.bdisable = true;
            } else {
                data.btitle = data.Status + (String.isBlank(sch.getStatusMessage()) ? '' : +': ' + sch.getStatusMessage());
            }
            data.bClass += ' ' + data.salesforce_id + ' ' + data.recipient_salesforce_id + ' ' + data.Status;
            oDataTableWrapper.logsData.add(data);
        }

        oDataTableWrapper.page_size = oMetadataConfig.getPageSize();
        oDataTableWrapper.current_page = oMetadataConfig.getCurrentPage();
        oDataTableWrapper.has_next = oMetadataConfig.getHasNext();
        oDataTableWrapper.current_page_records = oMetadataConfig.getCurrentPageRecords();
        oDataTableWrapper.total_records = oMetadataConfig.getTotalRecords();
        oDataTableWrapper.failed_log_count = oMetadataConfig.getFailedLogCount();
        return oDataTableWrapper;
    }

    /*******************************************************************************************************
     * @description Method used to attendee filters options to record page
     * @return Map<String, String>
     * @param objectName: sObject API Name
     **/
    @AuraEnabled
    public static Map<String, String> getAttendeeFilterOptions(String objectName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        return SCH_BtBaseUtils.getFilters(objectName);
    }

    /*******************************************************************************************************
     * @description Method used to get Org Wide email address
     * @return List<String>
     * @param none
     **/
    @AuraEnabled
    public static List<String> getOrgWideEmailAddress() {
        return SCH_BtBaseUtils.fetchOrgWidEmails();
    }

    /*******************************************************************************************************
     * @description Method used to validate that specified emailAddress and accessible by either all profile or specified userId + verified
     * @return Boolean
     * @param String emailAddress
     * @param String userId
     **/
    @AuraEnabled
    public static Boolean checkOrgWideEmailAddress(String emailAddress, String userId) {
        // Security Review fixes
        userId = SCH_BtBaseUtils.secureIdInjection(userId);
        emailAddress = String.isBlank(emailAddress) ? '' : String.escapeSingleQuotes(emailAddress);
        return SCH_BtBaseUtils.checkOrgWideEmailAddress(emailAddress, userId);
    }

    /*******************************************************************************************************
     * @description Method used to get schedule date time fields for Attendee & Session Attendee
     * @return Map<String, String>
     * @param object_name: sObject API Name which used to get schedule date time fields
     **/
    @AuraEnabled
    public static Map<String, String> getScheduleDateTimeFields(String objectName) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        Map<String, String> mapDateTimeFields = new Map<String, String>();
        if (objectName == 'conference360__Attendee__c') {
            mapDateTimeFields.put(SCH_BtBaseUtils.getsObjectFieldLabel(SCH_BtBaseUtils.eventSobjectName, 'conference360__Event_Start_Date_Time_GMT__c'), 'conference360__Event__c.conference360__Event_Start_Date_Time_GMT__c');
            mapDateTimeFields.put(SCH_BtBaseUtils.getsObjectFieldLabel(SCH_BtBaseUtils.eventSobjectName, 'conference360__Event_End_Date_Time_GMT__c'), 'conference360__Event__c.conference360__Event_End_Date_Time_GMT__c');
            mapDateTimeFields.put('Event Attendee ' + SCH_BtBaseUtils.getsObjectFieldLabel('conference360__Attendee__c', 'conference360__Registration_DateTime__c'), 'conference360__Attendee__c.conference360__Registration_DateTime__c');
            mapDateTimeFields.put('Event Attendee ' + SCH_BtBaseUtils.getsObjectFieldLabel('conference360__Attendee__c', 'CreatedDate'), 'conference360__Attendee__c.CreatedDate');
        } else if (objectName == 'conference360__Session_Attendee__c') {
            mapDateTimeFields.put('Session ' + SCH_BtBaseUtils.getsObjectFieldLabel('conference360__Session__c', 'conference360__Start_Date_Time_GMT__c'), 'conference360__Session__c.conference360__Start_Date_Time_GMT__c');
            mapDateTimeFields.put('Session ' + SCH_BtBaseUtils.getsObjectFieldLabel('conference360__Session__c', 'conference360__End_Date_Time_GMT__c'), 'conference360__Session__c.conference360__End_Date_Time_GMT__c');
            mapDateTimeFields.put('Session Attendee ' + SCH_BtBaseUtils.getsObjectFieldLabel('conference360__Session_Attendee__c', 'CreatedDate'), 'conference360__Session_Attendee__c.CreatedDate');
        }
        return mapDateTimeFields;
    }

    /*******************************************************************************************************
     * @description Method used to Retry Failed Records with the matching salesforce_id and execution_id
     * @return none
     * @param record_id: Schedule record Id
     * @param execution_id: Execution record Id
     **/
    @AuraEnabled
    public static void retryFailedRecords(String recordId, String executionId) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        executionId = SCH_BtBaseUtils.secureIdInjection(executionId);
        try {
            Map<String, String> mapParams = new Map<String, String>();
            //These parameters used for Blackthron API
            mapParams.put('schedule_sf_id', recordId);
            mapParams.put('execution_sf_id', executionId);
            //Retry Failed Records - API
            SCH_AccountService.retryFailedRecords(mapParams);
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }

    /*******************************************************************************************************
     * @description Method used to resend status email with the matching salesforce_id and execution_id
     * @return none
     * @param record_id: Schedule record Id
     * @param execution_id: Execution record Id
     **/
    @AuraEnabled
    public static void resendStatusEmail(String recordId, String executionId) {
        // Security Review fixes
        recordId = SCH_BtBaseUtils.secureIdInjection(recordId);
        executionId = SCH_BtBaseUtils.secureIdInjection(executionId);
        try {
            Map<String, String> mapParams = new Map<String, String>();
            //These parameters used for Blackthron API
            mapParams.put('schedule_sf_id', recordId);
            mapParams.put('execution_sf_id', executionId);
            Map<String, String> recipients = new Map<String, String>();
            recipients.put('first_name', UserInfo.getFirstName());
            recipients.put('last_name', UserInfo.getLastName());
            recipients.put('email', UserInfo.getUserEmail());
            recipients.put('user_id', UserInfo.getUserId());
            mapParams.put('recipient', JSON.serialize(recipients));
            //Retry Failed Records - API
            SCH_AccountService.resendStatusEmail(mapParams);
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }
    
    public class DataTableWrapper {
        @AuraEnabled public List<ColumnsWrapper> columns;
        @AuraEnabled public List<sObject> data;
        @AuraEnabled public List<ScheduleData> scheduleData;
        @AuraEnabled public List<ScheduleLogsData> logsData;
        @AuraEnabled public List<String> expandedRows;
        @AuraEnabled public String nameField;
        @AuraEnabled public String sObjectLabel;
        @AuraEnabled public Integer page_size;
        @AuraEnabled public Integer current_page;
        @AuraEnabled public Integer current_page_records;
        @AuraEnabled public Integer total_records;
        @AuraEnabled public Integer failed_log_count;
        @AuraEnabled public Boolean has_next;
    }

    public class ColumnsWrapper {
        @AuraEnabled
        public String label {
            get;
            set;
        }
        @AuraEnabled
        public String fieldName {
            get;
            set;
        }
        @AuraEnabled
        public String type {
            get;
            set;
        }
        @AuraEnabled
        public String iconLabel {
            get;
            set;
        }
        @AuraEnabled
        public String iconName {
            get;
            set;
        }
        @AuraEnabled
        public Integer initialWidth {
            get;
            set;
        }
        @AuraEnabled
        public DatatypeAttributes typeAttributes {
            get;
            set;
        }
        @AuraEnabled
        public DatacellAttributes cellAttributes {
            get;
            set;
        }

        public ColumnsWrapper(String label, String fieldName, String type, DatatypeAttributes typeAttributes) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.typeAttributes = typeAttributes;
        }

        public ColumnsWrapper(String label, String fieldName, String type, Integer initialWidth, DatatypeAttributes typeAttributes) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.typeAttributes = typeAttributes;
            this.initialWidth = initialWidth;
        }

        public ColumnsWrapper(String label, String fieldName, String type, DatatypeAttributes typeAttributes, DatacellAttributes cellAttributes) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.typeAttributes = typeAttributes;
            this.cellAttributes = cellAttributes;
        }

        public ColumnsWrapper(String label, String fieldName, String type, Integer initialWidth, DatatypeAttributes typeAttributes, DatacellAttributes cellAttributes) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.initialWidth = initialWidth;
            this.typeAttributes = typeAttributes;
            this.cellAttributes = cellAttributes;
        }
    }

    public class DatatypeAttributes {
        @AuraEnabled
        public Attribute label {
            get;
            set;
        }
        @AuraEnabled
        public String target {
            get;
            set;
        }
        @AuraEnabled
        public String name {
            get;
            set;
        }
        @AuraEnabled
        public String variant {
            get;
            set;
        }
        @AuraEnabled
        public Attribute disabled {
            get;
            set;
        }
        @AuraEnabled
        public Attribute title {
            get;
            set;
        }
        @AuraEnabled
        public Attribute iconName {
            get;
            set;
        }
        @AuraEnabled
        public Attribute alternativeText {
            get;
            set;
        }
        @AuraEnabled
        public Attribute iconClass {
            get;
            set;
        }
        @AuraEnabled
        public String iconPosition {
            get;
            set;
        }

        public DatatypeAttributes() {
            this.iconPosition = 'right';
        }

        public DatatypeAttributes(Attribute label, String target) {
            this();
            this.label = label;
            this.target = target;
        }

        public DatatypeAttributes(Attribute label, String target, String name, String variant) {
            this();
            this.label = label;
            this.target = target;
            this.name = name;
            this.variant = variant;
        }

        public DatatypeAttributes(Attribute label, String target, String name, String variant, Attribute disabled, Attribute title, Attribute iconName, Attribute alternativeText, Attribute iconClass) {
            this();
            this.label = label;
            this.target = target;
            this.name = name;
            this.variant = variant;
            this.disabled = disabled;
            this.title = title;
            this.iconName = iconName;
            this.alternativeText = alternativeText;
            this.iconClass = iconClass;
        }
    }

    public class DatacellAttributes {
        @AuraEnabled
        public Attribute iconName {
            get;
            set;
        }
        @AuraEnabled
        public Attribute iconLabel {
            get;
            set;
        }
        @AuraEnabled
        public Attribute iconAlternativeText {
            get;
            set;
        }
        @AuraEnabled
        public Attribute bClass {
            get;
            set;
        }

        @AuraEnabled
        public String alignment {
            get;
            set;
        }

        public DatacellAttributes() {
            this.bClass = new Attribute('bClass');
        }

        public DatacellAttributes(String alignment) {
            this.alignment = alignment;
        }

        public DatacellAttributes(Attribute iconName, Attribute iconLabel, Attribute iconAlternativeText) {
            this.iconName = iconName;
            this.iconLabel = iconLabel;
            this.iconAlternativeText = iconAlternativeText;
        }

    }

    public class Attribute {
        @AuraEnabled
        public String fieldName;
        public Attribute(String fieldName) {
            this.fieldName = fieldName;
        }
    }

    public class ScheduleData {
        @AuraEnabled public String ScheduleType;
        @AuraEnabled public String ScheduleActionName;
        @AuraEnabled public String Recipients;
        @AuraEnabled public String ScheduleDateTimeField;
        @AuraEnabled public String first_activated_at;
        @AuraEnabled public String Status;
        @AuraEnabled public String StatusMessage;
        @AuraEnabled public String RelatedDetails;
        @AuraEnabled public String salesforce_id;
        @AuraEnabled public String base_object;
        @AuraEnabled public String related_object;
        @AuraEnabled public String sms_to_number_field;
        @AuraEnabled public String email_to_address_field;
        @AuraEnabled public String base_sobject_criteria;
        @AuraEnabled public String related_sobject_criteria;
        @AuraEnabled public String bClass;
        @AuraEnabled public String base_related_relationship;
        @AuraEnabled public String NextExecutionStatus;
        @AuraEnabled public String NextExecutionDateTime;
    }

    public class ScheduleLogsData {
        @AuraEnabled public String salesforce_id;
        @AuraEnabled public String parent_log_name;
        @AuraEnabled public String recipient_salesforce_id;
        @AuraEnabled public String recipient_name;
        @AuraEnabled public String scheduleDateTime;
        @AuraEnabled public String Status;
        @AuraEnabled public Integer totalCounts;
        @AuraEnabled public Boolean bdisable;
        @AuraEnabled public String btitle;
        @AuraEnabled public String bIcon;
        @AuraEnabled public String bVar;
        @AuraEnabled public String bAlt;
        @AuraEnabled public String bClass;
        @AuraEnabled public String emailOrPhone;
    }

}