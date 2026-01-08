const mongoose = require('mongoose');

const categorySchema = mongoose.Schema({
    name: { type: String, required: true, unique: true },
    type: { type: String, enum: ['expense', 'income'], default: 'expense' },
    isDefault: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Category', categorySchema);
