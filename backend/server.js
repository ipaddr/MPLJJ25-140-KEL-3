const express = require('express');
const dotenv = require('dotenv');
const db = require('./config/firebaseConfig');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json()); // penting agar bisa baca body JSON

app.use('/api/auth', authRoutes); // routing auth

app.get('/', (req, res) => {
  res.send('Giziku Backend is Running');
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
