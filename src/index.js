const { WebClient } = require('@slack/client');

const response = JSON.parse(process.env.RESPONSE || '{}');
const response_type = process.env.RESPONSE_TYPE || 'ephemeral';
const secret = process.env.SECRET;
const token = process.env.TOKEN || 'BOT_ACCESS_TOKEN';

let secrets, slack;

/**
 * Get Slack tokens from memory or AWS SecretsManager.
 */
function getSecrets() {
  return new Promise((resolve, reject) => {
    if (secrets) {
      resolve(secrets);
    } else {
      console.log(`FETCH ${secret}`);
      const AWS = require('aws-sdk');
      const secretsmanager = new AWS.SecretsManager();
      secretsmanager.getSecretValue({SecretId: secret}, (err, data) => {
        if (err) {
          reject(err);
        } else {
          secrets = JSON.parse(data.SecretString);
          console.log(`RECEIVED ${secret}`);
          resolve(secrets);
        }
      });
    }
  });
}

/**
 * Get Slack client from memory or create.
 */
function getSlack() {
  return new Promise((resolve, reject) => {
    if (slack) {
      resolve(slack);
    } else {
      slack = new WebClient(secrets[token]);
      resolve(slack);
    }
  });
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
  response.channel = response.channel || payload.channel_id;
  if (response_type === 'dialog') {
    console.log(`DIALOG ${JSON.stringify(response)}`);
    return slack.dialog.open({
      trigger_id: payload.trigger_id,
      dialog: response
    });
  } else if (response_type == 'ephemeral') {
    console.log(`EPHEMERAL ${JSON.stringify(response)}`);
    return slack.chat.postEphemeral(response);
  } else {
    console.log(`IN_CHANNEL ${JSON.stringify(response)}`);
    return slack.chat.postMessage(response);
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
  return Promise.resolve().then(getSecrets).then(getSlack).then(() => {
    return Promise.all(getPayload(event).map(processEvent));
  }).then((res) => {
    callback();
  }).catch((err) => {
    console.error(`ERROR ${err}`);
    callback(err, {statusCode: '400', body: err.message});
  });
}

exports.handler = handler;
