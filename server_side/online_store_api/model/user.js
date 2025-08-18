const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  email: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  phone: { type: String, trim: true, index: true, unique: true, sparse: true }, // E.164 format recommended
  passwordHash: { type: String }, // bcrypt hash
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  isPhoneVerified: { type: Boolean, default: false },
  isEmailVerified: { type: Boolean, default: false },
  
  // Enhanced security fields
  tokenVersion: { type: Number, default: 0 }, // For token invalidation
  loginAttempts: { type: Number, default: 0 },
  lockUntil: { type: Date },
  
  // Password reset
  passwordResetToken: { type: String },
  passwordResetExpires: { type: Date },
  
  // Email verification
  emailVerificationToken: { type: String },
  emailVerificationExpires: { type: Date },
  
  // Store OTP details hashed (never plain)
  otp: {
    codeHash: { type: String },
    purpose: { type: String, enum: ['signup', 'login', 'reset'] },
    expiresAt: { type: Date },
  },
  
  // User profile
  name: { type: String, trim: true },
  avatar: { type: String },
  
  // Security settings
  twoFactorEnabled: { type: Boolean, default: false },
  lastLoginAt: { type: Date },
  lastLoginIP: { type: String },
  
}, { timestamps: true });

// Indexes for performance
userSchema.index({ email: 1, isEmailVerified: 1 });
userSchema.index({ phone: 1, isPhoneVerified: 1 });
userSchema.index({ passwordResetToken: 1, passwordResetExpires: 1 });

// Virtual for account lock status
userSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

module.exports = mongoose.model('User', userSchema);
