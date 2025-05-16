const express = require('express');
const router = express.Router();
const authController = require('./auth.controller');
const authMiddleware = require('../../middleware/auth.middleware');

// Public routes
router.post('/register', authController.register);

// Protected routes
router.get('/profile', authMiddleware, authController.getProfile);

module.exports = router;