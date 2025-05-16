/**
 * Standard API response format
 * @param {Object} res - Express response object
 * @param {Number} statusCode - HTTP status code
 * @param {String} message - Response message
 * @param {Object} data - Response data
 * @param {Boolean} success - Success flag
 * @returns {Object} Response object
 */
const apiResponse = (res, statusCode = 200, message = '', data = null, success = null) => {
  // Automatically determine success based on status code if not explicitly provided
  if (success === null) {
    success = statusCode >= 200 && statusCode < 400;
  }

  const response = {
    success,
    message,
    ...(data !== null && { data }),
    timestamp: new Date().toISOString()
  };

  return res.status(statusCode).json(response);
};

module.exports = { apiResponse };