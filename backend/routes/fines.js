const express = require('express');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const {
  listFines,
  payFine,
  updateFineAmount,
  clearFine,
} = require('../controllers/fineController');

const router = express.Router();

router.get('/', auth, requireRole('admin'), listFines);
router.post('/:id/pay', auth, requireRole('admin'), payFine);
router.put('/:id', auth, requireRole('admin'), updateFineAmount);
router.delete('/:id', auth, requireRole('admin'), clearFine);

module.exports = router;
