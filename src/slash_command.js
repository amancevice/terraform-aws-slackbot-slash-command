const AWS = require('aws-sdk');
const qs = require('querystring');
const { WebClient } = require('@slack/client');

const auth = JSON.parse(process.env.AUTH);
const encrypted_verificaton_token = process.env.ENCRYPTED_VERIFICATION_TOKEN;
const encrypted_web_api_token = process.env.ENCRYPTED_WEB_API_TOKEN;
const response_type = process.env.RESPONSE_TYPE;
const response = JSON.parse(process.env.RESPONSE);

let verification_token, web_api_token;

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
 * @param {object} event Lambda event object.
 * @param {function} callback Lambda event callback.
 */
function processEvent(event, callback) {
  const params = qs.parse(event.body);

  // Bad token
  if (params.token !== verification_token) {
    console.error(`Request token (${params.token}) does not match expected`);
    return callback('Invalid request token');
  }

  // Bad channel
  else if (!verifyChannel(params.channel_id)) {
    console.log(`CHANNEL PERMISSION DENIED`);
    callback(null, auth.channels.permission_denied);
  }

  // Bad user
  else if (!verifyUser(params.user_id)) {
    console.log(`USER PERMISSION DENIED`);
    callback(null, auth.users.permission_denied);
  }

  // Dialog response
  else if (response_type === 'dialog') {
    console.log(`DIALOG ${JSON.stringify(response)}`);
    const slack = new WebClient(web_api_token);
    slack.dialog.open({
        trigger_id: params.trigger_id,
        dialog: response
      })
      .then((res) => callback())
      .catch((err) => callback(err));
  }

  // Normal response
  else {
    console.log(`RESPONSE ${JSON.stringify(response)}`);
    callback(null, response);
  }
}

/**
 * Responds to any HTTP request that can provide a "message" field in the body.
 *
 * @param {object} event AWS Lambda event.
 * @param {object} context AWS Lambda context.
 * @param {function} callback AWS Lambda callback function.
 */
exports.handler = (event, context, callback) => {
  const done = (err, res) => callback(null, {
    statusCode: err ? '400' : '200',
    body: err ? (err.message || err) : JSON.stringify(res),
    headers: {
      'Content-Type': 'application/json',
    }
  });

  // Container reuse, simply process the event with the key in memory
  if (verification_token && web_api_token) {
    processEvent(event, done);
  }

  // Decrypt the token and process
  else if (!encrypted_verificaton_token || encrypted_verificaton_token === '<encrypted-token-here>') {
    done('Verification token has not been set.');
  }

  else if (!encrypted_web_api_token || encrypted_web_api_token === '<encrypted-token-here>') {
    done('Web API token has not been set.');
  }

  else {
    const verification_ciphertext = { CiphertextBlob: new Buffer(encrypted_verificaton_token, 'base64') };
    const web_api_ciphertext = { CiphertextBlob: new Buffer(encrypted_web_api_token, 'base64') };
    const kms = new AWS.KMS();
    kms.decrypt(verification_ciphertext, (err, data) => {
      if (err) {
        console.log('Decrypt error:', err);
        return done(err);
      }
      verification_token = data.Plaintext.toString('ascii');
      kms.decrypt(web_api_ciphertext, (err, data) => {
        if (err) {
          console.log('Decrypt error:', err);
          return done(err);
        }
        web_api_token = data.Plaintext.toString('ascii');
        processEvent(event, done);
      });
    });
  }
};
