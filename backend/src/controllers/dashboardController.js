const Expense = require('../models/Expense');
const Income = require('../models/Income');
const UpcomingPayment = require('../models/UpcomingPayment');

// @desc    Get dashboard summary
// @route   GET /api/dashboard
// @access  Public
const getDashboardData = async (req, res) => {
    try {
        const today = new Date();
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        const daysPassed = today.getDate();
        const totalDaysInMonth = endOfMonth.getDate();

        // 1. Current Balance (All Time)
        const allExpenses = await Expense.aggregate([{ $group: { _id: null, total: { $sum: '$amount' } } }]);
        const allIncome = await Income.aggregate([{ $group: { _id: null, total: { $sum: '$amount' } } }]);

        const totalExpensesAmount = allExpenses.length > 0 ? allExpenses[0].total : 0;
        const totalIncomeAmount = allIncome.length > 0 ? allIncome[0].total : 0;

        const currentBalance = totalIncomeAmount - totalExpensesAmount;

        // 2. This Month Data
        const thisMonthExpensesAgg = await Expense.aggregate([
            { $match: { date: { $gte: startOfMonth, $lte: endOfMonth } } },
            { $group: { _id: null, total: { $sum: '$amount' } } }
        ]);
        const thisMonthIncomeAgg = await Income.aggregate([
            { $match: { date: { $gte: startOfMonth, $lte: endOfMonth } } },
            { $group: { _id: null, total: { $sum: '$amount' } } }
        ]);

        const thisMonthExpenses = thisMonthExpensesAgg.length > 0 ? thisMonthExpensesAgg[0].total : 0;
        const thisMonthIncome = thisMonthIncomeAgg.length > 0 ? thisMonthIncomeAgg[0].total : 0;

        // 3. Upcoming Payments (Simple Logic: Sum of all active upcoming payments for simplicity, 
        // real world would check specific dates vs paid status)
        // We assume UpcomingPayment entries are "bills to pay soon".
        const upcomingPayments = await UpcomingPayment.find();

        // Filter for this month (This is a simplified logic needed for the "Smart Balance")
        // In a real app, you'd expand recurring patterns. Here we sum them all as "obligations".
        let upcomingTotal = 0;
        upcomingPayments.forEach(payment => {
            // For MVP, assume the amount is monthly or one-time relevant to now.
            upcomingTotal += payment.amount;
        });

        // 4. Smart Balance Logic
        const projectedBalance = currentBalance - upcomingTotal;

        // Daily Average Spend
        const dailyAverage = daysPassed > 0 ? (thisMonthExpenses / daysPassed) : 0;

        // Month End Balance Projection
        // Projected Expenses = (Daily Average * Total Days) OR (Expenses + Upcoming)
        // User Formula: Total Income (All Time? Or This Month?) - (Projected Expenses + Upcoming Payments)
        // Context implies "How much will I have at end of month?"
        // Let's assume Month End Balance = (Current Balance + Remaining Income Est) - (Remaining Expenses Est)
        // Using User Formula strictly: "Total Income - (Projected Expenses + Upcoming Payments)"
        // Interpreting "Total Income" as "This Month Income" makes sense for a monthly view, 
        // but "Month End Balance" usually refers to the final account state.
        // Let's use: Current Balance - Upcoming Payments - (Estimated Discretionary Spending for rest of month)
        // Estimated Discretionary = Daily Average * (TotalDays - DaysPassed)

        const daysRemaining = totalDaysInMonth - daysPassed;
        const estimatedRemainingDiscretionary = dailyAverage * daysRemaining;
        const monthEndBalance = currentBalance - upcomingTotal - estimatedRemainingDiscretionary;


        // 5. Category-wise expense chart
        const categoryExpenses = await Expense.aggregate([
            { $match: { date: { $gte: startOfMonth, $lte: endOfMonth } } },
            { $group: { _id: '$category', total: { $sum: '$amount' } } },
            { $sort: { total: -1 } }
        ]);

        // 6. Monthly spending trend (Last 6 months? Or daily breakdown of this month?)
        // "Monthly spending trend" usually means bar chart of last x months.
        // Let's get data for last 6 months.
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5);
        sixMonthsAgo.setDate(1);

        const monthlyTrend = await Expense.aggregate([
            { $match: { date: { $gte: sixMonthsAgo } } },
            {
                $group: {
                    _id: {
                        month: { $month: '$date' },
                        year: { $year: '$date' }
                    },
                    total: { $sum: '$amount' }
                }
            },
            { $sort: { '_id.year': 1, '_id.month': 1 } }
        ]);

        // Format trend for frontend
        const formattedTrend = monthlyTrend.map(item => ({
            month: `${item._id.year}-${item._id.month}`,
            val: item.total
        }));

        res.json({
            currentBalance,
            thisMonthIncome,
            thisMonthExpenses,
            upcomingTotal,
            projectedBalance,
            dailyAverage,
            monthEndBalance,
            categoryExpenses,
            monthlyTrend: formattedTrend,
            topCategories: categoryExpenses.slice(0, 3)
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getDashboardData };
