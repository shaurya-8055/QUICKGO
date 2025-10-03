import 'dart:convert';
import 'package:get/get_connect.dart';
import 'package:get/get.dart';
import '../utility/constants.dart';

class HttpService {
  // Use dynamic MAIN_URL that respects dart-define
  final String baseUrl = MAIN_URL;

  // Headers for proper content-type and acceptance
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  //? to send get request
  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await GetConnect().get(
        '$baseUrl/$endpointUrl',
        headers: _headers,
      );
    } catch (e) {
      return Response(
        body: json.encode({'error': e.toString()}),
        statusCode: 500,
      );
    }
  }

  //? to send post request
  Future<Response> addItem(
      {required String endpointUrl, required dynamic itemData}) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/$endpointUrl',
        itemData,
        headers: _headers,
      );
      print('POST Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error: $e');
      return Response(
        body: json.encode({'message': e.toString()}),
        statusCode: 500,
      );
    }
  }

  //? to send put (full update) request
  Future<Response> updateItem(
      {required String endpointUrl,
      required String itemId,
      required dynamic itemData}) async {
    try {
      final response = await GetConnect().put(
        '$baseUrl/$endpointUrl/$itemId',
        itemData,
        headers: _headers,
      );
      print('PUT Request to: $baseUrl/$endpointUrl/$itemId');
      print('PUT Payload: $itemData');
      print('PUT Response: ${response.body}');
      return response;
    } catch (e) {
      print('PUT Error: $e');
      return Response(
        body: json.encode({'message': e.toString()}),
        statusCode: 500,
      );
    }
  }

  //? to send patch (partial update) request - kept for fallback
  Future<Response> patchItem(
      {required String endpointUrl,
      required String itemId,
      required dynamic itemData}) async {
    try {
      final response = await GetConnect().patch(
        '$baseUrl/$endpointUrl/$itemId',
        itemData,
        headers: _headers,
      );
      print('PATCH Request to: $baseUrl/$endpointUrl/$itemId');
      print('PATCH Payload: $itemData');
      print('PATCH Response: ${response.body}');
      return response;
    } catch (e) {
      print('PATCH Error: $e');
      return Response(
        body: json.encode({'message': e.toString()}),
        statusCode: 500,
      );
    }
  }

  //? to send delete request
  Future<Response> deleteItem(
      {required String endpointUrl, required String itemId}) async {
    try {
      final response = await GetConnect().delete(
        '$baseUrl/$endpointUrl/$itemId',
        headers: _headers,
      );
      print('DELETE Request to: $baseUrl/$endpointUrl/$itemId');
      return response;
    } catch (e) {
      print('DELETE Error: $e');
      return Response(
        body: json.encode({'message': e.toString()}),
        statusCode: 500,
      );
    }
  }
}