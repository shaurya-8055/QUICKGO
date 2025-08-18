import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../models/api_response.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

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
    required String preferredDate, // ISO string
    required String preferredTime, // e.g., "2:30 PM"
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
        final msg = res.body?['message']?.toString() ??
            res.statusText ??
            'Request failed';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }

  // Admin: update status/assignee/notes
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
      final Response res = await _http.patchItem(
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
        final msg = res.body?['message']?.toString() ??
            res.statusText ??
            'Update failed';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }

  // Admin: delete a request (optional cleanup)
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
        final msg = res.body?['message']?.toString() ??
            res.statusText ??
            'Delete failed';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    } finally {
      _setSubmitting(false);
    }
  }
}
