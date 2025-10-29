const mongoose = require('mongoose');

const workerSchema = new mongoose.Schema({
  // Authentication fields
  username: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  email: { type: String, trim: true, lowercase: true, index: true, unique: true, sparse: true },
  phone: { type: String, trim: true, index: true, unique: true, required: true }, // E.164 format
  passwordHash: { type: String, required: true }, // bcrypt hash
  
  // Basic Information
  name: { type: String, required: true, trim: true },
  profileImage: { type: String },
  bio: { type: String, trim: true },
  dateOfBirth: { type: Date },
  gender: { type: String, enum: ['male', 'female', 'other'] },
  
  // Contact Information
  alternatePhone: { type: String, trim: true },
  address: {
    street: { type: String, trim: true },
    city: { type: String, trim: true },
    state: { type: String, trim: true },
    zipCode: { type: String, trim: true },
    country: { type: String, trim: true, default: 'India' }
  },
  
  // Location fields for map-based discovery
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] } // [longitude, latitude]
  },
  latitude: { type: Number },
  longitude: { type: Number },
  
  // Service Categories & Skills
  primaryCategory: { type: String, trim: true }, // AC Repair, Plumber, Electrician, etc.
  skills: [{ type: String, trim: true }], // Specific skills
  serviceRadius: { type: Number, default: 10 }, // km
  
  // Professional Information
  yearsExperience: { type: Number, default: 0, min: 0 },
  certifications: [{
    name: { type: String },
    issuedBy: { type: String },
    issuedDate: { type: Date },
    expiryDate: { type: Date },
    certificateUrl: { type: String }
  }],
  education: [{
    degree: { type: String },
    institution: { type: String },
    year: { type: Number }
  }],
  
  // Identity Verification
  verified: { type: Boolean, default: false },
  verificationDocuments: [{
    type: { type: String, enum: ['aadhar', 'pan', 'driving_license', 'passport', 'other'] },
    documentNumber: { type: String },
    documentUrl: { type: String },
    verifiedAt: { type: Date },
    verifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  }],
  backgroundCheckStatus: { type: String, enum: ['pending', 'verified', 'failed'], default: 'pending' },
  
  // Performance & Ratings
  rating: { type: Number, default: 0, min: 0, max: 5 },
  totalJobs: { type: Number, default: 0, min: 0 },
  completedJobs: { type: Number, default: 0, min: 0 },
  cancelledJobs: { type: Number, default: 0, min: 0 },
  totalReviews: { type: Number, default: 0, min: 0 },
  responseTime: { type: Number, default: 0 }, // Average response time in minutes
  acceptanceRate: { type: Number, default: 100, min: 0, max: 100 }, // Percentage
  completionRate: { type: Number, default: 100, min: 0, max: 100 }, // Percentage
  
  // Pricing
  pricePerHour: { type: Number, min: 0 },
  minimumCharge: { type: Number, min: 0 },
  currency: { type: String, default: 'INR' },
  paymentMethods: [{ type: String, enum: ['cash', 'upi', 'card', 'wallet'] }],
  
  // Availability
  active: { type: Boolean, default: true },
  currentlyAvailable: { type: Boolean, default: true },
  workingHours: {
    monday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    tuesday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    wednesday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    thursday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    friday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    saturday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: true } },
    sunday: { start: { type: String }, end: { type: String }, available: { type: Boolean, default: false } }
  },
  
  // Financial Information
  bankDetails: {
    accountHolderName: { type: String, trim: true },
    accountNumber: { type: String, trim: true },
    ifscCode: { type: String, trim: true },
    bankName: { type: String, trim: true },
    branchName: { type: String, trim: true },
    upiId: { type: String, trim: true }
  },
  panNumber: { type: String, trim: true },
  gstNumber: { type: String, trim: true },
  
  // Earnings & Wallet
  totalEarnings: { type: Number, default: 0, min: 0 },
  pendingEarnings: { type: Number, default: 0, min: 0 },
  availableBalance: { type: Number, default: 0, min: 0 },
  
  // Security & Verification
  isPhoneVerified: { type: Boolean, default: false },
  isEmailVerified: { type: Boolean, default: false },
  tokenVersion: { type: Number, default: 0 },
  loginAttempts: { type: Number, default: 0 },
  lockUntil: { type: Date },
  passwordResetToken: { type: String },
  passwordResetExpires: { type: Date },
  emailVerificationToken: { type: String },
  emailVerificationExpires: { type: Date },
  
  // OTP for phone verification
  otp: {
    codeHash: { type: String },
    purpose: { type: String, enum: ['signup', 'login', 'reset', 'verification'] },
    expiresAt: { type: Date },
  },
  
  // App Settings
  notificationSettings: {
    pushEnabled: { type: Boolean, default: true },
    smsEnabled: { type: Boolean, default: true },
    emailEnabled: { type: Boolean, default: true },
    newJobAlerts: { type: Boolean, default: true },
    promotionalAlerts: { type: Boolean, default: false }
  },
  language: { type: String, default: 'en' },
  
  // Statistics
  lastLoginAt: { type: Date },
  lastLoginIP: { type: String },
  deviceTokens: [{ type: String }], // For push notifications
  
  // Status
  accountStatus: { type: String, enum: ['active', 'suspended', 'deactivated', 'pending_approval'], default: 'pending_approval' },
  suspensionReason: { type: String },
  
  // Portfolio
  portfolio: [{
    title: { type: String },
    description: { type: String },
    imageUrls: [{ type: String }],
    completedDate: { type: Date }
  }],
  
}, { timestamps: true });

// Geospatial index for location-based queries
workerSchema.index({ location: '2dsphere' });

// Other indexes for performance
workerSchema.index({ phone: 1 });
workerSchema.index({ email: 1 });
workerSchema.index({ username: 1 });
workerSchema.index({ primaryCategory: 1, active: 1 });
workerSchema.index({ skills: 1 });
workerSchema.index({ latitude: 1, longitude: 1 });
workerSchema.index({ rating: -1 });
workerSchema.index({ active: 1, currentlyAvailable: 1 });
workerSchema.index({ verified: 1 });
workerSchema.index({ accountStatus: 1 });
workerSchema.index({ passwordResetToken: 1, passwordResetExpires: 1 });

// Virtual for account lock status
workerSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Virtual for completion rate calculation
workerSchema.virtual('calculatedCompletionRate').get(function() {
  if (this.totalJobs === 0) return 100;
  return Math.round((this.completedJobs / this.totalJobs) * 100);
});

// Update location coordinates when latitude/longitude change
workerSchema.pre('save', function(next) {
  if (this.latitude && this.longitude) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude]
    };
  }
  next();
});

module.exports = mongoose.model('Worker', workerSchema);
