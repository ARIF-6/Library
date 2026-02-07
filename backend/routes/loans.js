const express = require('express');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const {
  listMyLoans,
  listAllLoans,
  issueLoan,
  returnLoan,
  updateDueDate,
  deleteLoan,
} = require('../controllers/loanController');

const router = express.Router();

router.get('/me', auth, requireRole('user'), listMyLoans);
router.get('/', auth, requireRole('admin'), listAllLoans);
router.post('/', auth, requireRole('admin'), issueLoan);
router.post('/:id/return', auth, returnLoan);
router.put('/:id/due-date', auth, requireRole('admin'), updateDueDate);
router.delete('/:id', auth, requireRole('admin'), deleteLoan);

module.exports = router;
