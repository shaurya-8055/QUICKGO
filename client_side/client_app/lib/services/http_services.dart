import 'package:get/get_connect.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utility/constants.dart';

class HttpService {
  final String baseUrl = getMainUrl();
  final _box = GetStorage();

  Map<String, String> _authHeaders() {
    final token = _box.read(AUTH_TOKEN_BOX) as String?;
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  // Enhanced method with automatic token refresh
  Future<Response> _makeAuthenticatedRequest(
    Future<Response> Function() request,
  ) async {
    var response = await request();

    // If token expired, try to refresh
    if (response.statusCode == 401 && response.body?['expired'] == true) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request with new token
        response = await request();
      } else {
        // Refresh failed, redirect to login
        _handleAuthFailure();
      }
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _box.read('refresh_token') as String?;
      if (refreshToken == null) return false;

      final response = await GetConnect().post(
        '$baseUrl/auth/refresh-token',
        {'refreshToken': refreshToken},
      );

      if (response.isOk && response.body['success'] == true) {
        final newAccessToken = response.body['data']['accessToken'];
        final newRefreshToken = response.body['data']['refreshToken'];

        await _box.write(AUTH_TOKEN_BOX, newAccessToken);
        await _box.write('refresh_token', newRefreshToken);
        return true;
      }

      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  void _handleAuthFailure() {
    _box.remove(AUTH_TOKEN_BOX);
    _box.remove('refresh_token');
    _box.remove(USER_INFO_BOX);
    // Navigate to login screen
    Get.offAllNamed('/login'); // Adjust route name as needed
  }

  Future<Response> getItems({required String endpointUrl}) async {
    return await _makeAuthenticatedRequest(() async {
      return await GetConnect()
          .get('$baseUrl/$endpointUrl', headers: _authHeaders());
    });
  }

  Future<Response> addItem(
      {required String endpointUrl, required dynamic itemData}) async {
    return await _makeAuthenticatedRequest(() async {
      final response = await GetConnect()
          .post('$baseUrl/$endpointUrl', itemData, headers: _authHeaders());
      print(response.body);
      return response;
    });
  }

  Future<Response> updateItem(
      {required String endpointUrl,
      required String itemId,
      required dynamic itemData}) async {
    return await _makeAuthenticatedRequest(() async {
      return await GetConnect().put('$baseUrl/$endpointUrl/$itemId', itemData,
          headers: _authHeaders());
    });
  }

  Future<Response> deleteItem(
      {required String endpointUrl, required String itemId}) async {
    return await _makeAuthenticatedRequest(() async {
      return await GetConnect()
          .delete('$baseUrl/$endpointUrl/$itemId', headers: _authHeaders());
    });
  }
}
