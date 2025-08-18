const jwt = require('jsonwebtoken');

function auth(requiredRole) {
  return (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      if (!token) return res.status(401).json({ success: false, message: 'Missing token' });
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      req.user = payload;
      if (requiredRole && payload.role !== requiredRole) {
        return res.status(403).json({ success: false, message: 'Forbidden' });
      }
      next();
    } catch (e) {
      return res.status(401).json({ success: false, message: 'Invalid token' });
    }
  };
}

module.exports = { auth };
