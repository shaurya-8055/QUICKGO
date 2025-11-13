const bcrypt = require('bcryptjs');
const crypto = require('crypto');

/**
 * Generate a 6-digit OTP
 * @returns {string} 6-digit OTP
 */
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Hash OTP for secure storage
 * @param {string} otp - Plain text OTP
 * @returns {Promise<string>} Hashed OTP
 */
async function hashOtp(otp) {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(otp, salt);
}

/**
 * Verify OTP against hash
 * @param {string} otp - Plain text OTP to verify
 * @param {string} hash - Stored OTP hash
 * @returns {Promise<boolean>} True if OTP is valid
 */
async function verifyOtp(otp, hash) {
  return bcrypt.compare(otp, hash);
}

/**
 * Generate secure token for password reset
 * @returns {string} Random token
 */
function generateResetToken() {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Hash reset token for secure storage
 * @param {string} token - Plain text token
 * @returns {string} Hashed token
 */
function hashResetToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

module.exports = {
  generateOtp,
  hashOtp,
  verifyOtp,
  generateResetToken,
  hashResetToken
};