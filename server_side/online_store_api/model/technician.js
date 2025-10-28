const mongoose = require('mongoose');

const technicianSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    phone: { type: String, required: true, trim: true, unique: true },
    skills: [{ type: String, trim: true }],
    active: { type: Boolean, default: true },
    
    // Location fields for map-based discovery
    latitude: { type: Number },
    longitude: { type: Number },
    
    // Performance & rating fields
    rating: { type: Number, default: 0, min: 0, max: 5 },
    totalJobs: { type: Number, default: 0, min: 0 },
    yearsExperience: { type: Number, default: 0, min: 0 },
    
    // Profile information
    profileImage: { type: String },
    certifications: [{ type: String }],
    verified: { type: Boolean, default: false },
    bio: { type: String, trim: true },
    
    // Pricing
    pricePerHour: { type: Number, min: 0 },
    
    // Availability
    currentlyAvailable: { type: Boolean, default: true }
}, { timestamps: true });

// Indexes for better query performance
technicianSchema.index({ name: 1 });
technicianSchema.index({ skills: 1 });
technicianSchema.index({ latitude: 1, longitude: 1 });
technicianSchema.index({ rating: -1 });
technicianSchema.index({ active: 1, currentlyAvailable: 1 });

const Technician = mongoose.model('Technician', technicianSchema);

module.exports = Technician;
