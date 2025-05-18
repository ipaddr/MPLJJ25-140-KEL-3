const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

router.post("/register", authController.registerUser);
router.post("/login", authController.loginUser); // optional
router.get("/verify", authController.verifyToken);

module.exports = router;
