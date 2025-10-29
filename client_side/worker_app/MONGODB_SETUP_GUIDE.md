# Worker App - MongoDB Backend Setup Guide

## 🚀 Complete Integration Documentation

This document explains how to set up and run the Worker App with MongoDB backend, including authentication for both workers and customers (client app).

---

## 📋 Prerequisites

1. **Node.js** (v16 or higher)
2. **MongoDB** (Local or MongoDB Atlas)
3. **Flutter** (Latest stable version)
4. **Android Studio** / **VS Code**

---

## 🛠️ Backend Setup

### Step 1: Install Dependencies

```bash
cd worker_app/server
npm install
```

### Step 2: Configure Environment Variables

Create a `.env` file in `worker_app/server/`:

```env
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/worker_app
# Or use MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/worker_app?retryWrites=true&w=majority

# Server Configuration
PORT=5000
NODE_ENV=development

# JWT Secret (IMPORTANT: Change in production!)
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production_123456789

# JWT Expiration
JWT_EXPIRES_IN=7d

# CORS Origin
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
```

### Step 3: Start MongoDB

**Option A: Local MongoDB**

```bash
mongod
```

**Option B: MongoDB Atlas**

1. Create account at https://www.mongodb.com/cloud/atlas
2. Create a cluster
3. Get connection string
4. Update `MONGODB_URI` in `.env`

### Step 4: Start the Server

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

Server will run on `http://localhost:5000`

---

## 📱 Flutter App Setup

### Step 1: Update API Base URL

Edit `worker_app/lib/services/api_service.dart`:

```dart
class ApiService {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:5000/api';

  // For Physical Device (Replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  // For Production
  // static const String baseUrl = 'https://your-domain.com/api';
}
```

### Step 2: Add HTTP Package

The package is already added, but ensure it's in `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  get_storage: ^2.1.1
```

### Step 3: Run Flutter App

```bash
cd worker_app
flutter pub get
flutter run
```

---

## 🔐 Authentication Flow

### Worker Authentication

#### 1. Signup

```
POST /api/auth/worker/signup
{
  "phone": "+919876543210",
  "name": "John Doe",
  "password": "password123",
  "email": "john@example.com",
  "serviceType": ["AC Repair", "Electrician"],
  "city": "Mumbai"
}
```

#### 2. Login

```
POST /api/auth/worker/login
{
  "phone": "+919876543210",
  "password": "password123"
}
```

### Customer Authentication

#### 1. Signup

```
POST /api/auth/customer/signup
{
  "phone": "+919876543210",
  "name": "Jane Doe",
  "password": "password123",
  "email": "jane@example.com"
}
```

#### 2. Login

```
POST /api/auth/customer/login
{
  "phone": "+919876543210",
  "password": "password123"
}
```

---

## 🌐 API Endpoints

### Authentication

- `POST /api/auth/worker/signup` - Worker signup
- `POST /api/auth/worker/login` - Worker login
- `POST /api/auth/customer/signup` - Customer signup
- `POST /api/auth/customer/login` - Customer login

### Worker APIs (Requires Authentication)

- `GET /api/workers/profile` - Get worker profile
- `PUT /api/workers/profile` - Update worker profile
- `PUT /api/workers/availability` - Toggle availability
- `PUT /api/workers/location` - Update location
- `GET /api/workers/stats` - Get worker statistics

### Job APIs

- `GET /api/jobs/available` - Get available jobs (Worker)
- `GET /api/jobs/my-jobs` - Get active jobs (Worker)
- `GET /api/jobs/history` - Get job history (Worker)
- `POST /api/jobs/:jobId/accept` - Accept a job (Worker)
- `PUT /api/jobs/:jobId/status` - Update job status (Worker)
- `POST /api/jobs/:jobId/cancel` - Cancel a job (Worker)
- `POST /api/jobs/create` - Create a job (Customer)

### Earnings APIs (Worker)

- `GET /api/earnings/summary` - Get earnings summary
- `GET /api/earnings/transactions` - Get transaction history
- `POST /api/earnings/withdraw` - Request withdrawal

### Transaction APIs

- `GET /api/transactions` - Get all transactions
- `GET /api/transactions/:id` - Get transaction by ID

---

## 💾 Database Collections

### 1. **workers**

Stores worker information including:

- Authentication (phone, password)
- Personal details (name, email, photo)
- Service details (serviceType, city, serviceRadius)
- KYC documents (Aadhar, PAN)
- Bank details (account, IFSC, UPI)
- Stats (rating, completedJobs, totalEarnings)

### 2. **customers**

Stores customer information including:

- Authentication (phone, password)
- Personal details (name, email)
- Addresses

### 3. **jobs**

Stores all job requests:

- Service details
- Customer information
- Worker assignment
- Status tracking
- Pricing
- Location (geospatial)
- Ratings & feedback

### 4. **transactions**

Stores all financial transactions:

- Worker earnings
- Withdrawals
- Balance tracking
- Payment methods (UPI, Bank)

---

## 🔒 Security Features

1. **Password Hashing**: bcryptjs with salt rounds
2. **JWT Authentication**: Secure token-based auth
3. **Rate Limiting**: Prevents API abuse
4. **Helmet**: Security headers
5. **CORS**: Configurable origins
6. **Input Validation**: express-validator

---

## 📊 Testing the API

### Using Postman or cURL

**1. Worker Signup:**

```bash
curl -X POST http://localhost:5000/api/auth/worker/signup \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "name": "Test Worker",
    "password": "password123",
    "serviceType": ["AC Repair"],
    "city": "Mumbai"
  }'
```

**2. Worker Login:**

```bash
curl -X POST http://localhost:5000/api/auth/worker/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "password": "password123"
  }'
```

**3. Get Worker Profile (with token):**

```bash
curl -X GET http://localhost:5000/api/workers/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🔗 Client App Integration

The customer (client) app can use the same backend APIs:

```dart
// In client_app, create similar ApiService
final response = await ApiService().customerLogin(
  phone: '+919876543210',
  password: 'password123',
);

// Create a job
final job = await ApiService().createJob(
  serviceType: 'AC Repair',
  description: 'AC not cooling',
  address: '123 Main St, Mumbai',
  longitude: 72.8777,
  latitude: 19.0760,
  price: 500,
);
```

---

## 🐛 Troubleshooting

### Issue: Cannot connect to MongoDB

**Solution**: Ensure MongoDB is running and URI is correct

### Issue: Network error in Flutter app

**Solution**:

- For Android Emulator: Use `http://10.0.2.2:5000/api`
- For physical device: Use your computer's local IP
- Check firewall settings

### Issue: CORS errors

**Solution**: Update `CORS_ORIGIN` in `.env` file

### Issue: JWT token expired

**Solution**: Login again to get a new token

---

## 📈 Production Deployment

### Backend Deployment (Example: Heroku)

1. Create Heroku app
2. Add MongoDB Atlas URI
3. Set environment variables
4. Deploy:

```bash
git push heroku main
```

### Update Flutter App

```dart
static const String baseUrl = 'https://your-app.herokuapp.com/api';
```

---

## 🎯 Features Implemented

### ✅ Authentication

- Worker signup/login with JWT
- Customer signup/login with JWT
- Secure password hashing
- Token-based sessions

### ✅ Worker Management

- Profile CRUD operations
- Availability toggle
- Location tracking
- KYC document storage (Aadhar, PAN)
- Bank details (IFSC, UPI)

### ✅ Job Management

- Create jobs (Customer)
- View available jobs with distance (Worker)
- Accept/reject jobs
- Status updates (accepted → en_route → working → completed)
- Job history
- Cancellation with reasons

### ✅ Earnings & Transactions

- Real-time balance tracking
- Period-based earnings (today, week, month)
- Withdrawal requests (UPI, Bank)
- Transaction history
- Payment on job completion

### ✅ India-Specific Features

- Currency: ₹ (INR)
- Distance: Kilometers
- UPI integration
- IFSC codes
- Aadhar & PAN storage

---

## 🚀 Next Steps

1. **Testing**: Create comprehensive API tests
2. **Real-time**: Add Socket.io for live job updates
3. **Notifications**: Integrate push notifications
4. **Payment Gateway**: Add Razorpay/Paytm integration
5. **Admin Panel**: Create admin dashboard
6. **Analytics**: Add worker performance tracking

---

## 📞 Support

For issues or questions, check:

- Server logs: `worker_app/server/` directory
- Flutter debug console
- MongoDB logs

---

## 📄 License

MIT License - Feel free to use for your projects!
