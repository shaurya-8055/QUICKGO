const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');
const rateLimit = require('express-rate-limit');
const Worker = require('../model/worker');
const { generateOtp, hashOtp, verifyOtp } = require('../util/otp');
const { sendOtpEmail } = require('../services/email');
const { verifyGoogleIdToken } = require('../services/googleAuth');
const { workerAuth } = require('../middleware/workerAuth');
const crypto = require('crypto');

function normalizePhone(raw) {
  if (!raw) return null;
  const p = String(raw).replace(/[\s-]/g, '');
  if (p.startsWith('+')) return p;
  const cc = process.env.DEFAULT_COUNTRY_CODE; // e.g. +91
  if (cc) return `${cc}${p}`;
  return null;
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Generate an email OTP for a worker, persist its hash, and email it.
async function sendWorkerOtpEmail({ worker, email, purpose }) {
  const otp = generateOtp();
  worker.otp = {
    codeHash: await hashOtp(otp),
    purpose,
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  };
  await worker.save();
  const result = await sendOtpEmail(email, otp, purpose);
  return result;
}

const router = express.Router();

// Rate limiting
const strictLoginLimiter = rateLimit({ 
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: { success: false, message: 'Too many login attempts. Try again in 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const otpLimiter = rateLimit({ 
  windowMs: 10 * 60 * 1000, 
  max: 10,
  message: { success: false, message: 'Too many OTP requests. Try again in 10 minutes.' }
});

const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 3,
  message: { success: false, message: 'Too many password reset attempts. Try again in 1 hour.' }
});

// Token generation
function signTokens(worker) {
  const payload = { 
    id: worker._id, 
    role: 'worker',
    username: worker.username, 
    email: worker.email, 
    phone: worker.phone,
    name: worker.name,
    tokenVersion: worker.tokenVersion || 0
  };
  
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' });
  const refreshToken = jwt.sign(
    { id: worker._id, role: 'worker', tokenVersion: worker.tokenVersion || 0 }, 
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, 
    { expiresIn: '7d' }
  );
  
  return { accessToken, refreshToken };
}

// Password validation
function validatePassword(password) {
  const minLength = 8;
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumbers = /\d/.test(password);
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  
  if (password.length < minLength) {
    return { valid: false, message: 'Password must be at least 8 characters long' };
  }
  if (!hasUpperCase || !hasLowerCase) {
    return { valid: false, message: 'Password must contain both uppercase and lowercase letters' };
  }
  if (!hasNumbers) {
    return { valid: false, message: 'Password must contain at least one number' };
  }
  if (!hasSpecialChar) {
    return { valid: false, message: 'Password must contain at least one special character' };
  }
  
  return { valid: true };
}

// ================ WORKER REGISTRATION ================
router.post('/register', asyncHandler(async (req, res) => {
  let { 
    name, 
    username, 
    email, 
    phone, 
    password, 
    primaryCategory,
    skills,
    yearsExperience,
    pricePerHour,
    latitude,
    longitude,
    address
  } = req.body || {};
  
  // Required fields validation
  if (!name) return res.status(400).json({ success: false, message: 'name is required' });
  if (!email) return res.status(400).json({ success: false, message: 'email is required' });
  if (!password) return res.status(400).json({ success: false, message: 'password is required' });
  if (!primaryCategory) return res.status(400).json({ success: false, message: 'primaryCategory is required' });

  email = email.toLowerCase().trim();
  if (!isValidEmail(email)) {
    return res.status(400).json({ success: false, message: 'A valid email is required' });
  }

  // Validate password strength
  const passwordValidation = validatePassword(password);
  if (!passwordValidation.valid) {
    return res.status(400).json({ success: false, message: passwordValidation.message });
  }

  username = username?.toLowerCase();
  const normalizedPhone = phone ? normalizePhone(phone) : undefined; // phone is now optional

  // Check if worker already exists by email
  const existingByEmail = await Worker.findOne({ email });
  if (existingByEmail) {
    const result = await sendWorkerOtpEmail({ worker: existingByEmail, email, purpose: 'login' });
    if (!result.ok) return res.status(502).json({ success: false, message: 'Failed to send verification email' });
    return res.json({
      success: true,
      message: 'Email already registered. Verification code sent for login.',
      data: { workerId: existingByEmail._id },
    });
  }

  // Check duplicate username
  if (username) {
    const existingByUsername = await Worker.findOne({ username });
    if (existingByUsername) {
      return res.status(409).json({ success: false, message: 'Username already in use' });
    }
  }

  const passwordHash = await bcrypt.hash(password, 12);

  const workerData = {
    name,
    username,
    email,
    phone: normalizedPhone,
    passwordHash,
    primaryCategory,
    skills: skills || [],
    yearsExperience: yearsExperience || 0,
    pricePerHour: pricePerHour || 0,
    latitude: latitude || 0,
    longitude: longitude || 0,
    address: address || {},
    isEmailVerified: false,
    tokenVersion: 0,
    accountStatus: 'pending_approval'
  };

  const worker = await Worker.create(workerData);

  // Send email OTP for verification
  const result = await sendWorkerOtpEmail({ worker, email, purpose: 'signup' });
  if (!result.ok) {
    return res.status(502).json({ success: false, message: 'Failed to send verification email' });
  }

  return res.json({
    success: true,
    message: 'Worker registered. Verification code sent to your email.',
    data: { workerId: worker._id }
  });
}));

// Helper: shape the worker object returned to clients after auth.
function workerSummary(worker) {
  return {
    id: worker._id,
    name: worker.name,
    phone: worker.phone,
    email: worker.email,
    username: worker.username,
    primaryCategory: worker.primaryCategory,
    accountStatus: worker.accountStatus,
    verified: worker.verified,
    rating: worker.rating,
    profileImage: worker.profileImage,
    currentlyAvailable: worker.currentlyAvailable,
  };
}

// ================ VERIFY EMAIL OTP ================
router.post('/email/verify-otp', otpLimiter, asyncHandler(async (req, res) => {
  let { email, code } = req.body || {};
  if (!email || !code) {
    return res.status(400).json({ success: false, message: 'email and code are required' });
  }
  email = String(email).toLowerCase().trim();

  const worker = await Worker.findOne({ email });
  if (!worker || !worker.otp || !worker.otp.codeHash) {
    return res.status(400).json({ success: false, message: 'No verification code pending. Request a new one.' });
  }
  if (worker.otp.expiresAt && worker.otp.expiresAt < new Date()) {
    worker.otp = undefined;
    await worker.save();
    return res.status(400).json({ success: false, message: 'Verification code expired. Request a new one.' });
  }
  const ok = await verifyOtp(String(code), worker.otp.codeHash);
  if (!ok) return res.status(400).json({ success: false, message: 'Invalid verification code' });

  worker.isEmailVerified = true;
  worker.otp = undefined;
  worker.lastLoginAt = new Date();
  if (worker.accountStatus === 'pending_approval') {
    worker.accountStatus = 'active';
  }
  await worker.save();

  const tokens = signTokens(worker);
  return res.json({
    success: true,
    message: 'Email verified successfully',
    data: { worker: workerSummary(worker), accessToken: tokens.accessToken, refreshToken: tokens.refreshToken },
  });
}));

// ================ REQUEST EMAIL OTP FOR LOGIN ================
router.post('/email/request-otp', otpLimiter, asyncHandler(async (req, res) => {
  let { email } = req.body || {};
  if (!email) return res.status(400).json({ success: false, message: 'email is required' });
  email = String(email).toLowerCase().trim();
  if (!isValidEmail(email)) return res.status(400).json({ success: false, message: 'A valid email is required' });

  const worker = await Worker.findOne({ email });
  // Don't reveal whether the account exists.
  if (!worker) {
    return res.json({ success: true, message: 'If the email is registered, a verification code has been sent', data: null });
  }
  const result = await sendWorkerOtpEmail({ worker, email, purpose: 'login' });
  if (!result.ok) return res.status(502).json({ success: false, message: 'Failed to send verification email' });
  return res.json({ success: true, message: 'Verification code sent to your email', data: null });
}));

// ================ SIGN IN WITH GOOGLE ================
router.post('/google', strictLoginLimiter, asyncHandler(async (req, res) => {
  const { idToken } = req.body || {};
  if (!idToken) return res.status(400).json({ success: false, message: 'idToken is required' });

  let profile;
  try {
    profile = await verifyGoogleIdToken(idToken);
  } catch (e) {
    console.error('[WorkerGoogleAuth] verify failed:', e.message);
    return res.status(401).json({ success: false, message: 'Invalid Google token' });
  }

  let worker = await Worker.findOne({ $or: [{ googleId: profile.googleId }, { email: profile.email }] });
  if (!worker) {
    // New Google worker: created in pending_approval until an admin reviews them.
    worker = await Worker.create({
      googleId: profile.googleId,
      email: profile.email,
      name: profile.name || profile.email.split('@')[0],
      profileImage: profile.avatar,
      isEmailVerified: profile.emailVerified,
      tokenVersion: 0,
      accountStatus: 'pending_approval',
    });
  } else {
    if (!worker.googleId) worker.googleId = profile.googleId;
    if (!worker.profileImage && profile.avatar) worker.profileImage = profile.avatar;
    if (profile.emailVerified) worker.isEmailVerified = true;
    worker.lastLoginAt = new Date();
    await worker.save();
  }

  const tokens = signTokens(worker);
  return res.json({
    success: true,
    message: 'Google sign-in successful',
    data: { worker: workerSummary(worker), accessToken: tokens.accessToken, refreshToken: tokens.refreshToken },
  });
}));

// Deprecated phone/SMS OTP endpoints (mobile OTP has been removed).
router.post(['/request-otp', '/verify-otp'], (req, res) => {
  return res.status(410).json({
    success: false,
    message: 'Phone OTP is no longer supported. Use email OTP (/worker-auth/email/request-otp) or Google sign-in (/worker-auth/google).',
  });
});

// ================ PASSWORD LOGIN ================
router.post('/login', strictLoginLimiter, asyncHandler(async (req, res) => {
  const { identifier, password } = req.body || {};
  if (!identifier || !password) {
    return res.status(400).json({ 
      success: false, 
      message: 'identifier and password required' 
    });
  }
  
  const identLower = (identifier || '').toLowerCase();
  
  let worker = await Worker.findOne({ $or: [
    { username: identLower },
    { email: identLower },
    { phone: identifier },
    { phone: normalizePhone(identifier) },
  ] });
  
  if (!worker) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  // Check if account is locked
  if (worker.lockUntil && worker.lockUntil > Date.now()) {
    const lockTime = Math.ceil((worker.lockUntil - Date.now()) / (1000 * 60));
    return res.status(423).json({ 
      success: false, 
      message: `Account locked. Try again in ${lockTime} minutes.` 
    });
  }

  // Check account status
  if (worker.accountStatus === 'suspended') {
    return res.status(403).json({ 
      success: false, 
      message: 'Account suspended. Contact support.' 
    });
  }
  
  if (worker.accountStatus === 'deactivated') {
    return res.status(403).json({ 
      success: false, 
      message: 'Account deactivated. Please reactivate your account.' 
    });
  }

  const passwordValid = await bcrypt.compare(password, worker.passwordHash);
  
  if (!passwordValid) {
    // Increment login attempts
    const updates = { $inc: { loginAttempts: 1 } };
    const maxAttempts = 5;
    
    if (worker.loginAttempts + 1 >= maxAttempts && !worker.lockUntil) {
      updates.$set = { lockUntil: Date.now() + (30 * 60 * 1000) };
    }
    
    await Worker.updateOne({ _id: worker._id }, updates);
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  // Reset login attempts on successful login
  if (worker.loginAttempts > 0) {
    await Worker.updateOne(
      { _id: worker._id }, 
      { 
        $unset: { loginAttempts: '', lockUntil: '' },
        $set: { lastLoginAt: new Date() }
      }
    );
  }

  const tokens = signTokens(worker);
  res.json({ 
    success: true, 
    message: 'Login successful', 
    data: { 
      worker: {
        id: worker._id,
        name: worker.name,
        phone: worker.phone,
        email: worker.email,
        username: worker.username,
        primaryCategory: worker.primaryCategory,
        accountStatus: worker.accountStatus,
        verified: worker.verified,
        rating: worker.rating,
        profileImage: worker.profileImage,
        currentlyAvailable: worker.currentlyAvailable
      },
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken 
    } 
  });
}));

// ================ REFRESH TOKEN ================
router.post('/refresh-token', asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ success: false, message: 'Refresh token required' });
  }

  try {
    const payload = jwt.verify(
      refreshToken, 
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET
    );
    
    if (payload.role !== 'worker') {
      return res.status(401).json({ success: false, message: 'Invalid token type' });
    }
    
    const worker = await Worker.findById(payload.id);
    
    if (!worker || worker.tokenVersion !== payload.tokenVersion) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const tokens = signTokens(worker);
    res.json({
      success: true,
      message: 'Token refreshed',
      data: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      }
    });
  } catch (error) {
    return res.status(401).json({ success: false, message: 'Invalid refresh token' });
  }
}));

// ================ LOGOUT ================
router.post('/logout', workerAuth(), asyncHandler(async (req, res) => {
  await Worker.updateOne(
    { _id: req.worker.id }, 
    { $inc: { tokenVersion: 1 } }
  );
  res.json({ success: true, message: 'Logged out successfully' });
}));

// ================ LOGOUT FROM ALL DEVICES ================
router.post('/logout-all', workerAuth(), asyncHandler(async (req, res) => {
  await Worker.updateOne(
    { _id: req.worker.id }, 
    { $inc: { tokenVersion: 1 } }
  );
  res.json({ success: true, message: 'Logged out from all devices' });
}));

// ================ FORGOT PASSWORD (EMAIL OTP) ================
router.post('/forgot-password', passwordResetLimiter, asyncHandler(async (req, res) => {
  let { email } = req.body;
  if (!email) {
    return res.status(400).json({ success: false, message: 'Email is required' });
  }
  email = String(email).toLowerCase().trim();

  const worker = await Worker.findOne({ email });
  if (!worker) {
    return res.json({
      success: true,
      message: 'If the email exists, a code has been sent for password reset'
    });
  }

  const result = await sendWorkerOtpEmail({ worker, email, purpose: 'reset' });
  if (!result.ok) return res.status(502).json({ success: false, message: 'Failed to send reset email' });

  res.json({
    success: true,
    message: 'Reset code sent to your email'
  });
}));

// ================ RESET PASSWORD WITH OTP ================
router.post('/reset-password', asyncHandler(async (req, res) => {
  let { email, code, newPassword } = req.body;
  if (!email || !code || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'Email, code and new password are required'
    });
  }

  // Validate new password
  const passwordValidation = validatePassword(newPassword);
  if (!passwordValidation.valid) {
    return res.status(400).json({ success: false, message: passwordValidation.message });
  }

  email = String(email).toLowerCase().trim();
  const worker = await Worker.findOne({ email });

  if (!worker || !worker.otp || !worker.otp.codeHash) {
    return res.status(400).json({ success: false, message: 'No OTP pending' });
  }
  
  if (worker.otp.expiresAt && worker.otp.expiresAt < new Date()) {
    worker.otp = undefined;
    await worker.save();
    return res.status(400).json({ success: false, message: 'OTP expired' });
  }
  
  const ok = await verifyOtp(code, worker.otp.codeHash);
  if (!ok) return res.status(400).json({ success: false, message: 'Invalid OTP' });

  // Reset password
  worker.passwordHash = await bcrypt.hash(newPassword, 12);
  worker.otp = undefined;
  worker.tokenVersion += 1;
  await worker.save();

  res.json({ success: true, message: 'Password reset successful' });
}));

// ================ CHANGE PASSWORD ================
router.post('/change-password', workerAuth(), asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) {
    return res.status(400).json({ 
      success: false, 
      message: 'Current password and new password are required' 
    });
  }

  // Validate new password
  const passwordValidation = validatePassword(newPassword);
  if (!passwordValidation.valid) {
    return res.status(400).json({ success: false, message: passwordValidation.message });
  }

  const worker = await Worker.findById(req.worker.id);
  if (!worker || !worker.passwordHash) {
    return res.status(400).json({ success: false, message: 'Worker not found' });
  }

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(currentPassword, worker.passwordHash);
  if (!isCurrentPasswordValid) {
    return res.status(400).json({ success: false, message: 'Current password is incorrect' });
  }

  // Update password
  worker.passwordHash = await bcrypt.hash(newPassword, 12);
  worker.tokenVersion += 1;
  await worker.save();

  res.json({ success: true, message: 'Password changed successfully' });
}));

// ================ GET CURRENT WORKER PROFILE ================
router.get('/me', workerAuth(), asyncHandler(async (req, res) => {
  const worker = await Worker.findById(req.worker.id)
    .select('-passwordHash -otp -passwordResetToken -passwordResetExpires')
    .lean();
    
  if (!worker) return res.status(404).json({ success: false, message: 'Worker not found' });
  
  res.json({ success: true, message: 'OK', data: { worker } });
}));

// ================ UPDATE PROFILE ================
router.put('/profile', workerAuth(), asyncHandler(async (req, res) => {
  const {
    name,
    email,
    bio,
    skills,
    yearsExperience,
    pricePerHour,
    minimumCharge,
    latitude,
    longitude,
    address,
    workingHours,
    bankDetails,
    panNumber,
    gstNumber,
    language
  } = req.body;

  const updates = {};
  if (name) updates.name = name;
  if (email) updates.email = email.toLowerCase();
  if (bio !== undefined) updates.bio = bio;
  if (skills) updates.skills = skills;
  if (yearsExperience !== undefined) updates.yearsExperience = yearsExperience;
  if (pricePerHour !== undefined) updates.pricePerHour = pricePerHour;
  if (minimumCharge !== undefined) updates.minimumCharge = minimumCharge;
  if (latitude !== undefined) updates.latitude = latitude;
  if (longitude !== undefined) updates.longitude = longitude;
  if (address) updates.address = address;
  if (workingHours) updates.workingHours = workingHours;
  if (bankDetails) updates.bankDetails = bankDetails;
  if (panNumber) updates.panNumber = panNumber;
  if (gstNumber) updates.gstNumber = gstNumber;
  if (language) updates.language = language;

  const worker = await Worker.findByIdAndUpdate(
    req.worker.id,
    { $set: updates },
    { new: true, runValidators: true }
  ).select('-passwordHash -otp -passwordResetToken -passwordResetExpires');

  res.json({ 
    success: true, 
    message: 'Profile updated successfully', 
    data: { worker } 
  });
}));

// ================ UPDATE AVAILABILITY STATUS ================
router.put('/availability', workerAuth(), asyncHandler(async (req, res) => {
  const { currentlyAvailable } = req.body;
  
  if (typeof currentlyAvailable !== 'boolean') {
    return res.status(400).json({ 
      success: false, 
      message: 'currentlyAvailable must be boolean' 
    });
  }

  const worker = await Worker.findByIdAndUpdate(
    req.worker.id,
    { $set: { currentlyAvailable } },
    { new: true }
  ).select('currentlyAvailable');

  res.json({ 
    success: true, 
    message: 'Availability updated', 
    data: { currentlyAvailable: worker.currentlyAvailable } 
  });
}));

module.exports = router;
