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
private class FeatureToggleTest {
    /*******************************************************************************************************
     * @description Method used to test for Argument null expection
     **/
    @IsTest
    private static void constructor_nullRecord_expectArgumentNullException() {
        try {
            test.startTest();
            new FeatureToggle(null);

            TestHelper.expectedArgumentNullException();
        } catch (Exception e) {
            TestHelper.assertArgumentNullException(e, FeatureToggle.FEATURE_TOGGLE_PARAM);
        } finally {
            test.stopTest();
        }
    }

    /*******************************************************************************************************
     * @description Method used to test for feature record
     **/
    @IsTest
    private static void constructor_recordProvided_expectRecordStored() {
        FeatureToggle__mdt featureToggleRecord = FeatureToggleTestHelper.getActiveFeatureToggleTestRecord();

        if (featureToggleRecord == null) {
            System.assert(true, 'An admin in the containing org has deleted the test records. Assert true and exit.');
            return;
        }

        Test.startTest();
        FeatureToggle featureToggle = new FeatureToggle(featureToggleRecord);
        Test.stopTest();

        System.assertNotEquals(null, featureToggle.record, 'Expected the FeatureToggle to have a record stored.');
        System.assertEquals(featureToggleRecord, featureToggle.record,
                'Expected the stored record to match the given record.');
    }

    /*******************************************************************************************************
     * @description Method used to test for matching feature record
     **/
    @IsTest
    private static void label_expectLabelMatchesRecord() {
        FeatureToggle__mdt featureToggleRecord = FeatureToggleTestHelper.getActiveFeatureToggleTestRecord();

        if (featureToggleRecord == null) {
            System.assert(true, 'An admin in the containing org has deleted the test records. Assert true and exit.');
            return;
        }

        FeatureToggle featureToggle = new FeatureToggle(featureToggleRecord);

        Test.startTest();
        String featureToggleLabel = featureToggle.Label;
        Test.stopTest();

        System.assertEquals(featureToggleRecord.Label, featureToggleLabel,
                'Expected the feature toggle labels to match.');
    }

    /*******************************************************************************************************
     * @description Method used to test for matching feature record
     **/
    @IsTest
    private static void isActive_activeTrue_expectActive() {
        FeatureToggle__mdt featureToggleRecord = FeatureToggleTestHelper.getActiveFeatureToggleTestRecord();

        if (featureToggleRecord == null) {
            System.assert(true, 'An admin in the containing org has deleted the test records. Assert true and exit.');
            return;
        }

        FeatureToggle featureToggle = new FeatureToggle(featureToggleRecord);

        Test.startTest();
        Boolean isActive = featureToggle.IsActive;
        Test.stopTest();

        System.assert(isActive, 'Expected the feature toggle to be active.');
    }

    /*******************************************************************************************************
     * @description Method used to test for matching feature record
     **/
    @IsTest
    private static void isActive_activationDateExceeded_expectActive() {
        FeatureToggle__mdt featureToggleRecord = FeatureToggleTestHelper.getActivationFeatureToggleTestRecord();

        if (featureToggleRecord == null) {
            System.assert(true, 'An admin in the containing org has deleted the test records. Assert true and exit.');
            return;
        }

        FeatureToggle featureToggle = new FeatureToggle(featureToggleRecord);

        Test.startTest();
        Boolean isActive = featureToggle.IsActive;
        Test.stopTest();

        System.assert(isActive, 'Expected the feature toggle to be active.');
    }

    /*******************************************************************************************************
     * @description Method used to test for matching feature record
     **/
    @IsTest
    private static void isActive_deactivationDateExceeded_expectInactive() {
        FeatureToggle__mdt featureToggleRecord = FeatureToggleTestHelper.getInactiveFeatureToggleTestRecord();

        if (featureToggleRecord == null) {
            System.assert(true, 'An admin in the containing org has deleted the test records. Assert true and exit.');
            return;
        }

        FeatureToggle featureToggle = new FeatureToggle(featureToggleRecord);

        Test.startTest();
        Boolean isActive = featureToggle.IsActive;
        Test.stopTest();

        System.assert(!isActive, 'Expected the feature toggle to be inactive.');
    }
}