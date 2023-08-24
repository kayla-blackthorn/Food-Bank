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
 * The Selector class for the Schedule sObject
 *
**/
public with sharing class SCH_ScheduleSelector extends fflib_SObjectSelector {

	/**
	 *  @return a List of Schema.SObjectFields
	 *
	 *  Return a List of Schema.SObjectFields for this object.
	 *
	 **/
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			SCH_Schedule__c.Id,
			SCH_Schedule__c.Name,
			SCH_Schedule__c.Base_Object__c,
			SCH_Schedule__c.Base_Object_Evaluate_Criteria__c,
			SCH_Schedule__c.Base_Object_Evaluate_Criteria_JSON__c,
			SCH_Schedule__c.Related_Object__c,
			SCH_Schedule__c.Related_Object_Evaluate_Criteria__c,
			SCH_Schedule__c.Related_Object_Evaluate_Criteria_JSON__c,
			SCH_Schedule__c.Related_Object_Relationship_Name__c,
			SCH_Schedule__c.SObject_Record_Id__c,
			SCH_Schedule__c.Status__c,
			SCH_Schedule__c.Type__c,
			SCH_Schedule__c.Schedule_Date_Time__c,
			SCH_Schedule__c.Offset__c,
			SCH_Schedule__c.Offset_Type__c,
			SCH_Schedule__c.Offset_Value__c,
			SCH_Schedule__c.Schedule_Date_Time_Field__c,
			SCH_Schedule__c.Execute_Now__c
		};
	}

	/**
	 *  @return a Schema.SObjectType
	 *
	 *  Return the SObjectType for this object.
	 *
	 **/
	public Schema.SObjectType getSObjectType() {
		return SCH_Schedule__c.sObjectType;
	}

	/**
	 *  @param  ids - a Set of ids
	 *  @param  a List of Schedule
	 *
	 *
	 *
	 **/
	public List<SCH_Schedule__c> getSchedule(Set<Id> ids) {
		assertIsAccessible();
		fflib_QueryFactory query = newQueryFactory();
		query.setCondition('Id IN :ids');
		System.debug(loggingLevel.WARN, 'QUERY: ' + query.toSOQL());
		return (List<SCH_Schedule__c> ) Database.query(query.toSOQL());
	}

	/**
	 *  @param  ids - a Set of ids
	 *  @param  a List of Schedule with Schedule Actions
	 *
	 *
	 *
	 **/
	public List<SCH_Schedule__c> getScheduleWithActions(Set<Id> ids) {
		assertIsAccessible();
		fflib_QueryFactory query = newQueryFactory();
		query.setCondition('Id IN :ids');
		new SCH_ScheduleActionSelector()
			.addQueryFactorySubselect(query, SCH_BtBaseUtils.nameSpacePreFix + 'Schedule_Actions__r');
		System.debug(loggingLevel.WARN, 'QUERY: ' + query.toSOQL());
		return (List<SCH_Schedule__c> ) Database.query(query.toSOQL());
	}

	public String buildSObjectSchedulesByStatusQuery(String sObjectName, List<String> statusList) {
		assertIsAccessible();
		String query = String.format(
			'SELECT {0} FROM {1} ',
			new List<String> {
				getFieldListString(),
				getSObjectName(),
				sObjectName
			}
		);
		if (sObjectName != null) {
			query += ' WHERE Base_Object__c = :sObjectName';
		}
		if (statusList != null && statusList.size() > 0) {
			query += ' AND Status__c IN :statusList';
		}
		query += ' ORDER BY Name';
		System.debug('QUERY: ' + query);
		return query;
	}

}