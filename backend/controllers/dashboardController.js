const Book = require('../models/Book');
const User = require('../models/User');
const Reservation = require('../models/Reservation');
const Loan = require('../models/Loan');

const getAdminOverview = async (req, res) => {
  try {
    const [totalBooks, availableBooks, pendingBorrows, borrowedBooks, totalUsers] =
      await Promise.all([
        Book.count(),
        Book.count({ where: { status: 'available' } }),
        Book.count({ where: { status: 'pending' } }),
        Book.count({ where: { status: 'borrowed' } }),
        User.count(),
      ]);

    return res.json({
      totalBooks,
      availableBooks,
      pendingBorrows,
      borrowedBooks,
      totalUsers,
    });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const getUserOverview = async (req, res) => {
  try {
    const [totalBooks, myPending, myBorrowed] = await Promise.all([
      Book.count(),
      Reservation.count({
        where: { status: 'pending', userId: req.user.id },
      }),
      Loan.count({ where: { status: 'issued', userId: req.user.id } }),
    ]);

    return res.json({
      totalBooks,
      myPending,
      myBorrowed,
    });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { getAdminOverview, getUserOverview };
