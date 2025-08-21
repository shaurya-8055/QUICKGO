// Local development configuration
// Use this file for testing with local development server

// Your computer's local IP address for device testing
const String _LOCAL_DEVELOPMENT_URL = 'http://192.168.1.9:3000';

// Production URL
const String _PRODUCTION_URL = 'https://quickgo-tpum.onrender.com';

// Default localhost for emulator
const String _DEFAULT_URL = 'http://localhost:3000';

// Configure for local development server access from physical device
String getLocalDevUrl() {
  return _LOCAL_DEVELOPMENT_URL;
}

String getProductionUrl() {
  return _PRODUCTION_URL;
}

String getDefaultUrl() {
  return _DEFAULT_URL;
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
