const { db } = require('../../config/firebase');
const { apiResponse } = require('../../utils/apiResponse');

/**
 * Get dashboard statistics (for admin)
 */
const getAdminDashboardStats = async (req, res) => {
  try {
    // Total registered children
    const childrenSnapshot = await db.collection('children').count().get();
    const totalChildren = childrenSnapshot.data().count;

    // Total distributed aid this month
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);
    
    const distributionSnapshot = await db.collection('distributionRecords')
      .where('isRedeemed', '==', true)
      .where('redeemedAt', '>=', startOfMonth.toISOString())
      .count()
      .get();
    
    const monthlyDistributions = distributionSnapshot.data().count;

    // Nutrition status breakdown
    const nutritionSnapshot = await db.collection('nutritionRecords')
      .orderBy('createdAt', 'desc')
      .get();
    
    const nutritionStats = {
      KURANG: 0,
      NORMAL: 0,
      BERLEBIH: 0
    };

    // Get unique children with their latest nutrition record
    const latestRecords = new Map();
    nutritionSnapshot.forEach(doc => {
      const data = doc.data();
      if (!latestRecords.has(data.childId) || 
          new Date(data.createdAt) > new Date(latestRecords.get(data.childId).createdAt)) {
        latestRecords.set(data.childId, data);
      }
    });

    // Count nutrition statuses
    latestRecords.forEach(record => {
      nutritionStats[record.status]++;
    });

    // Format stats for response
    const stats = {
      totalChildren,
      monthlyDistributions,
      nutritionStats: [
        { status: 'KURANG', count: nutritionStats.KURANG },
        { status: 'NORMAL', count: nutritionStats.NORMAL },
        { status: 'BERLEBIH', count: nutritionStats.BERLEBIH }
      ]
    };

    return apiResponse(res, 200, 'Dashboard statistics retrieved successfully', stats);
  } catch (error) {
    console.error('Dashboard stats error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Get parent dashboard stats for their children
 */
const getParentDashboardStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // Get all children for the parent
    const childrenSnapshot = await db.collection('children')
      .where('parentId', '==', userId)
      .get();
    
    const children = [];
    const childIds = [];
    
    childrenSnapshot.forEach(doc => {
      const childData = doc.data();
      children.push(childData);
      childIds.push(childData.id);
    });

    // Get latest nutrition record for each child
    const nutritionData = [];
    
    for (const childId of childIds) {
      const nutritionSnapshot = await db.collection('nutritionRecords')
        .where('childId', '==', childId)
        .orderBy('createdAt', 'desc')
        .limit(1)
        .get();
      
      if (!nutritionSnapshot.empty) {
        nutritionData.push({
          childId,
          ...nutritionSnapshot.docs[0].data()
        });
      }
    }

    // Get recent distribution records
    const distributionSnapshot = await db.collection('distributionRecords')
      .where('childId', 'in', childIds)
      .orderBy('createdAt', 'desc')
      .limit(5)
      .get();
    
    const recentDistributions = [];
    distributionSnapshot.forEach(doc => {
      recentDistributions.push(doc.data());
    });

    return apiResponse(res, 200, 'Parent dashboard data retrieved', {
      children,
      nutritionData,
      recentDistributions
    });
  } catch (error) {
    console.error('Parent dashboard error:', error);
    return apiResponse(res, 500, error.message);
  }
};

module.exports = {
  getAdminDashboardStats,
  getParentDashboardStats
};