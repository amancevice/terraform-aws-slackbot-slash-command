output "request_url" {
  description = "Slash Command Request URL."
  value       = "${local.api_invoke_url}/slash-commands/${aws_api_gateway_resource.resource.path_part}"
}
