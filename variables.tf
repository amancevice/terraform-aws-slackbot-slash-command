variable api_name {
  description = "Slackbot REST API Gateway Name."
}

variable kms_key_arn {
  description = "KMS Key ARN."
  default     = ""
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
  default     = 1024
}

variable lambda_tags {
  description = "AWS resource tags."
  type        = map
  default     = {}
}

variable lambda_timeout {
  description = "Lambda function timeout."
  default     = 3
}

variable log_group_retention_in_days {
  description = "Days to retain logs in CloudWatch."
  default     = 30
}

variable log_group_tags {
  description = "AWS resource tags."
  type        = map
  default     = {}
}

variable role_name {
  description = "Slackbot role."
}

variable response {
  description = "Slack response JSON."
}

variable secret_name {
  description = "Name of Slackbot secret in AWS SecretsManager."
}

variable slackbot_topic {
  description = "Slackbot SNS topic."
}

variable slash_command {
  description = "Name of slash command."
}
