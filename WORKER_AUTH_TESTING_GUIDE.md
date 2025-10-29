# Quick Testing Guide - Worker Authentication

## 🧪 Test Authentication Flow

### Prerequisites

- Server running on Render (or locally)
- Postman or cURL installed
- MongoDB connection active

---

## Test Sequence

### 1️⃣ Test Registration

**Endpoint:** `POST /worker-auth/register`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_worker",
    "phone": "9876543210",
    "email": "test@worker.com",
    "password": "Test@1234",
    "name": "Test Worker",
    "primaryCategory": "Plumber"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Registration successful. OTP sent for verification.",
  "data": {
    "workerId": "...",
    "phone": "+919876543210"
  }
}
```

**What to Check:**

- ✅ Success response received
- ✅ Worker ID returned
- ✅ Phone normalized with country code
- ✅ OTP sent to phone (check SMS or console logs)

---

### 2️⃣ Test OTP Verification

**Check console logs** for OTP (if using fallback):

```
[WORKER-OTP][Local] Generated fallback OTP for +919876543210 purpose=signup
```

**Endpoint:** `POST /worker-auth/verify-otp`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "code": "123456"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Phone verified successfully",
  "data": {
    "worker": {
      "id": "...",
      "name": "Test Worker",
      "phone": "+919876543210",
      "email": "test@worker.com",
      "username": "test_worker",
      "primaryCategory": "Plumber",
      "accountStatus": "active",
      "verified": false
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**What to Check:**

- ✅ accessToken received
- ✅ refreshToken received
- ✅ accountStatus is "active"
- ✅ Worker details correct

**Save for next tests:**

- Copy `accessToken`
- Copy `refreshToken`
- Copy `worker.id`

---

### 3️⃣ Test Login

**Endpoint:** `POST /worker-auth/login`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "password": "Test@1234"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "worker": { ... },
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

**What to Check:**

- ✅ New tokens received
- ✅ Worker details returned
- ✅ currentlyAvailable status shown

---

### 4️⃣ Test Get Profile (Authenticated)

**Endpoint:** `GET /worker-auth/me`

```bash
curl -X GET https://your-app.onrender.com/worker-auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response:**

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "worker": {
      "id": "...",
      "name": "Test Worker",
      "phone": "+919876543210",
      "email": "test@worker.com",
      "username": "test_worker",
      "primaryCategory": "Plumber",
      "skills": [],
      "rating": 0,
      "totalJobs": 0,
      "completedJobs": 0,
      "verified": false,
      "accountStatus": "active",
      "currentlyAvailable": false
    }
  }
}
```

**What to Check:**

- ✅ Profile data returned
- ✅ No sensitive fields (passwordHash, otp)
- ✅ All worker fields present

---

### 5️⃣ Test Update Profile

**Endpoint:** `PUT /worker-auth/profile`

```bash
curl -X PUT https://your-app.onrender.com/worker-auth/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Experienced plumber with 10 years experience",
    "skills": ["Pipe Repair", "Bathroom Fitting", "Water Heater"],
    "pricePerHour": 500,
    "yearsExperience": 10,
    "latitude": 12.9716,
    "longitude": 77.5946
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "worker": {
      "bio": "Experienced plumber with 10 years experience",
      "skills": ["Pipe Repair", "Bathroom Fitting", "Water Heater"],
      "pricePerHour": 500,
      "yearsExperience": 10,
      "latitude": 12.9716,
      "longitude": 77.5946,
      "location": {
        "type": "Point",
        "coordinates": [77.5946, 12.9716]
      }
    }
  }
}
```

**What to Check:**

- ✅ Profile updated
- ✅ location.coordinates set correctly [longitude, latitude]
- ✅ All fields saved

---

### 6️⃣ Test Availability Toggle

**Endpoint:** `PUT /worker-auth/availability`

```bash
curl -X PUT https://your-app.onrender.com/worker-auth/availability \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentlyAvailable": true
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Availability updated",
  "data": {
    "currentlyAvailable": true
  }
}
```

**What to Check:**

- ✅ Availability updated
- ✅ Can toggle between true/false

---

### 7️⃣ Test Token Refresh

**Endpoint:** `POST /worker-auth/refresh-token`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Token refreshed",
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

**What to Check:**

- ✅ New accessToken received
- ✅ New refreshToken received
- ✅ Old accessToken stops working

---

### 8️⃣ Test Change Password

**Endpoint:** `POST /worker-auth/change-password`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/change-password \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "Test@1234",
    "newPassword": "NewTest@5678"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

**What to Check:**

- ✅ Password changed
- ✅ Can login with new password
- ✅ Old password doesn't work

**Test new password:**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "password": "NewTest@5678"
  }'
```

---

### 9️⃣ Test Logout

**Endpoint:** `POST /worker-auth/logout`

```bash
curl -X POST https://your-app.onrender.com/worker-auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Verify logout worked:**

```bash
curl -X GET https://your-app.onrender.com/worker-auth/me \
  -H "Authorization: Bearer YOUR_OLD_ACCESS_TOKEN"
```

**Expected Error:**

```json
{
  "success": false,
  "message": "Token expired. Please login again."
}
```

**What to Check:**

- ✅ Old accessToken invalidated
- ✅ Old refreshToken invalidated
- ✅ Need to login again

---

### 🔟 Test Forgot Password Flow

**Step 1: Request OTP**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "OTP sent for password reset"
}
```

**Step 2: Check OTP in logs**

```
[WORKER-OTP][Local] Generated fallback OTP for +919876543210 purpose=reset
```

**Step 3: Reset Password**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "code": "123456",
    "newPassword": "ResetPass@999"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Password reset successful"
}
```

**Step 4: Login with new password**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "password": "ResetPass@999"
  }'
```

**What to Check:**

- ✅ OTP received
- ✅ Password reset successful
- ✅ Can login with new password
- ✅ All old tokens invalidated

---

## 🔒 Test Security Features

### Test Password Validation

**Weak password (no uppercase):**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test2",
    "phone": "9876543211",
    "email": "test2@worker.com",
    "password": "weak123",
    "name": "Test2",
    "primaryCategory": "Plumber"
  }'
```

**Expected Error:**

```json
{
  "success": false,
  "message": "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"
}
```

---

### Test Account Locking

**Make 5 failed login attempts:**

```bash
for i in {1..5}; do
  curl -X POST https://your-app.onrender.com/worker-auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "phone": "+919876543210",
      "password": "WrongPassword123"
    }'
  echo "\n--- Attempt $i ---"
done
```

**Expected:**

- First 4 attempts: "Invalid credentials"
- 5th attempt: Account locked

**Try correct password while locked:**

```bash
curl -X POST https://your-app.onrender.com/worker-auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "password": "ResetPass@999"
  }'
```

**Expected Error:**

```json
{
  "success": false,
  "message": "Account locked due to multiple failed login attempts. Try again later."
}
```

**What to Check:**

- ✅ Account locked after 5 attempts
- ✅ Even correct password doesn't work
- ✅ Unlocks after 30 minutes

---

### Test Rate Limiting

**Make 6 login attempts quickly:**

```bash
for i in {1..6}; do
  curl -X POST https://your-app.onrender.com/worker-auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "phone": "+919876543210",
      "password": "Test@1234"
    }'
  sleep 1
done
```

**Expected:**

- First 5 attempts: Normal response
- 6th attempt: Rate limit error

```json
{
  "success": false,
  "message": "Too many requests, please try again later."
}
```

---

## 🗄️ Database Checks

### MongoDB Queries to Verify

**Check worker created:**

```javascript
db.workers.findOne({ phone: "+919876543210" });
```

**Check indexes created:**

```javascript
db.workers.getIndexes();
```

**Expected indexes:**

- phone (unique)
- email (unique)
- username (unique)
- location (2dsphere)
- primaryCategory
- skills
- rating
- verified
- accountStatus
- location + primaryCategory (compound)
- location + skills (compound)
- createdAt
- updatedAt

**Check location coordinates:**

```javascript
db.workers.findOne(
  { phone: "+919876543210" },
  { location: 1, latitude: 1, longitude: 1 }
);
```

**Expected:**

```json
{
  "location": {
    "type": "Point",
    "coordinates": [77.5946, 12.9716] // [longitude, latitude]
  },
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

---

## ✅ Complete Test Checklist

### Authentication

- [ ] Worker registration works
- [ ] OTP sent successfully
- [ ] OTP verification works
- [ ] Login with password works
- [ ] Token refresh works
- [ ] Logout invalidates tokens
- [ ] Logout all devices works

### Password Management

- [ ] Forgot password sends OTP
- [ ] Reset password with OTP works
- [ ] Change password works
- [ ] Password validation enforced
- [ ] Old password stops working after change

### Profile Management

- [ ] Get profile returns data
- [ ] Update profile works
- [ ] Location coordinates set correctly
- [ ] Availability toggle works

### Security

- [ ] Weak passwords rejected
- [ ] Account locks after 5 failed attempts
- [ ] Rate limiting works (5 login/15min)
- [ ] OTP rate limiting works (10 OTP/10min)
- [ ] Password reset rate limiting works (3/hour)
- [ ] Suspended accounts can't login
- [ ] Deactivated accounts can't login
- [ ] Pending approval accounts can login

### Token Management

- [ ] Access token expires after 15 minutes
- [ ] Refresh token works to get new access token
- [ ] Invalid tokens rejected
- [ ] Expired tokens return proper error
- [ ] Token version increments on logout

### Database

- [ ] All indexes created
- [ ] Geospatial index works
- [ ] Phone numbers normalized
- [ ] Passwords bcrypt hashed
- [ ] OTP codes hashed

---

## 🎯 Success Criteria

✅ **All 14 endpoints working**
✅ **Security features functional**
✅ **Database indexes created**
✅ **Rate limiting active**
✅ **Token management working**
✅ **Password validation enforced**
✅ **Account locking working**
✅ **OTP system functional**

---

## 🐛 Common Issues & Fixes

### Issue: "Phone must include country code"

**Fix:** Add `DEFAULT_COUNTRY_CODE=+91` to .env

### Issue: "OTP not received"

**Fix:** Check console logs for fallback OTP

### Issue: "Invalid token"

**Fix:** Ensure JWT_SECRET is set in .env

### Issue: "Worker not found"

**Fix:** Check MongoDB connection and database name

### Issue: "Account locked"

**Fix:** Wait 30 minutes or manually reset in database:

```javascript
db.workers.updateOne(
  { phone: "+919876543210" },
  { $unset: { loginAttempts: "", lockUntil: "" } }
);
```

### Issue: "Too many requests"

**Fix:** Wait for rate limit window to expire or test from different IP

---

## 📊 Test Results Template

```
WORKER AUTHENTICATION TEST RESULTS
===================================

Date: ___________
Server: ___________

Registration Flow:
[ ] Registration successful
[ ] OTP sent
[ ] OTP verification successful
[ ] Tokens received

Login Flow:
[ ] Login with password successful
[ ] Tokens received
[ ] Worker data correct

Profile Management:
[ ] Get profile works
[ ] Update profile works
[ ] Availability toggle works

Security:
[ ] Password validation works
[ ] Account locking works
[ ] Rate limiting works
[ ] Token expiry works

Overall Status: PASS / FAIL
Notes: ___________
```

**Ready to test! 🚀**
