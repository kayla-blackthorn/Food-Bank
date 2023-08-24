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
 * This is used as service class for Email
 *
**/
public with sharing class SCH_EmailService {

    /*******************************************************************************************************
     * @description Method used to send email
     * @return none
     * @param mapEmailParameters: Email Address, Email Template Id and Target Record Id details
     **/
    public static void sendTestEmails(Map<String, Object> mapEmailParameters) {
        Id emailtemplateId = getEmailTemplateId((String) mapEmailParameters.get('emailTemplateId'));
        Id orgWideEmailAddressId = getOrgWideEmailAddressId((String) mapEmailParameters.get('fromEmailAddress'));
        List<String> toAddresses = new List<String>();
        // preparing to addresses for sending email after trimming email
        for(String toAddress: (List<String>) mapEmailParameters.get('toEmailAddress')){
            String tmp = toAddress.trim();
            if (String.isNotBlank(tmp)) {
                toAddresses.add(tmp.trim());
            }
        }
        // validating the list of to addresses 
        if (toAddresses.size() > 0) {
            List<Messaging.SendEmailResult> results = SCH_BtBaseUtils.sendMail(orgWideEmailAddressId,
                (List<String>) mapEmailParameters.get('toEmailAddress'),
                (Id) mapEmailParameters.get('targetRecordId'),
                emailtemplateId, true);
            
            String errorMessage = '';
            for (Messaging.SendEmailResult emailResult: results) {
                if (emailResult.isSuccess() == false) {
                    for (Messaging.SendEmailError error: emailResult.getErrors()) {
                        errorMessage += error.getMessage() + '\n';
                        break;
                    }
                }
            }
            if (String.isNotBlank(errorMessage)) {
                throw new SCH_Exception(errorMessage.removeEnd('\n'), null);
            }
        } else{
            throw new SCH_Exception('To Address(s) not found.', null);
        }
    }

    /*******************************************************************************************************
     * @description Method used to get SF email template Id
     * @return Id
     * @param emailTemplateId: Event / Email Template Id
     **/
    public static Id getEmailTemplateId(String emailTemplateId) {
        // validating emailTemplateId as Id
        if (emailTemplateId instanceof Id) {
            SObjectType sObjectType;
            try {
                sObjectType = ((Id) emailTemplateId).getSobjectType();
            } catch (Exception excp) {
                System.debug('Exception> SCH_EmailService> getEmailTemplateId: ' + excp.getMessage());
                System.debug('Exception> SCH_EmailService> getEmailTemplateId: ' + excp.getStackTraceString());
            }
            if (sObjectType == null) {
                return null;
            }
            // emailTemplateId sObjectType with EmailTemplate SobjectType
            if (sObjectType == EmailTemplate.SObjectType) {
                sObject emailTemplateRecord = SCH_BtBaseUtils.getsObjectDetails('EmailTemplate', 'Id', emailTemplateId);
                if (emailTemplateRecord != null) {
                    return emailTemplateRecord.Id;
                }
            } else if (SCH_BtBaseUtils.INSTALLED_EVENTS) {
                //Check if Email Template Id is of a valid Event Email Template Or Not
                sObject eventTemplateRecord = SCH_BtBaseUtils.getsObjectDetails('conference360__Email_Template__c', 'Id, conference360__SF_Template_Id__c', emailTemplateId);
                if (eventTemplateRecord != null && eventTemplateRecord.get('conference360__SF_Template_Id__c') != null) {
                    return String.valueOf(eventTemplateRecord.get('conference360__SF_Template_Id__c'));
                }
            }
        }
        return null;
    }

    /*******************************************************************************************************
     * @description Method used to get SF Org Wide email address Id
     * @return Id
     * @param fromEmailAddress: Email Address
     **/
    public static Id getOrgWideEmailAddressId(String fromEmailAddress) {
        //Check if OrgWideEmailAddress is valid and available
        if (String.isNotBlank(fromEmailAddress)) {
            fromEmailAddress = String.escapeSingleQuotes(fromEmailAddress).trim().toLowerCase();
            Map<String, OrgWideEmailAddress> emailWiseOrgWiseAddress = SCH_BtBaseUtils.getOrgWideEmailAddresses(new List<String> {
                fromEmailAddress
            });
            if (emailWiseOrgWiseAddress.containsKey(fromEmailAddress)) {
                return emailWiseOrgWiseAddress.get(fromEmailAddress).Id;
            }
        }
        return null;
    }
}