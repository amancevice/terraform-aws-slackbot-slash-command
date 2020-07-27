const AWS           = require('aws-sdk');
const axios         = require('axios');
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
    console.log(`${response.type.toUpperCase()} ${payload.trigger_id}`);
    return slack.dialog.open({dialog: response, trigger_id: payload.trigger_id});
  }

  // Modal response
  else if (response.type === 'modal') {
    console.log(`${response.type.toUpperCase()} ${payload.trigger_id}`);
    return slack.views.open({view: response, trigger_id: payload.trigger_id});
  }

  // Direct response
  else {
    console.log(`POST ${payload.response_url}`);
    response.channel = payload.channel_id;
    return axios.post(payload.response_url, response);
  }
};

exports.handler = async (event) => {
  console.log(`EVENT ${JSON.stringify(event)}`);
  await Promise.resolve(slack || getSlack({SecretId: AWS_SECRET}));
  await Promise.all(event.Records.map(handle));
};
