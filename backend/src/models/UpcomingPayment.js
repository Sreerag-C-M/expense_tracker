const mongoose = require('mongoose');

const upcomingPaymentSchema = mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    amount: { type: Number, required: true },
    dueDate: { type: Date, required: true },
    frequency: { type: String, required: true, enum: ['one-time', 'monthly', 'yearly'] },
}, { timestamps: true });

module.exports = mongoose.model('UpcomingPayment', upcomingPaymentSchema);
