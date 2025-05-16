const { apiResponse } = require('../utils/apiResponse');

const checkRole = (roles = []) => {
  return (req, res, next) => {
    if (!req.user) {
      return apiResponse(res, 401, 'Unauthorized - User not authenticated');
    }

    const userRole = req.user.role;
    
    if (roles.length && !roles.includes(userRole)) {
      return apiResponse(res, 403, 'Forbidden - Insufficient permissions');
    }

    next();
  };
};

// Predefined middleware for common role checks
const isAdmin = checkRole(['admin']);
const isParent = checkRole(['parent']);
const isAdminOrParent = checkRole(['admin', 'parent']);

module.exports = {
  checkRole,
  isAdmin,
  isParent,
  isAdminOrParent
};