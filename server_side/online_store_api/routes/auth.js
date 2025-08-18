const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');
const rateLimit = require('express-rate-limit');
const User = require('../model/user');
const { generateOtp, hashOtp, verifyOtp } = require('../util/otp');
const { sendSms } = require('../services/sms');
const { hasTwilioEnv, sendVerification, checkVerification } = require('../services/twilioVerify');
const { auth } = require('../middleware/auth');

function normalizePhone(raw) {
  if (!raw) return null;
  const p = String(raw).replace(/[\s-]/g, '');
  if (p.startsWith('+')) return p;
  const cc = process.env.DEFAULT_COUNTRY_CODE; // e.g. +91
  if (cc) return `${cc}${p}`;
  return null; // require E.164 when no default is set
}

async function sendOtpWithFallback({ user, phone, purpose }) {
  const to = normalizePhone(phone);
  if (!to) {
    return { ok: false, message: 'Phone must include country code like +919012345678 or set DEFAULT_COUNTRY_CODE in .env' };
  }
  if (hasTwilioEnv()) {
    try {
    const resp = await sendVerification(to);
    console.log(`[OTP][Twilio] Sent verification to ${to} purpose=${purpose} status=${resp?.status}`);
    return { ok: true };
    } catch (e) {
    console.error(`[OTP][Twilio][ERROR] to ${to} purpose=${purpose}:`, e?.status || '', e?.code || '', e?.message || e);
      // fall through to local OTP
    }
  }
  // Local OTP fallback
  const otp = generateOtp();
  if (user) {
    user.otp = { codeHash: await hashOtp(otp), purpose, expiresAt: new Date(Date.now() + 10 * 60 * 1000) };
    await user.save();
  }
  console.log(`[OTP][Local] Generated fallback OTP for ${to} purpose=${purpose}`);
  await sendSms(to, `Your ${purpose} code is ${otp}`);
  return { ok: true, fallback: true };
}

const router = express.Router();

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 50 });
const otpLimiter = rateLimit({ windowMs: 10 * 60 * 1000, max: 10 });

function signToken(user) {
  const payload = { id: user._id, role: user.role, username: user.username, email: user.email, phone: user.phone };
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
}

// Register with password + phone; requires OTP verification after
router.post('/register', asyncHandler(async (req, res) => {
  let { username, email, phone, password } = req.body || {};
  if (!username && !email) return res.status(400).json({ success: false, message: 'username or email is required' });
  if (!phone) return res.status(400).json({ success: false, message: 'phone is required' });
  if (!password) return res.status(400).json({ success: false, message: 'password is required' });

  username = username?.toLowerCase();
  email = email?.toLowerCase();
  const normalizedPhone = normalizePhone(phone);
  if (!normalizedPhone) return res.status(400).json({ success: false, message: 'Phone must include country code like +919012345678 or set DEFAULT_COUNTRY_CODE' });

  // If phone already exists, treat as login via OTP
  const existingByPhone = await User.findOne({ $or: [{ phone }, { phone: normalizedPhone }] });
  if (existingByPhone) {
    const result = await sendOtpWithFallback({ user: existingByPhone, phone: normalizedPhone, purpose: 'login' });
    if (!result.ok) return res.status(400).json({ success: false, message: result.message });
    return res.json({ success: true, message: 'Phone already registered. OTP sent for login.', data: null });
  }

  // Block duplicate username/email if used by someone else
  const existingById = await User.findOne({ $or: [ { username }, { email } ] });
  if (existingById) return res.status(409).json({ success: false, message: 'Username or email already in use' });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ username, email, phone: normalizedPhone, passwordHash, isPhoneVerified: false });

  // Create OTP for signup
  {
  const result = await sendOtpWithFallback({ user, phone: normalizedPhone, purpose: 'signup' });
    if (!result.ok) return res.status(400).json({ success: false, message: result.message });
  }
  return res.json({ success: true, message: 'Registered. OTP sent to phone for verification.', data: null });
}));

// Verify OTP (signup/login)
router.post('/verify-otp', otpLimiter, asyncHandler(async (req, res) => {
  const { phone, code } = req.body || {};
  if (!phone || !code) return res.status(400).json({ success: false, message: 'phone and code required' });

  const to = normalizePhone(phone);
  if (!to) return res.status(400).json({ success: false, message: 'Phone must include country code like +919012345678 or set DEFAULT_COUNTRY_CODE in .env' });

  if (hasTwilioEnv()) {
    const result = await checkVerification(to, code);
    if (result.status !== 'approved') return res.status(400).json({ success: false, message: 'Invalid OTP' });
    const user = await User.findOne({ $or: [{ phone }, { phone: to }] });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    user.isPhoneVerified = true;
    user.otp = undefined;
    await user.save();
    const token = signToken(user);
    return res.json({ success: true, message: 'OTP verified', data: { user, token } });
  }

  const user = await User.findOne({ $or: [{ phone }, { phone: to }] });
  if (!user || !user.otp || !user.otp.codeHash) {
    return res.status(400).json({ success: false, message: 'No OTP pending' });
  }
  if (user.otp.expiresAt && user.otp.expiresAt < new Date()) {
    user.otp = undefined; await user.save();
    return res.status(400).json({ success: false, message: 'OTP expired' });
  }
  const ok = await verifyOtp(code, user.otp.codeHash);
  if (!ok) return res.status(400).json({ success: false, message: 'Invalid OTP' });
  user.isPhoneVerified = true;
  user.otp = undefined;
  await user.save();
  const token = signToken(user);
  return res.json({ success: true, message: 'OTP verified', data: { user, token } });
}));

// Request OTP for login (phone only)
router.post('/request-otp', otpLimiter, asyncHandler(async (req, res) => {
  const { phone } = req.body || {};
  if (!phone) return res.status(400).json({ success: false, message: 'phone required' });
  const to = normalizePhone(phone);
  if (!to) return res.status(400).json({ success: false, message: 'Phone must include country code like +919012345678 or set DEFAULT_COUNTRY_CODE' });
  const user = await User.findOne({ $or: [{ phone }, { phone: to }] });
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });
  const result = await sendOtpWithFallback({ user, phone: to, purpose: 'login' });
  if (!result.ok) return res.status(400).json({ success: false, message: result.message });
  return res.json({ success: true, message: 'OTP sent', data: null });
}));

// Password login with username/email/phone + password
router.post('/login', loginLimiter, asyncHandler(async (req, res) => {
  const { identifier, password } = req.body || {};
  if (!identifier || !password) return res.status(400).json({ success: false, message: 'identifier and password required' });
  const identLower = (identifier || '').toLowerCase();
  const maybeLocalUsername = identLower.includes('@') ? identLower.split('@')[0] : null;
  let user = await User.findOne({ $or: [
    { username: identLower },
    { email: identLower },
    { phone: identifier },
    { phone: normalizePhone(identifier) },
  { name: identLower },
  ...(maybeLocalUsername ? [{ username: maybeLocalUsername }, { name: maybeLocalUsername }] : [])
  ] });
  if (!user) return res.status(401).json({ success: false, message: 'Invalid credentials' });

  if (user.passwordHash) {
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ success: false, message: 'Invalid credentials' });
  } else {
    // Legacy migration: check raw legacy password
    const legacy = await User.findById(user._id).lean();
    if (!legacy || !legacy.password || legacy.password !== password) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const newHash = await bcrypt.hash(password, 10);
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const setOps = { passwordHash: newHash };
    if (!legacy.username && legacy.name) setOps.username = String(legacy.name).toLowerCase();
    if (!legacy.email && emailRegex.test(identifier)) setOps.email = identLower;
    await User.updateOne({ _id: user._id }, { $set: setOps, $unset: { password: '', name: '' } });
    user = await User.findById(user._id);
  }

  const token = signToken(user);
  res.json({ success: true, message: 'Login successful', data: { user, token } });
}));

module.exports = router;

// Protected: get current user profile (token required)
router.get('/me', auth(), asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id).lean();
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });
  res.json({ success: true, message: 'OK', data: { user } });
}));
