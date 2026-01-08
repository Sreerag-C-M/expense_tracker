const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
const apiRoutes = require('./routes/api');
const { graphqlHTTP } = require('express-graphql');
const schema = require('./graphql/schema');

dotenv.config();

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

app.use('/graphql', graphqlHTTP({
    schema,
    graphiql: true
}));

// Routes
app.use('/api', apiRoutes);

// Error Handling Middleware
app.use((err, req, res, next) => {
    const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
    res.status(statusCode);
    res.json({
        message: err.message,
        stack: process.env.NODE_ENV === 'production' ? null : err.stack,
    });
});

const PORT = process.env.PORT || 5000;

if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    });
}

module.exports = app;
