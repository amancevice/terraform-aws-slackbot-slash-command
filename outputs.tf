output sns_topic_arn {
  description = "SNS topic ARN."
  value       = "${aws_sns_topic.trigger.name}"
}

output sns_topic_name {
  description = "SNS topic name."
  value       = "${aws_sns_topic.trigger.name}"
}

output lambda_arn {
  description = "Lambda function ARN."
  value       = "${aws_lambda_function.lambda.arn}"
}

output lambda_name {
  description = "Lambda function name."
  value       = "${aws_lambda_function.lambda.function_name}"
}
