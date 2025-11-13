// services/twilioVerify.js
const twilio = require('twilio');
require('dotenv').config();

// Check if Twilio environment variables are set
function hasTwilioEnv() {
  return !!(process.env.TWILIO_ACCOUNT_SID && 
           process.env.TWILIO_AUTH_TOKEN && 
           process.env.TWILIO_VERIFY_SERVICE_SID);
}

const client = hasTwilioEnv() ? new twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN) : null;
const serviceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

// Send OTP
async function sendVerification(phone) {
  if (!hasTwilioEnv()) {
    throw new Error('Twilio environment variables not set');
  }
  
  try {
    const verification = await client.verify.v2
      .services(serviceSid)
      .verifications.create({ to: phone, channel: 'sms' });

    console.log('OTP sent:', verification.sid);
    return { success: true, sid: verification.sid, status: verification.status };
  } catch (err) {
    console.error('Error sending OTP:', err.message);
    throw err;
  }
}

// Verify OTP
async function checkVerification(phone, code) {
  if (!hasTwilioEnv()) {
    throw new Error('Twilio environment variables not set');
  }
  
  try {
    const verificationCheck = await client.verify.v2
      .services(serviceSid)
      .verificationChecks.create({ to: phone, code });

    return {
      success: verificationCheck.status === 'approved',
      status: verificationCheck.status,
    };
  } catch (err) {
    console.error('Error verifying OTP:', err.message);
    throw err;
  }
}

module.exports = { hasTwilioEnv, sendVerification, checkVerification };
