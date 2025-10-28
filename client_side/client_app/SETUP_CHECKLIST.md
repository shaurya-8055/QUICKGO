# Quick Setup Checklist ✅

## Before Running the App

### 1. ✅ Dependencies Installed

- [x] All packages installed via `flutter pub get`

### 2. ⚠️ API Keys Required (MUST DO)

#### Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select project
3. Enable **Maps SDK for Android** and **Maps SDK for iOS**
4. Create API key
5. Add to:

**Android**: `android/app/src/main/AndroidManifest.xml`

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
</application>
```

**iOS**: `ios/Runner/AppDelegate.swift`

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Gemini AI API Key

1. Go to [Google AI Studio](https://ai.google.dev/)
2. Create API key
3. Update `lib/services/gemini_ai_service.dart`:

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

### 3. ⚠️ Location Permissions

**Android**: `android/app/src/main/AndroidManifest.xml` (add before `<application>`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS**: `ios/Runner/Info.plist` (add inside `<dict>`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby service workers</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to find nearby service workers</string>
```

### 4. ⚠️ Register TechnicianProvider

In `lib/main.dart`, add to your MultiProvider list:

```dart
MultiProvider(
  providers: [
    // ... existing providers ...
    ChangeNotifierProvider(create: (_) => TechnicianProvider()),
  ],
  child: MyApp(),
)
```

### 5. ⚠️ Backend Updates Required

Your backend needs to support new technician fields. Update the Technician model schema:

**File**: `server_side/online_store_api/model/technician.js`

Add these fields:

```javascript
const technicianSchema = new mongoose.Schema(
  {
    name: String,
    phone: String,
    skills: [String],
    active: { type: Boolean, default: true },

    // NEW FIELDS:
    latitude: Number,
    longitude: Number,
    rating: { type: Number, default: 0 },
    totalJobs: { type: Number, default: 0 },
    yearsExperience: { type: Number, default: 0 },
    profileImage: String,
    certifications: [String],
    verified: { type: Boolean, default: false },
    pricePerHour: Number,
    bio: String,
    currentlyAvailable: { type: Boolean, default: true },
  },
  { timestamps: true }
);
```

---

## Testing Checklist

### Test 1: Worker Discovery

- [ ] Go to Services screen
- [ ] Select "AC Repair"
- [ ] Choose "Find Workers Nearby"
- [ ] Grant location permission
- [ ] See map with your location (blue marker)
- [ ] See worker markers (green/red)
- [ ] Toggle to list view
- [ ] Tap a worker to see profile

### Test 2: Filters

- [ ] In Worker Discovery, tap filter icon
- [ ] Adjust minimum rating slider
- [ ] Adjust max price slider
- [ ] Toggle "Verified Only"
- [ ] Tap "Apply Filters"
- [ ] Verify workers are filtered correctly

### Test 3: Worker Profile

- [ ] Select a worker from list/map
- [ ] See complete profile details
- [ ] Tap "Call" button (should open phone dialer)
- [ ] Tap "Book Service" (should open booking form)

### Test 4: AI Features (After API Key Setup)

- [ ] AI will automatically rank workers
- [ ] Check console for AI responses
- [ ] Verify ranking makes sense (high rating + close distance = top)

---

## Common Issues & Solutions

### ❌ Error: "Google Maps API key not found"

**Solution**: Make sure you added the API key to AndroidManifest.xml or AppDelegate.swift

### ❌ Error: "Location permission denied"

**Solution**:

1. Check permissions are added to manifest/Info.plist
2. Uninstall and reinstall the app
3. Grant permission when prompted

### ❌ Error: "No workers found"

**Solutions**:

1. Check backend is running and has technician data
2. Verify technicians have latitude/longitude values
3. Increase search radius
4. Check if worker skills match the category

### ❌ Map shows blank/grey tiles

**Solutions**:

1. Verify API key is correct
2. Enable billing on Google Cloud (Maps API requires billing)
3. Check internet connection

### ❌ AI features not working

**Solutions**:

1. Verify Gemini API key is added
2. Check internet connection
3. View console logs for API errors
4. Fallback ranking will still work

---

## Next Steps

### Immediate (Do Now):

1. ✅ Add Google Maps API key
2. ✅ Add Gemini AI API key
3. ✅ Update backend technician model
4. ✅ Register TechnicianProvider
5. ✅ Test on a real device (maps don't work well on emulators)

### Soon (Within a Week):

1. ⏰ Add sample technician data with lat/long to backend
2. ⏰ Implement payment integration (Razorpay/Stripe)
3. ⏰ Build chat feature
4. ⏰ Add voice/video calling

### Later (Future Enhancements):

1. 📊 Add analytics dashboard
2. 🔔 Push notifications for booking updates
3. ⭐ Rating & review system
4. 📸 Photo uploads for service issues
5. 🎯 Service history tracking

---

## 📞 Need Help?

If you get stuck:

1. Check the detailed documentation: `NEW_FEATURES_IMPLEMENTATION.md`
2. Review error messages in console
3. Verify all API keys are added correctly
4. Make sure backend is running and updated

---

**Good Luck! 🚀**

Your app now has:

- ✅ AI-powered recommendations
- ✅ Map-based worker discovery
- ✅ Smart filters
- ✅ Enhanced worker profiles
- ✅ Modern UI/UX

Just add the API keys and you're ready to go!
