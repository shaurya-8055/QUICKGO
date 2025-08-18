const express = require('express');
const router = express.Router();
const rateLimiters = new Map();
const crypto = require('crypto');
const asyncHandler = require('express-async-handler');
const { ServiceRequest, SERVICE_STATUS } = require('../model/serviceRequest');

// simple in-memory cooldown and dedupe
function makeKey(req) {
  const ip = req.headers['x-forwarded-for']?.split(',')[0] || req.socket.remoteAddress || 'ip';
  return `${ip}|${req.body.phone || ''}`;
}

function payloadHash(body) {
  const keys = ['userID','category','customerName','phone','address','description','preferredDate','preferredTime'];
  const subset = keys.reduce((acc, k) => { acc[k] = body[k]; return acc; }, {});
  return crypto.createHash('sha1').update(JSON.stringify(subset)).digest('hex');
}

router.post('/', asyncHandler(async (req, res) => {
  const { userID, category, customerName, phone, address, description, preferredDate, preferredTime } = req.body || {};
  if (!category || !customerName || !phone || !address || !preferredDate || !preferredTime) {
    return res.status(400).json({ success: false, message: 'Missing required fields', data: null });
  }

  // rate-limit 1/min per ip+phone
  const key = makeKey(req);
  const now = Date.now();
  const rl = rateLimiters.get(key);
  if (rl && now - rl.last < 60_000) {
    return res.status(429).json({ success: false, message: 'Too many requests. Please wait a minute.', data: null });
  }

  // dedupe identical payloads within 10s
  const h = payloadHash(req.body);
  if (rl && rl.hash === h && now - rl.last < 10_000) {
    return res.status(202).json({ success: true, message: 'Duplicate request ignored.', data: rl.lastCreated });
  }

  const doc = new ServiceRequest({ userID, category, customerName, phone, address, description, preferredDate, preferredTime, status: 'pending' });
  await doc.save();

  rateLimiters.set(key, { last: now, hash: h, lastCreated: doc });
  return res.json({ success: true, message: 'Service request created', data: doc });
}));

// GET /service-requests?userID=&status=&from=&to=&page=&limit=
router.get('/', asyncHandler(async (req, res) => {
  const { userID, status, from, to, page = 1, limit = 20 } = req.query;
  const q = {};
  if (userID) q.userID = userID;
  if (status) q.status = status;
  if (from || to) {
    q.createdAt = {};
    if (from) q.createdAt.$gte = new Date(from);
    if (to) q.createdAt.$lte = new Date(to);
  }

  const skip = (Number(page) - 1) * Number(limit);
  const [items, total] = await Promise.all([
    ServiceRequest.find(q).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
    ServiceRequest.countDocuments(q)
  ]);
  res.json({ success: true, message: 'OK', data: { items, total, page: Number(page), limit: Number(limit) } });
}));

// PATCH /service-requests/:id
router.patch('/:id', asyncHandler(async (req, res) => {
  const id = req.params.id;
  const update = {};
  const allowed = ['status','assigneeId','assigneeName','assigneePhone','notes'];
  for (const k of allowed) if (k in req.body) update[k] = req.body[k];
  if (update.status && !SERVICE_STATUS.includes(update.status)) {
    return res.status(400).json({ success: false, message: 'Invalid status', data: null });
  }
  const doc = await ServiceRequest.findByIdAndUpdate(id, update, { new: true });
  if (!doc) return res.status(404).json({ success: false, message: 'Not found', data: null });
  res.json({ success: true, message: 'Updated', data: doc });
}));

// PUT alias for environments that use PUT for updates
router.put('/:id', asyncHandler(async (req, res) => {
  const id = req.params.id;
  const update = {};
  const allowed = ['status','assigneeId','assigneeName','assigneePhone','notes'];
  for (const k of allowed) if (k in req.body) update[k] = req.body[k];
  if (update.status && !SERVICE_STATUS.includes(update.status)) {
    return res.status(400).json({ success: false, message: 'Invalid status', data: null });
  }
  const doc = await ServiceRequest.findByIdAndUpdate(id, update, { new: true });
  if (!doc) return res.status(404).json({ success: false, message: 'Not found', data: null });
  res.json({ success: true, message: 'Updated', data: doc });
}));

// DELETE /service-requests/:id (optional cleanup)
router.delete('/:id', asyncHandler(async (req, res) => {
  const id = req.params.id;
  const doc = await ServiceRequest.findByIdAndDelete(id);
  if (!doc) return res.status(404).json({ success: false, message: 'Not found', data: null });
  res.json({ success: true, message: 'Deleted', data: null });
}));

module.exports = router;
