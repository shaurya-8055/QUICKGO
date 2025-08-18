import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/api_response.dart';
import '../../../models/service_request.dart';
import '../../../services/http_services.dart';

class ServiceProvider extends ChangeNotifier {
  final HttpService _http = HttpService();
  DateTime? _lastSubmitAt;
  List<ServiceRequest> _myRequests = [];
  bool _loading = false;

  List<ServiceRequest> get myRequests => _myRequests;
  bool get loading => _loading;

  Future<(bool success, String message)> createServiceRequest({
    required String category,
    required String customerName,
    required String phone,
    required String address,
    String? description,
    required DateTime preferredDate,
    required String preferredTime,
    String? userId,
  }) async {
    try {
      // simple client-side cooldown to reduce duplicates (5s)
      if (_lastSubmitAt != null &&
          DateTime.now().difference(_lastSubmitAt!) <
              const Duration(seconds: 5)) {
        return (false, 'Please wait a few seconds before submitting again');
      }
      final payload = {
        'userID': userId,
        'category': category,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'description': description,
        'preferredDate': preferredDate.toIso8601String(),
        'preferredTime': preferredTime,
        'status': 'pending',
      };
      final res = await _http.addItem(
          endpointUrl: 'service-requests', itemData: payload);

      // Normalize body to Map<String, dynamic> when possible
      dynamic body = res.body;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {/* keep as String */}
      }

      if (res.isOk) {
        if (body is Map<String, dynamic>) {
          final api = ApiResponse.fromJson(body, null);
          _lastSubmitAt = DateTime.now();
          return (api.success, api.message);
        }
        _lastSubmitAt = DateTime.now();
        return (true, res.statusText ?? 'Request submitted');
      }

      // Non-OK path – safely extract a message regardless of body type
      if (body is Map && body['message'] != null) {
        return (false, body['message'].toString());
      }
      if (body is String && body.isNotEmpty) {
        final sanitized = _stripHtml(body).trim();
        return (false, sanitized.isNotEmpty ? sanitized : body);
      }
      return (false, res.statusText ?? 'Request failed');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<void> fetchMyRequests(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _myRequests = [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      final res =
          await _http.getItems(endpointUrl: 'service-requests?userID=$userId');

      dynamic body = res.body;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }

      if (res.isOk && body is Map<String, dynamic>) {
        final api = ApiResponse<List<ServiceRequest>>.fromJson(
          body,
          (json) => (json as List)
              .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        if (api.success) {
          _myRequests = api.data ?? [];
        }
      }
    } catch (_) {
      // ignore for now
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

String _stripHtml(String input) {
  // Quick sanitize for simple HTML error pages
  final withoutTags = input.replaceAll(RegExp(r"<[^>]*>"), ' ');
  return withoutTags.replaceAll(RegExp(r"\s+"), ' ');
}
