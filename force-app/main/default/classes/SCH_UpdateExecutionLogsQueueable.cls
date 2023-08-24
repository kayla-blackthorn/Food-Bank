/**
 * Blackthorn.io, ENTERPRISES CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io, Enterprises
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io, Enterprises and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io, Enterprises
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io, Enterprises.
 *
 * @description this class used to submit logs detail to BT API Server
 **/
public with sharing class SCH_UpdateExecutionLogsQueueable implements Queueable, Database.AllowsCallouts {
    private String relativeEndPoint;
    private String jsonRequestBody;

    public SCH_UpdateExecutionLogsQueueable(String relativeEndPoint, String jsonRequestBody) {
        this.relativeEndPoint = relativeEndPoint;
        this.jsonRequestBody = jsonRequestBody;
    }

    public void execute(QueueableContext context) {
        SCH_AccountService.updateExecutionLogs(relativeEndPoint, jsonRequestBody);
    }
}