const express = require('express');
const router = express.Router();

// Import route modules
const authRoutes = require('./auth/auth.routes');
const userRoutes = require('./user/user.routes');
const childRoutes = require('./child/child.routes');
const nutritionRoutes = require('./nutrition/nutrition.routes');
const educationRoutes = require('./education/education.routes');
const distributionRoutes = require('./distribution/distribution.routes');
const qrcodeRoutes = require('./qrcode/qrcode.routes');
const dashboardRoutes = require('./dashboard/dashboard.routes');
const adminRoutes = require('./admin/admin.routes');

// Assign routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/children', childRoutes);
router.use('/nutrition', nutritionRoutes);
router.use('/education', educationRoutes);
router.use('/distribution', distributionRoutes);
router.use('/qrcode', qrcodeRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/admin', adminRoutes);

// Base route
router.get('/', (req, res) => {
  res.json({
    message: 'GiziKu API v1',
    timestamp: new Date()
  });
});

module.exports = router;