/**
 * Responsible for running post-install/upgrade tasks, such as scheduling recommended jobs.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class InstallHandler implements System.InstallHandler {
    private static final String RUN_HOURLY = '0 0 * * * ? *';

    /**
     * @description Run post-install/upgrade tasks.
     * @param context - Install context.
     */
    global void onInstall(System.InstallContext context) {
    }

    /**
     * @description Schedule recommended jobs.
     */
    global static void scheduleRecommendedJobs() {
        scheduleFormSubmissionProcessIfMissing();
    }

    private static void scheduleFormSubmissionProcessIfMissing() {
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :FormSubmissionProcessAnswerBatch.FORM_SUBMISSION_JOB + '%'
        ];

        if (jobs.size() != 0) {
            return;
        }

        System.schedule(
            FormSubmissionProcessAnswerBatch.FORM_SUBMISSION_JOB + '0',
            RUN_HOURLY,
            new FormSubmissionProcessAnswerBatch()
        );
    }
}
