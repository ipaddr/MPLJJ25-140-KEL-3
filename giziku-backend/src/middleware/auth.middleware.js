const { admin } = require('../config/firebase');
const { apiResponse } = require('../utils/apiResponse');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return apiResponse(res, 401, 'Unauthorized - No token provided');
    }

    const token = authHeader.split(' ')[1];
    
    // Verify the Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    if (!decodedToken) {
      return apiResponse(res, 401, 'Unauthorized - Invalid token');
    }

    // Add user data to request
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      role: decodedToken.role || 'parent' // Default role
    };

    next();
  } catch (error) {
    console.error('Auth Middleware Error:', error);
    return apiResponse(res, 401, 'Unauthorized - Invalid token');
  }
};

module.exports = authMiddleware;