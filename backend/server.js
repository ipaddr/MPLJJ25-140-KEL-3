const express = require('express');
const dotenv = require('dotenv');
const db = require('./config/firebaseConfig');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.get('/', (req, res) => {
    res.send('NutriSmart Backend is Running');
});

app.listen(PORT, () => {
    console.log("Server is running on port ${PORT}");
});