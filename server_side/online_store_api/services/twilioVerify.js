// services/twilioVerify.js
const twilio = require('twilio');
require('dotenv').config();

const client = new twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
const serviceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

// Send OTP
async function sendOTP(phone) {
  try {
    const verification = await client.verify.v2
      .services(serviceSid)
      .verifications.create({ to: phone, channel: 'sms' });

    console.log('OTP sent:', verification.sid);
    return { success: true, sid: verification.sid };
  } catch (err) {
    console.error('Error sending OTP:', err.message);
    throw err;
  }
}

// Verify OTP
async function verifyOTP(phone, code) {
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

module.exports = { sendOTP, verifyOTP };
