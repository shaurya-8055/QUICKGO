// services/email.js
// Email delivery. Prefers Brevo's transactional HTTP API (reliable on hosts
// like Render where outbound SMTP is often throttled/blocked); falls back to
// SMTP via nodemailer if Brevo isn't configured or a send fails.
const axios = require('axios');
const nodemailer = require('nodemailer');
require('dotenv').config();

const BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email';

function hasBrevo() {
  return !!process.env.BREVO_API_KEY;
}

// Check if SMTP environment variables are configured
function hasEmailEnv() {
  return !!(process.env.EMAIL_HOST &&
            process.env.EMAIL_PORT &&
            process.env.EMAIL_USER &&
            process.env.EMAIL_PASS);
}

// Build Brevo's sender object from EMAIL_FROM. Accepts "Name <email>" or a
// plain address. NOTE: this address/domain must be a verified sender in Brevo,
// otherwise the API rejects the send.
function parseSender() {
  const from = process.env.EMAIL_FROM || process.env.EMAIL_USER || '';
  const match = from.match(/^\s*(.*?)\s*<\s*([^>]+)\s*>\s*$/);
  if (match) return { name: match[1] || 'QuickGo', email: match[2] };
  return { name: process.env.EMAIL_FROM_NAME || 'QuickGo', email: from };
}

async function sendViaBrevo({ to, subject, text, html }) {
  const res = await axios.post(
    BREVO_API_URL,
    {
      sender: parseSender(),
      to: [{ email: to }],
      subject,
      htmlContent: html || undefined,
      textContent: text || undefined,
    },
    {
      headers: {
        'api-key': process.env.BREVO_API_KEY,
        'content-type': 'application/json',
        accept: 'application/json',
      },
      timeout: 15000,
    }
  );
  return res.data; // { messageId }
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
// Tries Brevo first, then SMTP, then logs (so dev flows don't break).
async function sendEmail({ to, subject, text, html }) {
  // 1) Brevo transactional API (preferred)
  if (hasBrevo()) {
    try {
      const data = await sendViaBrevo({ to, subject, text, html });
      console.log(`[EMAIL] Sent via Brevo to ${to} messageId=${data && data.messageId}`);
      return { ok: true };
    } catch (err) {
      const detail = err.response && err.response.data
        ? JSON.stringify(err.response.data)
        : err.message;
      console.error(`[EMAIL][BREVO][ERROR] to ${to}: ${detail}`);
      // fall through to SMTP if it's configured
    }
  }

  // 2) SMTP fallback via nodemailer
  const tx = getTransporter();
  if (!tx) {
    // Nothing configured: log instead of failing so OTP flows still work in dev.
    console.warn('[EMAIL] Not configured (BREVO_API_KEY / EMAIL_* missing). Would have sent:', { to, subject, text });
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
    console.log(`[EMAIL] Sent via SMTP to ${to} messageId=${info.messageId}`);
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

module.exports = { hasEmailEnv, hasBrevo, sendEmail, sendOtpEmail };
