# AWS Lambda Slack Slash Command

Generic slash command handler for Slack.

## Quickstart

```terraform
# Slackbot API
module "slackbot" {
  source                   = "amancevice/slackbot/aws"
  slack_access_token       = "${var.slack_access_token}"
  slack_bot_access_token   = "${var.slack_bot_access_token}"
  slack_signing_secret     = "${var.slack_signing_secret}"

  callback_ids = [
    # ...
  ]

  event_types = [
    # ...
  ]
}

# Slackbot slash command
module "slash_command" {
  source                      = "amancevice/slack-slash-command/aws"
  api_name                    = "${module.slackbot.api_name}"
  api_execution_arn           = "${module.slackbot.api_execution_arn}"
  api_parent_id               = "${module.slackbot.slash_commands_resource_id}"
  api_invoke_url              = "${module.slackbot.slash_commands_request_url}"
  slackbot_secret             = "${module.slackbot.secret}"
  slackbot_secrets_policy_arn = "${module.slackbot.secrets_policy_arn}"
  slash_command               = "mycommand"

  response {
    text = ":sparkles: This will be the response of the Slash Command."
  }
}
```

This will add an API endpoint, `/v1/slash-commands/mycommand`, to be configured in Slack.

For every callback you plan on making (these are all custom values), add the callback ID to the `callback_ids` list in the `slackbot` module.
