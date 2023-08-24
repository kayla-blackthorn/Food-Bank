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
 * Test class for custom Exception class.
 *
**/
@IsTest
public class SCH_ExceptionTest {
    /*******************************************************************************************************
     * @description Method used to test custom exceptions
     **/
    @IsTest
    public static void testCustomExceptions() {
        Test.startTest();
        SCH_Exception exce;
        exce = new SCH_Exception();
        System.assertEquals(null, exce.getMessage());

        exce = new SCH_Exception('{"error":"System.NullPointerException: null input to JSON parser"}', '');
        System.assertEquals('System.NullPointerException: null input to JSON parser', exce.getMessage());
        Test.stopTest();
    }
    /*******************************************************************************************************
     * @description Method used to test custom exceptions
     **/
    @IsTest
    public static void testInvalidCustomExceptions() {
        Test.startTest();
        SCH_Exception exce;
        exce = new SCH_Exception();
        System.assertEquals(null, exce.getMessage());

        exce = new SCH_Exception('{"error":"System.DMLException: mixed dml operation"}', '');
        System.assertNotEquals('System.NullPointerException: null input to JSON parser', exce.getMessage());
        Test.stopTest();
    }

}