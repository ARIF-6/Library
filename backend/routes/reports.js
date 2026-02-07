const express = require('express');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const {
  issuedBooksReport,
  overdueBooksReport,
  userActivityReport,
  inventoryReport,
} = require('../controllers/reportController');

const router = express.Router();

router.get('/issued', auth, requireRole('admin'), issuedBooksReport);
router.get('/overdue', auth, requireRole('admin'), overdueBooksReport);
router.get('/users', auth, requireRole('admin'), userActivityReport);
router.get('/inventory', auth, requireRole('admin'), inventoryReport);

module.exports = router;
