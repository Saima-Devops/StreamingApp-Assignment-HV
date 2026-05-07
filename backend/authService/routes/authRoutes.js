const express = require('express');
const router = express.Router();

// Register
router.post('/register', (req, res) => {
  res.json({
    message: 'User registered successfully ✅',
    data: req.body
  });
});

// Login
router.post('/login', (req, res) => {
  res.json({
    message: 'User logged in successfully ✅',
    data: req.body
  });
});

module.exports = router;
