class AppConfig {
  static const String appName = 'QuickGo Worker';
  static const String appVersion = '1.0.0';

  // API Configuration
  // NOTE: the live API base URL lives in ApiService.baseUrl; this is kept in sync.
  static const String baseUrl = 'https://quickgo-tpum.onrender.com';
  static const String apiVersion = 'v1';

  // Google OAuth Web client ID (serverClientId for the backend to verify tokens).
  // Pass at build: flutter build apk --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

  // Endpoints
  static const String loginEndpoint = '/worker-auth/login';
  static const String requestEmailOtpEndpoint = '/worker-auth/email/request-otp';
  static const String verifyOtpEndpoint = '/worker-auth/email/verify-otp';
  static const String googleEndpoint = '/worker-auth/google';
  static const String jobsEndpoint = '/worker/jobs';
  static const String earningsEndpoint = '/worker/earnings';
  static const String profileEndpoint = '/worker/profile';

  // Firebase Collections
  static const String workersCollection = 'workers';
  static const String jobsCollection = 'jobs';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Pagination
  static const int itemsPerPage = 20;

  // Location
  static const double locationUpdateInterval = 10.0; // seconds
  static const double minDistanceFilter = 10.0; // meters

  // Job Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusEnRoute = 'en_route';
  static const String statusWorking = 'working';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Job Status (alternative naming for compatibility)
  static const String jobStatusPending = 'pending';
  static const String jobStatusAccepted = 'accepted';
  static const String jobStatusEnRoute = 'en_route';
  static const String jobStatusWorking = 'working';
  static const String jobStatusCompleted = 'completed';
  static const String jobStatusCancelled = 'cancelled';

  // Payment
  static const double platformFee = 0.15; // 15%
  static const double minWithdrawalAmount = 100.0;
}
