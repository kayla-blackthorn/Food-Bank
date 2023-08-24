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
 * This is used as wrapper class for Delta Records
 *
**/
public class SCH_DeltaRecordWrapper {
    public String logic_exp { get; set; }

    public List<Filters> filters { get; set; }

    public class Filters {
        public String f_id { get; set; }
        public String f { get; set; }
        public String op { get; set; }
        public String val { get; set; }
        public String f_type { get; set; }
    }

    public Set<String> getFieldsToCheck() {
        Set<String> fields = new Set<String> ();
        for (Filters fl: filters) {
            fields.add(fl.f);
        }
        return fields;
    }

    public class DeltaRequest {
        public String schedule_salesforce_id { get; set; }
        public String record_salesforce_id { get; set; }
        public String request_type { get; set; }
        public String schedule_field_value { get; set; }

        public DeltaRequest(String schedule_salesforce_id, String record_salesforce_id, String request_type, String schedule_field_value) {
            this.schedule_salesforce_id = schedule_salesforce_id;
            this.record_salesforce_id = record_salesforce_id;
            this.request_type = request_type;
            this.schedule_field_value = schedule_field_value;
        }
    }
}