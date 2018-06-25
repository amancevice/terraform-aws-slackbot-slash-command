output "encrypted_slack_verification_token" {
  description = "Encrypted Slack verification token"
  value       = "${local.encrypted_slack_verification_token}"
}

output "encrypted_slack_web_api_token" {
  description = "Encrypted Slack verification token"
  value       = "${local.encrypted_slack_web_api_token}"
}

output "request_url" {
  description = "Slash Command Request URL."
  value       = "${var.api_invoke_url}/slash-commands/${aws_api_gateway_resource.resource.path_part}"
}
