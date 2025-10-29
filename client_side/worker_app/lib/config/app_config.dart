class AppConfig {
  static const String appName = 'QuickGo Worker';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = 'v1';

  // Endpoints
  static const String loginEndpoint = '/auth/worker/login';
  static const String verifyOtpEndpoint = '/auth/worker/verify-otp';
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
