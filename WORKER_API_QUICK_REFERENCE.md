# 🚀 Worker Authentication API - Quick Reference

## Base URL

```
Production: https://your-app.onrender.com
Local: http://localhost:3000
```

## 📋 All Endpoints

### 🔓 Public Endpoints (No Auth Required)

| Method | Endpoint                       | Purpose                        |
| ------ | ------------------------------ | ------------------------------ |
| POST   | `/worker-auth/register`        | Register new worker            |
| POST   | `/worker-auth/verify-otp`      | Verify OTP after registration  |
| POST   | `/worker-auth/request-otp`     | Request OTP for login          |
| POST   | `/worker-auth/login`           | Password-based login           |
| POST   | `/worker-auth/refresh-token`   | Refresh access token           |
| POST   | `/worker-auth/forgot-password` | Request OTP for password reset |
| POST   | `/worker-auth/reset-password`  | Reset password with OTP        |

### 🔐 Protected Endpoints (Auth Required)

| Method | Endpoint                       | Purpose               |
| ------ | ------------------------------ | --------------------- |
| POST   | `/worker-auth/logout`          | Logout current device |
| POST   | `/worker-auth/logout-all`      | Logout all devices    |
| POST   | `/worker-auth/change-password` | Change password       |
| GET    | `/worker-auth/me`              | Get worker profile    |
| PUT    | `/worker-auth/profile`         | Update worker profile |
| PUT    | `/worker-auth/availability`    | Toggle availability   |

---

## 📝 Request Examples

### 1. Register Worker

```json
POST /worker-auth/register

{
  "username": "john_plumber",
  "phone": "9012345678",
  "email": "john@example.com",
  "password": "SecurePass@123",
  "name": "John Doe",
  "primaryCategory": "Plumber"
}
```

### 2. Verify OTP

```json
POST /worker-auth/verify-otp

{
  "phone": "+919012345678",
  "code": "123456"
}
```

### 3. Login

```json
POST /worker-auth/login

{
  "phone": "+919012345678",
  "password": "SecurePass@123"
}
```

### 4. Get Profile (requires token)

```
GET /worker-auth/me
Headers: Authorization: Bearer YOUR_ACCESS_TOKEN
```

### 5. Update Profile (requires token)

```json
PUT /worker-auth/profile
Headers: Authorization: Bearer YOUR_ACCESS_TOKEN

{
  "bio": "Experienced plumber",
  "skills": ["Pipe Repair", "Bathroom Fitting"],
  "pricePerHour": 500,
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

### 6. Toggle Availability (requires token)

```json
PUT /worker-auth/availability
Headers: Authorization: Bearer YOUR_ACCESS_TOKEN

{
  "currentlyAvailable": true
}
```

### 7. Forgot Password

```json
POST /worker-auth/forgot-password

{
  "phone": "+919012345678"
}
```

### 8. Reset Password

```json
POST /worker-auth/reset-password

{
  "phone": "+919012345678",
  "code": "123456",
  "newPassword": "NewSecurePass@456"
}
```

---

## 🔑 Authentication Header

For protected endpoints, include:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## ✅ Response Format

### Success Response

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description"
}
```

---

## ⚙️ Worker Categories

```
- AC Repair
- Plumber
- Electrician
- Carpenter
- Painter
- Cleaning
- Pest Control
- Appliance Repair
- Other
```

---

## 🔒 Password Requirements

```
✅ Minimum 8 characters
✅ At least 1 uppercase letter
✅ At least 1 lowercase letter
✅ At least 1 number
✅ At least 1 special character
```

---

## ⏱️ Rate Limits

```
Login:          5 attempts per 15 minutes
OTP Requests:   10 requests per 10 minutes
Password Reset: 3 requests per hour
```

---

## 📱 Account Status

```
pending_approval - New worker, awaiting admin approval
active          - Approved and operational
suspended       - Temporarily blocked by admin
deactivated     - Deactivated by worker
```

---

## 🕐 Token Expiry

```
Access Token:  15 minutes
Refresh Token: 7 days
OTP:          10 minutes
```

---

## 🐛 Common Error Codes

| Code | Message           | Cause                         |
| ---- | ----------------- | ----------------------------- |
| 400  | Invalid request   | Missing required fields       |
| 401  | Unauthorized      | Invalid/expired token         |
| 403  | Forbidden         | Account suspended/deactivated |
| 404  | Not found         | Worker not found              |
| 429  | Too many requests | Rate limit exceeded           |
| 500  | Server error      | Internal server error         |

---

## 🧪 Test with cURL

### Register

```bash
curl -X POST https://your-app.onrender.com/worker-auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test_worker","phone":"9876543210","email":"test@worker.com","password":"Test@1234","name":"Test Worker","primaryCategory":"Plumber"}'
```

### Login

```bash
curl -X POST https://your-app.onrender.com/worker-auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+919876543210","password":"Test@1234"}'
```

### Get Profile

```bash
curl -X GET https://your-app.onrender.com/worker-auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📦 Worker Profile Fields

```javascript
{
  id: string,
  username: string,
  name: string,
  email: string,
  phone: string,
  profileImage: string,
  bio: string,
  primaryCategory: string,
  skills: string[],
  yearsExperience: number,
  rating: number,
  totalJobs: number,
  completedJobs: number,
  pricePerHour: number,
  minimumCharge: number,
  currentlyAvailable: boolean,
  verified: boolean,
  accountStatus: string,
  location: {
    type: "Point",
    coordinates: [longitude, latitude]
  },
  latitude: number,
  longitude: number,
  serviceRadius: number,
  workingHours: {
    monday: { start: string, end: string, available: boolean },
    // ... other days
  },
  // ... many more fields
}
```

---

## 🎯 Quick Start

1. **Register** → Get worker ID
2. **Verify OTP** → Get tokens
3. **Update Profile** → Add skills, location, pricing
4. **Toggle Availability** → Go online
5. **Wait for admin approval** → Account status becomes 'active'
6. **Start accepting jobs** → Begin earning!

---

## 📞 Support

**Check logs:** Server logs show OTP codes when using fallback
**Database:** MongoDB Atlas 'test' database, 'workers' collection
**Environment:** Ensure all required env variables are set

---

**🚀 Ready to build your worker app!**
