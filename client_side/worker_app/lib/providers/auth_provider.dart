import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = GetStorage();
  final _apiService = ApiService();

  Map<String, dynamic>? _workerData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get workerData => _workerData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _workerData != null && _apiService.token != null;

  AuthProvider() {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedData = _storage.read('worker_data');
    if (savedData != null && _apiService.token != null) {
      _workerData = Map<String, dynamic>.from(savedData);
      notifyListeners();
    }
  }

  // Persist worker data from a successful auth response.
  void _persistWorker(Map<String, dynamic> response) {
    _workerData = response['data']['worker'];
    _storage.write('worker_data', _workerData);
  }

  // Sign up new worker. After signup the backend emails a verification code;
  // call verifyEmailOtp() with that code to finish and log in.
  Future<bool> signup({
    required String email,
    required String name,
    required String password,
    required String primaryCategory,
    String? phone,
    List<String>? skills,
    String? city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.workerSignup(
        email: email,
        name: name,
        password: password,
        primaryCategory: primaryCategory,
        phone: phone,
        skills: skills,
        city: city,
      );

      _isLoading = false;
      if (response['success'] == true) {
        notifyListeners();
        return true; // code emailed; proceed to OTP screen
      } else {
        _errorMessage = response['message'] ?? 'Signup failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during signup: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login worker with email/username/phone + password.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.workerLogin(
        identifier: identifier,
        password: password,
      );

      if (response['success'] == true) {
        _persistWorker(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Request an email OTP for login.
  Future<bool> requestEmailOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.workerRequestEmailOtp(email: email);
      _isLoading = false;
      if (response['success'] == true) {
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Failed to send code';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify an email OTP and log in.
  Future<bool> verifyEmailOtp(
      {required String email, required String code}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response =
          await _apiService.workerVerifyEmailOtp(email: email, code: code);
      _isLoading = false;
      if (response['success'] == true) {
        _persistWorker(response);
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Verification failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Continue with Google.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: AppConfig.googleWebClientId.isNotEmpty
            ? AppConfig.googleWebClientId
            : null,
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        _errorMessage = 'Google sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final gAuth = await account.authentication;
      final idToken = gAuth.idToken;
      if (idToken == null) {
        _errorMessage = 'Could not obtain Google ID token. Check GOOGLE_WEB_CLIENT_ID.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final response = await _apiService.workerGoogleSignIn(idToken: idToken);
      _isLoading = false;
      if (response['success'] == true) {
        _persistWorker(response);
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Google sign-in failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _apiService.clearToken();
    _storage.remove('worker_data');
    _workerData = null;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateWorkerProfile(data);

      if (response['success'] == true) {
        _workerData = response['data'];
        _storage.write('worker_data', _workerData);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle availability
  Future<void> toggleAvailability() async {
    try {
      final newStatus = !isAvailable;
      final response = await _apiService.toggleAvailability(newStatus);

      if (response['success'] == true) {
        _workerData?['isAvailable'] = newStatus;
        _workerData?['lastStatusUpdate'] = DateTime.now().toIso8601String();
        _storage.write('worker_data', _workerData);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error toggling availability: $e';
      notifyListeners();
    }
  }

  // Update location
  Future<bool> updateLocation(double longitude, double latitude) async {
    try {
      final response = await _apiService.updateLocation(longitude, latitude);

      if (response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  // Getters for worker data
  String get workerId => _workerData?['_id'] ?? '';
  String get workerName => _workerData?['name'] ?? 'Worker';
  String get workerPhone => _workerData?['phone'] ?? '';
  String get workerEmail => _workerData?['email'] ?? '';
  String? get workerPhoto => _workerData?['photoUrl'];
  double get workerRating => (_workerData?['rating'] ?? 0.0).toDouble();
  int get completedJobs => _workerData?['completedJobs'] ?? 0;
  bool get isOnline => _workerData?['isOnline'] ?? false;
  bool get isAvailable => _workerData?['isAvailable'] ?? false;
  bool get isVerified => _workerData?['isVerified'] ?? false;

  // KYC details
  String get aadharNumber => _workerData?['aadharNumber'] ?? '';
  bool get aadharVerified => _workerData?['aadharVerified'] ?? false;
  String get panNumber => _workerData?['panNumber'] ?? '';
  bool get panVerified => _workerData?['panVerified'] ?? false;

  // Bank details
  String get bankName => _workerData?['bankName'] ?? '';
  String get accountNumber => _workerData?['accountNumber'] ?? '';
  String get ifscCode => _workerData?['ifscCode'] ?? '';
  String get upiId => _workerData?['upiId'] ?? '';

  // Service details
  String get city => _workerData?['city'] ?? '';
  double get serviceRadius =>
      (_workerData?['serviceRadius'] ?? 10.0).toDouble();
  List<String> get serviceType {
    if (_workerData?['serviceType'] == null) return [];
    return List<String>.from(_workerData!['serviceType']);
  }
}
