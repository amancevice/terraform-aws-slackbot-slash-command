variable api_name {
  description = "Slackbot REST API Gateway Name."
}

variable cloudwatch_log_group_retention_in_days {
  description = "Days to retain logs in CloudWatch."
  default     = 30
}

variable lambda_description {
  description = "Lambda function description."
  default     = ""
}

variable lambda_function_name {
  description = "Lambda function name"
  default     = ""
}

variable lambda_memory_size {
  description = "Lambda function memory size."
  default     = 512
}

variable lambda_tags {
  description = "A set of key/value label pairs to assign to the function."
  type        = "map"
  default     = {}
}

variable lambda_timeout {
  description = "Lambda function timeout."
  default     = 3
}

variable role_name {
  description = "Slackbot role."
}

variable response {
  description = "Slack response object."
  type        = "map"
}

variable secret_name {
  description = "Name of Slackbot secret in AWS SecretsManager."
}

variable slash_command {
  description = "Name of slash command."
}

variable token {
  description = "Name of token key in Slackbot secret."
  default     = "BOT_ACCESS_TOKEN"
}
