import 'dart:developer';

import 'package:flutter_login/flutter_login.dart';

import '../../../models/user.dart';
import '../../../utility/snack_bar_helper.dart';
import '../login_screen.dart';
import '../../../services/http_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';

class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  UserProvider();

  Future<String?> login(LoginData data) async {
    try {
      final payload = {"identifier": data.name, "password": data.password};
      final response =
          await service.addItem(endpointUrl: 'auth/login', itemData: payload);
      if (response.isOk) {
        final body = response.body;
        final success = body['success'] == true;
        if (success) {
          final user =
              User.fromJson(body['data']['user'] as Map<String, dynamic>);
          final accessToken =
              body['data']['accessToken'] ?? body['data']['token'];
          final refreshToken = body['data']['refreshToken'];

          await saveLoginInfo(user);
          if (accessToken != null) {
            await box.write(AUTH_TOKEN_BOX, accessToken);
          }
          if (refreshToken != null) {
            await box.write('refresh_token', refreshToken);
          }
          SnackBarHelper.showSuccessSnackBar(
              body['message'] ?? 'Login success');
          log('Login success');
          return null;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to Login: ${body['message'] ?? 'Unknown error'}');
          return 'Failed to Login';
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
        return 'Error ${response.body?['message'] ?? response.statusText}';
      }
    } catch (e) {
      log('Login error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return 'An error occurred: $e';
    }
  }

  Future<String?> register(SignupData data) async {
    try {
      // Collect username OR email based on input, plus name
      final raw = data.name?.trim() ?? '';
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      final name = (data.additionalSignupData?["name"] ?? '').toString().trim();

      final payload = <String, dynamic>{
        if (emailRegex.hasMatch(raw))
          "email": raw.toLowerCase()
        else
          "username": raw.toLowerCase(),
        "password": data.password,
        if (name.isNotEmpty) "name": name,
      };

      final response = await service.addItem(
          endpointUrl: 'auth/register', itemData: payload);

      if (response.isOk) {
        final body = response.body;
        final success = body['success'] == true;
        if (success) {
          // User is now registered and logged in automatically
          final user =
              User.fromJson(body['data']['user'] as Map<String, dynamic>);
          final accessToken =
              body['data']['accessToken'] ?? body['data']['token'];
          final refreshToken = body['data']['refreshToken'];

          await saveLoginInfo(user);
          if (accessToken != null) {
            await box.write(AUTH_TOKEN_BOX, accessToken);
          }
          if (refreshToken != null) {
            await box.write('refresh_token', refreshToken);
          }

          SnackBarHelper.showSuccessSnackBar(
              body['message'] ?? 'Registration successful!');
          log('Registration Success - Auto logged in');
          return null;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to Register: ${body['message'] ?? 'Unknown error'}');
          return 'Failed to Register';
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
        return 'Error ${response.body?['message'] ?? response.statusText}';
      }
    } catch (e) {
      log('Register error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return 'An error occurred: $e';
    }
  }

  Future<String?> requestOtp(String phone) async {
    try {
      final norm = phone.replaceAll(RegExp(r"[\s-]"), '');
      final res = await service
          .addItem(endpointUrl: 'auth/request-otp', itemData: {'phone': norm});
      if (res.isOk && (res.body['success'] == true)) {
        await box.write(PENDING_OTP_PHONE, norm);
        SnackBarHelper.showSuccessSnackBar(res.body['message'] ?? 'OTP sent');
        return null;
      }
      return res.body?['message'] ?? 'Failed to request OTP';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> verifyOtp(
      {required String phone, required String code}) async {
    try {
      final norm = phone.replaceAll(RegExp(r"[\s-]"), '');
      final res = await service.addItem(
          endpointUrl: 'auth/verify-otp',
          itemData: {'phone': norm, 'code': code});
      if (res.isOk && (res.body['success'] == true)) {
        final user =
            User.fromJson(res.body['data']['user'] as Map<String, dynamic>);
        final accessToken =
            res.body['data']['accessToken'] ?? res.body['data']['token'];
        final refreshToken = res.body['data']['refreshToken'];

        await saveLoginInfo(user);
        if (accessToken != null) {
          await box.write(AUTH_TOKEN_BOX, accessToken);
        }
        if (refreshToken != null) {
          await box.write('refresh_token', refreshToken);
        }
        await box.remove(PENDING_OTP_PHONE);
        SnackBarHelper.showSuccessSnackBar('Welcome back');
        return null;
      }
      return res.body?['message'] ?? 'OTP verification failed';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> recoverPassword(String email) async {
    try {
      final res = await service.addItem(
          endpointUrl: 'auth/forgot-password',
          itemData: {'email': email.toLowerCase()});
      if (res.isOk && (res.body['success'] == true)) {
        SnackBarHelper.showSuccessSnackBar(
            res.body['message'] ?? 'Password reset link sent to your email');
        return null;
      }
      return res.body?['message'] ?? 'Failed to send password reset link';
    } catch (e) {
      return 'Error: $e';
    }
  }

  //? to save login info after login
  Future<void> saveLoginInfo(User? loginUser) async {
    await box.write(USER_INFO_BOX, loginUser?.toJson());
  }

  //? to get the login user detail from any whre the app
  User? getLoginUsr() {
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    try {
      User? userLogged = User.fromJson(userJson);
      // Return null if the user doesn't have a valid sId
      if (userLogged.sId == null || userLogged.sId!.isEmpty) {
        return null;
      }
      return userLogged;
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  //? to logout the user
  logOutUser() async {
    try {
      // Call logout API to invalidate tokens on server
      await service.addItem(endpointUrl: 'auth/logout', itemData: {});
    } catch (e) {
      // Continue with local logout even if API call fails
      print('Logout API call failed: $e');
    }

    box.remove(USER_INFO_BOX);
    box.remove(AUTH_TOKEN_BOX);
    box.remove('refresh_token');
    box.remove(PENDING_OTP_PHONE);
    Get.offAll(const LoginScreen());
  }

  // Token refresh method
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = box.read('refresh_token') as String?;
      if (refreshToken == null) return false;

      final response = await service.addItem(
        endpointUrl: 'auth/refresh-token',
        itemData: {'refreshToken': refreshToken},
      );

      if (response.isOk && response.body['success'] == true) {
        final newAccessToken = response.body['data']['accessToken'];
        final newRefreshToken = response.body['data']['refreshToken'];

        await box.write(AUTH_TOKEN_BOX, newAccessToken);
        await box.write('refresh_token', newRefreshToken);
        return true;
      }

      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }
}
