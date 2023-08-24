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
* A library to handle trigger functionality.
*
**/
global with sharing class SCH_TriggerHandler {
    static Map<String, String> logicTypes = new Map<String, String>();
    static Map<String, Map<String, String>> expressionLogic = new Map<String, Map<String, String>>();

     /*******************************************************************************************************
     * @description Method used to process the records
     * @return none
     * @param operationType: Apex trigger operation name
     * @param newList: List of new records
     * @param oldMap: map of records previous values
     **/
    global static void processRecords(System.TriggerOperation operationType, List<sObject> newList, Map<Id, sObject> oldMap) {
        //do checks if we should do callout for delta record handling
        if ((SCH_BtBaseUtils.smartScheduleFeatureEnabled || Test.isRunningTest()) &&
            (operationType == TriggerOperation.AFTER_INSERT || operationType == TriggerOperation.AFTER_UPDATE ||
                operationType == TriggerOperation.AFTER_DELETE || operationType == TriggerOperation.AFTER_UNDELETE)) {
            if (!System.isQueueable() && Limits.getLimitQueueableJobs()> Limits.getQueueableJobs()) {
                // do queueable
                System.enqueueJob(new SCH_DeltaRecordQueueable(operationType, newList, oldMap));
            } else if (!System.isFuture() && Limits.getLimitFutureCalls()> Limits.getFutureCalls()) {
                // do future
                handleDeltaRecordsFuture(json.serialize(operationType), json.serialize(newList), json.serialize(oldMap));
            } else if (!System.isBatch()) {
                // run batch
                Database.executeBatch(new SCH_DeltaRecordBatch(operationType, newList, oldMap));
            }
        }
    }
    static Map<String, TriggerOperation> triggerOperationMap {
        get{
            if(triggerOperationMap == null){
                triggerOperationMap = new Map<String, TriggerOperation>();
                triggerOperationMap.put('"AFTER_INSERT"', TriggerOperation.AFTER_INSERT);
                triggerOperationMap.put('"AFTER_UPDATE"', TriggerOperation.AFTER_UPDATE);
                triggerOperationMap.put('"AFTER_DELETE"', TriggerOperation.AFTER_DELETE);
                triggerOperationMap.put('"AFTER_UNDELETE"', TriggerOperation.AFTER_UNDELETE);
            }
            return triggerOperationMap;
        }set;
    }
    /*******************************************************************************************************
     * @description Method used to process the records
     * @return none
     * @param opType: Apex trigger operation name
     * @param newRec: List of new records
     * @param oldRec: map of records previous values
     **/
    @future(callout = true)
    public static void handleDeltaRecordsFuture(String opType, String newRec, String oldRec) {
        System.TriggerOperation operationType = triggerOperationMap.get(opType);
        List<sObject> newList = (List<sObject> ) Json.deserialize(newRec, List<sObject> .class);
        Map<Id, sObject> oldMap = (Map<Id, sObject> ) Json.deserialize(oldRec, Map<Id, sObject> .class);
        // enqueueing job as this is running in the Future context
        System.enqueueJob(new SCH_DeltaRecordQueueable(operationType, newList, oldMap));
    }

    /*******************************************************************************************************
     * @description Method used to process the records
     * @return none
     * @param opType: Apex trigger operation name
     * @param newRec: List of new records
     * @param oldRec: map of records previous values
     * @param lstSchedule: List of Schedule records
     **/
    public static void handleRecords(System.TriggerOperation operationType, List<sObject> newList, Map<Id, sObject> oldMap, List<SCH_Schedule__c> lstSchedule) {
        List<SCH_DeltaRecordWrapper.DeltaRequest> lstDeltaRequest = new List<SCH_DeltaRecordWrapper.DeltaRequest>();
        String recSObjectTypeName = '';
        if (lstSchedule.size() > 0) {
            // Doing it so we can handle AFTER_DELETE Use Case
            if (operationType == TriggerOperation.AFTER_DELETE && newList == null) {
                newList = oldMap.values();
                oldMap = null;
            } else {
                DescribeSobjectResult dsr = newList[0].getSObjectType().getDescribe();
                recSObjectTypeName = dsr.getName();
            }
            Map<Id, sObject> newRecordsMap = new Map<Id, sObject>();
            //Used to fetch related field details
            if (operationType != TriggerOperation.AFTER_DELETE && newList.size() > 0) {
                // pepare fields Set from all schedule and combine all fields from filter and make sure in the set there should be no duplicate
                Set<String> fields = new Set<String>();
                for (SCH_Schedule__c sc: lstSchedule) {
                    if (String.isNotBlank(sc.Base_Object_Evaluate_Criteria_JSON__c)) {
                        SCH_DeltaRecordWrapper baseObjWrap = (SCH_DeltaRecordWrapper) JSON.deserialize(sc.Base_Object_Evaluate_Criteria_JSON__c, SCH_DeltaRecordWrapper.class);
                        if (baseObjWrap.filters.size() > 0) {
                            fields.addAll(baseObjWrap.getFieldsToCheck());
                        }
                    }
                    if (String.isNotBlank(sc.Schedule_Date_Time_Field__c)) {
                        fields.add(sc.Schedule_Date_Time_Field__c);
                    }
                }
                //fetch record details - query record by using ids
                if (fields.size() > 0) {
                    // handling special case for Session Attendee sObject
                    if(recSObjectTypeName == SCH_BtBaseUtils.sessionAttendeeSobjectName){
                        fields.add('conference360__Session__r.conference360__Event__c');
                    }
                    String sSOQL = SCH_BtBaseUtils.prepareSObjectQuery(Id.valueOf(newList[0].Id).getSObjectType(), new List<String>(fields), null, 'Id in :newList');
                    newRecordsMap = new Map<Id, sObject>(Database.query(sSOQL));
                }
            }
            for (sObject obj: newList) {
                sObject matchingSObject = newRecordsMap.containsKey(obj.Id) ? newRecordsMap.get(obj.Id) : obj;
                for (SCH_Schedule__c sc: lstSchedule) {
                    Boolean isScheduleDateTimeFieldChanged = false;
                    Boolean isFilteredFieldChanged = false;
                    Boolean isNewVersionMatched = false;
                    Boolean isOldVersionMatched = false;
                    if (String.isNotBlank(sc.Schedule_Date_Time_Field__c)) {
                        Set<String> fieldsToCheck = new Set<String> {
                            sc.Schedule_Date_Time_Field__c
                        };
                        isScheduleDateTimeFieldChanged = isModified(fieldsToCheck, matchingSObject, oldMap);
                    }
                    if (String.isBlank(sc.Base_Object_Evaluate_Criteria_JSON__c)) {
                        String recId = 'Id=\'' + obj.Id + '\'';
                        DescribeSobjectResult dsr = obj.getSObjectType().getDescribe();
                        if (dsr.getName() == SCH_BtBaseUtils.sessionSobjectName || dsr.getName() == SCH_BtBaseUtils.attendeeSobjectName) {
                            recId = 'conference360__Event__c=\'' + obj.get('conference360__Event__c') + '\'';
                        } else if (dsr.getName() == SCH_BtBaseUtils.sessionAttendeeSobjectName) {
                            if (operationType == TriggerOperation.AFTER_DELETE) {
                                isNewVersionMatched = false;
                                isOldVersionMatched = true;
                            } else {
                                sObject session = matchingSObject.getSObject('conference360__Session__r');
                                if (session != null) {
                                    recId = 'conference360__Session__r.conference360__Event__c=\'' + session.get('conference360__Event__c') + '\'';
                                }
                            }
                        }
                        if (String.isBlank(sc.SObject_Record_Id__c) || (String.isNotBlank(sc.SObject_Record_Id__c) && recId == sc.Base_Object_Evaluate_Criteria__c)) {
                            isFilteredFieldChanged = true;
                            isNewVersionMatched = true;
                            isOldVersionMatched = operationType == TriggerOperation.AFTER_UPDATE;
                        }
                    } else {
                        SCH_DeltaRecordWrapper baseObjWrap = (SCH_DeltaRecordWrapper) JSON.deserialize(sc.Base_Object_Evaluate_Criteria_JSON__c, SCH_DeltaRecordWrapper.class);
                        if (baseObjWrap.filters.size() > 0 && String.isNotBlank(baseObjWrap.logic_exp)) {
                            isFilteredFieldChanged = isModified(baseObjWrap.getFieldsToCheck(), matchingSObject, oldMap);
                        }
                        if (isFilteredFieldChanged || isScheduleDateTimeFieldChanged) {
                            isNewVersionMatched = evalExpression(matchingSObject, baseObjWrap, operationType == TriggerOperation.AFTER_DELETE);
                            if (operationType == TriggerOperation.AFTER_UPDATE) {
                                isOldVersionMatched = evalExpression(oldMap.get((Id) obj.Id), baseObjWrap, true);
                            }
                        }
                    }
                    /*
                    New record creation
                        If it matches the criterai with any active schedule
                            A new Execution record should be created on API server for all such schedules
                    Record Update
                        If its Old version does not but New version does match with any active schedule
                            A new Execution record(s) should be created on API server for all such schedules
                        If its Old version does but New version does not match with any active schedule
                            The existing Execution record(s) should be acrhived on API server for all such schedules
                        If both Old and New versions match the same set of active schedules
                            And there is a change in schedule_field
                                The execution_date_time on existing Execution records should be reCalculated
                    */
                    if (isNewVersionMatched || isOldVersionMatched) {
                        String request_type = null;
                        if (isNewVersionMatched && !isOldVersionMatched) {
                            request_type = 'create';
                        } else if (!isNewVersionMatched && isOldVersionMatched) {
                            request_type = 'archived';
                        } else if (isNewVersionMatched && isOldVersionMatched && isScheduleDateTimeFieldChanged) {
                            request_type = 're-calculate';
                        }
                        if (request_type != null) {
                            if (operationType == TriggerOperation.AFTER_DELETE) {
                                request_type = 'archived';
                            }
                            String schedule_field_value = String.isNotBlank(sc.Schedule_Date_Time_Field__c) ?
                                String.valueOf(matchingSObject.get(sc.Schedule_Date_Time_Field__c)) :
                                String.valueOf(sc.Schedule_Date_Time__c);
                            lstDeltaRequest.add(new SCH_DeltaRecordWrapper.DeltaRequest(sc.Id, String.valueOf(obj.Id), request_type, schedule_field_value));
                        }
                    }
                }
            }
        }
        if (lstDeltaRequest.size() > 0) {
            SCH_AccountService.createDelta(JSON.serialize(lstDeltaRequest));
        }
    }

    /*******************************************************************************************************
     * @description Method used to check record is modified or not
     * @return Boolean
     * @param fieldsToCheck: fields api name to check values are updated or not
     * @param obj: sObject record
     * @param oldMap: map of records previous values
     **/
    private static Boolean isModified(Set<String> fieldsToCheck, sObject obj, Map<Id, sObject> oldMap) {
        Boolean isModifiedFlag = false;
        Boolean isContainingRelativeField = false;
        for (String fld: fieldsToCheck) {
            // if field is not containing relative field, then only need to check following 
            if (fld.indexOf('.') == -1) {
                if (oldMap == null || (oldMap != null && (obj.get(fld) != oldMap.get(String.valueOf(obj.get('Id'))).get(fld)))) {
                    isModifiedFlag = true;
                    break;
                }
            } else { //if containing relative
                isContainingRelativeField = true;
                break;
            }
        }
        // if field is not containing relative field
        if (isContainingRelativeField) {
            isModifiedFlag = isContainingRelativeField;
        }
        return isModifiedFlag;
    }

     /*******************************************************************************************************
     * @description Method used to evulate the expression
     * @return Boolean
     * @param obj: sObject record
     * @param baseObjWrap: Delta record wrapper
     * @param isBypass: used to bypass the condition
     **/
    @testVisible
    private static Boolean evalExpression(sObject obj, SCH_DeltaRecordWrapper baseObjWrap, Boolean isBypass) {
        List<Boolean> lstBoolean = evalFilters(obj, baseObjWrap.filters, isBypass);
        // Starting loop in reverse order to handle if we have more then 9 filters
        // Example: 1 AND 2 AND (3 OR 4) AND (5 OR 6 OR 7 OR 8 OR 9) AND 10
        String logical_expression = baseObjWrap.logic_exp;
        for (integer i = lstBoolean.size() - 1; i >= 0; i--) {
            logical_expression = logical_expression.replace(String.valueOf(i + 1), String.valueOf(lstBoolean[i]).toUpperCase());
            logical_expression = logical_expression.trim();
        }
        return SCH_BooleanExpression.eval(logical_expression);
    }

    /*******************************************************************************************************
     * @description Method used to validate the expression
     * @return List<Boolean>
     * @param obj: sObject record
     * @param filters: List of sObject filters
     * @param isBypass: used to bypass the condition
     **/
    private static List<Boolean> evalFilters(sObject obj, List<SCH_DeltaRecordWrapper.filters> filters, Boolean isBypass) {
        List<Boolean> lstBoolean = new List<Boolean>();
        for (SCH_DeltaRecordWrapper.filters filter: filters) {
            boolean hasMatched = false;
            //Return match return if Relative field updated on record update / delete
            if (filter.f.indexOf('.')> -1 && isBypass) {
                hasMatched = true;
            } else {
                //pull field value from record
                Object valObj = SCH_BtBaseUtils.extractFieldValue(obj, filter.f);
                if (filter.f_type == String.valueof(Schema.DisplayType.STRING) || filter.f_type == String.valueof(Schema.DisplayType.PHONE) || filter.f_type == String.valueof(Schema.DisplayType.EMAIL) || filter.f_type == String.valueof(Schema.DisplayType.PICKLIST) || filter.f_type == String.valueof(Schema.DisplayType.MULTIPICKLIST) || filter.f_type == 'text' || filter.f_type == 'email' || filter.f_type == 'url' || filter.f_type == 'textarea' || filter.f_type == 'combobox') {
                    String val = String.valueOf(valObj);
                    hasMatched = handleTextDataType(filter, val);
                } else if (filter.f_type == String.valueof(Schema.DisplayType.BOOLEAN) || filter.f_type == 'checkbox') {
                    Boolean val = Boolean.valueOf(valObj);
                    hasMatched = handleBooleanDataType(filter, val);
                } else if (filter.f_type == String.valueof(Schema.DisplayType.INTEGER) || (filter.f_type == String.valueof(Schema.DisplayType.CURRENCY)) || (filter.f_type == String.valueof(Schema.DisplayType.PERCENT)) || filter.f_type == String.valueof(Schema.DisplayType.DOUBLE) || filter.f_type == 'tel' || filter.f_type == 'number') {
                    Decimal val = (Decimal) valObj;
                    hasMatched = handleNumberDataType(filter, val);
                } else if (filter.f_type == String.valueof(Schema.DisplayType.DATE) || filter.f_type == String.valueof(Schema.DisplayType.DATETIME) || filter.f_type == 'date' || filter.f_type == 'datetime' || filter.f_type == 'time') {
                    Datetime val = (Datetime) valObj;
                    hasMatched = handleDatetimeDataType(filter, val);
                }
            }
            lstBoolean.add(hasMatched);
        }
        return lstBoolean;
    }

    /*******************************************************************************************************
     * @description Method used to validate filter for text fields
     * @return boolean
     * @param filter: sObject filter
     * @param val: field value
     **/
    private static boolean handleTextDataType(SCH_DeltaRecordWrapper.filters filter, String val) {
        boolean hasValueMatched = false;
        if (filter.op == '=') {
            if (val == filter.val) {
                hasValueMatched = true;
            }
        } else if (filter.op == '!=' || filter.op == '<>') {
            if (val != filter.val) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'starts_with') {
            if (val.startsWithIgnoreCase(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'ends_with') {
            if (val.endsWithIgnoreCase(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_null') {
            if (String.isBlank(val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_not_null') {
            if (String.isNotBlank(val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'contains') {
            if (String.isNotBlank(val) && val.contains(filter.val)) {
                hasValueMatched = true;
            }
        }
        return hasValueMatched;
    }

    /*******************************************************************************************************
     * @description Method used to validate filter for boolean fields
     * @return boolean
     * @param filter: sObject filter
     * @param val: field value
     **/
    private static boolean handleBooleanDataType(SCH_DeltaRecordWrapper.filters filter, Boolean val) {
        boolean hasValueMatched = false;
        if (filter.op == '=') {
            if (val == Boolean.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '<>') {
            if (val != Boolean.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_null') {
            if (val == null) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_not_null') {
            if (val != null) {
                hasValueMatched = true;
            }
        }
        return hasValueMatched;
    }

    /*******************************************************************************************************
     * @description Method used to validate filter for DateTime fields
     * @return boolean
     * @param filter: sObject filter
     * @param val: field value
     **/
    private static boolean handleDateTimeDataType(SCH_DeltaRecordWrapper.filters filter, Datetime val) {
        boolean hasValueMatched = false;
        if (filter.op == '=') {
            if (val == Datetime.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '<>') {
            if (val != Datetime.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_null') {
            if (val == null) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_not_null') {
            if (val != null) {
                hasValueMatched = true;
            }
        }
        return hasValueMatched;
    }

    /*******************************************************************************************************
     * @description Method used to validate filter for Number fields
     * @return boolean
     * @param filter: sObject filter
     * @param val: field value
     **/
    private static boolean handleNumberDataType(SCH_DeltaRecordWrapper.filters filter, Decimal val) {
        boolean hasValueMatched = false;
        if (filter.op == '=') {
            if (val == Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '!=' || filter.op == '<>') {
            if (val != Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '>') {
            if (val> Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '<') {
            if (val<Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '>=') {
            if (val >= Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == '<=') {
            if (val <= Decimal.valueOf(filter.val)) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_null') {
            if (val == null) {
                hasValueMatched = true;
            }
        } else if (filter.op == 'is_not_null') {
            if (val != null) {
                hasValueMatched = true;
            }
        }

        return hasValueMatched;
    }
}