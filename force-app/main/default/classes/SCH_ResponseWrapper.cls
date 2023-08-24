/**
 * Blackthorn.io ENTERPRISES CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io Enterprises, LLC
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io Enterprises, LLC and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io Enterprises, LLC
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io Enterprises, LLC.
 *
 * 
 * A library of methods used to handle HTTP responses.
 *
 *
**/
public with sharing class SCH_ResponseWrapper {
    private String jsonString;

    /**
     *  @param  jsonString - a JSON string from the Http Response body
     *
     *  Constructor
     *
     **/
    public SCH_ResponseWrapper(String jsonString) {
        this.jsonString = jsonString;
        System.debug(logginglevel.WARN, 'SCH_ResponseWrapper JSON: ' + jsonString);
    }

    /**
     *  @return - a SCH_Account
     *
     *  Deserialize the response as a SCH_Account object.
     *
     **/
    public SCH_Account getAccount() {
        return (SCH_Account) JSON.deserialize(jsonString, SCH_Account.class);
    }

    /**
     *  @return - a SCH_Account
     *
     *  Deserialize the response as a SCH_Account object.
     *
     **/
    public SCH_Account updateAccount() {
        return (SCH_Account) JSON.deserialize(jsonString, SCH_Account.class);
    }

    /**
     *  @return - a List SCH_Schedule
     *
     *  Deserialize the response as a List SCH_Schedule.
     *
     **/
    public SCH_Schedule getSchedules() {
        return (SCH_Schedule) JSON.deserialize(jsonString, SCH_Schedule.class);
    }

    /**
     *  @return - a List SCH_ExecutionSchedule
     *
     *  Deserialize the response as a List SCH_ExecutionSchedule.
     *
     **/
    public SCH_ExecutionSchedule getExecutionSchedules() {
        return (SCH_ExecutionSchedule) JSON.deserialize(jsonString, SCH_ExecutionSchedule.class);
    }


    /**
     *  @return - a Map<String, Object>
     *
     *  Deserialize the response as a Map<String, Object> to have SMS(simplesms) account details.
     *
     **/
    public Map<String, Object> getSMSDetails() {
        return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
    }

    /**
     * @return an Map<String, String> containing knowledge Articles keys with link
     * 
     * Extract Knowledege Articles
     * 
     **/
    public Map<String, Object> getHelpLink() {
        return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
    }
}