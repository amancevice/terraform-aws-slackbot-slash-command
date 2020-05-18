# AWS Lambda Slack Slash Command

[![terraform](https://img.shields.io/github/v/tag/amancevice/terraform-aws-slackbot-slash-command?color=62f&label=version&logo=terraform&style=flat-square)](https://registry.terraform.io/modules/amancevice/serverless-pypi/aws)
[![build](https://img.shields.io/github/workflow/status/amancevice/terraform-aws-slackbot-slash-command/Test?logo=github&style=flat-square)](https://github.com/amancevice/terraform-aws-slackbot-slash-command/actions)

Generic slash command handler for Slack.

## Quickstart

```hcl
locals {
  slash_response = {
    response_type = "[ ephemeral | in_channel | dialog ]"
    text          = ":sparkles: This will be the response of the Slash Command."

    blocks = {
      /* … */
    }
  }
}

module slackbot_slash_command {
  source        = "amancevice/slackbot-slash-command/aws"
  version       = "~> 15.1"
  api_name      = "<api-gateway-rest-api-name>"
  role_name     = "<iam-role-name>"
  secret_name   = "<secretsmanager-secret-name>"
  response      = jsonencode(local.slash_response)
  slash_command = "my-command-name"
}
```
