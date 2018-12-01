locals {
  lambda_function_name = "${coalesce(var.lambda_function_name, "slack-${var.api_name}-slash-${var.slash_command}")}"
  lambda_description   = "${coalesce(var.lambda_description, "Slack handler for /${var.slash_command}")}"
}

data aws_iam_role role {
  name = "${var.role_name}"
}

resource aws_cloudwatch_log_group logs {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = "${var.cloudwatch_log_group_retention_in_days}"
}

resource aws_lambda_function lambda {
  description      = "${local.lambda_description}"
  filename         = "${path.module}/package.zip"
  function_name    = "${local.lambda_function_name}"
  handler          = "index.handler"
  kms_key_arn      = "${var.kms_key_arn}"
  memory_size      = "${var.lambda_memory_size}"
  role             = "${data.aws_iam_role.role.arn}"
  runtime          = "nodejs8.10"
  source_code_hash = "${base64sha256(file("${path.module}/package.zip"))}"
  tags             = "${var.lambda_tags}"
  timeout          = "${var.lambda_timeout}"

  environment {
    variables {
      AWS_SECRET = "${var.secret_name}"
      RESPONSE   = "${jsonencode(var.response)}"
      TOKEN      = "${var.token}"
    }
  }
}

resource aws_lambda_permission invoke {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic.arn}"
}

resource aws_sns_topic topic {
  name = "slack_slash_${var.slash_command}"
}

resource aws_sns_topic_subscription subscription {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
}
