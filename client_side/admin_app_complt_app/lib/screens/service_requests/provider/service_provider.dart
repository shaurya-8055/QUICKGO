import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../models/api_response.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../core/data/data_provider.dart';

class ServiceProvider extends ChangeNotifier {
  final HttpService _http = HttpService();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void _setSubmitting(bool v) {
    _isSubmitting = v;
    notifyListeners();
  }

  // Creates a service request and returns (success, message)
  Future<(bool, String)> createServiceRequest({
    String? userID,
    required String category,
    required String customerName,
    required String phone,
    required String address,
    String? description,
    required String preferredDate,
    required String preferredTime,
    String status = 'pending',
  }) async {
    try {
      _setSubmitting(true);
      final payload = {
        'userID': userID,
        'category': category,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'description': description,
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'status': status,
      };

      final Response res = await _http.addItem(
          endpointUrl: 'service-requests', itemData: payload);

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg = res.body is Map
            ? res.body['message']?.toString() ??
                res.body['error']?.toString() ??
                'Request failed'
            : res.statusText ?? 'Request failed';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar('Create Error: $msg');
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }

  // Admin: update status/assignee/notes using PUT
  Future<(bool, String)> updateStatus({
    required String id,
    required String status,
    String? assigneeId,
    String? assigneeName,
    String? assigneePhone,
    String? notes,
  }) async {
    try {
      _setSubmitting(true);
      final payload = {
        'status': status,
        if (assigneeId != null && assigneeId.isNotEmpty)
          'assigneeId': assigneeId,
        if (assigneeName != null && assigneeName.isNotEmpty)
          'assigneeName': assigneeName,
        if (assigneePhone != null && assigneePhone.isNotEmpty)
          'assigneePhone': assigneePhone,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      // ✅ CHANGED: Using updateItem (PUT) instead of patchItem (PATCH)
      final Response res = await _http.updateItem(
        endpointUrl: 'service-requests',
        itemId: id,
        itemData: payload,
      );

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg = res.body is Map
            ? res.body['message']?.toString() ??
                res.body['error']?.toString() ??
                'Update failed'
            : res.statusText ?? 'Update failed';
        SnackBarHelper.showErrorSnackBar('Update Error: $msg');
        return (false, msg);
      }
    } catch (e) {
      final msg = 'Network error: ${e.toString()}';
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }

  // Admin: update service request status and assignee using PUT
  Future<(bool, String)> updateServiceRequest({
    required String id,
    String? status,
    String? assigneeId,
    String? assigneeName,
    String? assigneePhone,
    String? notes,
    BuildContext? context, // Add context to refresh data
  }) async {
    try {
      _setSubmitting(true);
      final payload = <String, dynamic>{};
      if (status != null) payload['status'] = status;
      if (assigneeId != null) payload['assigneeId'] = assigneeId;
      if (assigneeName != null) payload['assigneeName'] = assigneeName;
      if (assigneePhone != null) payload['assigneePhone'] = assigneePhone;
      if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

      print('Updating service request $id with payload: $payload');

      // ✅ CHANGED: Using updateItem (PUT) instead of patchItem (PATCH)
      final Response res = await _http.updateItem(
        endpointUrl: 'service-requests',
        itemId: id,
        itemData: payload,
      );

      print('Update response status: ${res.statusCode}');
      print('Update response body: ${res.body}');

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          SnackBarHelper.showSuccessSnackBar(api.message);
          
          // Automatically refresh the service requests data
          if (context != null) {
            try {
              await context.read<DataProvider>().getAllServiceRequests();
              print('✓ Service requests data refreshed automatically');
            } catch (e) {
              print('Warning: Could not refresh data provider: $e');
            }
          }
          
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg = res.body is Map
            ? res.body['message']?.toString() ??
                res.body['error']?.toString() ??
                'Update failed'
            : res.statusText ?? 'Update failed';
        SnackBarHelper.showErrorSnackBar('Update Error: $msg');
        return (false, msg);
      }
    } catch (e) {
      final msg = 'Network error: ${e.toString()}';
      print('Service request update error: $msg');
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }

  // Admin: delete a request
  Future<(bool, String)> deleteRequest(String id) async {
    try {
      _setSubmitting(true);
      final Response res =
          await _http.deleteItem(endpointUrl: 'service-requests', itemId: id);

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg = res.body is Map
            ? res.body['message']?.toString() ??
                res.body['error']?.toString() ??
                'Delete failed'
            : res.statusText ?? 'Delete failed';
        SnackBarHelper.showErrorSnackBar('Delete Error: $msg');
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar('Delete Network Error: $msg');
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }
}