const { db } = require('../../config/firebase');
const { apiResponse } = require('../../utils/apiResponse');
const { v4: uuidv4 } = require('uuid');
const aiService = require('../../services/ai.service');

/**
 * Calculate and classify nutrition status
 */
const calculateNutritionStatus = async (req, res) => {
  try {
    const { childId, weight, height, age } = req.body;
    const userId = req.user.uid;

    // Validate child belongs to user
    const childDoc = await db.collection('children')
      .doc(childId)
      .get();
    
    if (!childDoc.exists || childDoc.data().parentId !== userId) {
      return apiResponse(res, 403, 'Unauthorized to access this child data');
    }

    // Use AI service to classify nutrition status
    const nutritionData = await aiService.classifyNutritionStatus({
      weight,
      height,
      age,
      gender: childDoc.data().gender
    });

    // Save nutrition record
    const recordId = uuidv4();
    await db.collection('nutritionRecords').doc(recordId).set({
      id: recordId,
      childId,
      parentId: userId,
      weight,
      height,
      age,
      bmi: nutritionData.bmi,
      status: nutritionData.status,
      recommendations: nutritionData.recommendations,
      createdAt: new Date().toISOString()
    });

    return apiResponse(res, 200, 'Nutrition status calculated', nutritionData);
  } catch (error) {
    console.error('Nutrition calculation error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Get nutrition history for a child
 */
const getNutritionHistory = async (req, res) => {
  try {
    const { childId } = req.params;
    const userId = req.user.uid;

    // Validate child belongs to user
    const childDoc = await db.collection('children')
      .doc(childId)
      .get();
    
    if (!childDoc.exists || childDoc.data().parentId !== userId) {
      return apiResponse(res, 403, 'Unauthorized to access this child data');
    }

    // Get nutrition records
    const recordsSnapshot = await db.collection('nutritionRecords')
      .where('childId', '==', childId)
      .orderBy('createdAt', 'desc')
      .get();
    
    const records = [];
    recordsSnapshot.forEach(doc => {
      records.push(doc.data());
    });

    return apiResponse(res, 200, 'Nutrition history retrieved', { records });
  } catch (error) {
    console.error('Get nutrition history error:', error);
    return apiResponse(res, 500, error.message);
  }
};

module.exports = {
  calculateNutritionStatus,
  getNutritionHistory
};