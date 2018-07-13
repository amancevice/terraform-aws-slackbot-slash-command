variable "api_name" {
  description = "Slackbot REST API Gateway Name."
}

variable "api_execution_arn" {
  description = "Slackbot REST API Gateway deployment execution ARN."
}

variable "api_invoke_url" {
  description = "Slackbot REST API Gateway invocation URL."
}

variable "api_parent_id" {
  description = "Slackbot slash commands parent resource ID."
}

variable "auth_channels_exclude" {
  description = "Optional list of Slack channel IDs to blacklist."
  type        = "list"
  default     = []
}

variable "auth_channels_include" {
  description = "Optional list of Slack channel IDs to whitelist."
  type        = "list"
  default     = []
}

variable "auth_channels_permission_denied" {
  description = "Permission denied message for channels."
  type        = "map"

  default {
    text = "Sorry, you can't do that in this channel."
  }
}

variable "auth_users_exclude" {
  description = "Optional list of Slack user IDs to blacklist."
  type        = "list"
  default     = []
}

variable "auth_users_include" {
  description = "Optional list of Slack user IDs to whitelist."
  type        = "list"
  default     = []
}

variable "auth_users_permission_denied" {
  description = "Permission denied message for users."
  type        = "map"

  default {
    text = "Sorry, you don't have permission to do that."
  }
}

variable "lambda_description" {
  description = "Lambda function description."
  default     = "Slack slash command handler."
}

variable "lambda_function_name" {
  description = "Lambda function name"
  default     = ""
}

variable "lambda_memory_size" {
  description = "Lambda function memory size."
  default     = 512
}

variable "lambda_tags" {
  description = "A set of key/value label pairs to assign to the function."
  type        = "map"

  default {
    deployment-tool = "terraform"
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout."
  default     = 3
}

variable "role_name" {
  description = "Name of role for slash command Lambdas."
  default     = ""
}

variable "role_path" {
  description = "Path for slash command role."
  default     = ""
}

variable "response_type" {
  description = "Direct or dialog."
  default     = "direct"
}

variable "response" {
  description = "Slack response object."
  type        = "map"

  default {
    text = "OK"
  }
}

variable "slackbot_secret" {
  description = "Name of Slackbot secret in AWS SecretsManager."
}

variable "slackbot_token" {
  description = "Name of token key in Slackbot secret."
  default     = "BOT_ACCESS_TOKEN"
}

variable "slackbot_secrets_policy_arn" {
  description = "ARN of policy granting read access to Slackbot secrets."
}

variable "slash_command" {
  description = "Name of slash command."
}
