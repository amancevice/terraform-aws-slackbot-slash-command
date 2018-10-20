output sns_topic {
  description = "Name of SNS topic trigger."
  value       = "${aws_sns_topic.trigger.name}"
}

output lambda_name {
  description = "Lambda function name."
  value       = "${aws_lambda_function.lambda.function_name}"
}
