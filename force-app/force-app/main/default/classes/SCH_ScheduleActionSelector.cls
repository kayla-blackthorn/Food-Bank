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
 * The Selector class for the Schedule Action sObject
 *
**/
public with sharing class SCH_ScheduleActionSelector extends fflib_SObjectSelector {

	/**
	 *  @return a List of Schema.SObjectFields
	 *
	 *  Return a List of Schema.SObjectFields for this object.
	 *
	 **/
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			SCH_Schedule_Action__c.Id,
			SCH_Schedule_Action__c.Action__c,
			SCH_Schedule_Action__c.Name,
			SCH_Schedule_Action__c.Email_From_Address__c,
			SCH_Schedule_Action__c.Email_From_Address_Id__c,
			SCH_Schedule_Action__c.Email_To_Address_Field__c,
			SCH_Schedule_Action__c.Email_Template_Id__c,
			SCH_Schedule_Action__c.SMS_From_Number__c,
			SCH_Schedule_Action__c.SMS_To_Number_Field__c,
			SCH_Schedule_Action__c.Schedule__c,
			SCH_Schedule_Action__c.SMS_Message__c,
			SCH_Schedule_Action__c.SMS_Template_Id__c,
			SCH_Schedule_Action__c.SMS_Attachment_Id__c,
			SCH_Schedule_Action__c.Associate_With_Referenced_Record__c
		};
	}

	/**
	 *  @return a Schema.SObjectType
	 *
	 *  Return the SObjectType for this object.
	 *
	 **/
	public Schema.SObjectType getSObjectType() {
		return SCH_Schedule_Action__c.sObjectType;
	}

}