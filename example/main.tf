provider "aws" {
  region = "us-east-1"
}

module "slackbot" {
  source                   = "amancevice/slackbot/aws"
  callback_ids             = ["my_callback_1"]
  event_types              = ["channel_rename"]
  slack_verification_token = "${var.slack_verification_token}"
}

module "slash_command" {
  source                   = "amancevice/slack-slash-command/aws"
  api_execution_arn        = "${module.socialismbot.api_execution_arn}"
  api_invoke_url           = "${module.socialismbot.api_invoke_url}"
  api_name                 = "${module.socialismbot.api_name}"
  api_parent_id            = "${module.socialismbot.slash_commands_resource_id}"
  kms_key_id               = "${module.socialismbot.kms_key_id}"
  slack_verification_token = "${var.slack_verification_token}"
  slack_web_api_token      = "${var.slack_web_api_token}"
  slash_command            = "mycommand"

  response {
    text = ":sparkles: This will be the response of the Slash Command."
  }
}
