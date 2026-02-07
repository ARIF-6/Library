const Joi = require('joi');
const Book = require('../models/Book');
const Reservation = require('../models/Reservation');
const Loan = require('../models/Loan');

const createReservation = async (req, res) => {
  const schema = Joi.object({
    bookId: Joi.number().integer().required(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const book = await Book.findByPk(req.body.bookId);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    if (book.status !== 'available') {
      return res.status(400).json({ message: 'Book is not available' });
    }

    const reservation = await Reservation.create({
      bookId: book.id,
      userId: req.user.id,
    });

    await book.update({ status: 'pending', available: false });

    return res.status(201).json({ reservation });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const listMyReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
    });
    return res.json({ reservations });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const listAllReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
      order: [['createdAt', 'DESC']],
    });
    return res.json({ reservations });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const approveReservation = async (req, res) => {
  const schema = Joi.object({
    dueDate: Joi.date().required(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const reservation = await Reservation.findByPk(req.params.id);
    if (!reservation) return res.status(404).json({ message: 'Reservation not found' });
    if (reservation.status !== 'pending') {
      return res.status(400).json({ message: 'Reservation not pending' });
    }

    const book = await Book.findByPk(reservation.bookId);
    if (!book) return res.status(404).json({ message: 'Book not found' });

    const loan = await Loan.create({
      bookId: reservation.bookId,
      userId: reservation.userId,
      issuedBy: req.user.id,
      dueDate: new Date(req.body.dueDate),
    });

    await reservation.update({
      status: 'approved',
      approvedBy: req.user.id,
    });
    await book.update({ status: 'borrowed', available: false });

    return res.json({ reservation, loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const rejectReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findByPk(req.params.id);
    if (!reservation) return res.status(404).json({ message: 'Reservation not found' });
    if (reservation.status !== 'pending') {
      return res.status(400).json({ message: 'Reservation not pending' });
    }

    const book = await Book.findByPk(reservation.bookId);
    if (!book) return res.status(404).json({ message: 'Book not found' });

    await reservation.update({
      status: 'rejected',
      approvedBy: req.user.id,
    });
    await book.update({ status: 'available', available: true });

    return res.json({ reservation });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const cancelReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findByPk(req.params.id);
    if (!reservation) return res.status(404).json({ message: 'Reservation not found' });
    if (reservation.userId !== req.user.id) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    if (reservation.status !== 'pending') {
      return res.status(400).json({ message: 'Reservation not pending' });
    }
    const book = await Book.findByPk(reservation.bookId);
    if (book) {
      await book.update({ status: 'available', available: true });
    }
    await reservation.update({ status: 'cancelled' });
    return res.json({ reservation });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const deleteReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findByPk(req.params.id);
    if (!reservation) return res.status(404).json({ message: 'Reservation not found' });
    await reservation.destroy();
    return res.json({ message: 'Reservation deleted' });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createReservation,
  listMyReservations,
  listAllReservations,
  approveReservation,
  rejectReservation,
  cancelReservation,
  deleteReservation,
};
