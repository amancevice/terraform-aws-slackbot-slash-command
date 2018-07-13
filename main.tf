locals {
  api_invoke_url = "${var.api_invoke_url}"
  function_name  = "${coalesce("${var.lambda_function_name}", "slack-slash-command-${var.slash_command}")}"
  role_path      = "${coalesce("${var.role_path}", "/${var.api_name}/")}"

  auth {
    channels {
      permission_denied = "${var.auth_channels_permission_denied}"
      exclude           = ["${var.auth_channels_exclude}"]
      include           = ["${var.auth_channels_include}"]
    }
    users {
      permission_denied = "${var.auth_users_permission_denied}"
      exclude           = ["${var.auth_users_exclude}"]
      include           = ["${var.auth_users_include}"]
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/dist/package.zip"
  source_dir  = "${path.module}/src"
}

data "aws_api_gateway_rest_api" "api" {
  name = "${var.api_name}"
}

data "aws_caller_identity" "current" {
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${data.aws_api_gateway_rest_api.api.id}"
  parent_id   = "${var.api_parent_id}"
  path_part   = "${var.slash_command}"
}

resource "aws_api_gateway_method" "post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  rest_api_id   = "${data.aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_integration" "integration" {
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "${aws_api_gateway_method.post.http_method}"
  integration_http_method = "POST"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  rest_api_id             = "${data.aws_api_gateway_rest_api.api.id}"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.slash_command.invoke_arn}"
}

resource "aws_api_gateway_method_response" "response" {
  http_method = "${aws_api_gateway_method.post.http_method}"
  resource_id = "${aws_api_gateway_method.post.resource_id}"
  rest_api_id = "${data.aws_api_gateway_rest_api.api.id}"
  status_code = "200"

  response_models {
    "application/json" = "Empty"
  }
}

resource "aws_lambda_function" "slash_command" {
  description      = "${var.lambda_description}"
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${local.function_name}"
  handler          = "index.handler"
  memory_size      = "${var.lambda_memory_size}"
  role             = "${var.role_arn}"
  runtime          = "nodejs8.10"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  tags             = "${var.lambda_tags}"
  timeout          = "${var.lambda_timeout}"

  environment {
    variables {
      AUTH            = "${jsonencode(local.auth)}"
      RESPONSE        = "${jsonencode(var.response)}"
      RESPONSE_TYPE   = "${var.response_type}"
      SECRET          = "${var.secret}"
      SIGNING_VERSION = "${var.slack_signing_version}"
      TOKEN           = "${var.slackbot_token}"
    }
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slash_command.arn}"
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowAPIGatewayInvoke"
  source_arn    = "${var.api_execution_arn}/POST/slash-commands/${aws_api_gateway_resource.resource.path_part}"
}
