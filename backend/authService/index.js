const express = require('express');
const cors = require('cors');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// CORS configuration
const allowedOrigins = (process.env.CLIENT_URLS || process.env.CLIENT_URL || 'http://localhost:3000')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));

// Middleware
app.use(express.json());
app.use(cookieParser());

require('./util/conn');

// Health check route
app.get('/', (req, res) => {
  res.json({ success: true, service: 'auth', status: 'ok' });
});

app.use('/api/health', require('./routes/healthCheck.route'));
app.use('/api/auth/health', require('./routes/healthCheck.route'));

// Routes
app.use('/api/auth', require('./routes/user.route'));

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    message: 'Route not found',
    path: req.originalUrl
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Auth Service running on port ${PORT}`);
});
