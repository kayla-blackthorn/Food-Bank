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
 * This is used as wrapper class to show the schedules
 *
**/
public with sharing class SCH_Schedule {

    public class Schedule {
        private String name;
        private String salesforce_id;
        private String base_sobject;
        private String base_sobject_criteria;
        private String related_sobject;
        private String related_sobject_criteria;
        private String base_related_relationship;
        private String offset_value;
        private String offset_type;
        private String offset;
        private String schedule_field;
        private String schedule_date_time;
        private String first_activated_at;
        private String status;
        private String schedule_type;
        private String record_id;
        private String next_execution_date_time;
        private String next_execution_status;

        private List<ScheduleAction> actions;
        public Schedule() {}

        public Schedule(SCH_Schedule__c schedule) {
            name = schedule.Name;
            salesforce_id = schedule.Id;
            base_sobject = schedule.Base_Object__c;
            base_sobject_criteria = schedule.Base_Object_Evaluate_Criteria__c;
            related_sobject = schedule.Related_Object__c;
            related_sobject_criteria = schedule.Related_Object_Evaluate_Criteria__c;
            base_related_relationship = schedule.Related_Object_Relationship_Name__c;
            offset_value = (schedule.Offset_Value__c != null ? schedule.Offset_Value__c + '' : null);
            offset_type = schedule.Offset_Type__c;
            offset = schedule.Offset__c;
            schedule_field = schedule.Schedule_Date_Time_Field__c;
            schedule_date_time = (schedule.Schedule_Date_Time__c != null ? (schedule.Schedule_Date_Time__c + '') : null);
            status = schedule.Status__c;
            schedule_type = schedule.Type__c;
            record_id = schedule.SObject_Record_Id__c;

            if (schedule.getSobjects(SCH_BtBaseUtils.nameSpacePreFix+'Schedule_Actions__r') != null) {
                actions = new List<ScheduleAction>();
                List<SCH_Schedule_Action__c> scheduleActions = (List<SCH_Schedule_Action__c> ) schedule.getSobjects(SCH_BtBaseUtils.nameSpacePreFix+'Schedule_Actions__r');
                for (SCH_Schedule_Action__c scheduleAction: scheduleActions) {
                    actions.add(new ScheduleAction(scheduleAction));
                }
            }
        }

        @AuraEnabled
        public String getName() {
            return name;
        }

        @AuraEnabled
        public String getSalesforceId() {
            return salesforce_id;
        }

        @AuraEnabled
        public String getBaseSobject() {
            return base_sobject;
        }

        @AuraEnabled
        public String getBaseSobjectCriteria() {
            return base_sobject_criteria;
        }

        @AuraEnabled
        public String getRelatedSobject() {
            return related_sobject;
        }

        @AuraEnabled
        public String getRelatedSobjectCriteria() {
            return related_sobject_criteria;
        }

        @AuraEnabled
        public String getBaseRelatedRelationship() {
            return base_related_relationship;
        }

        @AuraEnabled
        public String getOffsetValue() {
            return offset_value;
        }

        @AuraEnabled
        public String getoffset_type() {
            return offset_type;
        }

        @AuraEnabled
        public String getoffset() {
            return offset;
        }

        @AuraEnabled
        public String getschedule_field() {
            return schedule_field;
        }

        @AuraEnabled
        public String getScheduleDateTime() {
            return schedule_date_time;
        }

        @AuraEnabled
        public String getFirstActivatedAt() {
            return first_activated_at;
        }

        @AuraEnabled
        public String getstatus() {
            return status;
        }

        @AuraEnabled
        public String getschedule_type() {
            return schedule_type;
        }

        @AuraEnabled
        public String getRecordId() {
            return record_id;
        }

        @AuraEnabled
        public List<ScheduleAction> getactions() {
            return actions;
        }
        @AuraEnabled
        public String getNextExecutionDateTime() {
            return next_execution_date_time;
        }
        @AuraEnabled
        public String getNextExecutionStatus() {
            return next_execution_status;
        }
    }

    public class ScheduleAction {
        private String name;
        private String salesforce_id;
        private String action_type;
        private String sms_from_number;
        private String sms_to_number_field;
        private String sms_body;
        private String sms_template_id;
        private String sms_attachment_id;
        private String email_from_address;
        private String email_from_address_id;
        private String email_to_address_field;
        private List<String> email_cc_address;
        private List<String> email_bcc_address;
        private String email_subject;
        private String email_body;
        private String email_template_id;
        private Boolean associate_with_referenced_record;

        public ScheduleAction(SCH_Schedule_Action__c scheduleAction) {
            name = scheduleAction.Name;
            salesforce_id = scheduleAction.Id;
            action_type = (String.isNotBlank(scheduleAction.Action__c) ? scheduleAction.Action__c.toLowerCase() : scheduleAction.Action__c);
            // SMS related fields
            sms_from_number = scheduleAction.SMS_From_Number__c;
            sms_to_number_field = scheduleAction.SMS_To_Number_Field__c;
            sms_body = scheduleAction.SMS_Message__c;
            sms_template_id = scheduleAction.SMS_Template_Id__c;
            sms_attachment_id = scheduleAction.SMS_Attachment_Id__c;
            // Email related fields
            email_from_address = scheduleAction.Email_From_Address__c;
            email_from_address_id = scheduleAction.Email_From_Address_Id__c;
            email_to_address_field = scheduleAction.Email_To_Address_Field__c;
            email_template_id = scheduleAction.Email_Template_Id__c;
            associate_with_referenced_record = scheduleAction.Associate_With_Referenced_Record__c;
        }

        @AuraEnabled
        public String getName() {
            return name;
        }

        @AuraEnabled
        public String getSalesforceId() {
            return salesforce_id;
        }

        @AuraEnabled
        public String getActionType() {
            return action_type;
        }

        @AuraEnabled
        public String getSmsFromNumber() {
            return sms_from_number;
        }

        @AuraEnabled
        public String getSmsToNumberField() {
            return sms_to_number_field;
        }

        @AuraEnabled
        public String getSmsBody() {
            return sms_body;
        }

        @AuraEnabled
        public String getSmsTemplateId() {
            return sms_template_id;
        }

        @AuraEnabled
        public String getSmsAttachmentId() {
            return sms_attachment_id;
        }

        @AuraEnabled
        public String getEmailFromAddress() {
            return email_from_address;
        }

        @AuraEnabled
        public String getEmailFromAddressId() {
            return email_from_address_id;
        }

        @AuraEnabled
        public String getEmailToAddressField() {
            return email_to_address_field;
        }

        @AuraEnabled
        public List<String> getEmailCCAddress() {
            return email_cc_address;
        }

        @AuraEnabled
        public List<String> getEmailBccAddress() {
            return email_bcc_address;
        }

        @AuraEnabled
        public String getEmailSubject() {
            return email_subject;
        }

        @AuraEnabled
        public String getEmailBody() {
            return email_body;
        }

    }

    public class Logs {
        private String action_type;
        private String status;
        private String status_message;
        private String salesforce_id;
        private String recipient;
        private String sms_sid;
        private String email_id;
        private String execution_date_time;
        private String created_at;
        private String updated_at;

        @AuraEnabled
        public String getActionType() {
            return action_type;
        }

        @AuraEnabled
        public String getStatus() {
            return status;
        }

        @AuraEnabled
        public String getStatusMessage() {
            return status_message;
        }

        @AuraEnabled
        public String getSalesforceId() {
            return salesforce_id;
        }

        @AuraEnabled
        public String getRecipient() {
            return recipient;
        }

        @AuraEnabled
        public String getSmsSId() {
            return sms_sid;
        }

        @AuraEnabled
        public String getEmailId() {
            return email_id;
        }

        @AuraEnabled
        public String getExecutionDateTime() {
            return execution_date_time;
        }

        @AuraEnabled
        public String getCreatedAt() {
            return created_at;
        }

        @AuraEnabled
        public String getUpdatedAt() {
            return updated_at;
        }
    }

    public class MetadataConfig {
        private Integer page_size;
        private Integer current_page;
        private Integer current_page_records;
        private Integer total_records;
        private Boolean has_next;

        @AuraEnabled
        public Integer getPageSize() {
            return page_size;
        }

        @AuraEnabled
        public Integer getCurrentPage() {
            return current_page;
        }

        @AuraEnabled
        public Integer getCurrentPageRecords() {
            return current_page_records;
        }

        @AuraEnabled
        public Integer getTotalRecords() {
            return total_records;
        }

        @AuraEnabled
        public Boolean getHasNext() {
            return has_next;
        }
    }

    private MetadataConfig metadata;
    private List<Schedule> records;

    public SCH_Schedule() {}

    @AuraEnabled
    public MetadataConfig getMetadata() {
        return metadata;
    }

    @AuraEnabled
    public List<Schedule> getRecords() {
        return records;
    }
}