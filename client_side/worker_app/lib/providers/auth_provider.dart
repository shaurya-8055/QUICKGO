import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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

  // Sign up new worker
  Future<bool> signup({
    required String phone,
    required String name,
    required String password,
    String? email,
    List<String>? serviceType,
    String? city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.workerSignup(
        phone: phone,
        name: name,
        password: password,
        email: email,
        serviceType: serviceType,
        city: city,
      );

      if (response['success'] == true) {
        _workerData = response['data']['worker'];
        _storage.write('worker_data', _workerData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Signup failed';
        _isLoading = false;
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

  // Login worker
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.workerLogin(
        phone: phone,
        password: password,
      );

      if (response['success'] == true) {
        _workerData = response['data']['worker'];
        _storage.write('worker_data', _workerData);
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
