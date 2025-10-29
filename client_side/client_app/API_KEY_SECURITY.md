# 🔐 API Key Security Guide

## ⚠️ IMPORTANT: Your API Keys Were Exposed

Your Google Maps and Gemini API keys were previously committed to GitHub in plain text. This is a **critical security issue**. Follow these steps immediately:

## 🚨 Immediate Actions Required

### 1. Rotate Your API Keys

#### Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis)
2. Navigate to "Credentials"
3. Find your current API key: `***REMOVED***`
4. **Delete** or **Regenerate** this key
5. Create a new API key
6. Set proper restrictions (see below)

#### Google Gemini API Key

1. Go to [Google AI Studio](https://ai.google.dev/)
2. Revoke your current API key: `***REMOVED***`
3. Generate a new API key

### 2. Update Your Local Configuration

After generating new API keys:

1. Open `.env` file (already in .gitignore):

```env
GOOGLE_MAPS_API_KEY=your_new_google_maps_key_here
GEMINI_API_KEY=your_new_gemini_key_here
```

2. Update `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="your_new_google_maps_key_here"/>
```

### 3. Set Up API Key Restrictions

#### For Google Maps API Key:

1. **Application restrictions**:
   - Select "Android apps"
   - Add your app's package name: `com.example.client_app`
   - Add your SHA-1 certificate fingerprint
2. **API restrictions**:
   - Select "Restrict key"
   - Enable only these APIs:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Geocoding API
     - Places API (if using autocomplete)

#### For Gemini API Key:

1. Set usage limits
2. Monitor usage regularly
3. Consider IP restrictions if applicable

## 📁 Files That Should NEVER Contain Real API Keys

- ❌ Any file committed to Git
- ❌ AndroidManifest.xml (use build configurations instead)
- ❌ Any Dart/Flutter source code
- ✅ `.env` file (already in .gitignore)
- ✅ Local configuration files (not committed)

## 🔒 Better Approach: Use Build Configurations

### For Android (Recommended)

1. Create `android/local.properties` (already in .gitignore):

```properties
# Android local properties
GOOGLE_MAPS_API_KEY=your_actual_key_here
```

2. Update `android/app/build.gradle`:

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

android {
    defaultConfig {
        manifestPlaceholders = [
            googleMapsApiKey: localProperties.getProperty('GOOGLE_MAPS_API_KEY', '')
        ]
    }
}
```

3. Update `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${googleMapsApiKey}"/>
```

## 🔍 Check If Your Keys Were Compromised

1. **Check Google Cloud Console**:

   - Go to "APIs & Services" → "Credentials"
   - Click on your API key
   - Check "API key requests" for unusual activity

2. **Check Gemini API Usage**:

   - Go to [Google AI Studio](https://ai.google.dev/)
   - Review usage statistics
   - Look for unexpected spikes

3. **Search GitHub**:
   - Search for your API keys in GitHub to see if they're exposed
   - Use GitHub's secret scanning alerts

## 🛡️ Prevention for Future

### Git Hooks (Recommended)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/sh
# Check for API keys before committing

if git diff --cached | grep -E "AIzaSy[A-Za-z0-9_-]{33}"; then
    echo "❌ ERROR: Google API key detected in commit!"
    echo "Please remove API keys and use environment variables instead."
    exit 1
fi

exit 0
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Use GitHub Secret Scanning

GitHub automatically scans for exposed secrets. Make sure it's enabled:

1. Go to your repository → Settings → Security
2. Enable "Secret scanning"
3. Enable "Push protection"

## 📝 Checklist

- [ ] Rotated Google Maps API key
- [ ] Rotated Gemini API key
- [ ] Updated `.env` file with new keys
- [ ] Updated `AndroidManifest.xml` with new Maps key
- [ ] Set API key restrictions in Google Cloud Console
- [ ] Verified `.env` is in `.gitignore`
- [ ] Checked for unusual API usage
- [ ] Set up git hooks to prevent future exposure
- [ ] Enabled GitHub secret scanning

## 🆘 If You Need Help

1. **Google Cloud Support**: [https://cloud.google.com/support](https://cloud.google.com/support)
2. **Report Compromised Keys**: [https://support.google.com/](https://support.google.com/)
3. **GitHub Security**: [https://docs.github.com/en/code-security](https://docs.github.com/en/code-security)

## 📚 Additional Resources

- [API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)
- [Keeping Secrets Safe in Git](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)

---

**Remember**: API keys are like passwords. Once exposed, they must be rotated immediately.
