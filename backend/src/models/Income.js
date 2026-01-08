const mongoose = require('mongoose');

const incomeSchema = mongoose.Schema({
    amount: { type: Number, required: true },
    source: { type: String, required: true },
    date: { type: Date, required: true, default: Date.now },
    isRecurring: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Income', incomeSchema);
