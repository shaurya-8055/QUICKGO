import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Default URLs for local development. Android emulators cannot reach the host
// machine via `localhost`, they need `10.0.2.2`.
const String _LOCALHOST_URL = 'http://localhost:3000';
const String _ANDROID_EMULATOR_URL = 'http://10.0.2.2:3000';

// Backwards-compat constant (some old code may read this), but prefer getMainUrl().
const String MAIN_URL = _LOCALHOST_URL;

// Determine the correct base URL for the current platform.
String getMainUrl() {
  if (kIsWeb) return _LOCALHOST_URL; // adjust if hosting elsewhere
  try {
    if (Platform.isAndroid) return _ANDROID_EMULATOR_URL;
    // iOS Simulator and desktop can use localhost
    return _LOCALHOST_URL;
  } catch (_) {
    return _LOCALHOST_URL;
  }
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
