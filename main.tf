locals {
  api_invoke_url                     = "${var.api_invoke_url}"
  function_name                      = "${coalesce("${var.lambda_function_name}", "slack-slash-command-${var.slash_command}")}"
  log_arn_prefix                     = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
  role_name                          = "${coalesce("${var.role_name}", "${local.function_name}-role")}"
  role_inline_policy_name            = "${coalesce("${var.role_inline_policy_name}", "${local.role_name}-inline-policy")}"
  slack_verification_token_encrypted = "${element(coalescelist("${data.aws_kms_ciphertext.verification_token.*.ciphertext_blob}", list("${var.slack_verification_token}")), 0)}"
  slack_web_api_token_encrypted      = "${element(coalescelist("${data.aws_kms_ciphertext.web_api_token.*.ciphertext_blob}", list("${var.slack_web_api_token}")), 0)}"

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

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "inline" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }

  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${local.log_arn_prefix}:log-group:/aws/lambda/${aws_lambda_function.slash_command.function_name}:*"
    ]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${data.aws_kms_key.key.arn}"]
  }
}

data "aws_kms_ciphertext" "verification_token" {
  count     = "${var.auto_encrypt_tokens}"
  key_id    = "${data.aws_kms_key.key.id}"
  plaintext = "${var.slack_verification_token}"
}

data "aws_kms_ciphertext" "web_api_token" {
  count     = "${var.auto_encrypt_tokens}"
  key_id    = "${data.aws_kms_key.key.id}"
  plaintext = "${var.slack_web_api_token}"
}

data "aws_kms_key" "key" {
  key_id = "${var.kms_key_id}"
}

data "aws_region" "current" {
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

resource "aws_iam_role" "role" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
  name               = "${local.role_name}"
  path               = "${var.role_path}"
}

resource "aws_iam_role_policy" "role_policy" {
  name   = "${local.role_inline_policy_name}"
  role   = "${aws_iam_role.role.id}"
  policy = "${data.aws_iam_policy_document.inline.json}"
}

resource "aws_lambda_function" "slash_command" {
  description      = "${var.lambda_description}"
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${local.function_name}"
  handler          = "slash_command.handler"
  memory_size      = "${var.lambda_memory_size}"
  role             = "${aws_iam_role.role.arn}"
  runtime          = "nodejs8.10"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda.output_path}"))}"
  tags             = "${var.lambda_tags}"
  timeout          = "${var.lambda_timeout}"

  environment {
    variables = {
      AUTH                         = "${jsonencode(local.auth)}"
      ENCRYPTED_VERIFICATION_TOKEN = "${local.slack_verification_token_encrypted}"
      ENCRYPTED_WEB_API_TOKEN      = "${local.slack_web_api_token_encrypted}"
      RESPONSE_TYPE                = "${var.response_type}"
      RESPONSE                     = "${jsonencode(var.response)}"
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
