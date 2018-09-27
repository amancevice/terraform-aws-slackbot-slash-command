variable "api_name" {
  description = "Slackbot REST API Gateway Name."
}

variable "lambda_description" {
  description = "Lambda function description."
  default     = ""
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

variable "role" {
  description = "Slackbot role."
}

variable "response" {
  description = "Slack response object."
  type        = "map"
}

variable "secret" {
  description = "Name of Slackbot secret in AWS SecretsManager."
}

variable "slash_command" {
  description = "Name of slash command."
}

variable "token" {
  description = "Name of token key in Slackbot secret."
  default     = "BOT_ACCESS_TOKEN"
}
