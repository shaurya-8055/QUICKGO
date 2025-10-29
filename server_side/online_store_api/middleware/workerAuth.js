const jwt = require('jsonwebtoken');
const Worker = require('../model/worker');

/**
 * Worker Authentication Middleware
 * Validates JWT tokens for worker routes
 * @param {boolean} requireActive - If true, only allows active workers (default: true)
 */
function workerAuth(requireActive = true) {
  return async (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (!token) {
        return res.status(401).json({ success: false, message: 'Access token required' });
      }
      
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      
      // Verify the token is for a worker role
      if (payload.role !== 'worker') {
        return res.status(403).json({ 
          success: false, 
          message: 'Worker authentication required' 
        });
      }
      
      // Check if worker still exists and token version matches
      const worker = await Worker.findById(payload.id).select(
        'tokenVersion accountStatus active verified phone isPhoneVerified'
      );
      
      if (!worker) {
        return res.status(401).json({ success: false, message: 'Worker not found' });
      }
      
      // Check token version for security (logout invalidation)
      if (worker.tokenVersion !== payload.tokenVersion) {
        return res.status(401).json({ 
          success: false, 
          message: 'Token expired. Please login again.' 
        });
      }
      
      // Check if phone is verified
      if (!worker.isPhoneVerified) {
        return res.status(403).json({ 
          success: false, 
          message: 'Phone verification required',
          requiresVerification: true 
        });
      }
      
      // Check account status
      if (worker.accountStatus === 'suspended') {
        return res.status(403).json({ 
          success: false, 
          message: 'Your account has been suspended. Please contact support.',
          accountStatus: 'suspended'
        });
      }
      
      if (worker.accountStatus === 'deactivated') {
        return res.status(403).json({ 
          success: false, 
          message: 'Your account is deactivated. Please reactivate to continue.',
          accountStatus: 'deactivated'
        });
      }
      
      if (worker.accountStatus === 'pending_approval') {
        return res.status(403).json({ 
          success: false, 
          message: 'Your account is pending admin approval.',
          accountStatus: 'pending_approval'
        });
      }
      
      // Check if account is active (for routes that require active status)
      if (requireActive && !worker.active) {
        return res.status(403).json({ 
          success: false, 
          message: 'Account is not active. Please activate your account.',
          accountStatus: 'inactive'
        });
      }
      
      req.worker = payload;
      req.worker.dbWorker = worker; // Include DB worker for additional checks
      
      // Update last seen (optional, for activity tracking)
      if (process.env.TRACK_WORKER_ACTIVITY === 'true') {
        await Worker.updateOne(
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

/**
 * Optional Worker Auth - doesn't fail if no token
 * Useful for public routes that have optional worker features
 */
function optionalWorkerAuth() {
  return async (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (token) {
        const payload = jwt.verify(token, process.env.JWT_SECRET);
        
        if (payload.role === 'worker') {
          const worker = await Worker.findById(payload.id).select('tokenVersion accountStatus');
          
          if (worker && worker.tokenVersion === payload.tokenVersion) {
            req.worker = payload;
            req.worker.dbWorker = worker;
          }
        }
      }
      
      next();
    } catch (e) {
      // Ignore token errors in optional auth
      next();
    }
  };
}

/**
 * Admin or Worker Auth - allows both admin and worker access
 * Useful for routes that can be accessed by admins managing workers
 */
function adminOrWorkerAuth() {
  return async (req, res, next) => {
    try {
      const header = req.headers['authorization'] || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (!token) {
        return res.status(401).json({ success: false, message: 'Access token required' });
      }
      
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      
      if (payload.role === 'admin') {
        // Admin access - use User model
        const User = require('../model/user');
        const user = await User.findById(payload.id).select('role tokenVersion');
        
        if (!user || user.tokenVersion !== payload.tokenVersion) {
          return res.status(401).json({ success: false, message: 'Invalid token' });
        }
        
        req.user = payload;
        req.user.dbUser = user;
        req.isAdmin = true;
      } else if (payload.role === 'worker') {
        // Worker access
        const worker = await Worker.findById(payload.id).select(
          'tokenVersion accountStatus active verified'
        );
        
        if (!worker || worker.tokenVersion !== payload.tokenVersion) {
          return res.status(401).json({ success: false, message: 'Invalid token' });
        }
        
        req.worker = payload;
        req.worker.dbWorker = worker;
        req.isAdmin = false;
      } else {
        return res.status(403).json({ 
          success: false, 
          message: 'Admin or worker access required' 
        });
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

/**
 * Verified Worker Auth - requires worker to be verified
 * Useful for routes that require verified worker status (e.g., accepting jobs)
 */
function verifiedWorkerAuth() {
  return async (req, res, next) => {
    const authMiddleware = workerAuth();
    
    authMiddleware(req, res, async (err) => {
      if (err) return next(err);
      
      const worker = req.worker.dbWorker;
      
      if (!worker.verified) {
        return res.status(403).json({ 
          success: false, 
          message: 'Verified worker status required. Please complete verification process.',
          requiresVerification: true
        });
      }
      
      next();
    });
  };
}

module.exports = { 
  workerAuth,
  optionalWorkerAuth,
  adminOrWorkerAuth,
  verifiedWorkerAuth,
  authenticateWorker: workerAuth() // Default worker auth
};
