const axios = require('axios');

/**
 * Pluggable SMS sender.
 * In production, replace the implementation with your SMS gateway HTTP API.
 * Export a single function sendSms(phone, message) that resolves true/false.
 */
async function sendSms(phone, message) {
  try {
    // Example placeholder: log only. Replace with real SMS provider.
    if (process.env.NODE_ENV !== 'production') {
      console.log(`[DEV SMS] to ${phone}: ${message}`);
      return true;
    }
    // Example generic POST if you have a gateway:
    // await axios.post(process.env.SMS_API_URL, { to: phone, message, apiKey: process.env.SMS_API_KEY });
    return true;
  } catch (e) {
    console.error('SMS send failed', e.message);
    return false;
  }
}

module.exports = { sendSms };
