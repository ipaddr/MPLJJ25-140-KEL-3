const admin = require('../config/firebaseConfig');

// Fungsi untuk mendaftarkan user baru
exports.registerUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password
    });

    res.status(201).json({
      message: 'User created successfully',
      uid: userRecord.uid,
      email: userRecord.email
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Fungsi untuk verifikasi ID token (dikirim dari frontend)
exports.verifyToken = async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token missing or invalid' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    res.status(200).json({
      uid: decodedToken.uid,
      email: decodedToken.email
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
