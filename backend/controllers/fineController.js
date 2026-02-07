const Loan = require('../models/Loan');

const listFines = async (req, res) => {
  try {
    const fines = await Loan.findAll({
      where: { finePaid: false },
      order: [['createdAt', 'DESC']],
    });
    return res.json({ fines });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const payFine = async (req, res) => {
  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });
    if (loan.fineAmount <= 0) {
      return res.status(400).json({ message: 'No fine to pay' });
    }
    await loan.update({ finePaid: true });
    return res.json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const updateFineAmount = async (req, res) => {
  const amount = Number(req.body.amount);
  if (Number.isNaN(amount) || amount < 0) {
    return res.status(400).json({ message: 'Invalid amount' });
  }
  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });
    await loan.update({ fineAmount: amount, finePaid: amount === 0 });
    return res.json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

const clearFine = async (req, res) => {
  try {
    const loan = await Loan.findByPk(req.params.id);
    if (!loan) return res.status(404).json({ message: 'Loan not found' });
    await loan.update({ fineAmount: 0, finePaid: true });
    return res.json({ loan });
  } catch (err) {
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { listFines, payFine, updateFineAmount, clearFine };
