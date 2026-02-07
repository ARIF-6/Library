require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const sequelize = require('./config/db');

// Test DB connection
sequelize.authenticate()
  .then(() => console.log('Database connected'))
  .catch(err => console.error('Database connection error:', err));

// Sync database
sequelize.sync({ alter: true })
  .then(() => console.log('Database synced'))
  .catch(err => console.error('Sync error:', err));

// Import routes
const authRoutes = require('./routes/auth');
const bookRoutes = require('./routes/books');
const dashboardRoutes = require('./routes/dashboard');
const reservationRoutes = require('./routes/reservations');
const loanRoutes = require('./routes/loans');
const fineRoutes = require('./routes/fines');
const reportRoutes = require('./routes/reports');
const userRoutes = require('./routes/users');

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/books', bookRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/loans', loanRoutes);
app.use('/api/fines', fineRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/users', userRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
