# AWS Lambda Slack Slash Command

Generic slash command handler for Slack.

## Quickstart

Create a `main.tf` file with the following contents:

```terraform
# main.tf

provider "aws" {
  region = "<region-name>"
}

module "slackbot" {
  source                   = "amancevice/slackbot/aws"
  callback_ids             = ["<your-slack-callbacks-here>"]
  event_types              = ["<your-slack-events-here>"]
  slack_verification_token = "<slack-verification-token>"
}

module "slash_command" {
  source                   = "amancevice/slack-slash-command/aws"
  api_execution_arn        = "${module.socialismbot.api_execution_arn}"
  api_invoke_url           = "${module.socialismbot.api_invoke_url}"
  api_name                 = "${module.socialismbot.api_name}"
  api_parent_id            = "${module.socialismbot.slash_commands_resource_id}"
  kms_key_id               = "${module.socialismbot.kms_key_id}"
  slack_verification_token = "<slack-verification-token>"
  slack_web_api_token      = "<slack-web-api-token>"
  slash_command            = "mycommand"

  response {
    text = ":sparkles: This will be the response of the Slash Command."
  }
}
```

_Note: this is not a secure way of storing your verification/Web API tokens. See the [example](./example) for more secure/detailed deployment._


In a terminal window, initialize the state:

```bash
terraform init
```

Then review & apply the changes

```bash
terraform apply
```
