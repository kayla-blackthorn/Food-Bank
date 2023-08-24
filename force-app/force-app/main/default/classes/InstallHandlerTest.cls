@IsTest
private class InstallHandlerTest {
    private static final String ASSERT_FORM_SUBMISSION_JOB_SCHEDULED = 'Expected 1 FormSubmissionProcessAnswerBatch job to be scheduled';
    @IsTest
    private static void scheduleRecommendedJobs_whenNoJobScheduled_expectJobsToBeScheduled() {
        Test.startTest();
        InstallHandler.scheduleRecommendedJobs();
        Test.stopTest();

        List<CronTrigger> formSubmissionJob = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :FormSubmissionProcessAnswerBatch.FORM_SUBMISSION_JOB + '%'
        ];

        Assert.areEqual(1, formSubmissionJob.size(), ASSERT_FORM_SUBMISSION_JOB_SCHEDULED);
    }

    @IsTest
    private static void scheduleRecommendedJobs_whenJobAlreadyScheduled_expectJobsToNotBeScheduled() {
        System.scheduleBatch(
            new FormSubmissionProcessAnswerBatch(),
            FormSubmissionProcessAnswerBatch.FORM_SUBMISSION_JOB + Datetime.now().addMinutes(5).minute(),
            5,
            1
        );

        Test.startTest();
        InstallHandler.scheduleRecommendedJobs();
        Test.stopTest();

        List<CronTrigger> formSubmissionJob = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :FormSubmissionProcessAnswerBatch.FORM_SUBMISSION_JOB + '%'
        ];

        Assert.areEqual(1, formSubmissionJob.size(), ASSERT_FORM_SUBMISSION_JOB_SCHEDULED);
    }
}
