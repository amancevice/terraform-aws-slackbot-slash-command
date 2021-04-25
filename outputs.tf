output "lambda" {
  description = "Slash command Lambda function"
  value       = aws_lambda_function.lambda
}

output "logs" {
  description = "Lambda function CloudWatch log group"
  value       = aws_cloudwatch_log_group.logs
}

output "rule" {
  description = "EventBridge rule"
  value       = aws_cloudwatch_event_rule.rule
}

output "target" {
  description = "EventBridge rule"
  value       = aws_cloudwatch_event_target.target
}
