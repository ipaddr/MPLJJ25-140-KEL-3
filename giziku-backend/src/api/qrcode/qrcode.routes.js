const express = require('express');
const router = express.Router();
const qrcodeController = require('./qrcode.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const { isAdmin, isAdminOrParent } = require('../../middleware/role.middleware');

// All routes require authentication
router.use(authMiddleware);

// Generate QR code
router.post('/generate', isAdminOrParent, qrcodeController.generateQRCode);

// Verify QR code (admin only)
router.post('/verify', isAdmin, qrcodeController.verifyQRCode);

module.exports = router;