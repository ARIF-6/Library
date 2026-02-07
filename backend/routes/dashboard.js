const express = require('express');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const {
  getAdminOverview,
  getUserOverview,
} = require('../controllers/dashboardController');

const router = express.Router();

router.get('/admin', auth, requireRole('admin'), getAdminOverview);
router.get('/user', auth, requireRole('user'), getUserOverview);

module.exports = router;
