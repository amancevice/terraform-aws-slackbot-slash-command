# AWS Lambda Slack Slash Command

[![terraform](https://img.shields.io/github/v/tag/amancevice/terraform-aws-slackbot-slash-command?color=62f&label=version&logo=terraform&style=flat-square)](https://registry.terraform.io/modules/amancevice/slackbot-slash-command/aws)
[![build](https://img.shields.io/github/workflow/status/amancevice/terraform-aws-slackbot-slash-command/validate?logo=github&style=flat-square)](https://github.com/amancevice/terraform-aws-slackbot-slash-command/actions)

Add-on for [amancevice/slackbot/aws](https://github.com/amancevice/terraform-aws-slackbot) terraform module to handle /slash-commands in your Slack App

## Quickstart

```terraform
module "slackbot" {
  source  = "amancevice/slackbot/aws"
  version = "~> 22.0"
  # …
}

module "slackbot_slash_command" {
  source  = "amancevice/slackbot-slash-command/aws"
  version = "~> 19.0"

  # Required

  lambda_role_arn   = module.slackbot.role.arn
  slack_secret_name = module.slackbot.secret.name
  slack_topic_arn   = module.slackbot.topic.arn

  lambda_function_name = "my-slash-command"
  slack_slash_command  = "example"

  slack_response = jsonencode({
    response_type = "ephemeral | in_channel | dialog | modal"
    text          = ":sparkles: This will be the response"
    blocks        = [ /* … */ ]
  })

  # Optional

  lambda_description          = "Slackbot handler for /example"
  lambda_kms_key_arn          = "<kms-key-arn>"
  lambda_memory_size          = 128
  lambda_timeout              = 3
  log_group_retention_in_days = 30
  slack_response_type         = "direct | modal"

  log_group_tags = { /* … */ }
  lambda_tags    = { /* … */ }
}
```
