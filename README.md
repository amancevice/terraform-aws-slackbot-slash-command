# AWS Lambda Slack Slash Command

Generic slash command handler for Slack.

## Quickstart

```terraform
# Slackbot API
module slackbot {
  source                  = "amancevice/slackbot/aws"
  api_description         = "My Slack app API"
  api_name                = "<my-api>"
  api_stage_name          = "<my-api-stage>"
  slack_bot_access_token  = "${var.slack_bot_access_token}"
  slack_client_id         = "${var.slack_client_id}"
  slack_client_secret     = "${var.slack_client_secret}"
  slack_signing_secret    = "${var.slack_signing_secret}"
  slack_user_access_token = "${var.slack_access_token}"
}

# Slackbot slash command
module "slash_command" {
  source        = "amancevice/slack-slash-command/aws"
  api_name      = "${module.slackbot.api_name}"
  role_name     = "${module.slackbot.role_name}"
  secret_name   = "${module.slackbot.secret_name}"
  slash_command = "mycommand"

  response {
    response_type = "ephemeral|in_channel|dialog"
    text          = ":sparkles: This will be the response of the Slash Command."
  }
}
```

This will add an SNS topic `slack_slash_<slash-command>` whose messages trigger a Lambda function to issue the response via the Slack Web API.
