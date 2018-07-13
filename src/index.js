const auth = JSON.parse(process.env.AUTH);

let signing_secret, access_token;

/**
 * Get Slack tokens from memory or AWS SecretsManager.
 */
function getSigningSecret() {
  return new Promise((resolve, reject) => {
    if (signing_secret) {
      resolve(signing_secret);
    } else {
      const secret = process.env.SECRET;
      console.log(`FETCH ${secret}`);
      const AWS = require('aws-sdk');
      const secrets = new AWS.SecretsManager();
      secrets.getSecretValue({SecretId: secret}, (err, data) => {
        if (err) {
          reject(err);
        } else {
          const secrets = JSON.parse(data.SecretString);
          signing_secret = secrets.SIGNING_SECRET;
          access_token = secrets.BOT_ACCESS_TOKEN;
          console.log(`RECEIVED SIGNING SECRET`);
          resolve(secrets);
        }
      });
    }
  });
}

/**
 * Verify request signature.
 *
 * @param {object} event AWS API Gateway event.
 */
function verifyRequest(event) {
  return new Promise((resolve, reject) => {
    const crypto = require('crypto');
    const qs = require('querystring');
    const signing_version = process.env.SIGNING_VERSION;
    const payload = qs.parse(event.body);
    const ts = event.headers['X-Slack-Request-Timestamp']
    const req = event.headers['X-Slack-Signature'];
    const hmac = crypto.createHmac('sha256', signing_secret);
    const data = `${signing_version}:${event.headers['X-Slack-Request-Timestamp']}:${event.body}`;
    const sig = `${signing_version}=${hmac.update(data).digest('hex')}`;
    console.log(`SIGNATURES ${JSON.stringify({request: req, calculated: sig})}`);
    if (Math.abs(new Date()/1000 - ts) > 60 * 5) {
      reject('Request too old');
    } else if (req !== sig) {
      reject('Signatures do not match');
    } else if (!verifyChannel(payload.channel_id)) {
      reject(auth.channels.permission_denied);
    } else if (!verifyUser(payload.user_id)) {
      reject(auth.users.permission_denied);
    } else {
      resolve(payload);
    }
  });
}

/**
 * Verify slash command was executed from authorized channel.
 *
 * @param {string} channel Slack channel ID
 */
function verifyChannel(channel) {
  return auth.channels.exclude.indexOf(channel) < 0 &&
        (auth.channels.include.length == 0 ||
         auth.channels.include.indexOf(channel) >= 0);
}

/**
 * Verify user is authorized to execute slash command.
 *
 * @param {string} channel Slack channel ID
 */
function verifyUser(user) {
  return auth.users.exclude.indexOf(user) < 0 &&
        (auth.users.include.length == 0 ||
         auth.users.include.indexOf(user) >= 0);
}

/**
 * Process Slash Command.
 *
 * @param {object} body Slack slash command payload.
 */
function processEvent(payload) {
  return new Promise((resolve, reject) => {
    const response = JSON.parse(process.env.RESPONSE);
    const response_type = process.env.RESPONSE_TYPE;
    if (response_type === 'dialog') {
      console.log(`DIALOG ${JSON.stringify(response)}`);
      const { WebClient } = require('@slack/client');
      const slack = new WebClient(access_token);
      slack.dialog.open({
        trigger_id: payload.trigger_id,
        dialog: response
      }).then((res) => {
        resolve();
      });
    } else {
      console.log(`RESPONSE ${JSON.stringify(response)}`);
      resolve(response);
    }
  });
}

/**
 * AWS Lambda handler for slash commands.
 *
 * @param {object} event AWS Lambda event.
 * @param {object} context AWS Lambda context.
 * @param {function} callback AWS Lambda callback function.
 */
function handler(event, context, callback) {
  getSigningSecret().then((res) => {
    return verifyRequest(event);
  }).then((res) => {
    return processEvent(res);
  }).then((res) => {
    callback(null, {
      statusCode: '200',
      body: JSON.stringify(res),
      headers: {'Content-Type': 'application/json'}
    });
  }).catch((err) => {
    console.error(`ERROR ${err}`);
    callback(err, {statusCode: '400', body: err.message});
  });
};

exports.handler = handler;
