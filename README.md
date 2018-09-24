# AWS Lambda Slack Slash Command

Generic slash command handler for Slack.

## Quickstart

```terraform
# Slackbot API
module "slackbot" {
  source                 = "amancevice/slackbot/aws"
  slack_access_token     = "${var.slack_access_token}"
  slack_bot_access_token = "${var.slack_bot_access_token}"
  slack_signing_secret   = "${var.slack_signing_secret}"
}

# Slackbot slash command
module "slash_command" {
  source        = "amancevice/slack-slash-command/aws"
  api_name      = "${module.slackbot.api_name}"
  response_type = "dialog|ephemeral|in_channel"
  role          = "${module.slackbot.role}"
  secret        = "${module.slackbot.secret}"
  slash_command = "mycommand"

  response {
    text = ":sparkles: This will be the response of the Slash Command."
  }
}
```

This will add an SNS topic `slack_slash_<slash-command>` whose messages trigger a Lambda function to issue the response via the Slack Web API.
