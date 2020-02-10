output lambda {
  description = "Slash command Lambda function."
  value       = aws_lambda_function.lambda
}

output logs {
  description = "Lambda function CloudWatch log group."
  value       = aws_cloudwatch_log_group.logs
}

output permission {
  description = "Lambda invocation permission."
  value       = aws_lambda_permission.invoke
}

output subscription {
  description = "SNS subscription."
  value       = aws_sns_topic_subscription.subscription
}
