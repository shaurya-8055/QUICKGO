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

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await GetConnect()
          .get('$baseUrl/$endpointUrl', headers: _authHeaders());
    } catch (e) {
      // return a Map body, not an encoded String, so callers can safely access keys
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> addItem(
      {required String endpointUrl, required dynamic itemData}) async {
    try {
      final response = await GetConnect()
          .post('$baseUrl/$endpointUrl', itemData, headers: _authHeaders());
      print(response.body);
      return response;
    } catch (e) {
      print('Error: $e');
      // return a Map body, not an encoded String, so callers can safely access keys
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> updateItem(
      {required String endpointUrl,
      required String itemId,
      required dynamic itemData}) async {
    try {
      return await GetConnect().put('$baseUrl/$endpointUrl/$itemId', itemData,
          headers: _authHeaders());
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> deleteItem(
      {required String endpointUrl, required String itemId}) async {
    try {
      return await GetConnect()
          .delete('$baseUrl/$endpointUrl/$itemId', headers: _authHeaders());
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }
}
