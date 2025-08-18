const mongoose = require('mongoose');

const SERVICE_STATUS = ['pending', 'approved', 'in-progress', 'completed', 'cancelled'];

const serviceRequestSchema = new mongoose.Schema({
    userID: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    category: { type: String, required: true, trim: true },
    customerName: { type: String, required: true, trim: true },
    phone: { type: String, required: true, trim: true },
    address: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    preferredDate: { type: Date, required: true },
    preferredTime: { type: String, required: true },
    status: { type: String, enum: SERVICE_STATUS, default: 'pending', index: true },
    assigneeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Technician' },
    assigneeName: { type: String, trim: true },
    assigneePhone: { type: String, trim: true },
    notes: { type: String, trim: true }
}, { timestamps: true });

// Helpful indexes for common queries
serviceRequestSchema.index({ userID: 1, createdAt: -1 });
serviceRequestSchema.index({ phone: 1, createdAt: -1 });
serviceRequestSchema.index({ status: 1, createdAt: -1 });

const ServiceRequest = mongoose.model('ServiceRequest', serviceRequestSchema);

module.exports = { ServiceRequest, SERVICE_STATUS };
