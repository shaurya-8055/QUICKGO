// Production URL pointing to your deployed Render server
const String _PRODUCTION_URL = 'https://quickgo-tpum.onrender.com';

// Use dart-define API_BASE_URL if provided, otherwise fallback to localhost
const String _DEFAULT_URL = 'http://localhost:3000';

// Backwards-compat constant (some old code may read this), but prefer getMainUrl().
const String MAIN_URL =
    String.fromEnvironment('API_BASE_URL', defaultValue: _DEFAULT_URL);

// Determine the correct base URL for the current platform.
String getMainUrl() {
  // Use dart-define API_BASE_URL if provided
  const String envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }

  // Use production server for APK builds and device testing
  return _PRODUCTION_URL;

  // For local development with physical device, uncomment this:
  // return _LOCAL_DEV_URL;

  // For emulator testing, uncomment this:
  // return _DEFAULT_URL;

  // For local development, uncomment these imports and modify return logic:
  // import 'dart:io' show Platform;
  // import 'package:flutter/foundation.dart' show kIsWeb;
  // const String _LOCALHOST_URL = 'http://localhost:3000';
  // const String _ANDROID_EMULATOR_URL = 'http://10.0.2.2:3000';

  // if (kIsWeb) return _LOCALHOST_URL;
  // try {
  //   if (Platform.isAndroid) return _ANDROID_EMULATOR_URL;
  //   return _LOCALHOST_URL;
  // } catch (_) {
  //   return _LOCALHOST_URL;
  // }
}

// Google OAuth Web client ID (used as serverClientId so the backend can verify
// the ID token). Pass at build time with:
//   flutter build apk --dart-define=GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
// On web, also add the same value as a <meta name="google-signin-client_id"> in web/index.html.
const String GOOGLE_WEB_CLIENT_ID =
    String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

const FAVORITE_PRODUCT_BOX = 'FAVORITE_PRODUCT_BOX';
const USER_INFO_BOX = 'USER_INFO_BOX';
const AUTH_TOKEN_BOX = 'AUTH_TOKEN_BOX';
const PENDING_OTP_PHONE = 'PENDING_OTP_PHONE';
const PENDING_OTP_EMAIL = 'PENDING_OTP_EMAIL';

const PHONE_KEY = 'PHONE_KEY';
const STREET_KEY = 'STREET_KEY';
const CITY_KEY = 'CITY_KEY';
const STATE_KEY = 'STATE_KEY';
const POSTAL_CODE_KEY = 'POSTAL_CODE_KEY';
const COUNTRY_KEY = 'COUNTRY_KEY';
