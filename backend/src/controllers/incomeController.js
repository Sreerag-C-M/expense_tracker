const Income = require('../models/Income');

// @desc    Get all income
// @route   GET /api/income
// @access  Public
const getIncomes = async (req, res) => {
    try {
        const incomes = await Income.find().sort({ date: -1 });
        res.json(incomes);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get single income
// @route   GET /api/income/:id
// @access  Public
const getIncomeById = async (req, res) => {
    try {
        const income = await Income.findById(req.params.id);
        if (income) {
            res.json(income);
        } else {
            res.status(404).json({ message: 'Income not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create new income
// @route   POST /api/income
// @access  Public
const createIncome = async (req, res) => {
    const { amount, source, date, isRecurring } = req.body;

    try {
        const income = new Income({
            amount,
            source,
            date,
            isRecurring,
        });

        const createdIncome = await income.save();
        res.status(201).json(createdIncome);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Update income
// @route   PUT /api/income/:id
// @access  Public
const updateIncome = async (req, res) => {
    const { amount, source, date, isRecurring } = req.body;

    try {
        const income = await Income.findById(req.params.id);

        if (income) {
            income.amount = amount || income.amount;
            income.source = source || income.source;
            income.date = date || income.date;
            income.isRecurring = isRecurring !== undefined ? isRecurring : income.isRecurring;

            const updatedIncome = await income.save();
            res.json(updatedIncome);
        } else {
            res.status(404).json({ message: 'Income not found' });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Delete income
// @route   DELETE /api/income/:id
// @access  Public
const deleteIncome = async (req, res) => {
    try {
        const income = await Income.findById(req.params.id);

        if (income) {
            await income.deleteOne();
            res.json({ message: 'Income removed' });
        } else {
            res.status(404).json({ message: 'Income not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getIncomes,
    getIncomeById,
    createIncome,
    updateIncome,
    deleteIncome,
};
