output "request_urls" {
  description = "Slackbot Request URLs."

  value {
    slash_command = "${module.slash_command.request_url}"
    events        = "${module.slackbot.events_request_url}"
    callbacks     = "${module.slackbot.callbacks_request_url}"
  }
}

output "sns_topic_arns" {
  description = "SNS topics created."
  value       = [
    "${module.slackbot.callback_topic_arns}",
    "${module.slackbot.event_topic_arns}"
  ]
}
