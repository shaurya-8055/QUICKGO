// services/email.js
// Email delivery via SMTP (Gmail by default) using nodemailer.
const nodemailer = require('nodemailer');
require('dotenv').config();

// Check if email environment variables are configured
function hasEmailEnv() {
  return !!(process.env.EMAIL_HOST &&
            process.env.EMAIL_PORT &&
            process.env.EMAIL_USER &&
            process.env.EMAIL_PASS);
}

let transporter = null;
function getTransporter() {
  if (transporter) return transporter;
  if (!hasEmailEnv()) return null;
  transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT) || 587,
    // 465 = implicit TLS, otherwise STARTTLS on 587
    secure: Number(process.env.EMAIL_PORT) === 465,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS, // Gmail requires an App Password, not the account password
    },
  });
  return transporter;
}

// Send a generic email. Returns { ok, fallback?, message? }.
async function sendEmail({ to, subject, text, html }) {
  const tx = getTransporter();
  if (!tx) {
    // No email configured: log instead of failing so OTP flows still work in dev.
    console.warn('[EMAIL] Not configured (EMAIL_* missing). Would have sent:', { to, subject, text });
    return { ok: true, fallback: true };
  }
  try {
    const info = await tx.sendMail({
      from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
      to,
      subject,
      text,
      html,
    });
    console.log(`[EMAIL] Sent to ${to} messageId=${info.messageId}`);
    return { ok: true };
  } catch (err) {
    console.error(`[EMAIL][ERROR] to ${to}:`, err.message);
    return { ok: false, message: err.message };
  }
}

// Send an OTP code email with a simple branded template.
async function sendOtpEmail(to, code, purpose = 'verification') {
  const subject = `Your QuickGo ${purpose} code`;
  const text = `Your QuickGo ${purpose} code is ${code}. It expires in 10 minutes. If you did not request this, ignore this email.`;
  const html = `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:24px;border:1px solid #eee;border-radius:12px">
      <h2 style="color:#FF7F2A;margin:0 0 8px">QuickGo</h2>
      <p style="font-size:15px;color:#333">Use the code below to complete your ${purpose}:</p>
      <div style="font-size:32px;font-weight:700;letter-spacing:8px;text-align:center;background:#f6f6f6;padding:16px;border-radius:8px;margin:16px 0">${code}</div>
      <p style="font-size:13px;color:#777">This code expires in 10 minutes. If you didn't request it, you can safely ignore this email.</p>
    </div>`;
  return sendEmail({ to, subject, text, html });
}

module.exports = { hasEmailEnv, sendEmail, sendOtpEmail };
