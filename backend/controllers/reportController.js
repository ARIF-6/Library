const { Op } = require('sequelize');
const Book = require('../models/Book');
const Loan = require('../models/Loan');
const User = require('../models/User');

const issuedBooksReport = async (req, res) => {
  try {
    const loans = await Loan.findAll({
      where: { status: 'issued' },
      order: [['createdAt', 'DESC']],
    });
    return res.json({ loans, count: loans.length });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const overdueBooksReport = async (req, res) => {
  try {
    const now = new Date();
    const loans = await Loan.findAll({
      where: { status: 'issued', dueDate: { [Op.lt]: now } },
      order: [['dueDate', 'ASC']],
    });
    return res.json({ loans, count: loans.length });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const userActivityReport = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'username', 'email', 'role'],
      order: [['createdAt', 'DESC']],
    });
    const loans = await Loan.findAll();
    const activity = users.map((u) => {
      const userLoans = loans.filter((l) => l.userId === u.id);
      return {
        userId: u.id,
        username: u.username,
        email: u.email,
        role: u.role,
        totalLoans: userLoans.length,
        activeLoans: userLoans.filter((l) => l.status === 'issued').length,
      };
    });
    return res.json({ activity });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const inventoryReport = async (req, res) => {
  try {
    const totalBooks = await Book.count();
    const availableBooks = await Book.count({ where: { status: 'available' } });
    const pendingBooks = await Book.count({ where: { status: 'pending' } });
    const borrowedBooks = await Book.count({ where: { status: 'borrowed' } });
    return res.json({
      totalBooks,
      availableBooks,
      pendingBooks,
      borrowedBooks,
    });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  issuedBooksReport,
  overdueBooksReport,
  userActivityReport,
  inventoryReport,
};
