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
 * This is used as wrapper class to show the schedule logs
 *
**/
public class SCH_ExecutionSchedule {

    public class Schedule {
        private String action_type;
        private String status;
        private String status_message;
        private String salesforce_id;
        private String sms_sid;
        private String email_id;
        private String execution_date_time;
        private String created_at;
        private String updated_at;
        private String sidekiq_job_id;
        private String email_or_phone;
        private Integer log_counts;
        private List<Logs> logs;
        private Execution execution;

        public Schedule() {}

        @AuraEnabled
        public String getActionType() {
            return action_type;
        }

        @AuraEnabled
        public String getSalesforceId() {
            return salesforce_id;
        }

        @AuraEnabled
        public String getStatus() {
            return status;
        }

        @AuraEnabled
        public String getStatusMessage() {
            return (String.isBlank(status_message) ? '' : status_message);
        }

        @AuraEnabled
        public String getEmailId() {
            return email_id;
        }

        @AuraEnabled
        public String getSMSSId() {
            return sms_sid;
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

        @AuraEnabled
        public String getSidekiqJobId() {
            return sidekiq_job_id;
        }

        @AuraEnabled
        public Integer getLogCounts() {
            return log_counts;
        }

        @AuraEnabled
        public List<Logs> getLogs() {
            return logs;
        }

        @AuraEnabled
        public Execution getExecution() {
            return execution;
        }
        @AuraEnabled
        public String getEmailOrPhone(){
            return email_or_phone;
        }
    }

    public class Execution {
        private String salesforce_id;
        private String status;
        private String status_message;
        private String execution_date_time;
        private String created_at;
        private String updated_at;
        private String sidekiq_job_id;

        @AuraEnabled
        public String getSalesforceId() {
            return salesforce_id;
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

        @AuraEnabled
        public String getSidekiqJobId() {
            return sidekiq_job_id;
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
        private Integer current_page_execution_records;
        private Integer current_page_log_records;
        private Integer total_execution_records;
        private Integer total_log_records;
        private Integer total_records;
        private Integer failed_log_count;  
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
        public Integer getCurrentPageExecutionRecords() {
            return current_page_execution_records;
        }

        @AuraEnabled
        public Integer getCurrentPageLogRecords() {
            return current_page_log_records;
        }

        @AuraEnabled
        public Integer getTotalExecutionRecords() {
            return total_execution_records;
        }

        @AuraEnabled
        public Integer getTotalLogRecords() {
            return total_log_records;
        }

        @AuraEnabled
        public Integer getTotalRecords() {
            return total_records;
        }

        @AuraEnabled
        public Integer getFailedLogCount() {
            return failed_log_count;
        }   

        @AuraEnabled
        public Boolean getHasNext() {
            return has_next;
        }
    }

    private MetadataConfig metadata;
    private List<Schedule> records;

    public SCH_ExecutionSchedule() {}

    @AuraEnabled
    public MetadataConfig getMetadata() {
        return metadata;
    }

    @AuraEnabled
    public List<Schedule> getRecords() {
        return records;
    }
}