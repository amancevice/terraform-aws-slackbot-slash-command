const response = JSON.parse(process.env.RESPONSE || '{}');
const secret = process.env.AWS_SECRET;
const token = process.env.TOKEN || 'BOT_TOKEN';

let secrets;

/**
 * Get Slack tokens from memory or AWS SecretsManager.
 */
function getSecrets() {
  if (secrets) {
    console.log(`CACHED ${secret}`);
    return Promise.resolve(secrets);
  } else {
    console.log(`FETCH ${secret}`);
    const AWS = require('aws-sdk');
    const secretsmanager = new AWS.SecretsManager();
    return secretsmanager.getSecretValue({
      SecretId: secret
    }).promise().then((data) => {
      secrets = JSON.parse(data.SecretString);
      return secrets;
    });
  }
}

/**
 * Get payload from event.
 *
 * @param {object} event Event object.
 */
function getPayload(event) {
  return event.Records.map((record) => {
    return JSON.parse(Buffer.from(record.Sns.Message, 'base64'));
  });
}

/**
 * Process Slash Command.
 *
 * @param {object} body Slack slash command payload.
 */
function processEvent(payload) {
  response.channel = payload.channel_id;
  if (response.response_type === 'dialog') {
    console.log(`DIALOG ${JSON.stringify(response)}`);
    const { WebClient } = require('@slack/client');
    const slack = new WebClient(secrets[token]);
    return slack.dialog.open({
      trigger_id: payload.trigger_id,
      dialog: response
    });
  } else {
    const rp = require('request-promise');
    const options = {
      method: 'POST',
      uri: payload.response_url,
      body: response,
      json: true
    };
    console.log(`POST ${JSON.stringify(options)}`);
    return rp(options);
  }
}

/**
 * AWS Lambda handler for slash commands.
 *
 * @param {object} event Event object.
 * @param {object} context Event context.
 * @param {function} callback Lambda callback function.
 */
function handler(event, context, callback) {
  console.log(`EVENT ${JSON.stringify(event)}`);
  return getSecrets().then(() => {
    return Promise.all(getPayload(event).map(processEvent));
  }).then((res) => {
    callback();
  }).catch((err) => {
    console.error(`ERROR ${err}`);
    callback(err, {statusCode: '400', body: err.message});
  });
}

exports.handler = handler;
