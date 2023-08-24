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
 *
**/
@IsTest
private class ArgumentNullExceptionTest {
    private static final String TEST_VAR = 'testVar';
    /*******************************************************************************************************
     * @description Method used to test exception scneario if object is null
     **/
    @IsTest
    private static void throwIfNull_objIsNull_expectException() {
        try {
            test.startTest();
            ArgumentNullException.throwIfNull(null, TEST_VAR);
            TestHelper.expectedArgumentNullException();
        } catch (Exception e) {
            TestHelper.assertArgumentNullException(e, TEST_VAR);
        } finally {
            test.stopTest();
        }
    }
    /*******************************************************************************************************
     * @description Method used to test exception scneario if object is not null
     **/
    @IsTest
    private static void throwIfNull_objIsNotNull_expectNoException() {
        try {
            test.startTest();
            ArgumentNullException.throwIfNull('Not Null', TEST_VAR);
        } catch (Exception e) {
            System.assert(false, 'Expected there to be no exception thrown.');
        } finally {
            test.stopTest();
        }
    }
}