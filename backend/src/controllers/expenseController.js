const Expense = require('../models/Expense');

// @desc    Get all expenses
// @route   GET /api/expenses
// @access  Public
const getExpenses = async (req, res) => {
    try {
        const expenses = await Expense.find().sort({ date: -1 });
        res.json(expenses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get single expense
// @route   GET /api/expenses/:id
// @access  Public
const getExpenseById = async (req, res) => {
    try {
        const expense = await Expense.findById(req.params.id);
        if (expense) {
            res.json(expense);
        } else {
            res.status(404).json({ message: 'Expense not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create new expense
// @route   POST /api/expenses
// @access  Public
const createExpense = async (req, res) => {
    const { amount, category, description, date, paymentType, isRecurring, recurrenceType } = req.body;

    try {
        const expense = new Expense({
            amount,
            category,
            description,
            date,
            paymentType,
            isRecurring,
            recurrenceType,
        });

        const createdExpense = await expense.save();
        res.status(201).json(createdExpense);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Update expense
// @route   PUT /api/expenses/:id
// @access  Public
const updateExpense = async (req, res) => {
    const { amount, category, description, date, paymentType, isRecurring, recurrenceType } = req.body;

    try {
        const expense = await Expense.findById(req.params.id);

        if (expense) {
            expense.amount = amount || expense.amount;
            expense.category = category || expense.category;
            expense.description = description || expense.description;
            expense.date = date || expense.date;
            expense.paymentType = paymentType || expense.paymentType;
            expense.isRecurring = isRecurring !== undefined ? isRecurring : expense.isRecurring;
            expense.recurrenceType = recurrenceType || expense.recurrenceType;

            const updatedExpense = await expense.save();
            res.json(updatedExpense);
        } else {
            res.status(404).json({ message: 'Expense not found' });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Delete expense
// @route   DELETE /api/expenses/:id
// @access  Public
const deleteExpense = async (req, res) => {
    try {
        const expense = await Expense.findById(req.params.id);

        if (expense) {
            await expense.deleteOne();
            res.json({ message: 'Expense removed' });
        } else {
            res.status(404).json({ message: 'Expense not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getExpenses,
    getExpenseById,
    createExpense,
    updateExpense,
    deleteExpense,
};
