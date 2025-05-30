import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fortis_apps/core/data/services/token_storage.dart';
import 'package:fortis_apps/core/data/services/user_storage.dart';
import 'api_service.dart';

class AuthService {
  final Dio dio = ApiService().dio;

  // Login
  Future<Map<String, dynamic>> login(String nip, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'nip': nip,
        'password': password,
      });

      final data = response.data;

      await TokenStorage.saveToken(data['access_token']);
      await UserStorage.saveUser(data['user']);

      return {'success': true, 'data': data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    final current = await UserStorage.getUser();
    if (current == null) return null;
    return current;
  }

// Conditionally load user data
  Future<Map<String, dynamic>?> loadUser() async {
    // Storage
    final cached = await getUser();

    // API
    final token = await TokenStorage.getToken();
    if (token == null) return null;

    try {
      final response = await dio.get('/auth/me');

      final newUser = response.data;
      await UserStorage.saveUser(newUser);

      return newUser;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        print("ehem");
        return null;
      }
      return cached;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {}

    await TokenStorage.clearToken();
    await UserStorage.clearUser();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return false;

      final response = await dio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      await TokenStorage.saveToken(data['access_token']);
      return true;
    } catch (e) {
      print('Refresh token failed: $e');
      return false;
    }
  }


  // Cek login
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
