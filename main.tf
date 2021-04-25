terraform {
  required_version = "~> 0.13"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

locals {
  events = {
    source = var.event_source

    bus = {
      name = var.event_bus_name
    }

    rule = {
      name        = var.event_rule_name
      description = var.event_rule_description
    }
  }

  lambda = {
    description   = coalesce(var.lambda_description, "Slack handler for /${local.slack.slash_command}")
    function_name = var.lambda_function_name
    kms_key_arn   = var.lambda_kms_key_arn
    role_arn      = var.lambda_role_arn
    runtime       = var.lambda_runtime
    memory_size   = var.lambda_memory_size
    tags          = var.lambda_tags
    timeout       = var.lambda_timeout

    environment = {
      EVENTS_BUS_NAME = local.events.bus.name
      EVENTS_SOURCE   = local.events.source
      SLACK_RESPONSE  = local.slack.response
    }
  }

  log_group = {
    retention_in_days = var.log_group_retention_in_days
    tags              = var.log_group_tags
  }

  slack = {
    response      = var.slack_response
    response_type = var.slack_response_type
    slash_command = var.slack_slash_command
  }
}

data "archive_file" "package" {
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/package.zip"
  type        = "zip"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = local.log_group.retention_in_days
  tags              = local.log_group.tags
}

resource "aws_lambda_function" "lambda" {
  description      = local.lambda.description
  filename         = data.archive_file.package.output_path
  function_name    = local.lambda.function_name
  handler          = "index.${local.slack.response_type}"
  kms_key_arn      = local.lambda.kms_key_arn
  memory_size      = local.lambda.memory_size
  role             = local.lambda.role_arn
  runtime          = local.lambda.runtime
  source_code_hash = data.archive_file.package.output_base64sha256
  tags             = local.lambda.tags
  timeout          = local.lambda.timeout

  environment {
    variables = local.lambda.environment
  }
}

resource "aws_lambda_permission" "invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
  statement_id  = "AllowExecutionFromEventBridge"
}

resource "aws_cloudwatch_event_rule" "rule" {
  event_bus_name = local.events.bus.name
  name           = local.events.rule.name
  description    = local.events.rule.description

  event_pattern = jsonencode({
    detail-type = ["slash"]
    source      = [local.events.source]

    detail = {
      command = ["/${local.slack.slash_command}"]
    }
  })
}

resource "aws_cloudwatch_event_target" "target" {
  arn            = aws_lambda_function.lambda.arn
  event_bus_name = aws_cloudwatch_event_rule.rule.event_bus_name
  rule           = aws_cloudwatch_event_rule.rule.name
  target_id      = "slack-slash-${local.slack.slash_command}"
}
