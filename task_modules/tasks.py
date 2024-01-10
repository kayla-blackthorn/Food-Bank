from cumulusci.tasks.command import Command

class PostToSlackCommand(Command):
    task_options = {
        "test_variable": {
            "description": "The version number to post to Slack",
            "required": True,
        },
        "test_variable2": {
            "description": "The version number to post to Slack",
            "required": True,
        },
    }

    def _run_task(self):
        self.logger.info(f'Test Variable: {self.options["test_variable"]}')
        self.logger.info(f'Test Variable 2: {test_variable2}')

        message = f'Successfully Created Kayla Test Package Version: {self.options["test_variable"]}\n'
        message += 'Install URL: https://login.salesforce.com/packaging/installPackage.apexp?p0={}'.format(self.options['test_variable2'])
        self.options["command"] = (
            'curl -X POST -H "Content-Type: application/json" '
            '-d \'{{"text":"{}"}}\' '
            'https://hooks.slack.com/services/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'.format(message)
        )
        super()._run_task()