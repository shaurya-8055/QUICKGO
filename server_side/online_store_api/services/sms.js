// services/sms.js
const twilio = require('twilio');

// optional: use env vars TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE
const client = new twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

async function sendSMS(to, message) {
  try {
    const res = await client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE,
      to,
    });
    console.log('SMS sent:', res.sid);
    return res.sid;
  } catch (err) {
    console.error('SMS sending failed:', err.message);
    throw err;
  }
}

module.exports = sendSMS;
