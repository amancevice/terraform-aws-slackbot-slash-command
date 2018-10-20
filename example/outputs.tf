output sns_topic {
  description = "Name of SNS topic trigger."
  value       = "${module.slash_command.sns_topic}"
}

output lambda_name {
  description = "Lambda function name."
  value       = "${module.slash_command.lambda_name}"
}
