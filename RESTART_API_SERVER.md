# ✅ Database Configuration Updated

## What Changed

Updated MongoDB connection to use the **test** database:

**Before:**

```
mongodb+srv://...@shop.jiobekx.mongodb.net/?retryWrites=true&w=majority
```

**After:**

```
mongodb+srv://...@shop.jiobekx.mongodb.net/test?retryWrites=true&w=majority
```

## 🚀 Restart API Server Now

### Step 1: Stop Current API Server

If your API server is running, **stop it** by pressing `Ctrl+C` in the terminal.

### Step 2: Restart API Server

```powershell
cd server_side\online_store_api
node index.js
```

### Step 3: Verify Connection

Look for this message in the console:

```
✅ Connected to MongoDB
Server running on port 3000
```

## 📊 Verify Admin Portal Can See Data

### Step 1: Open Admin Portal

- If not running, start it:
  ```powershell
  cd client_side\admin_app_complt_app
  flutter run -d chrome
  ```

### Step 2: Navigate to Service Requests

- Log into admin portal
- Go to "Service Requests" section

### Step 3: Expected Results

You should now see:

- ✅ Service requests from the "test" database
- ✅ The booking you just created (AC Repair for "dk")
- ✅ All collections visible: brands, categories, orders, products, etc.

## 🔍 What Collections Are Available

From your MongoDB screenshot, the "test" database contains:

| Collection      | Documents  | Status            |
| --------------- | ---------- | ----------------- |
| servicerequests | (has data) | ✅ Now accessible |
| brands          | 6          | ✅ Now accessible |
| categories      | 8          | ✅ Now accessible |
| coupons         | 0          | ✅ Now accessible |
| notifications   | 5          | ✅ Now accessible |
| orders          | 7          | ✅ Now accessible |
| posters         | 4          | ✅ Now accessible |
| products        | 6          | ✅ Now accessible |
| reviews         | 0          | ✅ Now accessible |

## 🧪 Test the Fix

### Test 1: View Service Requests

1. Admin Portal → Service Requests
2. **Expected**: See your AC Repair booking for "dk"
3. **Expected**: Status shows "pending"

### Test 2: Filter by Category

1. Search for "AC Repair" in the search box
2. **Expected**: Your booking appears in results

### Test 3: View Products

1. Admin Portal → Products
2. **Expected**: See 6 products from test database

### Test 4: View Orders

1. Admin Portal → Orders
2. **Expected**: See 7 orders from test database

## ⚠️ Important Notes

### Database Selection

- **Client App**: Also uses same MongoDB URL - will automatically use "test" database
- **Admin Portal**: Uses HTTP API which connects to "test" database
- **All data**: Now centralized in "test" database

### If You Still Don't See Data

**Option 1: Check API Server Console**

- Look for connection errors
- Verify it says "Connected to MongoDB"
- Check for any error messages

**Option 2: Check Browser Console**

- Open admin portal
- Press F12 to open DevTools
- Go to Console tab
- Look for network errors or API errors

**Option 3: Test API Directly**
Open browser and visit:

```
http://localhost:3000/service-requests
```

**Expected**: JSON response with your service requests

**Option 4: Verify Client App**

- Book another service from client app
- Check MongoDB Compass - should appear in servicerequests collection
- Refresh admin portal - should see new booking

## 🔧 Troubleshooting

### Error: "Failed to connect to MongoDB"

- Check internet connection
- Verify MongoDB Atlas cluster is running
- Check if IP is whitelisted in MongoDB Atlas

### Error: "Cannot GET /service-requests"

- API server not running
- Wrong port (should be 3000)
- Check if routes are registered

### Admin Portal Shows Empty Lists

- **Refresh** the admin portal (F5)
- Click the **refresh button** in each section
- Check browser console for errors
- Verify API is returning data (visit http://localhost:3000/service-requests)

## ✅ Success Criteria

After restart, you should be able to:

- ✅ See service requests in admin portal
- ✅ Filter and search service requests
- ✅ View products, orders, categories from test database
- ✅ Create new bookings from client app
- ✅ See new bookings immediately in admin portal (after refresh)

---

**Next Step**: Restart the API server now using the commands above!
