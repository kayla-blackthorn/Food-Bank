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
 * A custom Exception class.
 *
**/
public with sharing class SCH_Exception extends Exception {
    private String message;

    public SCH_Exception(String message, String t) {
        this.message = message;
    }
    /**
     *  @return the exception message
     *
     *  Overridden method that returns the message.
     *
     **/
    public override String getMessage() {
        String errorMessage = '';
        System.debug('message ' + message);
        try {
            JSONParser parser = JSON.createParser(message);

            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    parser.nextToken();
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        if (parser.getText() == 'error') {
                            parser.nextToken();
                            errorMessage = parser.getText();
                            break;
                        }
                    }
                }
            }
        } catch (System.Exception e) {
            System.debug(loggingLevel.WARN, 'Error while parsing JSON: ' + e.getMessage() + '--' + e.getStackTraceString());
            errorMessage = this.message;
        }

        return errorMessage;
    }
}