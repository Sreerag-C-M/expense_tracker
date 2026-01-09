const mongoose = require('mongoose');

const expenseSchema = mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amount: { type: Number, required: true },
    category: { type: String, required: false }, // Can be custom
    description: { type: String, required: true },
    date: { type: Date, required: true, default: Date.now },
    paymentType: { type: String, required: true, enum: ['cash', 'bank', 'upi', 'card', 'other'], default: 'cash' },
    isRecurring: { type: Boolean, default: false },
    recurrenceType: { type: String, enum: ['monthly', 'yearly', null], default: null },
}, { timestamps: true });

module.exports = mongoose.model('Expense', expenseSchema);
