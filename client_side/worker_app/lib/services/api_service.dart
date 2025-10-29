import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  // Change this to your server URL
  // For Android Emulator (RECOMMENDED for testing)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:5000/api';

  // For physical device: Use your computer's IP address
  // Find your IP: Run 'ipconfig' in PowerShell, look for IPv4 Address
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  // For production
  // static const String baseUrl = 'https://your-domain.com/api';

  final _storage = GetStorage();

  // Get token from storage
  String? get token => _storage.read('auth_token');

  // Headers with authorization
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // Authentication APIs
  Future<Map<String, dynamic>> workerSignup({
    required String phone,
    required String name,
    required String password,
    String? email,
    List<String>? serviceType,
    String? city,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/worker/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'password': password,
          if (email != null) 'email': email,
          'serviceType': serviceType ?? [],
          if (city != null) 'city': city,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> workerLogin({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/worker/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> customerSignup({
    required String phone,
    required String name,
    required String password,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/customer/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'password': password,
          if (email != null) 'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> customerLogin({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Worker APIs
  Future<Map<String, dynamic>> getWorkerProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workers/profile'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateWorkerProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/workers/profile'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleAvailability(bool isAvailable) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/workers/availability'),
        headers: headers,
        body: jsonEncode({'isAvailable': isAvailable}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateLocation(
      double longitude, double latitude) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/workers/location'),
        headers: headers,
        body: jsonEncode({
          'longitude': longitude,
          'latitude': latitude,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Job APIs
  Future<Map<String, dynamic>> getAvailableJobs({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/available?page=$page'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyJobs({String? status}) async {
    try {
      final url = status != null
          ? '$baseUrl/jobs/my-jobs?status=$status'
          : '$baseUrl/jobs/my-jobs';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getJobHistory({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/history?page=$page'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/$jobId/accept'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateJobStatus(
      String jobId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jobs/$jobId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelJob(String jobId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/$jobId/cancel'),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createJob({
    required String serviceType,
    required String description,
    required String address,
    required double longitude,
    required double latitude,
    required double price,
    String? urgency,
    DateTime? scheduledTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/create'),
        headers: headers,
        body: jsonEncode({
          'serviceType': serviceType,
          'description': description,
          'address': address,
          'longitude': longitude,
          'latitude': latitude,
          'price': price,
          if (urgency != null) 'urgency': urgency,
          if (scheduledTime != null)
            'scheduledTime': scheduledTime.toIso8601String(),
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Earnings APIs
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/earnings/summary'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getTransactions({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/earnings/transactions?page=$page'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String method,
    String? upiId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/earnings/withdraw'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'method': method,
          if (upiId != null) 'upiId': upiId,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Save token if present
      if (data['data'] != null && data['data']['token'] != null) {
        _storage.write('auth_token', data['data']['token']);
      }
      return data;
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Request failed',
        'statusCode': response.statusCode,
      };
    }
  }

  // Clear token on logout
  void clearToken() {
    _storage.remove('auth_token');
  }
}
