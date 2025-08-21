const jwt = require('jsonwebtoken');
const User = require('../model/user');

function auth(requiredRole) {
  return async (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (!token) {
        return res.status(401).json({ success: false, message: 'Access token required' });
      }
      
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      
      // Check if user still exists and token version matches
      const user = await User.findById(payload.id).select('role tokenVersion isPhoneVerified');
      if (!user) {
        return res.status(401).json({ success: false, message: 'User not found' });
      }
      
      // Check token version for security (logout invalidation)
      if (user.tokenVersion !== payload.tokenVersion) {
        return res.status(401).json({ success: false, message: 'Token expired. Please login again.' });
      }
      
      // Check if phone is verified (except for admin routes)
      if (!user.isPhoneVerified && requiredRole !== 'admin') {
        return res.status(403).json({ 
          success: false, 
          message: 'Phone verification required',
          requiresVerification: true 
        });
      }
      
      req.user = payload;
      req.user.dbUser = user; // Include DB user for additional checks
      
      // Role-based access control
      if (requiredRole && payload.role !== requiredRole) {
        return res.status(403).json({ 
          success: false, 
          message: `${requiredRole} access required` 
        });
      }
      
      // Update last seen (optional, for activity tracking)
      if (process.env.TRACK_USER_ACTIVITY === 'true') {
        await User.updateOne(
          { _id: payload.id }, 
          { 
            lastLoginAt: new Date(),
            lastLoginIP: req.ip || req.connection.remoteAddress 
          }
        );
      }
      
      next();
    } catch (e) {
      if (e.name === 'TokenExpiredError') {
        return res.status(401).json({ 
          success: false, 
          message: 'Token expired',
          expired: true 
        });
      }
      return res.status(401).json({ success: false, message: 'Invalid token' });
    }
  };
}

// Optional auth - doesn't fail if no token
function optionalAuth() {
  return async (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (token) {
        const payload = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(payload.id).select('role tokenVersion');
        
        if (user && user.tokenVersion === payload.tokenVersion) {
          req.user = payload;
          req.user.dbUser = user;
        }
      }
      
      next();
    } catch (e) {
      // Ignore token errors in optional auth
      next();
    }
  };
}

module.exports = { 
  auth, 
  optionalAuth,
  authenticateToken: auth() // Default auth without role requirement
};
