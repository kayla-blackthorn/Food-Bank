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
 * This is used as apex job to create delta records
 *
**/
public with sharing class SCH_DeltaRecordBatch implements Database.Batchable<sObject> , Database.AllowsCallouts {
    public System.TriggerOperation operationType;
    public List<sObject> newList;
    public Map<Id, sObject> oldMap;

    public SCH_DeltaRecordBatch(System.TriggerOperation operationType, List<sObject> newList, Map<Id, sObject> oldMap) {
        this.operationType = operationType;
        this.newList = newList;
        this.oldMap = oldMap;
    }

    /*******************************************************************************************************
     * @description Method used to check Schedule Configuration 
     * @return List<sObject>
     **/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        SCH_ScheduleSelector ss = new SCH_ScheduleSelector();
        System.debug('newList> ' + newList);
        sObject record;
        if (newList != null) {
            record = newList[0];
        } else if (oldMap != null) {
            record = oldMap.values()[0];
        }
        String sObjectName = record == null ? 'not_defined' : String.valueOf(Id.valueOf(record.Id).getSObjectType());
        List<String> statusList = new List<String> {
            'Scheduled'
        };
        return Database.getQueryLocator(ss.buildSObjectSchedulesByStatusQuery(sObjectName, statusList));
    }

     /*******************************************************************************************************
     * @description Method used to create data at api side
     * @return none
     **/
    public void execute(Database.BatchableContext BC, List<SCH_Schedule__c> scope) {
        List<SCH_Schedule__c> lstScheduled = new List<SCH_Schedule__c>();

        for (SCH_Schedule__c sc: scope) {
            lstScheduled.add(sc);
        }

        if (lstScheduled.size() > 0) {
            SCH_TriggerHandler.handleRecords(operationType, newList, oldMap, lstScheduled);
        }
    }

    public void finish(Database.BatchableContext BC) {}
}