const express = require('express');
const router = express.Router();
const educationController = require('./education.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const { isAdmin, isAdminOrParent } = require('../../middleware/role.middleware');

// All routes require authentication
router.use(authMiddleware);

// Create educational content (admin only)
router.post(
  '/',
  isAdmin,
  educationController.upload.single('file'),
  educationController.createEducationalContent
);

// Get all educational content (paginated)
router.get('/', isAdminOrParent, educationController.getAllEducationalContent);

// Get educational content by ID
router.get('/:id', isAdminOrParent, educationController.getEducationalContentById);

// Update educational content (admin only)
router.put('/:id', isAdmin, educationController.updateEducationalContent);

// Delete educational content (admin only)
router.delete('/:id', isAdmin, educationController.deleteEducationalContent);

module.exports = router;