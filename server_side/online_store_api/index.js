const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const asyncHandler = require('express-async-handler');
const dotenv = require('dotenv');
// const { seedTechnicians } = require('./util/seedTechnicians');
dotenv.config();

const app = express();

// Enhanced MongoDB connection with better error handling
const connectDB = async () => {
    try {
        const mongoUrl = process.env.MONGO_URL;
        if (!mongoUrl) {
            throw new Error('MONGO_URL environment variable is not defined');
        }
        
        await mongoose.connect(mongoUrl, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        
        console.log('✅ Connected to MongoDB Database');
        // Seed technicians if none exist
        // await seedTechnicians();
    } catch (error) {
        console.error('❌ MongoDB connection error:', error.message);
        process.exit(1);
    }
};

// Connect to database
connectDB();

// Handle mongoose connection events
mongoose.connection.on('error', (error) => {
    console.error('MongoDB connection error:', error);
});

mongoose.connection.on('disconnected', () => {
    console.log('MongoDB disconnected');
});

// Graceful shutdown
process.on('SIGINT', async () => {
    await mongoose.connection.close();
    console.log('MongoDB connection closed.');
    process.exit(0);
});
// CORS: reflect origin and allow PATCH/OPTIONS with common headers
const corsOptions = {
    origin: true,
    
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    credentials: false,
};
app.use(cors(corsOptions));
// Explicit preflight handler not needed; our reflective middleware handles OPTIONS

app.use(bodyParser.json());
// Defensive CORS headers (in addition to cors middleware), and fast-track OPTIONS
app.use((req, res, next) => {
    const origin = req.headers.origin || '*';
    const reqMethod = req.headers['access-control-request-method'];
    const reqHeaders = req.headers['access-control-request-headers'];

    res.header('Access-Control-Allow-Origin', origin);
    res.header('Vary', 'Origin');
    // Allow the requested method explicitly (plus defaults)
    const defaultMethods = 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS';
    res.header('Access-Control-Allow-Methods', reqMethod ? `${defaultMethods},${reqMethod}` : defaultMethods);
    // Reflect requested headers if present, otherwise allow a wide set
    const defaultHeaders = 'Content-Type,Authorization,Accept,Origin,X-Requested-With,Content-Length';
    res.header('Access-Control-Allow-Headers', reqHeaders ? reqHeaders : defaultHeaders);
    res.header('Access-Control-Max-Age', '600');

    if (req.method === 'OPTIONS') {
        return res.sendStatus(204);
    }
    next();
});
app.get("/", (req, res) => {
    res.send("helloo test")
})
//? setting static folder path
app.use('/image/products', express.static('public/products'));
app.use('/image/category', express.static('public/category'));
app.use('/image/poster', express.static('public/posters'));



// Routes
app.use('/categories', require('./routes/category'));
app.use('/subCategories', require('./routes/subCategory'));
app.use('/brands', require('./routes/brand'));
app.use('/variantTypes', require('./routes/variantType'));
app.use('/variants', require('./routes/variant'));
app.use('/products', require('./routes/product'));
app.use('/couponCodes', require('./routes/couponCode'));
app.use('/posters', require('./routes/poster'));
app.use('/users', require('./routes/user'));
app.use('/auth', require('./routes/auth'));
app.use('/worker-auth', require('./routes/workerAuth'));
app.use('/orders', require('./routes/order'));
app.use('/payment', require('./routes/payment'));
app.use('/notification', require('./routes/notification'));
app.use('/service-requests', require('./routes/serviceRequest'));
app.use('/technicians', require('./routes/technician'));
app.use('/reviews', require('./routes/review'));


// Example route using asyncHandler directly in app.js
app.get('/', asyncHandler(async (req, res) => {
    res.json({ success: true, message: 'API working successfully', data: null });
}));

// Global error handler
app.use((error, req, res, next) => {
    res.status(500).json({ success: false, message: error.message, data: null });
});


app.listen(process.env.PORT, () => {
    console.log(`Server running on port ${process.env.PORT}`);
});


