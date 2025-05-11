const { admin, db, auth } = require('../config/firebase');
const User = require('../models/user');
const { validateRegisterInput, validateLoginInput } = require('../utils/validators');

exports.register = async (req, res) => {
  try {
    // Validate input
    const { errors, isValid } = validateRegisterInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { email, password, fullName, phoneNumber, role, address } = req.body;

    // Check if user exists
    const userExists = await User.findByEmail(email);
    if (userExists) {
      return res.status(400).json({ email: 'Email already exists' });
    }

    // Create user in Firebase Auth
    const newAuthUser = await auth.createUser({
      email,
      password,
      displayName: fullName
    });

    // Set custom claims for role
    await auth.setCustomUserClaims(newAuthUser.uid, { role });

    // Create user document in Firestore
    const userData = {
      uid: newAuthUser.uid,
      fullName,
      email,
      phoneNumber,
      role,
      address
    };

    const newUser = await User.create(userData);

    // Generate token
    const token = await auth.createCustomToken(newAuthUser.uid);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      user: {
        uid: newUser.uid,
        fullName: newUser.fullName,
        email: newUser.email,
        role: newUser.role
      }
    });
  } catch (error) {
    console.error('Error registering user:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.login = async (req, res) => {
  try {
    // Validate input
    const { errors, isValid } = validateLoginInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { email, password } = req.body;

    // Get user from Firebase Auth
    const userRecord = await auth.getUserByEmail(email).catch(() => null);
    if (!userRecord) {
      return res.status(404).json({ email: 'User not found' });
    }

    // Custom token doesn't handle password verification, 
    // In a real app you'd use Firebase Auth REST API or SDK for client auth
    // This is just for demonstration purposes
    const token = await auth.createCustomToken(userRecord.uid);

    // Get user details from Firestore
    const user = await User.findById(userRecord.uid);

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        uid: user.uid,
        fullName: user.fullName,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Error logging in:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.uid);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      user: {
        uid: user.uid,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        address: user.address
      }
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { fullName, phoneNumber, address } = req.body;
    
    const user = await User.findById(req.user.uid);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update user data
    const updatedUser = await user.update({
      fullName: fullName || user.fullName,
      phoneNumber: phoneNumber || user.phoneNumber,
      address: address || user.address
    });

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        uid: updatedUser.uid,
        fullName: updatedUser.fullName,
        email: updatedUser.email,
        phoneNumber: updatedUser.phoneNumber,
        role: updatedUser.role,
        address: updatedUser.address
      }
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};