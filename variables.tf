variable "lambda_description" {
  description = "Lambda function description"
  default     = null
}

variable "lambda_function_name" {
  description = "Lambda function name"
}

variable "lambda_kms_key_arn" {
  description = "KMS Key ARN"
  default     = null
}

variable "lambda_memory_size" {
  description = "Lambda function memory size"
  default     = 128
}

variable "lambda_role_arn" {
  description = "Slackbot role ARN"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  default     = "nodejs14.x"
}

variable "lambda_tags" {
  description = "AWS resource tags"
  type        = map(string)
  default     = {}
}

variable "lambda_timeout" {
  description = "Lambda function timeout"
  default     = 3
}

variable "log_group_retention_in_days" {
  description = "Days to retain logs in CloudWatch"
  default     = 30
}

variable "log_group_tags" {
  description = "AWS resource tags"
  type        = map(string)
  default     = {}
}

variable "slack_response" {
  description = "Slack response JSON"
}

variable "slack_secret_name" {
  description = "Name of Slackbot secret in AWS SecretsManager"
}

variable "slack_slash_command" {
  description = "Name of slash command"
}

variable "slack_topic_arn" {
  description = "Slackbot SNS topic"
}
