const mongoose = require('mongoose');

const technicianSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    phone: { type: String, required: true, trim: true, unique: true },
    skills: [{ type: String, trim: true }],
    active: { type: Boolean, default: true }
}, { timestamps: true });

technicianSchema.index({ name: 1 });

const Technician = mongoose.model('Technician', technicianSchema);

module.exports = Technician;
