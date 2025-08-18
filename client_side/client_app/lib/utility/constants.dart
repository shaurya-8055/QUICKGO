// Production URL pointing to your deployed Render server
const String _PRODUCTION_URL = 'https://quickgo-tpum.onrender.com';

// Backwards-compat constant (some old code may read this), but prefer getMainUrl().
const String MAIN_URL = _PRODUCTION_URL;

// Determine the correct base URL for the current platform.
String getMainUrl() {
  // Always use production URL for deployed app
  return _PRODUCTION_URL;

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

const FAVORITE_PRODUCT_BOX = 'FAVORITE_PRODUCT_BOX';
const USER_INFO_BOX = 'USER_INFO_BOX';
const AUTH_TOKEN_BOX = 'AUTH_TOKEN_BOX';
const PENDING_OTP_PHONE = 'PENDING_OTP_PHONE';

const PHONE_KEY = 'PHONE_KEY';
const STREET_KEY = 'STREET_KEY';
const CITY_KEY = 'CITY_KEY';
const STATE_KEY = 'STATE_KEY';
const POSTAL_CODE_KEY = 'POSTAL_CODE_KEY';
const COUNTRY_KEY = 'COUNTRY_KEY';
