locals {
  function_name  = "${coalesce(var.lambda_function_name, "slack-${var.api_name}-slash-${var.slash_command}")}"
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/dist/package.zip"
  source_dir  = "${path.module}/src"
}

data "aws_caller_identity" "current" {
}

data "aws_iam_role" "role" {
  name = "${var.role}"
}

resource "aws_lambda_function" "lambda" {
  description      = "${var.lambda_description}"
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${local.function_name}"
  handler          = "index.handler"
  memory_size      = "${var.lambda_memory_size}"
  role             = "${data.aws_iam_role.role.arn}"
  runtime          = "nodejs8.10"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  tags             = "${var.lambda_tags}"
  timeout          = "${var.lambda_timeout}"

  environment {
    variables {
      RESPONSE      = "${jsonencode(var.response)}"
      RESPONSE_TYPE = "${var.response_type}"
      SECRET        = "${var.secret}"
      TOKEN         = "${var.token}"
    }
  }
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.trigger.arn}"
}

resource "aws_sns_topic" "trigger" {
  name = "slack_slash_${var.slash_command}"
}
