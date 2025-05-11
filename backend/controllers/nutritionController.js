const { admin, db } = require('../config/firebase');
const Child = require('../models/child');
const NutritionRecord = require('../models/NutritionRecord');
const NutritionRecommendation = require('../models/NutritionRecommendation');
const { validateNutritionInput } = require('../utils/validators');
const { analyzeNutritionStatus, generateRecommendations } = require('../services/nutritionAI');

exports.addNutritionRecord = async (req, res) => {
  try {
    // Validate input
    const { errors, isValid } = validateNutritionInput(req.body);
    if (!isValid) {
      return res.status(400).json(errors);
    }

    const { childId, weight, height, date } = req.body;
    
    // Find child
    const child = await Child.findById(childId);
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    
    // Check if the user has permission to add records for this child
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to add records for this child'
      });
    }
    
    // Calculate age in months
    const birthDate = child.dateOfBirth.toDate ? child.dateOfBirth.toDate() : new Date(child.dateOfBirth);
    const recordDate = new Date(date);
    const ageInMonths = (recordDate.getFullYear() - birthDate.getFullYear()) * 12 + 
                       (recordDate.getMonth() - birthDate.getMonth());
    
    // Calculate BMI
    const heightInM = height / 100;
    const bmi = weight / (heightInM * heightInM);
    
    // Use AI service to analyze nutrition status
    const nutritionStatus = await analyzeNutritionStatus(ageInMonths, weight, height, bmi, child.gender);
    
    // Create new nutrition record
    const nutritionRecord = await NutritionRecord.create({
      childId,
      date: new Date(date),
      age: ageInMonths,
      weight,
      height,
      bmi,
      nutritionStatus
    });
    
    // Generate nutrition recommendations based on status
    const recommendations = await generateRecommendations(nutritionStatus);
    const nutritionRecommendation = await NutritionRecommendation.create({
      nutritionStatusId: nutritionRecord.id,
      recommendations: recommendations.foodItems,
      mealPlans: recommendations.mealPlans
    });
    
    return res.status(201).json({
      success: true,
      message: 'Nutrition record added successfully',
      data: {
        nutritionRecord,
        recommendations: nutritionRecommendation
      }
    });
    
  } catch (error) {
    console.error('Error adding nutrition record:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getNutritionHistory = async (req, res) => {
  try {
    const { childId } = req.params;
    
    // Find child
    const child = await Child.findById(childId);
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    
    // Check permission
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this child\'s records'
      });
    }
    
    // Get all nutrition records for the child
    const nutritionRecords = await NutritionRecord.findByChildId(childId);
    
    // Get recommendations for each record
    const records = await Promise.all(nutritionRecords.map(async (record) => {
      const recommendation = await NutritionRecommendation.findByNutritionStatusId(record.id);
      return {
        ...record,
        recommendation: recommendation || null
      };
    }));
    
    return res.status(200).json({
      success: true,
      count: records.length,
      data: records
    });
    
  } catch (error) {
    console.error('Error fetching nutrition history:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getNutritionStatus = async (req, res) => {
  try {
    const { childId } = req.params;
    
    // Find child
    const child = await Child.findById(childId);
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    
    // Check permission
    if (child.parentId !== req.user.uid && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this child\'s status'
      });
    }
    
    // Get the latest nutrition record
    const latestRecord = await NutritionRecord.findLatestByChildId(childId);
    if (!latestRecord) {
      return res.status(404).json({
        success: false,
        message: 'No nutrition records found for this child'
      });
    }
    
    // Get recommendations for the record
    const recommendation = await NutritionRecommendation.findByNutritionStatusId(latestRecord.id);
    
    return res.status(200).json({
      success: true,
      data: {
        nutritionRecord: latestRecord,
        recommendation: recommendation || null
      }
    });
    
  } catch (error) {
    console.error('Error fetching nutrition status:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.analyzeNutrition = async (req, res) => {
  try {
    const { weight, height, childId, date } = req.body;
    
    // Find child
    const child = await Child.findById(childId);
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    
    // Calculate age in months
    const birthDate = child.dateOfBirth.toDate ? child.dateOfBirth.toDate() : new Date(child.dateOfBirth);
    const analysisDate = date ? new Date(date) : new Date();
    const ageInMonths = (analysisDate.getFullYear() - birthDate.getFullYear()) * 12 + 
                       (analysisDate.getMonth() - birthDate.getMonth());
    
    // Calculate BMI
    const heightInM = height / 100;
    const bmi = weight / (heightInM * heightInM);
    
    // Use AI service to analyze nutrition status without saving
    const nutritionStatus = await analyzeNutritionStatus(ageInMonths, weight, height, bmi, child.gender);
    
    // Generate recommendations
    const recommendations = await generateRecommendations(nutritionStatus);
    
    return res.status(200).json({
      success: true,
      data: {
        nutritionStatus,
        ageInMonths,
        bmi,
        recommendations
      }
    });
    
  } catch (error) {
    console.error('Error analyzing nutrition:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getNutritionStats = async (req, res) => {
  try {
    // This would be an admin-only endpoint
    
    // Get counts by nutrition status
    const snapshot = await db.collection('nutritionRecords')
      .orderBy('createdAt', 'desc')
      .limit(1000) // Limit for performance
      .get();
    
    const records = snapshot.docs.map(doc => doc.data());
    
    // Calculate statistics
    const statusCounts = records.reduce((acc, record) => {
      const status = record.nutritionStatus;
      if (!acc[status]) acc[status] = 0;
      acc[status]++;
      return acc;
    }, {});
    
    // Calculate average BMI
    const totalBmi = records.reduce((sum, record) => sum + record.bmi, 0);
    const averageBmi = records.length > 0 ? totalBmi / records.length : 0;
    
    return res.status(200).json({
      success: true,
      data: {
        totalRecords: records.length,
        statusCounts,
        averageBmi
      }
    });
    
  } catch (error) {
    console.error('Error fetching nutrition stats:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};