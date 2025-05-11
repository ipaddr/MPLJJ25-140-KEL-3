const { admin } = require('../config/firebase');
const Child = require('../models/child');
const { validateChildInput } = require('../utils/validators');

exports.getAllChildren = async (req, res) => {
  try {
    // Get all children for the logged-in parent
    const children = await Child.findByParentId(req.user.uid);

    return res.status(200).json({
      success: true,
      count: children.length,
      data: children
    });
  } catch (error) {
    console.error('Error fetching children:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getChildById = async (req, res) => {
  try {
    const child = await Child.findById(req.params.id);
    
    if (!child) {
      return res.status(404).json({
        success: false,
        message: 'Child not found'
      });
    }

    // Check if the child belongs to the logged-in parent
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this child\'s data'
      });
    }

    return res.status(200).json({
      success: true,
      data: child
    });
  } catch (error) {
    console.error('Error fetching child:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.addChild = async (req, res) => {
  try {
    // Validate input
    const { errors, isValid } = validateChildInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { fullName, dateOfBirth, gender } = req.body;

    // Create new child document
    const newChild = await Child.create({
      parentId: req.user.uid,
      fullName,
      dateOfBirth: new Date(dateOfBirth),
      gender
    });

    return res.status(201).json({
      success: true,
      message: 'Child added successfully',
      data: newChild
    });
  } catch (error) {
    console.error('Error adding child:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.updateChild = async (req, res) => {
  try {
    // Find child
    let child = await Child.findById(req.params.id);
    
    if (!child) {
      return res.status(404).json({
        success: false,
        message: 'Child not found'
      });
    }

    // Check ownership
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this child\'s data'
      });
    }

    // Validate input
    const { errors, isValid } = validateChildInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { fullName, dateOfBirth, gender } = req.body;

    // Update child
    const updatedChild = await child.update({
      fullName: fullName || child.fullName,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : child.dateOfBirth,
      gender: gender || child.gender
    });

    return res.status(200).json({
      success: true,
      message: 'Child updated successfully',
      data: updatedChild
    });
  } catch (error) {
    console.error('Error updating child:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.deleteChild = async (req, res) => {
  try {
    // Find child
    const child = await Child.findById(req.params.id);
    
    if (!child) {
      return res.status(404).json({
        success: false,
        message: 'Child not found'
      });
    }

    // Check ownership
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this child\'s data'
      });
    }

    // Delete child
    await child.delete();

    return res.status(200).json({
      success: true,
      message: 'Child deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting child:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};