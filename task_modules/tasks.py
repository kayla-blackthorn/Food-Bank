from cumulusci.tasks.command import Command

class PostToSlackCommand(Command):
    task_options = {
        "version_id": {
            "description": "The version id to post to Slack",
            "required": True,
        },
        "version_number": {
            "description": "The version number to post to Slack",
            "required": True,
        },
    }

    def _run_task(self):
        message = f'Successfully Created Kayla Test Package Version: {self.options["version_number"]}\n'
        message += 'Install URL: https://login.salesforce.com/packaging/installPackage.apexp?p0={}'.format(self.options['version_id'])
        self.options["command"] = (
            'curl -X POST -H "Content-Type: application/json" '
            '-d \'{{"text":"{}"}}\' '
            'https://hooks.slack.com/services/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'.format(message)
        )
        super()._run_task()