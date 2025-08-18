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
          final token = body['data']['token'] as String?;
          await saveLoginInfo(user);
          if (token != null) {
            await box.write(AUTH_TOKEN_BOX, token);
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
      // Collect username OR email based on input, plus phone (normalized)
      final raw = data.name?.trim() ?? '';
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      final phoneRaw = (data.additionalSignupData?["phone"] ?? '').toString();
      final phone = phoneRaw.replaceAll(RegExp(r"[\s-]"), '');
      final payload = <String, dynamic>{
        if (emailRegex.hasMatch(raw))
          "email": raw.toLowerCase()
        else
          "username": raw.toLowerCase(),
        "phone": phone,
        "password": data.password,
      };
      final response = await service.addItem(
          endpointUrl: 'auth/register', itemData: payload);
      if (response.isOk) {
        final body = response.body;
        final success = body['success'] == true;
        if (success) {
          // Persist pending phone so Login screen can route to OTP screen
          final phone = payload['phone'];
          if (phone != null) {
            await box.write(PENDING_OTP_PHONE, phone);
          }
          SnackBarHelper.showSuccessSnackBar(
              body['message'] ?? 'Registered. Verify OTP.');
          log('Register Success');
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
        final token = res.body['data']['token'] as String?;
        await saveLoginInfo(user);
        if (token != null) {
          await box.write(AUTH_TOKEN_BOX, token);
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

  //? to save login info after login
  Future<void> saveLoginInfo(User? loginUser) async {
    await box.write(USER_INFO_BOX, loginUser?.toJson());
  }

  //? to get the login user detail from any whre the app
  User? getLoginUsr() {
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
    User? userLogged = User.fromJson(userJson ?? {});
    return userLogged;
  }

  //? to logout the user
  logOutUser() {
    box.remove(USER_INFO_BOX);
    box.remove(AUTH_TOKEN_BOX);
    box.remove(PENDING_OTP_PHONE);
    Get.offAll(const LoginScreen());
  }
}
