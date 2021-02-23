terraform {
  required_version = "~> 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

locals {
  lambda = {
    description   = coalesce(var.lambda_description, "Slack handler for /${local.slack.slash_command}")
    filename      = "${path.module}/package.zip"
    function_name = var.lambda_function_name
    handler       = "index.handler"
    kms_key_arn   = var.lambda_kms_key_arn
    role_arn      = var.lambda_role_arn
    runtime       = var.lambda_runtime
    memory_size   = var.lambda_memory_size
    tags          = var.lambda_tags
    timeout       = var.lambda_timeout

    environment = {
      AWS_SECRET = local.slack.secret_name
      RESPONSE   = local.slack.response
    }
  }

  log_group = {
    retention_in_days = var.log_group_retention_in_days
    tags              = var.log_group_tags
  }

  slack = {
    response      = var.slack_response
    secret_name   = var.slack_secret_name
    slash_command = var.slack_slash_command
    topic_arn     = var.slack_topic_arn
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = local.log_group.retention_in_days
  tags              = local.log_group.tags
}

resource "aws_lambda_function" "lambda" {
  description      = local.lambda.description
  filename         = local.lambda.filename
  function_name    = local.lambda.function_name
  handler          = local.lambda.handler
  kms_key_arn      = local.lambda.kms_key_arn
  memory_size      = local.lambda.memory_size
  role             = local.lambda.role_arn
  runtime          = local.lambda.runtime
  source_code_hash = filebase64sha256(local.lambda.filename)
  tags             = local.lambda.tags
  timeout          = local.lambda.timeout

  environment {
    variables = local.lambda.environment
  }
}

resource "aws_lambda_permission" "invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = local.slack.topic_arn
}

resource "aws_sns_topic_subscription" "subscription" {
  endpoint  = aws_lambda_function.lambda.arn
  protocol  = "lambda"
  topic_arn = local.slack.topic_arn

  filter_policy = jsonencode({
    id   = [local.slack.slash_command]
    type = ["slash"]
  })
}
