const { db } = require('../../config/firebase');
const { apiResponse } = require('../../utils/apiResponse');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');

/**
 * Generate QR code for aid distribution
 */
const generateQRCode = async (req, res) => {
  try {
    const { childId, aidType, quantity } = req.body;
    const userId = req.user.uid;

    // Validate child belongs to user if not admin
    if (req.user.role === 'parent') {
      const childDoc = await db.collection('children')
        .doc(childId)
        .get();
      
      if (!childDoc.exists || childDoc.data().parentId !== userId) {
        return apiResponse(res, 403, 'Unauthorized to generate QR for this child');
      }
    }

    // Create distribution record
    const distributionId = uuidv4();
    const qrData = {
      distributionId,
      childId,
      aidType,
      quantity,
      createdBy: userId,
      timestamp: new Date().toISOString(),
      isRedeemed: false
    };

    // Save to database
    await db.collection('distributionRecords').doc(distributionId).set(qrData);

    // Generate QR code
    const qrCodeData = JSON.stringify(qrData);
    const qrCodeImage = await QRCode.toDataURL(qrCodeData);

    return apiResponse(res, 200, 'QR Code generated successfully', {
      qrCode: qrCodeImage,
      distributionId
    });
  } catch (error) {
    console.error('QR generation error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Verify QR code for aid distribution
 */
const verifyQRCode = async (req, res) => {
  try {
    const { qrData } = req.body;
    
    let distributionData;
    try {
      distributionData = JSON.parse(qrData);
    } catch (e) {
      return apiResponse(res, 400, 'Invalid QR code data');
    }

    const { distributionId } = distributionData;

    // Get distribution record
    const distributionDoc = await db.collection('distributionRecords')
      .doc(distributionId)
      .get();
    
    if (!distributionDoc.exists) {
      return apiResponse(res, 404, 'Distribution record not found');
    }

    const distribution = distributionDoc.data();

    // Check if already redeemed
    if (distribution.isRedeemed) {
      return apiResponse(res, 400, 'Aid already distributed', {
        distributionData: distribution
      });
    }

    // Mark as redeemed
    await db.collection('distributionRecords')
      .doc(distributionId)
      .update({
        isRedeemed: true,
        redeemedAt: new Date().toISOString(),
        redeemedBy: req.user.uid
      });

    return apiResponse(res, 200, 'QR Code verified successfully', {
      distributionData: {
        ...distribution,
        isRedeemed: true,
        redeemedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('QR verification error:', error);
    return apiResponse(res, 500, error.message);
  }
};

module.exports = {
  generateQRCode,
  verifyQRCode
};