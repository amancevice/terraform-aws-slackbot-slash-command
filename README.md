# AWS Lambda Slack Slash Command

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
  source        = "amancevice/slack-slash-command/aws"
  version       = "~> 15.0"
  api_name      = "<api-gateway-rest-api-name>"
  role_name     = "<iam-role-name>"
  secret_name   = "<secretsmanager-secret-name>"
  response      = jsonencode(local.slash_response)
  slash_command = "my-command-name"
}
```
