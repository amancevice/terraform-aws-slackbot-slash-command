// AWS
variable "aws_region" {
  description = "AWS region name."
  default     = ""
}

variable "aws_account_id" {
  description = "AWS account ID."
  default     = ""
}

// Slack
variable "slack_verification_token" {
  description = "Slack verification token."
}

variable "slack_web_api_token" {
  description = "Slack Web API token."
}

variable "slash_command" {
  description = "Name of slash command."
}

// REST API
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

// KMS
variable "kms_key_id" {
  description = "Slackbot KMS Key ID."
}

// Role
variable "role_name" {
  description = "Name of role for Slackbot Lambdas."
  default     = ""
}

variable "role_path" {
  description = "Path for Slackbot role."
  default     = "/service-role/"
}

variable "role_policy_name" {
  description = "Name of inline Slackbot role policy."
  default     = ""
}

// Lambda
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
  default     = 128
}

variable "lambda_timeout" {
  description = "Lambda function timeout."
  default     = 3
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

// Auth
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
