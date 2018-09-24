output "sns_topic" {
  description = "Name of SNS topic trigger."
  value       = "${aws_sns_topic.trigger.name}"
}

output "lambda_function" {
  description = "Name of lambda function SNS handler."
  value       = "${aws_lambda_function.lambda.function_name}"
}
