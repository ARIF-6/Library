const express = require('express');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const {
  createReservation,
  listMyReservations,
  listAllReservations,
  approveReservation,
  rejectReservation,
  cancelReservation,
  deleteReservation,
} = require('../controllers/reservationController');

const router = express.Router();

router.post('/', auth, requireRole('user'), createReservation);
router.get('/me', auth, requireRole('user'), listMyReservations);
router.get('/', auth, requireRole('admin'), listAllReservations);
router.post('/:id/approve', auth, requireRole('admin'), approveReservation);
router.post('/:id/reject', auth, requireRole('admin'), rejectReservation);
router.post('/:id/cancel', auth, requireRole('user'), cancelReservation);
router.delete('/:id', auth, requireRole('admin'), deleteReservation);

module.exports = router;
