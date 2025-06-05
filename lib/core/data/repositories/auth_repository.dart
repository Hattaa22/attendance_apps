import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/user_storage.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String nip, String password);
  Future<UserModel> getCurrentUser();
  Future<UserModel> refreshUser();
  Future<String> refreshToken();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl() : _dio = ApiService().dio;

  @override
  Future<LoginResponse> login(String nip, String password) async {
    print('DEBUG: Starting login process...');
    print('DEBUG: NIP: $nip');

    try {
      print('DEBUG: Making login API call to /auth/login');
      final response = await _dio.post('/auth/login', data: {
        'nip': nip,
        'password': password,
      }).timeout(Duration(seconds: 15));

      print('DEBUG: Login API response status: ${response.statusCode}');
      print('DEBUG: Login API response data: ${response.data}');

      print('DEBUG: Parsing LoginResponse...');
      final loginResponse = LoginResponse.fromJson(response.data);
      print('DEBUG: LoginResponse parsed successfully');

      print('DEBUG: Saving token...');
      await TokenStorage.saveToken(loginResponse.accessToken);
      print('DEBUG: Token saved successfully');

      print('DEBUG: Saving user data...');
      await UserStorage.saveUser(loginResponse.user.toJson());
      print('DEBUG: User data saved successfully');

      return loginResponse;
    } on DioException catch (e) {
      print('DEBUG: DioException caught');
      print('DEBUG: Status Code: ${e.response?.statusCode}');
      print('DEBUG: Response Data: ${e.response?.data}');
      print('DEBUG: Error Type: ${e.type}');
      print('DEBUG: Error Message: ${e.message}');

      String errorMessage = 'Login failed';

      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Invalid credentials';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('DEBUG: Other exception: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (!await _isAuthenticated()) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _dio.get('/auth/me');
      final user = UserModel.fromJson(response.data);

      await UserStorage.saveUser(user.toJson());
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearAuthData();
        throw Exception('Session expired');
      }

      throw Exception(e.response?.data['message'] ?? 'Failed to get user data');
    }
  }

  @override
  Future<UserModel> refreshUser() async {
    try {
      if (await _isAuthenticated()) {
        return await getCurrentUser();
      }
    } catch (e) {
      print('Failed to refresh from API: $e');
    }

    // Fall back to cached data
    final cachedUserData = await UserStorage.getUser();
    if (cachedUserData != null) {
      return UserModel.fromJson(cachedUserData);
    }

    throw Exception('No user data available');
  }

  @override
  Future<String> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      final newToken = response.data['access_token'];

      await TokenStorage.saveToken(newToken);
      return newToken;
    } on DioException catch (e) {
      await _clearAuthData();
      throw Exception('Token refresh failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      print('Logout API error: ${e.message}');
    }

    await _clearAuthData();
  }

  Future<void> _clearAuthData() async {
    await TokenStorage.clearToken();
    await UserStorage.clearUser();
  }

  Future<bool> _isAuthenticated() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
