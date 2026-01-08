const express = require('express');
const router = express.Router();

const {
    getExpenses,
    getExpenseById,
    createExpense,
    updateExpense,
    deleteExpense,
} = require('../controllers/expenseController');

const {
    getIncomes,
    getIncomeById,
    createIncome,
    updateIncome,
    deleteIncome,
} = require('../controllers/incomeController');

const {
    getUpcomingPayments,
    getUpcomingPaymentById,
    createUpcomingPayment,
    updateUpcomingPayment,
    deleteUpcomingPayment,
} = require('../controllers/paymentController');

const {
    getCategories,
    createCategory,
    deleteCategory,
} = require('../controllers/categoryController');

const { getDashboardData } = require('../controllers/dashboardController');

// Expense Routes
router.route('/expenses').get(getExpenses).post(createExpense);
router.route('/expenses/:id').get(getExpenseById).put(updateExpense).delete(deleteExpense);

// Income Routes
router.route('/income').get(getIncomes).post(createIncome);
router.route('/income/:id').get(getIncomeById).put(updateIncome).delete(deleteIncome);

// Upcoming Payment Routes
router.route('/upcoming-payments').get(getUpcomingPayments).post(createUpcomingPayment);
router.route('/upcoming-payments/:id').get(getUpcomingPaymentById).put(updateUpcomingPayment).delete(deleteUpcomingPayment);

// Category Routes
router.route('/categories').get(getCategories).post(createCategory);
router.route('/categories/:id').delete(deleteCategory);

// Dashboard Route
router.get('/dashboard', getDashboardData);

module.exports = router;
