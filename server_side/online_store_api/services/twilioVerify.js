const twilio = require('twilio');

function hasTwilioEnv() {
  return !!(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_VERIFY_SERVICE_SID);
}

function getClient() {
  return twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
}

async function sendVerification(phone) {
  if (!hasTwilioEnv()) throw new Error('Twilio env not configured');
  const client = getClient();
  return client.verify.v2
    .services(process.env.TWILIO_VERIFY_SERVICE_SID)
    .verifications.create({ to: phone, channel: 'sms' });
}

async function checkVerification(phone, code) {
  if (!hasTwilioEnv()) throw new Error('Twilio env not configured');
  const client = getClient();
  return client.verify.v2
    .services(process.env.TWILIO_VERIFY_SERVICE_SID)
    .verificationChecks.create({ to: phone, code });
}

module.exports = { hasTwilioEnv, sendVerification, checkVerification };
