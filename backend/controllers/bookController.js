const Joi = require('joi');
const { Op } = require('sequelize');
const Book = require('../models/Book');

const getBooks = async (req, res) => {
  try {
    const search = req.query.search;
    const where = search
      ? {
          [Op.or]: [
            { title: { [Op.iLike]: `%${search}%` } },
            { author: { [Op.iLike]: `%${search}%` } },
            { isbn: { [Op.iLike]: `%${search}%` } },
            { genre: { [Op.iLike]: `%${search}%` } },
          ],
        }
      : {};
    const books = await Book.findAll({ where });
    res.json({ books });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

const getBook = async (req, res) => {
  const { id } = req.params;
  try {
    const book = await Book.findByPk(id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    res.json({ book });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

const createBook = async (req, res) => {
  const schema = Joi.object({
    title: Joi.string().required(),
    author: Joi.string().required(),
    isbn: Joi.string().required(),
    publishedYear: Joi.number().integer().optional(),
    genre: Joi.string().optional(),
    available: Joi.boolean().optional(),
    status: Joi.string().valid('available', 'pending', 'borrowed').optional(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const book = await Book.create(req.body);
    res.status(201).json({ book });
  } catch (err) {
    if (err.name === 'SequelizeUniqueConstraintError') {
      res.status(400).json({ message: 'ISBN already exists' });
    } else {
      res.status(500).json({ message: 'Server error' });
    }
  }
};

const updateBook = async (req, res) => {
  const { id } = req.params;
  const schema = Joi.object({
    title: Joi.string().optional(),
    author: Joi.string().optional(),
    isbn: Joi.string().optional(),
    publishedYear: Joi.number().integer().optional(),
    genre: Joi.string().optional(),
    available: Joi.boolean().optional(),
    status: Joi.string().valid('available', 'pending', 'borrowed').optional(),
  });
  const { error } = schema.validate(req.body);
  if (error) return res.status(400).json({ message: error.details[0].message });

  try {
    const book = await Book.findByPk(id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    await book.update(req.body);
    res.json({ book });
  } catch (err) {
    if (err.name === 'SequelizeUniqueConstraintError') {
      res.status(400).json({ message: 'ISBN already exists' });
    } else {
      res.status(500).json({ message: 'Server error' });
    }
  }
};

const deleteBook = async (req, res) => {
  const { id } = req.params;
  try {
    const book = await Book.findByPk(id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    await book.destroy();
    res.json({ message: 'Book deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getBooks,
  getBook,
  createBook,
  updateBook,
  deleteBook,
};
