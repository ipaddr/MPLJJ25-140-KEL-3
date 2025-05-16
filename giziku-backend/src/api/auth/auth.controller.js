const { auth, db } = require('../../config/firebase');
const { apiResponse } = require('../../utils/apiResponse');

/**
 * Register a new user
 */
const register = async (req, res) => {
  try {
    const { email, password, fullName, phoneNumber, role = 'parent' } = req.body;

    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: fullName,
      phoneNumber
    });

    // Set custom claims for role
    await auth.setCustomUserClaims(userRecord.uid, { role });

    // Store additional user data in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      fullName,
      email,
      phoneNumber,
      role,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    return apiResponse(res, 201, 'User registered successfully', { uid: userRecord.uid });
  } catch (error) {
    console.error('Registration error:', error);
    return apiResponse(res, 400, error.message);
  }
};

/**
 * Get current user profile
 */
const getProfile = async (req, res) => {
  try {
    const { uid } = req.user;

    // Get user data from Firestore
    const userDoc = await db.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      return apiResponse(res, 404, 'User not found');
    }

    const userData = userDoc.data();
    
    // Remove sensitive information
    delete userData.password;

    return apiResponse(res, 200, 'Profile retrieved successfully', userData);
  } catch (error) {
    console.error('Get profile error:', error);
    return apiResponse(res, 500, error.message);
  }
};

module.exports = {
  register,
  getProfile
};