const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');
const rateLimit = require('express-rate-limit');
const User = require('../model/user');
const { generateOtp, hashOtp, verifyOtp } = require('../util/otp');
const { sendOtpEmail, sendEmail } = require('../services/email');
const { verifyGoogleIdToken, verifyGoogleAccessToken } = require('../services/googleAuth');
const { auth } = require('../middleware/auth');
const crypto = require('crypto');

function normalizePhone(raw) {
  if (!raw) return null;
  const p = String(raw).replace(/[\s-]/g, '');
  if (p.startsWith('+')) return p;
  const cc = process.env.DEFAULT_COUNTRY_CODE; // e.g. +91
  if (cc) return `${cc}${p}`;
  return null; // require E.164 when no default is set
}

const router = express.Router();

// Enhanced rate limiting
const strictLoginLimiter = rateLimit({ 
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: { success: false, message: 'Too many login attempts. Try again in 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 50 });
const otpLimiter = rateLimit({ 
  windowMs: 10 * 60 * 1000, 
  max: 10,
  message: { success: false, message: 'Too many OTP requests. Try again in 10 minutes.' }
});

const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 password reset attempts per hour
  message: { success: false, message: 'Too many password reset attempts. Try again in 1 hour.' }
});

// Enhanced token generation with refresh tokens
function signTokens(user) {
  const payload = { 
    id: user._id, 
    role: user.role, 
    username: user.username, 
    email: user.email, 
    phone: user.phone,
    tokenVersion: user.tokenVersion || 0
  };
  
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' });
  const refreshToken = jwt.sign(
    { id: user._id, tokenVersion: user.tokenVersion || 0 }, 
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, 
    { expiresIn: '7d' }
  );
  
  return { accessToken, refreshToken };
}

// Password strength validation
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

// Register with email/username + password (no phone verification required)
router.post('/register', asyncHandler(async (req, res) => {
  let { username, email, password, name } = req.body || {};
  
  // Require either username or email
  if (!username && !email) {
    return res.status(400).json({ success: false, message: 'username or email is required' });
  }
  if (!password) {
    return res.status(400).json({ success: false, message: 'password is required' });
  }

  // Validate password strength
  const passwordValidation = validatePassword(password);
  if (!passwordValidation.valid) {
    return res.status(400).json({ success: false, message: passwordValidation.message });
  }

  username = username?.toLowerCase();
  email = email?.toLowerCase();

  // Check for duplicate username/email
  const existingUser = await User.findOne({ 
    $or: [ 
      username ? { username } : null, 
      email ? { email } : null 
    ].filter(Boolean) 
  });
  
  if (existingUser) {
    return res.status(409).json({ 
      success: false, 
      message: 'Username or email already in use' 
    });
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await User.create({ 
    username, 
    email, 
    name,
    passwordHash, 
    isPhoneVerified: true, // Set to true since we're not verifying phone
    isEmailVerified: false,
    tokenVersion: 0
  });

  // Automatically log the user in after registration
  const tokens = signTokens(user);
  
  return res.json({ 
    success: true, 
    message: 'Registration successful! You are now logged in.', 
    data: { 
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        name: user.name,
        role: user.role
      },
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    } 
  });
}));

// ---------------------------------------------------------------------------
// Email OTP authentication (passwordless). Replaces the old phone/SMS OTP flow.
// Unified login+signup: requesting a code for a new email creates a shell user.
// ---------------------------------------------------------------------------

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Request an email OTP (creates the account if it doesn't exist yet).
router.post('/email/request-otp', otpLimiter, asyncHandler(async (req, res) => {
  let { email, name } = req.body || {};
  if (!email) return res.status(400).json({ success: false, message: 'email is required' });
  email = String(email).toLowerCase().trim();
  if (!isValidEmail(email)) return res.status(400).json({ success: false, message: 'A valid email is required' });

  let user = await User.findOne({ email });
  const isNew = !user;
  if (!user) {
    user = await User.create({ email, name, isEmailVerified: false, tokenVersion: 0 });
  }

  const otp = generateOtp();
  user.otp = {
    codeHash: await hashOtp(otp),
    purpose: isNew ? 'signup' : 'login',
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  };
  await user.save();

  const result = await sendOtpEmail(email, otp, isNew ? 'signup' : 'login');
  if (!result.ok) return res.status(502).json({ success: false, message: 'Failed to send verification email' });

  return res.json({
    success: true,
    message: 'Verification code sent to your email',
    data: { isNewUser: isNew },
  });
}));

// Verify an email OTP and return auth tokens.
router.post('/email/verify-otp', otpLimiter, asyncHandler(async (req, res) => {
  let { email, code } = req.body || {};
  if (!email || !code) return res.status(400).json({ success: false, message: 'email and code are required' });
  email = String(email).toLowerCase().trim();

  const user = await User.findOne({ email });
  if (!user || !user.otp || !user.otp.codeHash) {
    return res.status(400).json({ success: false, message: 'No verification code pending. Request a new one.' });
  }
  if (user.otp.expiresAt && user.otp.expiresAt < new Date()) {
    user.otp = undefined; await user.save();
    return res.status(400).json({ success: false, message: 'Verification code expired. Request a new one.' });
  }
  const ok = await verifyOtp(String(code), user.otp.codeHash);
  if (!ok) return res.status(400).json({ success: false, message: 'Invalid verification code' });

  user.isEmailVerified = true;
  user.otp = undefined;
  user.lastLoginAt = new Date();
  await user.save();

  const tokens = signTokens(user);
  return res.json({
    success: true,
    message: 'Email verified',
    data: { user, accessToken: tokens.accessToken, refreshToken: tokens.refreshToken },
  });
}));

// Sign in with Google: verify the ID token from the client and issue our tokens.
router.post('/google', loginLimiter, asyncHandler(async (req, res) => {
  const { idToken, accessToken } = req.body || {};
  if (!idToken && !accessToken) {
    return res.status(400).json({ success: false, message: 'idToken or accessToken is required' });
  }

  let profile;
  try {
    // Flutter web (Google Identity Services) only provides an access token.
    profile = idToken
      ? await verifyGoogleIdToken(idToken)
      : await verifyGoogleAccessToken(accessToken);
  } catch (e) {
    console.error('[GoogleAuth] verify failed:', e.message);
    return res.status(401).json({ success: false, message: 'Invalid Google token' });
  }

  // Find by googleId, otherwise link to an existing account with the same email.
  let user = await User.findOne({ $or: [{ googleId: profile.googleId }, { email: profile.email }] });
  if (!user) {
    user = await User.create({
      googleId: profile.googleId,
      email: profile.email,
      name: profile.name,
      avatar: profile.avatar,
      isEmailVerified: profile.emailVerified,
      tokenVersion: 0,
    });
  } else {
    // Link Google to an existing email-based account on first Google login.
    if (!user.googleId) user.googleId = profile.googleId;
    if (!user.avatar && profile.avatar) user.avatar = profile.avatar;
    if (!user.name && profile.name) user.name = profile.name;
    if (profile.emailVerified) user.isEmailVerified = true;
    user.lastLoginAt = new Date();
    await user.save();
  }

  const tokens = signTokens(user);
  return res.json({
    success: true,
    message: 'Google sign-in successful',
    data: { user, accessToken: tokens.accessToken, refreshToken: tokens.refreshToken },
  });
}));

// Demo login: instantly sign in with a shared demo account, no credentials.
router.post('/demo-login', loginLimiter, asyncHandler(async (req, res) => {
  const email = 'demo@quickgo.com';
  let user = await User.findOne({ email });
  if (!user) {
    user = await User.create({
      email,
      name: 'Demo User',
      isEmailVerified: true,
      tokenVersion: 0,
    });
  }
  user.lastLoginAt = new Date();
  await user.save();

  const tokens = signTokens(user);
  return res.json({
    success: true,
    message: 'Signed in as demo user',
    data: { user, accessToken: tokens.accessToken, refreshToken: tokens.refreshToken },
  });
}));

// Deprecated phone/SMS OTP endpoints (mobile OTP has been removed).
router.post(['/request-otp', '/verify-otp'], (req, res) => {
  return res.status(410).json({
    success: false,
    message: 'Phone OTP is no longer supported. Use email OTP (/auth/email/request-otp) or Google sign-in (/auth/google).',
  });
});

// Password login with username/email/phone + password
router.post('/login', strictLoginLimiter, asyncHandler(async (req, res) => {
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

  // Check if account is locked
  if (user.lockUntil && user.lockUntil > Date.now()) {
    const lockTime = Math.ceil((user.lockUntil - Date.now()) / (1000 * 60));
    return res.status(423).json({ 
      success: false, 
      message: `Account locked. Try again in ${lockTime} minutes.` 
    });
  }

  let passwordValid = false;
  
  if (user.passwordHash) {
    passwordValid = await bcrypt.compare(password, user.passwordHash);
  } else {
    // Legacy migration: check raw legacy password
    const legacy = await User.findById(user._id).lean();
    if (legacy && legacy.password && legacy.password === password) {
      passwordValid = true;
      // Migrate to hashed password
      const newHash = await bcrypt.hash(password, 12);
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      const setOps = { passwordHash: newHash };
      if (!legacy.username && legacy.name) setOps.username = String(legacy.name).toLowerCase();
      if (!legacy.email && emailRegex.test(identifier)) setOps.email = identLower;
      await User.updateOne({ _id: user._id }, { $set: setOps, $unset: { password: '', name: '' } });
      user = await User.findById(user._id);
    }
  }
  
  if (!passwordValid) {
    // Increment login attempts
    const updates = { $inc: { loginAttempts: 1 } };
    const maxAttempts = 5;
    
    if (user.loginAttempts + 1 >= maxAttempts && !user.lockUntil) {
      updates.$set = { lockUntil: Date.now() + (30 * 60 * 1000) }; // 30 minutes lock
    }
    
    await User.updateOne({ _id: user._id }, updates);
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  // Reset login attempts on successful login
  if (user.loginAttempts > 0) {
    await User.updateOne(
      { _id: user._id }, 
      { $unset: { loginAttempts: '', lockUntil: '' } }
    );
  }

  const tokens = signTokens(user);
  res.json({ 
    success: true, 
    message: 'Login successful', 
    data: { 
      user, 
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken 
    } 
  });
}));

module.exports = router;

// Token refresh endpoint
router.post('/refresh-token', asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ success: false, message: 'Refresh token required' });
  }

  try {
    const payload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET);
    const user = await User.findById(payload.id);
    
    if (!user || user.tokenVersion !== payload.tokenVersion) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const tokens = signTokens(user);
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

// Logout endpoint (invalidate tokens)
router.post('/logout', auth(), asyncHandler(async (req, res) => {
  await User.updateOne(
    { _id: req.user.id }, 
    { $inc: { tokenVersion: 1 } }
  );
  res.json({ success: true, message: 'Logged out successfully' });
}));

// Logout from all devices
router.post('/logout-all', auth(), asyncHandler(async (req, res) => {
  await User.updateOne(
    { _id: req.user.id }, 
    { $inc: { tokenVersion: 1 } }
  );
  res.json({ success: true, message: 'Logged out from all devices' });
}));

// Password reset request
router.post('/forgot-password', passwordResetLimiter, asyncHandler(async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ success: false, message: 'Email is required' });
  }

  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) {
    // Don't reveal if email exists
    return res.json({ 
      success: true, 
      message: 'If email exists, password reset instructions have been sent' 
    });
  }

  // Generate secure reset token
  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');
  
  user.passwordResetToken = resetTokenHash;
  user.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
  await user.save();

  // Email the reset token to the user (never return it in the response).
  await sendEmail({
    to: user.email,
    subject: 'QuickGo password reset',
    text: `Use this code to reset your password: ${resetToken}\nIt expires in 10 minutes. If you didn't request this, ignore this email.`,
  });

  res.json({
    success: true,
    message: 'If the email exists, password reset instructions have been sent',
  });
}));

// Password reset confirmation
router.post('/reset-password', asyncHandler(async (req, res) => {
  const { token, newPassword } = req.body;
  if (!token || !newPassword) {
    return res.status(400).json({ 
      success: false, 
      message: 'Token and new password are required' 
    });
  }

  // Validate new password
  const passwordValidation = validatePassword(newPassword);
  if (!passwordValidation.valid) {
    return res.status(400).json({ success: false, message: passwordValidation.message });
  }

  const resetTokenHash = crypto.createHash('sha256').update(token).digest('hex');
  
  const user = await User.findOne({
    passwordResetToken: resetTokenHash,
    passwordResetExpires: { $gt: Date.now() }
  });

  if (!user) {
    return res.status(400).json({ 
      success: false, 
      message: 'Invalid or expired reset token' 
    });
  }

  // Reset password
  user.passwordHash = await bcrypt.hash(newPassword, 12);
  user.passwordResetToken = undefined;
  user.passwordResetExpires = undefined;
  user.tokenVersion += 1; // Invalidate all existing tokens
  await user.save();

  res.json({ success: true, message: 'Password reset successful' });
}));

// Change password (authenticated users)
router.post('/change-password', auth(), asyncHandler(async (req, res) => {
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

  const user = await User.findById(req.user.id);
  if (!user || !user.passwordHash) {
    return res.status(400).json({ success: false, message: 'User not found' });
  }

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!isCurrentPasswordValid) {
    return res.status(400).json({ success: false, message: 'Current password is incorrect' });
  }

  // Update password
  user.passwordHash = await bcrypt.hash(newPassword, 12);
  user.tokenVersion += 1; // Invalidate all existing tokens
  await user.save();

  res.json({ success: true, message: 'Password changed successfully' });
}));

// Protected: get current user profile (token required)
router.get('/me', auth(), asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id).select('-passwordHash -otp -passwordResetToken -passwordResetExpires').lean();
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });
  res.json({ success: true, message: 'OK', data: { user } });
}));
