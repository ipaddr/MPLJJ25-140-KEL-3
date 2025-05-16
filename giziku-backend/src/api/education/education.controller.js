const { db, storage } = require('../../config/firebase');
const { apiResponse } = require('../../utils/apiResponse');
const { v4: uuidv4 } = require('uuid');
const multer = require('multer');
const path = require('path');

// Multer setup for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'image/jpeg', 
      'image/png', 
      'video/mp4', 
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File type not allowed'));
    }
  }
});

/**
 * Create educational content (admin only)
 */
const createEducationalContent = async (req, res) => {
  try {
    const { title, type, description, category } = req.body;
    const userId = req.user.uid;
    
    // Generate ID for the content
    const contentId = uuidv4();
    
    // Create content object
    const contentData = {
      id: contentId,
      title,
      type, // 'article', 'video', 'infographic'
      description,
      category,
      createdBy: userId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      viewCount: 0
    };
    
    // Handle file upload if present
    if (req.file) {
      const fileExtension = path.extname(req.file.originalname);
      const fileName = `education/${contentId}${fileExtension}`;
      
      // Upload to Firebase Storage
      const fileRef = storage.bucket().file(fileName);
      const blobStream = fileRef.createWriteStream({
        metadata: {
          contentType: req.file.mimetype
        }
      });
      
      // Handle stream errors
      blobStream.on('error', (error) => {
        console.error('File upload error:', error);
        return apiResponse(res, 500, 'File upload failed');
      });
      
      // On success, get file URL
      blobStream.on('finish', async () => {
        // Make file publicly accessible
        await fileRef.makePublic();
        
        // Get public URL
        const fileUrl = `https://storage.googleapis.com/${storage.bucket().name}/${fileName}`;
        
        // Update content with file URL
        contentData.fileUrl = fileUrl;
        
        // Save to Firestore
        await db.collection('educationalContent').doc(contentId).set(contentData);
        
        return apiResponse(res, 201, 'Educational content created successfully', contentData);
      });
      
      // Write file to storage
      blobStream.end(req.file.buffer);
    } else {
      // Save content to Firestore (without file)
      await db.collection('educationalContent').doc(contentId).set(contentData);
      return apiResponse(res, 201, 'Educational content created successfully', contentData);
    }
  } catch (error) {
    console.error('Create educational content error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Get all educational content (paginated)
 */
const getAllEducationalContent = async (req, res) => {
  try {
    const { limit = 10, page = 1, category, type } = req.query;
    const limitNum = parseInt(limit);
    const offset = (parseInt(page) - 1) * limitNum;
    
    // Build query based on filters
    let query = db.collection('educationalContent');
    
    if (category) {
      query = query.where('category', '==', category);
    }
    
    if (type) {
      query = query.where('type', '==', type);
    }
    
    // Get total count for pagination
    const countQuery = query;
    const countSnapshot = await countQuery.count().get();
    const totalItems = countSnapshot.data().count;
    
    // Get paginated results
    query = query.orderBy('createdAt', 'desc')
      .limit(limitNum)
      .offset(offset);
    
    const snapshot = await query.get();
    
    const content = [];
    snapshot.forEach(doc => {
      content.push(doc.data());
    });
    
    return apiResponse(res, 200, 'Educational content retrieved successfully', {
      content,
      pagination: {
        totalItems,
        currentPage: parseInt(page),
        totalPages: Math.ceil(totalItems / limitNum),
        itemsPerPage: limitNum
      }
    });
  } catch (error) {
    console.error('Get educational content error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Get educational content by ID
 */
const getEducationalContentById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const contentDoc = await db.collection('educationalContent').doc(id).get();
    
    if (!contentDoc.exists) {
      return apiResponse(res, 404, 'Educational content not found');
    }
    
    const contentData = contentDoc.data();
    
    // Update view count
    await db.collection('educationalContent').doc(id).update({
      viewCount: contentData.viewCount + 1
    });
    
    // Return content with updated view count
    return apiResponse(res, 200, 'Educational content retrieved successfully', {
      ...contentData,
      viewCount: contentData.viewCount + 1
    });
  } catch (error) {
    console.error('Get educational content by ID error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Update educational content (admin only)
 */
const updateEducationalContent = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, category } = req.body;
    
    // Check if content exists
    const contentDoc = await db.collection('educationalContent').doc(id).get();
    
    if (!contentDoc.exists) {
      return apiResponse(res, 404, 'Educational content not found');
    }
    
    // Update fields
    const updateData = {
      updatedAt: new Date().toISOString()
    };
    
    if (title) updateData.title = title;
    if (description) updateData.description = description;
    if (category) updateData.category = category;
    
    // Update in Firestore
    await db.collection('educationalContent').doc(id).update(updateData);
    
    // Get updated content
    const updatedDoc = await db.collection('educationalContent').doc(id).get();
    
    return apiResponse(res, 200, 'Educational content updated successfully', updatedDoc.data());
  } catch (error) {
    console.error('Update educational content error:', error);
    return apiResponse(res, 500, error.message);
  }
};

/**
 * Delete educational content (admin only)
 */
const deleteEducationalContent = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if content exists
    const contentDoc = await db.collection('educationalContent').doc(id).get();
    
    if (!contentDoc.exists) {
      return apiResponse(res, 404, 'Educational content not found');
    }
    
    const contentData = contentDoc.data();
    
    // Delete file from storage if exists
    if (contentData.fileUrl) {
      const fileUrl = contentData.fileUrl;
      const fileName = fileUrl.split('/').pop();
      
      await storage.bucket().file(`education/${fileName}`).delete()
        .catch(err => {
          console.warn('Failed to delete file:', err);
          // Continue with deletion even if file deletion fails
        });
    }
    
    // Delete from Firestore
    await db.collection('educationalContent').doc(id).delete();
    
    return apiResponse(res, 200, 'Educational content deleted successfully');
  } catch (error) {
    console.error('Delete educational content error:', error);
    return apiResponse(res, 500, error.message);
  }
};

module.exports = {
  upload,
  createEducationalContent,
  getAllEducationalContent,
  getEducationalContentById,
  updateEducationalContent,
  deleteEducationalContent
};