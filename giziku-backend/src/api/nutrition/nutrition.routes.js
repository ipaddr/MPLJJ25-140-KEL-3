const express = require('express');
const router = express.Router();
const nutritionController = require('./nutrition.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const { isParent } = require('../../middleware/role.middleware');

// All routes require authentication
router.use(authMiddleware);

// Calculate and save nutrition status
router.post('/calculate', isParent, nutritionController.calculateNutritionStatus);

// Get nutrition history for a child
router.get('/history/:childId', isParent, nutritionController.getNutritionHistory);

module.exports = router;