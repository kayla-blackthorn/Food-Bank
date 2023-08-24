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
 * This is used as queueable job to process triggered records for deleta syncing
 *
**/
public with sharing class SCH_DeltaRecordQueueable implements Queueable, Database.AllowsCallouts {
    public System.TriggerOperation operationType;
    public List<sObject> newList;
    public Map<Id, sObject> oldMap;

    public SCH_DeltaRecordQueueable(System.TriggerOperation operationType, List<sObject> newList, Map<Id, sObject> oldMap) {
        this.operationType = operationType;
        this.newList = newList;
        this.oldMap = oldMap;
    }

    public void execute(QueueableContext context) {
        Database.executeBatch(new SCH_DeltaRecordBatch(operationType, newList, oldMap));
    }
}