const UpcomingPayment = require('../models/UpcomingPayment');

// @desc    Get all upcoming payments
// @route   GET /api/upcoming-payments
// @access  Public
const getUpcomingPayments = async (req, res) => {
    try {
        const payments = await UpcomingPayment.find().sort({ dueDate: 1 });
        res.json(payments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get single upcoming payment
// @route   GET /api/upcoming-payments/:id
// @access  Public
const getUpcomingPaymentById = async (req, res) => {
    try {
        const payment = await UpcomingPayment.findById(req.params.id);
        if (payment) {
            res.json(payment);
        } else {
            res.status(404).json({ message: 'Upcoming Payment not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create new upcoming payment
// @route   POST /api/upcoming-payments
// @access  Public
const createUpcomingPayment = async (req, res) => {
    const { title, amount, dueDate, frequency } = req.body;

    try {
        const payment = new UpcomingPayment({
            title,
            amount,
            dueDate,
            frequency,
        });

        const createdPayment = await payment.save();
        res.status(201).json(createdPayment);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Update upcoming payment
// @route   PUT /api/upcoming-payments/:id
// @access  Public
const updateUpcomingPayment = async (req, res) => {
    const { title, amount, dueDate, frequency } = req.body;

    try {
        const payment = await UpcomingPayment.findById(req.params.id);

        if (payment) {
            payment.title = title || payment.title;
            payment.amount = amount || payment.amount;
            payment.dueDate = dueDate || payment.dueDate;
            payment.frequency = frequency || payment.frequency;

            const updatedPayment = await payment.save();
            res.json(updatedPayment);
        } else {
            res.status(404).json({ message: 'Upcoming Payment not found' });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// @desc    Delete upcoming payment
// @route   DELETE /api/upcoming-payments/:id
// @access  Public
const deleteUpcomingPayment = async (req, res) => {
    try {
        const payment = await UpcomingPayment.findById(req.params.id);

        if (payment) {
            await payment.deleteOne();
            res.json({ message: 'Upcoming Payment removed' });
        } else {
            res.status(404).json({ message: 'Upcoming Payment not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getUpcomingPayments,
    getUpcomingPaymentById,
    createUpcomingPayment,
    updateUpcomingPayment,
    deleteUpcomingPayment,
};
