# 🚀 Vercel Deployment Guide - Client App

## ✅ Fixes Applied

### 1. Removed .env from pubspec.yaml assets

**Reason**: `.env` file is in `.gitignore` (correct for security), so it won't be in the repository. Vercel builds fail when assets are missing.

**Change in `pubspec.yaml`**:

```yaml
# BEFORE:
assets:
  - assets/images/
  - .env  # ❌ This causes build failure on Vercel

# AFTER:
assets:
  - assets/images/
  # .env loaded locally, Vercel uses dashboard environment variables
```

### 2. Updated main.dart to handle missing .env

**Change in `lib/main.dart`**:

```dart
// BEFORE:
await dotenv.load(fileName: ".env");  // ❌ Throws error if file missing

// AFTER:
try {
  await dotenv.load(fileName: ".env");
} catch (e) {
  print('Note: .env file not found, using system environment variables');
}
```

### 3. Updated GeminiAIService to support compile-time constants

**Change in `lib/services/gemini_ai_service.dart`**:

```dart
// BEFORE:
final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

// AFTER:
final apiKey = dotenv.env['GEMINI_API_KEY'] ??
               const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
```

---

## 🔧 Vercel Configuration Required

### Step 1: Set Environment Variables in Vercel Dashboard

1. **Go to your Vercel project**:

   - Visit: https://vercel.com/dashboard
   - Select your project: QUICKGO

2. **Navigate to Settings → Environment Variables**

3. **Add these environment variables**:

#### API Base URL

```
Name: API_BASE_URL
Value: https://your-api-domain.com
OR
Value: http://localhost:3000 (for testing)
```

#### Google Maps API Key

```
Name: GOOGLE_MAPS_API_KEY
Value: YOUR_GOOGLE_MAPS_API_KEY_HERE
```

#### Gemini AI API Key

```
Name: GEMINI_API_KEY
Value: YOUR_GEMINI_API_KEY_HERE
```

4. **Set environment for**:

   - ✅ Production
   - ✅ Preview
   - ✅ Development

5. **Click "Save"**

---

### Step 2: Update vercel.json Build Command

The build command needs to pass environment variables to Flutter:

**File**: `client_side/client_app/vercel.json`

```json
{
  "buildCommand": "flutter/bin/flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY",
  "outputDirectory": "build/web",
  "installCommand": "git clone https://github.com/flutter/flutter.git -b stable --depth 1 && flutter/bin/flutter config --enable-web && flutter/bin/flutter pub get"
}
```

---

### Step 3: Get Your API Keys

#### Google Maps API Key:

1. Go to: https://console.cloud.google.com/
2. Enable Maps JavaScript API
3. Create API credentials
4. Copy the API key
5. Add to Vercel environment variables

#### Gemini AI API Key:

1. Go to: https://aistudio.google.com/app/apikey
2. Create new API key
3. Copy the key
4. Add to Vercel environment variables

#### API Base URL:

- If you have a deployed backend API, use that URL
- For testing, you can use: `http://localhost:3000`
- **Important**: Make sure to deploy your backend API first!

---

## 📝 Updated File Structure

```
client_side/client_app/
├── .env (local only, in .gitignore) ✅
├── .env.example (template in git) ✅
├── pubspec.yaml (no .env in assets) ✅
├── lib/
│   ├── main.dart (handles missing .env) ✅
│   └── services/
│       └── gemini_ai_service.dart (supports dart-define) ✅
└── vercel.json (with environment variables) ⚠️ UPDATE THIS
```

---

## 🧪 Testing the Fix

### Local Testing (Should still work):

```powershell
cd client_side\client_app
flutter run -d chrome
```

**Expected**: App loads using `.env` file

### Vercel Testing:

1. Commit and push changes:

```bash
git add .
git commit -m "Fix Vercel deployment - use environment variables"
git push
```

2. Vercel will automatically redeploy

3. Check build logs at: https://vercel.com/dashboard

**Expected**: Build succeeds without `.env` error

---

## ⚠️ Important Notes

### For Local Development:

- ✅ Keep using `.env` file locally
- ✅ Never commit `.env` to git
- ✅ Share `.env.example` with team members

### For Production/Vercel:

- ✅ Set environment variables in Vercel dashboard
- ✅ No `.env` file in repository
- ✅ Secrets stay secure in Vercel

### Security Best Practices:

1. **Never commit** API keys to git
2. **Rotate exposed keys** immediately (if you accidentally committed them)
3. **Use Vercel's** environment variable encryption
4. **Set API restrictions** on Google Cloud Console (restrict by domain)

---

## 🐛 Troubleshooting

### Build Still Fails with "No file or variants found for asset: .env"

**Solution**: Make sure you've removed `.env` from `pubspec.yaml` assets section:

```yaml
# This should NOT be in your pubspec.yaml:
assets:
  - .env # ❌ REMOVE THIS LINE
```

### "GEMINI_API_KEY not found" Error

**Solution**:

1. Check Vercel dashboard → Settings → Environment Variables
2. Make sure `GEMINI_API_KEY` is set
3. Redeploy the project

### Google Maps not working on Vercel

**Solution**:

1. Add `GOOGLE_MAPS_API_KEY` to Vercel environment variables
2. Update `vercel.json` buildCommand to include: `--dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY`
3. In your code, use: `const String.fromEnvironment('GOOGLE_MAPS_API_KEY')`

### API calls failing (CORS errors)

**Solution**:

1. Deploy your backend API to a production server
2. Update `API_BASE_URL` in Vercel to point to production API
3. Configure CORS on your backend to allow Vercel domain

---

## 📋 Deployment Checklist

Before deploying to Vercel:

- [ ] ✅ Removed `.env` from `pubspec.yaml` assets
- [ ] ✅ Updated `main.dart` with try-catch for dotenv.load()
- [ ] ✅ Updated services to support `String.fromEnvironment()`
- [ ] ✅ Created/updated `vercel.json` with build command
- [ ] ✅ Set environment variables in Vercel dashboard:
  - [ ] API_BASE_URL
  - [ ] GEMINI_API_KEY
  - [ ] GOOGLE_MAPS_API_KEY
- [ ] ✅ Deployed backend API (if not already deployed)
- [ ] ✅ Tested locally first
- [ ] ✅ Committed and pushed changes
- [ ] ✅ Monitored Vercel build logs

---

## 🎯 Next Steps

1. **Create vercel.json** in `client_side/client_app/` with the configuration above
2. **Add environment variables** to Vercel dashboard
3. **Commit and push** changes
4. **Monitor deployment** at https://vercel.com/dashboard

---

## 📞 Support

If you encounter issues:

1. Check Vercel build logs for specific errors
2. Verify all environment variables are set correctly
3. Test locally first to ensure code works
4. Check browser console for runtime errors

---

**Status**: ✅ Ready to deploy after setting Vercel environment variables
**Last Updated**: October 29, 2025
