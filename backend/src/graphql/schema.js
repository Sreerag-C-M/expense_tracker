const {
    GraphQLObjectType,
    GraphQLID,
    GraphQLString,
    GraphQLBoolean,
    GraphQLFloat,
    GraphQLList,
    GraphQLSchema,
    GraphQLNonNull
} = require('graphql');

const Expense = require('../models/Expense');
const Income = require('../models/Income');
const Category = require('../models/Category');
const UpcomingPayment = require('../models/UpcomingPayment');

// Expense Type
const ExpenseType = new GraphQLObjectType({
    name: 'Expense',
    fields: () => ({
        id: { type: GraphQLID },
        amount: { type: GraphQLFloat },
        category: { type: GraphQLString },
        description: { type: GraphQLString },
        date: { type: GraphQLString },
        paymentType: { type: GraphQLString },
        isRecurring: { type: GraphQLBoolean },
        recurrenceType: { type: GraphQLString },
        createdAt: { type: GraphQLString },
        updatedAt: { type: GraphQLString }
    })
});

// Income Type
const IncomeType = new GraphQLObjectType({
    name: 'Income',
    fields: () => ({
        id: { type: GraphQLID },
        amount: { type: GraphQLFloat },
        source: { type: GraphQLString },
        date: { type: GraphQLString },
        isRecurring: { type: GraphQLBoolean },
        createdAt: { type: GraphQLString },
        updatedAt: { type: GraphQLString }
    })
});

// Category Type
const CategoryType = new GraphQLObjectType({
    name: 'Category',
    fields: () => ({
        id: { type: GraphQLID },
        name: { type: GraphQLString },
        type: { type: GraphQLString }, // 'expense' or 'income'
        isDefault: { type: GraphQLBoolean },
        createdAt: { type: GraphQLString },
        updatedAt: { type: GraphQLString }
    })
});

// Upcoming Payment Type
const UpcomingPaymentType = new GraphQLObjectType({
    name: 'UpcomingPayment',
    fields: () => ({
        id: { type: GraphQLID },
        title: { type: GraphQLString },
        amount: { type: GraphQLFloat },
        dueDate: { type: GraphQLString },
        frequency: { type: GraphQLString },
        createdAt: { type: GraphQLString },
        updatedAt: { type: GraphQLString }
    })
});

// Dashboard Types
const CategoryAggregateType = new GraphQLObjectType({
    name: 'CategoryAggregate',
    fields: () => ({
        category: {
            type: GraphQLString,
            resolve: (parent) => parent._id
        },
        total: { type: GraphQLFloat }
    })
});

const MonthlyTrendType = new GraphQLObjectType({
    name: 'MonthlyTrend',
    fields: () => ({
        month: { type: GraphQLString },
        val: { type: GraphQLFloat }
    })
});

const DashboardType = new GraphQLObjectType({
    name: 'Dashboard',
    fields: () => ({
        currentBalance: { type: GraphQLFloat },
        thisMonthIncome: { type: GraphQLFloat },
        thisMonthExpenses: { type: GraphQLFloat },
        upcomingTotal: { type: GraphQLFloat },
        projectedBalance: { type: GraphQLFloat },
        dailyAverage: { type: GraphQLFloat },
        monthEndBalance: { type: GraphQLFloat },
        categoryExpenses: { type: new GraphQLList(CategoryAggregateType) },
        monthlyTrend: { type: new GraphQLList(MonthlyTrendType) },
        topCategories: { type: new GraphQLList(CategoryAggregateType) }
    })
});

// Root Query
const RootQuery = new GraphQLObjectType({
    name: 'RootQueryType',
    fields: {
        // Dashboard
        dashboard: {
            type: DashboardType,
            async resolve(parent, args) {
                const today = new Date();
                const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
                const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                const daysPassed = today.getDate();
                const totalDaysInMonth = endOfMonth.getDate();

                // 1. Current Balance
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

                // 3. Upcoming Payments
                const upcomingPayments = await UpcomingPayment.find();
                let upcomingTotal = 0;
                upcomingPayments.forEach(payment => {
                    upcomingTotal += payment.amount;
                });

                // 4. Smart Balance Logic
                const projectedBalance = currentBalance - upcomingTotal;
                const dailyAverage = daysPassed > 0 ? (thisMonthExpenses / daysPassed) : 0;
                const daysRemaining = totalDaysInMonth - daysPassed;
                const estimatedRemainingDiscretionary = dailyAverage * daysRemaining;
                const monthEndBalance = currentBalance - upcomingTotal - estimatedRemainingDiscretionary;

                // 5. Category-wise expense chart
                const categoryExpenses = await Expense.aggregate([
                    { $match: { date: { $gte: startOfMonth, $lte: endOfMonth } } },
                    { $group: { _id: '$category', total: { $sum: '$amount' } } },
                    { $sort: { total: -1 } }
                ]);

                // 6. Monthly spending trend
                const sixMonthsAgo = new Date();
                sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5);
                sixMonthsAgo.setDate(1);
                const monthlyTrend = await Expense.aggregate([
                    { $match: { date: { $gte: sixMonthsAgo } } },
                    {
                        $group: {
                            _id: { month: { $month: '$date' }, year: { $year: '$date' } },
                            total: { $sum: '$amount' }
                        }
                    },
                    { $sort: { '_id.year': 1, '_id.month': 1 } }
                ]);
                const formattedTrend = monthlyTrend.map(item => ({
                    month: `${item._id.year}-${item._id.month}`,
                    val: item.total
                }));

                return {
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
                };
            }
        },
        // Expenses
        expenses: {
            type: new GraphQLList(ExpenseType),
            resolve(parent, args) {
                return Expense.find();
            }
        },
        expense: {
            type: ExpenseType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args) {
                return Expense.findById(args.id);
            }
        },
        // Incomes
        incomes: {
            type: new GraphQLList(IncomeType),
            resolve(parent, args) {
                return Income.find();
            }
        },
        income: {
            type: IncomeType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args) {
                return Income.findById(args.id);
            }
        },
        // Categories
        categories: {
            type: new GraphQLList(CategoryType),
            resolve(parent, args) {
                return Category.find();
            }
        },
        category: {
            type: CategoryType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args) {
                return Category.findById(args.id);
            }
        },
        // Upcoming Payments
        upcomingPayments: {
            type: new GraphQLList(UpcomingPaymentType),
            resolve(parent, args) {
                return UpcomingPayment.find();
            }
        },
        upcomingPayment: {
            type: UpcomingPaymentType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args) {
                return UpcomingPayment.findById(args.id);
            }
        }
    }
});

// Mutation
const Mutation = new GraphQLObjectType({
    name: 'Mutation',
    fields: {
        // Expense Mutations
        addExpense: {
            type: ExpenseType,
            args: {
                amount: { type: new GraphQLNonNull(GraphQLFloat) },
                category: { type: GraphQLString },
                description: { type: new GraphQLNonNull(GraphQLString) },
                date: { type: GraphQLString },
                paymentType: { type: new GraphQLNonNull(GraphQLString) },
                isRecurring: { type: GraphQLBoolean },
                recurrenceType: { type: GraphQLString }
            },
            resolve(parent, args) {
                const expense = new Expense({
                    amount: args.amount,
                    category: args.category,
                    description: args.description,
                    date: args.date,
                    paymentType: args.paymentType,
                    isRecurring: args.isRecurring,
                    recurrenceType: args.recurrenceType
                });
                return expense.save();
            }
        },
        deleteExpense: {
            type: ExpenseType,
            args: { id: { type: new GraphQLNonNull(GraphQLID) } },
            resolve(parent, args) {
                return Expense.findByIdAndDelete(args.id);
            }
        },
        updateExpense: {
            type: ExpenseType,
            args: {
                id: { type: new GraphQLNonNull(GraphQLID) },
                amount: { type: GraphQLFloat },
                category: { type: GraphQLString },
                description: { type: GraphQLString },
                date: { type: GraphQLString },
                paymentType: { type: GraphQLString },
                isRecurring: { type: GraphQLBoolean },
                recurrenceType: { type: GraphQLString }
            },
            resolve(parent, args) {
                return Expense.findByIdAndUpdate(
                    args.id,
                    {
                        $set: {
                            amount: args.amount,
                            category: args.category,
                            description: args.description,
                            date: args.date,
                            paymentType: args.paymentType,
                            isRecurring: args.isRecurring,
                            recurrenceType: args.recurrenceType
                        }
                    },
                    { new: true }
                );
            }
        },
        // Income Mutations
        addIncome: {
            type: IncomeType,
            args: {
                amount: { type: new GraphQLNonNull(GraphQLFloat) },
                source: { type: new GraphQLNonNull(GraphQLString) },
                date: { type: GraphQLString },
                isRecurring: { type: GraphQLBoolean }
            },
            resolve(parent, args) {
                const income = new Income({
                    amount: args.amount,
                    source: args.source,
                    date: args.date,
                    isRecurring: args.isRecurring
                });
                return income.save();
            }
        },
        deleteIncome: {
            type: IncomeType,
            args: { id: { type: new GraphQLNonNull(GraphQLID) } },
            resolve(parent, args) {
                return Income.findByIdAndDelete(args.id);
            }
        },
        updateIncome: {
            type: IncomeType,
            args: {
                id: { type: new GraphQLNonNull(GraphQLID) },
                amount: { type: GraphQLFloat },
                source: { type: GraphQLString },
                date: { type: GraphQLString },
                isRecurring: { type: GraphQLBoolean }
            },
            resolve(parent, args) {
                return Income.findByIdAndUpdate(
                    args.id,
                    {
                        $set: {
                            amount: args.amount,
                            source: args.source,
                            date: args.date,
                            isRecurring: args.isRecurring
                        }
                    },
                    { new: true }
                );
            }
        },
        // Category Mutations
        addCategory: {
            type: CategoryType,
            args: {
                name: { type: new GraphQLNonNull(GraphQLString) },
                type: { type: GraphQLString },
                isDefault: { type: GraphQLBoolean }
            },
            resolve(parent, args) {
                const category = new Category({
                    name: args.name,
                    type: args.type,
                    isDefault: args.isDefault
                });
                return category.save();
            }
        },
        deleteCategory: {
            type: CategoryType,
            args: { id: { type: new GraphQLNonNull(GraphQLID) } },
            resolve(parent, args) {
                return Category.findByIdAndDelete(args.id);
            }
        },
        // Upcoming Payment Mutations
        addUpcomingPayment: {
            type: UpcomingPaymentType,
            args: {
                title: { type: new GraphQLNonNull(GraphQLString) },
                amount: { type: new GraphQLNonNull(GraphQLFloat) },
                dueDate: { type: new GraphQLNonNull(GraphQLString) },
                frequency: { type: new GraphQLNonNull(GraphQLString) }
            },
            resolve(parent, args) {
                const upcomingPayment = new UpcomingPayment({
                    title: args.title,
                    amount: args.amount,
                    dueDate: args.dueDate,
                    frequency: args.frequency
                });
                return upcomingPayment.save();
            }
        },
        deleteUpcomingPayment: {
            type: UpcomingPaymentType,
            args: { id: { type: new GraphQLNonNull(GraphQLID) } },
            resolve(parent, args) {
                return UpcomingPayment.findByIdAndDelete(args.id);
            }
        },
        updateUpcomingPayment: {
            type: UpcomingPaymentType,
            args: {
                id: { type: new GraphQLNonNull(GraphQLID) },
                title: { type: GraphQLString },
                amount: { type: GraphQLFloat },
                dueDate: { type: GraphQLString },
                frequency: { type: GraphQLString }
            },
            resolve(parent, args) {
                return UpcomingPayment.findByIdAndUpdate(
                    args.id,
                    {
                        $set: {
                            title: args.title,
                            amount: args.amount,
                            dueDate: args.dueDate,
                            frequency: args.frequency
                        }
                    },
                    { new: true }
                );
            }
        }
    }
});

module.exports = new GraphQLSchema({
    query: RootQuery,
    mutation: Mutation
});
