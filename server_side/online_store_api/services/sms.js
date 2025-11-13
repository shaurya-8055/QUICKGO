// services/sms.js
const twilio = require('twilio');

// optional: use env vars TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE
const client = new twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

async function sendSms(to, message) {
  try {
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      console.log(`[SMS] Would send to ${to}: ${message}`);
      return 'mock_message_id';
    }
    
    const res = await client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE,
      to,
    });
    console.log('SMS sent:', res.sid);
    return res.sid;
  } catch (err) {
    console.error('SMS sending failed:', err.message);
    // Don't throw in development - just log
    console.log(`[SMS FALLBACK] Would send to ${to}: ${message}`);
    return 'fallback_message_id';
  }
}

module.exports = { sendSms };
