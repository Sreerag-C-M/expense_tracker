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
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

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

// User Type
const UserType = new GraphQLObjectType({
    name: 'User',
    fields: () => ({
        id: { type: GraphQLID },
        name: { type: GraphQLString },
        email: { type: GraphQLString },
        createdAt: { type: GraphQLString }
    })
});

// Auth Token Type
const AuthTokenType = new GraphQLObjectType({
    name: 'AuthToken',
    fields: () => ({
        token: { type: GraphQLString },
        user: { type: UserType }
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
            async resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                const userObjectId = new mongoose.Types.ObjectId(context.user.id);

                const today = new Date();
                const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
                const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                const daysPassed = today.getDate();
                const totalDaysInMonth = endOfMonth.getDate();

                // 1. Current Balance
                const allExpenses = await Expense.aggregate([
                    { $match: { user: userObjectId } },
                    { $group: { _id: null, total: { $sum: '$amount' } } }
                ]);
                const allIncome = await Income.aggregate([
                    { $match: { user: userObjectId } },
                    { $group: { _id: null, total: { $sum: '$amount' } } }
                ]);
                const totalExpensesAmount = allExpenses.length > 0 ? allExpenses[0].total : 0;
                const totalIncomeAmount = allIncome.length > 0 ? allIncome[0].total : 0;
                const currentBalance = totalIncomeAmount - totalExpensesAmount;

                // 2. This Month Data
                const thisMonthExpensesAgg = await Expense.aggregate([
                    { $match: { user: userObjectId } },
                    { $addFields: { convertedDate: { $toDate: "$date" } } },
                    { $match: { convertedDate: { $gte: startOfMonth, $lte: endOfMonth } } },
                    { $group: { _id: null, total: { $sum: '$amount' } } }
                ]);
                const thisMonthIncomeAgg = await Income.aggregate([
                    { $match: { user: userObjectId } },
                    { $addFields: { convertedDate: { $toDate: "$date" } } },
                    { $match: { convertedDate: { $gte: startOfMonth, $lte: endOfMonth } } },
                    { $group: { _id: null, total: { $sum: '$amount' } } }
                ]);
                const thisMonthExpenses = thisMonthExpensesAgg.length > 0 ? thisMonthExpensesAgg[0].total : 0;
                const thisMonthIncome = thisMonthIncomeAgg.length > 0 ? thisMonthIncomeAgg[0].total : 0;

                // 3. Upcoming Payments
                const upcomingPayments = await UpcomingPayment.find({ user: context.user.id });
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
                    { $match: { user: userObjectId } },
                    { $addFields: { convertedDate: { $toDate: "$date" } } },
                    { $match: { convertedDate: { $gte: startOfMonth, $lte: endOfMonth } } },
                    { $group: { _id: '$category', total: { $sum: '$amount' } } },
                    { $sort: { total: -1 } }
                ]);

                // 6. Monthly spending trend
                const sixMonthsAgo = new Date();
                sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5);
                sixMonthsAgo.setDate(1);

                const monthlyTrend = await Expense.aggregate([
                    { $match: { user: userObjectId } },
                    { $addFields: { convertedDate: { $toDate: "$date" } } },
                    { $match: { convertedDate: { $gte: sixMonthsAgo } } },
                    {
                        $group: {
                            _id: { month: { $month: '$convertedDate' }, year: { $year: '$convertedDate' } },
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Expense.find({ user: context.user.id });
            }
        },
        expense: {
            type: ExpenseType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Expense.findOne({ _id: args.id, user: context.user.id });
            }
        },
        // Incomes
        incomes: {
            type: new GraphQLList(IncomeType),
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Income.find({ user: context.user.id });
            }
        },
        income: {
            type: IncomeType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Income.findOne({ _id: args.id, user: context.user.id });
            }
        },
        // Categories
        categories: {
            type: new GraphQLList(CategoryType),
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Category.find({ user: context.user.id });
            }
        },
        category: {
            type: CategoryType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Category.findOne({ _id: args.id, user: context.user.id });
            }
        },
        // Upcoming Payments
        upcomingPayments: {
            type: new GraphQLList(UpcomingPaymentType),
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return UpcomingPayment.find({ user: context.user.id });
            }
        },
        upcomingPayment: {
            type: UpcomingPaymentType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return UpcomingPayment.findOne({ _id: args.id, user: context.user.id });
            }
        }
    }
});

// Mutation
const Mutation = new GraphQLObjectType({
    name: 'Mutation',
    fields: {
        // Auth Mutations
        signup: {
            type: AuthTokenType,
            args: {
                name: { type: new GraphQLNonNull(GraphQLString) },
                email: { type: new GraphQLNonNull(GraphQLString) },
                password: { type: new GraphQLNonNull(GraphQLString) }
            },
            async resolve(parent, args) {
                const { name, email, password } = args;
                const user = await User.create({ name, email, password });
                const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });
                return { token, user };
            }
        },
        login: {
            type: AuthTokenType,
            args: {
                email: { type: new GraphQLNonNull(GraphQLString) },
                password: { type: new GraphQLNonNull(GraphQLString) }
            },
            async resolve(parent, args) {
                const { email, password } = args;
                const user = await User.findOne({ email }).select('+password');
                if (!user) {
                    throw new Error('Invalid credentials');
                }
                const isMatch = await user.matchPassword(password);
                if (!isMatch) {
                    throw new Error('Invalid credentials');
                }
                const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });
                return { token, user };
            }
        },
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                const expense = new Expense({
                    user: context.user.id,
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Expense.findOneAndDelete({ _id: args.id, user: context.user.id });
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Expense.findOneAndUpdate(
                    { _id: args.id, user: context.user.id },
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                const income = new Income({
                    user: context.user.id,
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Income.findOneAndDelete({ _id: args.id, user: context.user.id });
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Income.findOneAndUpdate(
                    { _id: args.id, user: context.user.id },
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                const category = new Category({
                    user: context.user.id,
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return Category.findOneAndDelete({ _id: args.id, user: context.user.id });
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                const upcomingPayment = new UpcomingPayment({
                    user: context.user.id,
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return UpcomingPayment.findOneAndDelete({ _id: args.id, user: context.user.id });
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
            resolve(parent, args, context) {
                if (!context.user) throw new Error('Not authorized');
                return UpcomingPayment.findOneAndUpdate(
                    { _id: args.id, user: context.user.id },
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
