const Joi = require('joi');
const Book = require('../models/Book');
const Loan = require('../models/Loan');

const listMyLoans = async (req, res) => {
  try {
    const loans = await Loan.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
    });
    return res.json({ loans });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const listAllLoans = async (req, res) => {
  try {
    const loans = await Loan.findAll({
      order: [['createdAt', 'DESC']],
    });
    return res.json({ loans });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const issueLoan = async (req, res) => {
  const schema = Joi.object({
    bookId: Joi.number().integer().required(),
    userId: Joi.number().integer().required(),
    dueDate: Joi.date().required(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const book = await Book.findByPk(req.body.bookId);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    if (book.status !== 'available') {
      return res.status(400).json({ message: 'Book is not available' });
    }

    const loan = await Loan.create({
      bookId: req.body.bookId,
      userId: req.body.userId,
      issuedBy: req.user.id,
      dueDate: new Date(req.body.dueDate),
    });

    await book.update({ status: 'borrowed', available: false });
    return res.status(201).json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const returnLoan = async (req, res) => {
  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });

    const isOwner = loan.userId === req.user.id;
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    if (loan.status !== 'issued') {
      return res.status(400).json({ message: 'Loan already returned' });
    }

    const now = new Date();
    const dueDate = new Date(loan.dueDate);
    let fineAmount = 0;
    if (now > dueDate) {
      const msPerDay = 1000 * 60 * 60 * 24;
      const daysLate = Math.ceil((now - dueDate) / msPerDay);
      const rate = Number(process.env.FINE_PER_DAY || 1);
      fineAmount = daysLate * rate;
    }

    await loan.update({
      status: 'returned',
      returnedAt: now,
      fineAmount,
      finePaid: fineAmount === 0,
    });

    const book = await Book.findByPk(loan.bookId);
    if (book) {
      await book.update({ status: 'available', available: true });
    }

    return res.json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const updateDueDate = async (req, res) => {
  const schema = Joi.object({
    dueDate: Joi.date().required(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });
    await loan.update({ dueDate: new Date(req.body.dueDate) });
    return res.json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const deleteLoan = async (req, res) => {
  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });
    await loan.destroy();
    return res.json({ message: 'Loan deleted' });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  listMyLoans,
  listAllLoans,
  issueLoan,
  returnLoan,
  updateDueDate,
  deleteLoan,
};
