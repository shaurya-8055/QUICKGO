# 🚀 Worker App - Quick Start Guide

Welcome to the Worker App with MongoDB backend integration!

## ✅ Features Implemented

### Backend (Node.js + MongoDB)

- ✅ Worker Authentication (Signup/Login with JWT)
- ✅ Customer Authentication (for client app)
- ✅ Profile Management (KYC, Bank Details, UPI)
- ✅ Job Management (Available, Accept, Complete, History)
- ✅ Earnings Tracking (Today, Week, Month, Total)
- ✅ Withdrawals (UPI & Bank Transfer)
- ✅ Transaction History
- ✅ Geolocation-based Job Search
- ✅ India-specific features (₹, Aadhar, PAN, IFSC, UPI)

### Flutter App

- ✅ 6 Complete Screens (Profile, Available Jobs, Active Jobs, Earnings, History, Home)
- ✅ Login & Signup Screens
- ✅ MongoDB Integration via REST API
- ✅ JWT Token Management
- ✅ State Management with Provider
- ✅ Local Data Persistence (GetStorage)

---

## 📦 Quick Setup (5 Steps)

### Step 1: Install Node.js Dependencies

```powershell
cd worker_app\server
npm install
```

**Packages installed:**

- express - Web framework
- mongoose - MongoDB ODM
- bcryptjs - Password hashing
- jsonwebtoken - JWT authentication
- express-validator - Input validation
- dotenv - Environment variables
- cors - Cross-origin requests
- helmet - Security headers
- morgan - HTTP logger
- express-rate-limit - Rate limiting

### Step 2: Setup MongoDB

**Option A - Local MongoDB:**

1. Install MongoDB from https://www.mongodb.com/try/download/community
2. Start MongoDB: `mongod`

**Option B - MongoDB Atlas (Cloud - Recommended):**

1. Create free account at https://www.mongodb.com/cloud/atlas
2. Create cluster (free tier available)
3. Get connection string (looks like: `mongodb+srv://username:password@cluster...`)

### Step 3: Create .env File

Create `worker_app\server\.env` with:

```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017/worker_app
# Or Atlas: mongodb+srv://username:password@cluster.mongodb.net/worker_app

# Server
PORT=5000
NODE_ENV=development

# JWT (Change in production!)
JWT_SECRET=my_super_secret_key_change_this_123456
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000
```

### Step 4: Start Backend Server

```powershell
cd worker_app\server
npm start
```

You should see:

```
✅ Connected to MongoDB
📍 Database: worker_app
🚀 Server running on port 5000
📡 API available at http://localhost:5000/api
```

### Step 5: Update Flutter API URL

Edit `worker_app\lib\services\api_service.dart` (line 7):

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:5000/api';

// For Physical Device (use your computer's IP)
// Find your IP: Run 'ipconfig' in PowerShell, look for IPv4 Address
// static const String baseUrl = 'http://192.168.1.100:5000/api';
```

### Step 6: Run Flutter App

```powershell
cd worker_app
flutter pub get
flutter run
```

---

## 🎯 Testing the Setup

### Test 1: Backend Health Check

Open browser: `http://localhost:5000/health`

You should see:

```json
{
  "status": "OK",
  "message": "Worker App Server is running",
  "timestamp": "2024-..."
}
```

### Test 2: Worker Signup (Using PowerShell)

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/auth/worker/signup" -Method POST -ContentType "application/json" -Body '{
  "phone": "+919876543210",
  "name": "Test Worker",
  "password": "password123",
  "serviceType": ["AC Repair", "Electrician"],
  "city": "Mumbai"
}'
```

Success response:

```json
{
  "success": true,
  "message": "Worker registered successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "worker": {
      "_id": "...",
      "phone": "+919876543210",
      "name": "Test Worker",
      ...
    }
  }
}
```

### Test 3: Worker Login (Using PowerShell)

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/auth/worker/login" -Method POST -ContentType "application/json" -Body '{
  "phone": "+919876543210",
  "password": "password123"
}'
```

### Test 4: Flutter App Signup

1. Launch app
2. Wait for splash screen
3. Click "Create New Account"
4. Fill form:
   - Name: Your Name
   - Phone: +919876543210
   - Password: password123
   - Select services
5. Click "Create Account"
6. Should navigate to Home screen

---

## 📖 API Documentation

### Base URL

```
http://localhost:5000/api
```

### Authentication Endpoints

#### Worker Signup

```http
POST /auth/worker/signup
Content-Type: application/json

{
  "phone": "+919876543210",
  "name": "John Doe",
  "password": "password123",
  "email": "john@example.com",
  "serviceType": ["AC Repair", "Plumber"],
  "city": "Mumbai"
}
```

#### Worker Login

```http
POST /auth/worker/login
Content-Type: application/json

{
  "phone": "+919876543210",
  "password": "password123"
}
```

Returns:

```json
{
  "success": true,
  "data": {
    "token": "JWT_TOKEN_HERE",
    "worker": { ...worker data... }
  }
}
```

### Worker Endpoints (Require Authorization Header)

All requests must include:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Get Profile

```http
GET /workers/profile
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Update Profile

```http
PUT /workers/profile
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Updated Name",
  "email": "new@email.com"
}
```

#### Toggle Availability

```http
PUT /workers/availability
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "isAvailable": true
}
```

#### Update Location

```http
PUT /workers/location
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "longitude": 72.8777,
  "latitude": 19.0760
}
```

### Job Endpoints

#### Get Available Jobs (Near Worker)

```http
GET /jobs/available?longitude=72.8777&latitude=19.0760&radius=10
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Accept Job

```http
POST /jobs/:jobId/accept
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Update Job Status

```http
PUT /jobs/:jobId/status
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "status": "working"
}
```

Allowed statuses: `accepted`, `en_route`, `working`, `completed`

#### Complete Job

```http
POST /jobs/:jobId/complete
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "finalPrice": 500
}
```

### Earnings Endpoints

#### Get Earnings Summary

```http
GET /earnings/summary
Authorization: Bearer YOUR_JWT_TOKEN
```

Returns:

```json
{
  "success": true,
  "data": {
    "totalEarnings": 15000,
    "availableBalance": 12000,
    "todayEarnings": 500,
    "weekEarnings": 3000,
    "monthEarnings": 8000,
    "pendingWithdrawals": 3000
  }
}
```

#### Request Withdrawal

```http
POST /earnings/withdraw
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "amount": 1000,
  "method": "upi",
  "upiId": "worker@paytm"
}
```

Or for bank transfer:

```json
{
  "amount": 5000,
  "method": "bank",
  "bankDetails": {
    "accountNumber": "1234567890",
    "ifscCode": "HDFC0001234",
    "bankName": "HDFC Bank"
  }
}
```

---

## 🏗️ Project Structure

```
worker_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   ├── providers/                   # State management
│   │   ├── auth_provider.dart       # ✅ MongoDB integrated
│   │   ├── job_provider.dart        # Uses Firebase (update next)
│   │   └── earnings_provider.dart   # Uses Firebase (update next)
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # ✅ Complete
│   │   │   └── signup_screen.dart   # ✅ Complete
│   │   ├── home/                    # ✅ Complete
│   │   ├── profile/                 # ✅ Complete
│   │   ├── available_jobs/          # ✅ Complete
│   │   ├── active_jobs/             # ✅ Complete
│   │   ├── earnings/                # ✅ Complete
│   │   └── job_history/             # ✅ Complete
│   └── services/
│       └── api_service.dart         # ✅ Complete HTTP client
│
└── server/                          # Backend
    ├── server.js                    # Express server
    ├── .env.example                 # Environment template
    ├── package.json                 # Dependencies
    ├── models/
    │   ├── Worker.js                # Worker schema
    │   ├── Customer.js              # Customer schema
    │   ├── Job.js                   # Job schema
    │   └── Transaction.js           # Transaction schema
    ├── routes/
    │   ├── auth.js                  # Auth endpoints
    │   ├── workers.js               # Worker endpoints
    │   ├── jobs.js                  # Job endpoints
    │   ├── earnings.js              # Earnings endpoints
    │   └── transactions.js          # Transaction endpoints
    └── middleware/
        └── auth.js                  # JWT verification
```

---

## 🔧 Common Issues & Solutions

### Issue 1: Cannot connect to MongoDB

**Error:** `MongoServerError: connection failed`

**Solution:**

1. Ensure MongoDB is running: `mongod`
2. Check MONGODB_URI in `.env`
3. For Atlas, ensure IP whitelist includes your IP

### Issue 2: Flutter app can't reach server

**Error:** `SocketException: Connection refused`

**Solution:**

- **Android Emulator:** Use `http://10.0.2.2:5000/api`
- **iOS Simulator:** Use `http://localhost:5000/api`
- **Physical Device:**
  1. Find your PC IP: Run `ipconfig` in PowerShell
  2. Look for "IPv4 Address" (e.g., 192.168.1.100)
  3. Use `http://192.168.1.100:5000/api`
  4. Ensure PC and phone on same WiFi
  5. Check Windows Firewall allows port 5000

### Issue 3: JWT Token Invalid

**Error:** `401 Unauthorized`

**Solution:**

1. Login again to get new token
2. Token expires after 7 days (check JWT_EXPIRES_IN)
3. Ensure Authorization header format: `Bearer TOKEN`

### Issue 4: CORS Error

**Error:** `CORS policy blocked`

**Solution:**
Add your origin to `.env`:

```env
CORS_ORIGIN=http://localhost:3000,http://192.168.1.100:8080
```

---

## 🌟 Next Steps

### 1. Update Job Provider

Replace Firebase queries with API calls:

```dart
// In job_provider.dart
Future<void> loadAvailableJobs() async {
  final response = await _apiService.getAvailableJobs(
    longitude: currentLongitude,
    latitude: currentLatitude,
    radius: 10,
  );
  // Process response...
}
```

### 2. Update Earnings Provider

Replace Firebase with API:

```dart
// In earnings_provider.dart
Future<void> loadEarnings() async {
  final response = await _apiService.getEarningsSummary();
  // Process response...
}
```

### 3. Add Customer App Integration

The backend supports customers too!

- Customer can create jobs
- Workers see jobs and accept
- Both share same MongoDB database

### 4. Production Deployment

**Backend:**

1. Deploy to Heroku/Railway/Render
2. Use MongoDB Atlas
3. Update JWT_SECRET
4. Enable HTTPS

**Flutter:**

1. Update baseUrl in api_service.dart
2. Build release APK: `flutter build apk --release`

---

## 📊 MongoDB Collections

Your database will have these collections:

### workers

- Worker authentication & profile
- KYC documents (Aadhar, PAN)
- Bank & UPI details
- Service offerings
- Location & availability
- Ratings & stats

### jobs

- Service requests
- Customer & worker assignment
- Location (with geo-index)
- Status tracking
- Pricing in ₹
- Ratings & feedback

### transactions

- Earnings from jobs
- Withdrawal requests
- UPI/Bank payment details
- Transaction status

### customers

- Customer authentication
- Addresses
- Payment methods

---

## 📱 App Flow

```
App Launch
    ↓
Splash Screen (3 seconds)
    ↓
Check Authentication
    ↓
┌───────────────┬───────────────┐
│  Authenticated │ Not Authenticated
│       ↓        │       ↓
│  Home Screen  │  Login Screen
│               │       ↓
│               │  Signup Screen
│               │       ↓
│               │  Home Screen
└───────────────┴───────────────┘
         ↓
Bottom Navigation:
- Available Jobs
- Active Jobs
- Profile
- Earnings
- Job History
```

---

## 🎓 Learning Resources

- **Node.js:** https://nodejs.org/docs
- **Express.js:** https://expressjs.com/
- **MongoDB:** https://university.mongodb.com/
- **Mongoose:** https://mongoosejs.com/docs/
- **JWT:** https://jwt.io/introduction
- **Flutter HTTP:** https://pub.dev/packages/http
- **Provider:** https://pub.dev/packages/provider

---

## ✅ Checklist

- [ ] Node.js installed
- [ ] MongoDB running (local or Atlas)
- [ ] Dependencies installed (`npm install`)
- [ ] `.env` file created
- [ ] Backend server running (http://localhost:5000)
- [ ] Health check works (http://localhost:5000/health)
- [ ] API base URL updated in Flutter
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App launches successfully
- [ ] Can signup new worker
- [ ] Can login with worker credentials
- [ ] Profile screen shows worker data

---

## 🚀 You're All Set!

Your Worker App with MongoDB backend is ready!

**Test the complete flow:**

1. Start backend: `cd server && npm start`
2. Run Flutter app: `flutter run`
3. Signup as new worker
4. Toggle availability
5. View profile

**Need help?** Check the MongoDB Setup Guide or API documentation above.

Happy coding! 🎉
