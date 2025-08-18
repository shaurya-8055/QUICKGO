const express = require('express');
const router = express.Router();
const asyncHandler = require('express-async-handler');
const Technician = require('../model/technician');

// GET /technicians?skills=ac,fridge&active=true
router.get('/', asyncHandler(async (req, res) => {
  const { skills, active } = req.query;
  const q = {};
  if (skills) q.skills = { $all: String(skills).split(',').map(s => s.trim()).filter(Boolean) };
  if (active !== undefined) q.active = active === 'true';
  const items = await Technician.find(q).sort({ name: 1 });
  res.json({ success: true, message: 'OK', data: items });
}));

router.post('/', asyncHandler(async (req, res) => {
  const { name, phone, skills = [], active = true } = req.body || {};
  if (!name || !phone) return res.status(400).json({ success: false, message: 'Missing required fields', data: null });
  const doc = new Technician({ name, phone, skills, active });
  await doc.save();
  res.json({ success: true, message: 'Created', data: doc });
}));

router.patch('/:id', asyncHandler(async (req, res) => {
  const id = req.params.id;
  const { name, phone, skills, active } = req.body || {};
  const update = {};
  if (name !== undefined) update.name = name;
  if (phone !== undefined) update.phone = phone;
  if (skills !== undefined) update.skills = skills;
  if (active !== undefined) update.active = active;
  const doc = await Technician.findByIdAndUpdate(id, update, { new: true });
  if (!doc) return res.status(404).json({ success: false, message: 'Not found', data: null });
  res.json({ success: true, message: 'Updated', data: doc });
}));

module.exports = router;
