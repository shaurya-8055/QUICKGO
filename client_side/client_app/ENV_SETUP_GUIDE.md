# Environment Variables Setup Guide

This guide explains how to set up API keys securely using environment variables.

## 📋 Prerequisites

- Google Maps API Key (for map-based worker discovery)
- Google Gemini AI API Key (for AI-powered recommendations)

## 🔧 Setup Steps

### 1. Get Your API Keys

#### **Google Maps API Key**

1. Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if building for iOS)
   - Geocoding API
   - Places API (optional, for autocomplete)
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key
6. **Restrict your API key** for security:
   - Application restrictions: Select "Android apps" and add your package name
   - API restrictions: Select "Restrict key" and choose the Maps-related APIs

#### **Google Gemini AI API Key**

1. Go to [Google AI Studio](https://ai.google.dev/)
2. Click "Get API key"
3. Create a new API key
4. Copy your API key

### 2. Configure Environment Variables

#### **Option A: Using .env File (Recommended)**

1. The `.env` file already exists in the project root
2. Open `.env` and replace the placeholder values:

```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_KEY_HERE

# Google Gemini AI API Key
GEMINI_API_KEY=YOUR_ACTUAL_GEMINI_KEY_HERE
```

3. Save the file

**✅ The `.env` file is already added to `.gitignore`, so your keys won't be committed to GitHub**

#### **Option B: Direct Configuration (Not Recommended)**

If you prefer not to use the `.env` file approach, you can configure the API keys directly in the code:

**For Google Maps:**
Update `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_KEY_HERE"/>
```

**For Gemini AI:**
Update `lib/services/gemini_ai_service.dart`:

```dart
GeminiAIService() {
  final apiKey = 'YOUR_GEMINI_KEY_HERE'; // Not recommended - use .env instead
  _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
}
```

### 3. Install Dependencies

Run the following command to install `flutter_dotenv`:

```bash
flutter pub get
```

### 4. Verify Setup

1. The `.env` file should be loaded in `lib/main.dart`:

```dart
await dotenv.load(fileName: ".env");
```

2. Gemini AI service should read from environment:

```dart
final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
```

3. Run the app to test:

```bash
flutter run --debug
```

## 🔒 Security Best Practices

### ✅ DO:

- ✅ Use `.env` for local development
- ✅ Keep `.env` in `.gitignore`
- ✅ Use `.env.example` as a template (can be committed)
- ✅ Restrict API keys in Google Cloud Console
- ✅ Use different API keys for development and production
- ✅ Rotate API keys periodically
- ✅ Monitor API usage in Google Cloud Console

### ❌ DON'T:

- ❌ Commit `.env` to version control
- ❌ Share API keys publicly
- ❌ Use the same API keys across multiple projects
- ❌ Leave API keys unrestricted
- ❌ Hardcode API keys in source code

## 📝 File Structure

```
client_app/
├── .env                    # Your actual API keys (NEVER commit this)
├── .env.example            # Template file (safe to commit)
├── .gitignore             # Contains .env to prevent commits
├── lib/
│   ├── main.dart          # Loads environment variables
│   └── services/
│       └── gemini_ai_service.dart  # Uses GEMINI_API_KEY
└── android/app/src/main/
    └── AndroidManifest.xml  # Uses GOOGLE_MAPS_API_KEY
```

## 🚀 For Team Members

When a new developer clones the project:

1. Copy `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Ask the team lead for the development API keys

3. Update `.env` with the provided keys

4. Run `flutter pub get`

5. Build and run the app

## ⚠️ Troubleshooting

### "GEMINI_API_KEY not found in .env file"

- Make sure `.env` exists in the project root
- Verify the key name is exactly `GEMINI_API_KEY` (case-sensitive)
- Run `flutter clean` and `flutter pub get`

### "Google Maps not loading"

- Check that your API key is correctly set in AndroidManifest.xml
- Verify the API key has Maps SDK for Android enabled
- Check that your app's SHA-1 fingerprint is added to the API key restrictions

### "Package 'flutter_dotenv' not found"

- Run `flutter pub add flutter_dotenv`
- Run `flutter pub get`

## 📚 Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Google AI Gemini API Documentation](https://ai.google.dev/docs)
- [flutter_dotenv Package](https://pub.dev/packages/flutter_dotenv)
- [Best Practices for API Key Security](https://cloud.google.com/docs/authentication/api-keys)

## 🔄 Updating API Keys in Production

For production builds, consider using:

- Flutter Build Configurations
- CI/CD environment variables
- Secret management services (AWS Secrets Manager, Google Secret Manager, etc.)
- Firebase Remote Config

Never hardcode production API keys in the source code or `.env` file that might be committed.
