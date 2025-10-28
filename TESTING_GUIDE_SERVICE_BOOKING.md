# Testing Guide: Service Booking Fix

## Quick Test Steps

### 1. Test Client App - Service Booking

#### Prerequisites:

- Client app running on emulator/device
- User logged in
- Backend API running

#### Test Steps:

1. **Navigate to Services**:

   - Open the app
   - Go to Services section
   - Select any service category (e.g., Painter, Plumber)

2. **Fill Booking Form**:

   - Enter customer name
   - Enter phone number
   - Enter address
   - Add description (optional)
   - Select preferred date
   - Choose time slot (Morning/Afternoon/Evening)

3. **Submit Booking**:

   - Click "Book Service" or "Submit" button
   - **Expected**: Green success SnackBar appears
   - **Expected**: Message says "Service booking request submitted successfully!"
   - **Should NOT see**: Any error about null operator
   - **Expected**: Automatically navigate back after 1.5 seconds

4. **Verify Notification**:

   - After successful booking, tap the bell icon (notifications)
   - **Expected**: See new notification "Service booking submitted"
   - **Expected**: Notification shows category and time slot

5. **Check My Requests**:
   - Navigate to "My Service Requests" or Profile > My Bookings
   - **Expected**: See your newly created booking
   - **Expected**: Status shows as "pending"

### 2. Test Admin Portal - View Bookings

#### Prerequisites:

- Admin app running on browser/desktop
- Admin logged in
- At least one service booking created

#### Test Steps:

1. **Navigate to Service Requests**:

   - Log into admin portal
   - Find "Service Requests" in the sidebar
   - Click to open Service Requests screen

2. **Verify Booking Display**:

   - **Expected**: See data table with all service requests
   - **Expected**: Your test booking is visible
   - Check columns display correctly:
     - Customer name
     - Phone number
     - Service category
     - Preferred date
     - Preferred time
     - Status (should be "pending")

3. **Test Filtering**:

   - Click the status dropdown
   - Select "pending"
   - **Expected**: Only pending requests shown
   - Select "All status"
   - **Expected**: All requests visible again

4. **Test Search**:

   - Type customer name in search box
   - **Expected**: List filters to matching records
   - Type phone number
   - **Expected**: List filters to matching records
   - Clear search
   - **Expected**: All records visible again

5. **Test Refresh**:

   - Click refresh button (circular arrow icon)
   - **Expected**: Success message appears
   - **Expected**: List reloads with latest data

6. **Test Actions** (if implemented):
   - Click action button on a request
   - Try updating status
   - **Expected**: Status updates successfully
   - **Expected**: Confirmation message appears

### 3. Edge Case Testing

#### Test Without Internet:

1. Turn off WiFi/mobile data
2. Try to book a service
3. **Expected**: Error message about network failure
4. **Should NOT**: Show null operator error
5. **Should NOT**: Crash the app

#### Test Rapid Booking:

1. Book a service
2. Immediately try to book again (within 5 seconds)
3. **Expected**: Message "Please wait a few seconds before submitting again"
4. Wait 5 seconds
5. Try booking again
6. **Expected**: Booking should work normally

#### Test with Empty Fields:

1. Leave required fields empty
2. Try to submit
3. **Expected**: Validation errors for required fields
4. **Should NOT**: Create incomplete booking

### 4. Log Verification

#### Check Console Output:

```bash
# In client app terminal, look for:
✓ Service request created
✓ {success: true, message: Service request created, data: {...}}

# Should NOT see:
✗ Null check operator used on a null value
✗ NoSuchMethodError
✗ Storage error: ... (unless storage is actually unavailable)
```

#### Check Backend Logs:

```bash
# In API terminal, look for:
✓ POST /service-requests 200 OK
✓ Request body contains all expected fields

# Should NOT see:
✗ 500 Internal Server Error
✗ Missing required fields
✗ Database save errors
```

## Success Criteria

### Client App:

- ✅ Booking completes without showing null operator error
- ✅ Success message displays correctly
- ✅ Notification is added to notifications list
- ✅ User can view their booking in request history
- ✅ App doesn't crash during booking process

### Admin Portal:

- ✅ All service bookings are visible
- ✅ Filter by status works correctly
- ✅ Search functionality works
- ✅ Refresh updates the list
- ✅ All booking details display accurately
- ✅ Action buttons are responsive

### Backend:

- ✅ Service requests saved to database
- ✅ All fields persisted correctly
- ✅ Timestamps recorded
- ✅ User ID linked to request
- ✅ Status defaults to "pending"

## Common Issues & Solutions

### Issue: Still seeing null operator error

**Solution**:

- Ensure you've hot restarted the app (not just hot reload)
- Check that GetStorage.init() is called in main.dart
- Verify NotificationsProvider is registered in MultiProvider

### Issue: Bookings not showing in admin portal

**Solution**:

- Verify API endpoint is accessible: http://your-api/service-requests
- Check that admin portal is using same API base URL as client
- Try refreshing the admin portal
- Check browser console for errors

### Issue: Notifications not appearing

**Solution**:

- This is now non-critical - booking should still work
- Check console for "Storage error" messages
- Verify GetStorage is properly initialized
- Try clearing app data and restarting

### Issue: Admin portal showing empty list

**Solution**:

- Click the refresh button
- Check network tab in browser dev tools
- Verify API is returning data
- Check console for JavaScript errors

## Hot Restart Command

```bash
# In client app directory
cd client_side/client_app

# Hot restart the app
# Press 'R' in the terminal running flutter
# Or use VS Code command: Flutter: Hot Restart
```

## Database Verification

### MongoDB Query to Check Bookings:

```javascript
// In MongoDB Compass or Shell
db.servicerequests.find().sort({ createdAt: -1 }).limit(10);

// Should return recent bookings with:
// - userID (not null)
// - category
// - customerName
// - phone
// - address
// - status: "pending"
// - createdAt timestamp
```

---

**Tip**: Test the booking flow at least 3 times with different data to ensure consistency.

**Tip**: Keep both client app and admin portal open side-by-side to verify real-time sync.

**Tip**: Check the terminal/console logs during testing - they provide valuable debugging info.
