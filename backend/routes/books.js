const express = require('express');
const {
  getBooks,
  getBook,
  createBook,
  updateBook,
  deleteBook,
} = require('../controllers/bookController');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');

const router = express.Router();

router.get('/', auth, getBooks);
router.get('/:id', auth, getBook);
router.post('/', auth, requireRole('admin'), createBook);
router.put('/:id', auth, requireRole('admin'), updateBook);
router.delete('/:id', auth, requireRole('admin'), deleteBook);

module.exports = router;
