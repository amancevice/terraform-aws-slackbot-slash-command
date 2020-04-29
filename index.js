const AWS           = require('aws-sdk');
const request       = require('request-promise');
const { WebClient } = require('@slack/web-api');

const AWS_SECRET = process.env.AWS_SECRET;
const RESPONSE   = process.env.RESPONSE;

const secretsmanager = new AWS.SecretsManager();

let slack;

const getSlack = async (options) => {
  const secret = await secretsmanager.getSecretValue(options).promise();
  slack = new WebClient(JSON.parse(secret.SecretString).SLACK_TOKEN);
  return slack;
};

const handle = async (record) => {
  const response = JSON.parse(RESPONSE || '{}');
  const payload  = JSON.parse(record.Sns.Message);

  // Dialog response (deprecated)
  if (response.response_type === 'dialog') {
    return slack.dialog.open({
      dialog:     response,
      trigger_id: payload.trigger_id,
    });
  }

  // Modal response
  if (response.type === 'modal') {
    return slack.views.open({
      trigger_id: payload.trigger_id,
      view:       response,
    });
  }

  // Normal response
  response.channel = payload.channel_id;
  return request({
    body:   response,
    json:   true,
    method: 'POST',
    uri:    payload.response_url,
  });
};

exports.handler = async (event) => {
  console.log(`EVENT ${JSON.stringify(event)}`);
  await Promise.resolve(slack || getSlack({SecretId: AWS_SECRET}));
  return await Promise.all(event.Records.map(handle));
};
