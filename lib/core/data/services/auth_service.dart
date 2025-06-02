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
      String errorMessage = 'An error occurred';

      if (e.response != null) {
        if (e.response?.data is Map &&
            e.response?.data['error'] != null) {
          errorMessage = e.response?.data['error'];
        } else if (e.response?.data is Map &&
            e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        } else {
          errorMessage = e.message ?? 'Request error';
        }
      } else {
        errorMessage = e.message ?? 'Could not connect to the server';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    return await UserStorage.getUser();
  }

  Future<Map<String, dynamic>?> loadUser() async {
    final cached = await getUser();
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
        print("Token expired or is not valid, logging out.");
        return null;
      }

      print("Error load user: ${e.message}");
      return cached;
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      print('Logout error: ${e.message}');
    }

    await TokenStorage.clearToken();
    await UserStorage.clearUser();
  }

  Future<bool> refreshToken() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return false;

      final response = await dio.post('/auth/refresh');
      final data = response.data;
      await TokenStorage.saveToken(data['access_token']);
      return true;

    } on DioException catch (e) {
      print('Refresh token failed: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
