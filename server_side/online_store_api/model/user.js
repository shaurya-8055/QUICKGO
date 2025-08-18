const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  email: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  phone: { type: String, trim: true, index: true, unique: true, sparse: true }, // E.164 format recommended
  passwordHash: { type: String }, // bcrypt hash
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  isPhoneVerified: { type: Boolean, default: false },
  isEmailVerified: { type: Boolean, default: false },
  // Store OTP details hashed (never plain)
  otp: {
    codeHash: { type: String },
    purpose: { type: String, enum: ['signup', 'login', 'reset'] },
    expiresAt: { type: Date },
  },
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

module.exports = User;
