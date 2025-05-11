const { admin, storage } = require('../config/firebase');
const FoodItem = require('../models/FoodItem');
const { validateFoodItemInput } = require('../utils/validators');
const { generateQRCode } = require('../services/qrCodeService');

exports.getAllFoodItems = async (req, res) => {
  try {
    // Get all food items
    const foodItems = await FoodItem.getAll();

    return res.status(200).json({
      success: true,
      count: foodItems.length,
      data: foodItems
    });
  } catch (error) {
    console.error('Error fetching food items:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getFoodItemById = async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    return res.status(200).json({
      success: true,
      data: foodItem
    });
  } catch (error) {
    console.error('Error fetching food item:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.addFoodItem = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to add food items'
      });
    }

    // Validate input
    const { errors, isValid } = validateFoodItemInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { 
      name, 
      description, 
      type, 
      quantity, 
      unitOfMeasure, 
      nutritionalInfo 
    } = req.body;

    // Handle file upload if image exists
    let imageUrl = '';
    if (req.file) {
      const bucket = storage.bucket();
      const blob = bucket.file(`food-items/${Date.now()}_${req.file.originalname}`);
      
      // Create a write stream and upload the file
      const blobStream = blob.createWriteStream({
        metadata: {
          contentType: req.file.mimetype
        }
      });
      
      blobStream.on('error', (error) => {
        throw new Error('Error uploading image: ' + error.message);
      });
      
      blobStream.on('finish', async () => {
        // Make the file publicly accessible
        await blob.makePublic();
        
        // The public URL
        imageUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
      });
      
      blobStream.end(req.file.buffer);
    }

    // Generate QR code for the food item
    const qrCodeData = {
      type: 'food-item',
      id: '', // Will be filled after creation
      name,
      description: description.substring(0, 50) // Truncate for QR code
    };
    
    // Create food item first without QR Code
    const newFoodItem = await FoodItem.create({
      name,
      description,
      type,
      imageUrl,
      quantity,
      unitOfMeasure,
      nutritionalInfo,
      qrCode: '' // Will be updated
    });
    
    // Update QR code data with the new ID
    qrCodeData.id = newFoodItem.id;
    const qrCode = await generateQRCode(JSON.stringify(qrCodeData));
    
    // Update the food item with the QR code
    await newFoodItem.update({ qrCode });

    return res.status(201).json({
      success: true,
      message: 'Food item added successfully',
      data: {
        ...newFoodItem,
        qrCode
      }
    });
  } catch (error) {
    console.error('Error adding food item:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.updateFoodItem = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update food items'
      });
    }

    // Find food item
    let foodItem = await FoodItem.findById(req.params.id);
    
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Validate input
    const { errors, isValid } = validateFoodItemInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { 
      name, 
      description, 
      type, 
      quantity, 
      unitOfMeasure, 
      nutritionalInfo 
    } = req.body;

    // Handle file upload if new image exists
    let imageUrl = foodItem.imageUrl;
    if (req.file) {
      const bucket = storage.bucket();
      const blob = bucket.file(`food-items/${Date.now()}_${req.file.originalname}`);
      
      // Create a write stream and upload the file
      const blobStream = blob.createWriteStream({
        metadata: {
          contentType: req.file.mimetype
        }
      });
      
      blobStream.on('error', (error) => {
        throw new Error('Error uploading image: ' + error.message);
      });
      
      blobStream.on('finish', async () => {
        // Make the file publicly accessible
        await blob.makePublic();
        
        // The public URL
        imageUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
      });
      
      blobStream.end(req.file.buffer);
    }

    // Update food item
    const updatedFoodItem = await foodItem.update({
      name: name || foodItem.name,
      description: description || foodItem.description,
      type: type || foodItem.type,
      imageUrl,
      quantity: quantity || foodItem.quantity,
      unitOfMeasure: unitOfMeasure || foodItem.unitOfMeasure,
      nutritionalInfo: nutritionalInfo || foodItem.nutritionalInfo
    });

    return res.status(200).json({
      success: true,
      message: 'Food item updated successfully',
      data: updatedFoodItem
    });
  } catch (error) {
    console.error('Error updating food item:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.deleteFoodItem = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete food items'
      });
    }

    // Find food item
    const foodItem = await FoodItem.findById(req.params.id);
    
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Delete the image from storage if exists
    if (foodItem.imageUrl) {
      const bucket = storage.bucket();
      const fileName = foodItem.imageUrl.split('/').pop();
      const file = bucket.file(`food-items/${fileName}`);
      
      try {
        await file.delete();
      } catch (error) {
        console.error('Error deleting image file:', error);
        // Continue with deletion even if image removal fails
      }
    }

    // Delete food item
    await foodItem.delete();

    return res.status(200).json({
      success: true,
      message: 'Food item deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting food item:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.generateQRCode = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to generate QR codes'
      });
    }

    const { id } = req.params;
    
    // Find food item
    const foodItem = await FoodItem.findById(id);
    
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Generate QR code data
    const qrCodeData = {
      type: 'food-item',
      id: foodItem.id,
      name: foodItem.name,
      description: foodItem.description.substring(0, 50) // Truncate for QR code
    };
    
    // Generate QR code
    const qrCode = await generateQRCode(JSON.stringify(qrCodeData));
    
    // Update food item with QR code
    await foodItem.update({ qrCode });

    return res.status(200).json({
      success: true,
      message: 'QR code generated successfully',
      data: {
        qrCode
      }
    });
  } catch (error) {
    console.error('Error generating QR code:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};