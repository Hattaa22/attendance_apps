import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../storages/token_storage.dart';
import '../storages/user_storage.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String identifier, String password);
  Future<UserModel> getCurrentUser();
  Future<UserModel> refreshUser();
  Future<String> refreshToken();
  Future<void> logout();
  Future<bool> validateToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl() : _dio = ApiService().dio;

  @override
  Future<LoginResponse> login(String identifier, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      }).timeout(Duration(seconds: 15));

      final loginResponse = LoginResponse.fromJson(response.data);

      await TokenStorage.saveToken(loginResponse.accessToken);
      await UserStorage.saveUser(loginResponse.user.toJson());

      return loginResponse;
    } on DioException catch (e) {
      String errorMessage = 'Login failed';

      if (e.response?.statusCode == 422 && e.response?.data != null) {
        final errors = e.response?.data;
        if (errors is Map && errors.containsKey('identifier')) {
          final identifierErrors = errors['identifier'];
          errorMessage = identifierErrors is List
              ? identifierErrors.first
              : identifierErrors;
        } else if (errors is Map && errors.containsKey('password')) {
          final passwordErrors = errors['password'];
          errorMessage =
              passwordErrors is List ? passwordErrors.first : passwordErrors;
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email/NIP or password';
      } else if (e.response?.data is Map) {
        errorMessage = e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Invalid credentials';
      }

      throw Exception(errorMessage);
    } catch (e) {
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
    print('DEBUG: refreshUser() called');

    if (!await _isAuthenticated()) {
      print('DEBUG: No token found, checking cache');
      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        print('DEBUG: Returning cached user data (no token)');
        return UserModel.fromJson(cachedUserData);
      }
      throw Exception('No user data available');
    }

    try {
      print('DEBUG: Token found, validating with server...');

      return await getCurrentUser().timeout(
        Duration(seconds: 8),
        onTimeout: () {
          print('DEBUG: API timeout - this is a network issue, not auth issue');
          throw Exception('API timeout');
        },
      );
    } on DioException catch (e) {
      print('DEBUG: DioException in refreshUser: ${e.response?.statusCode}');

      if (e.response?.statusCode == 401) {
        print('DEBUG: 401 detected - clearing auth data');
        await _clearAuthData();
        throw Exception('Session expired - token is invalid');
      }

      print('DEBUG: Non-auth error (${e.response?.statusCode}), trying cache');
      rethrow;
    } catch (e) {
      print('DEBUG: Non-Dio error in refreshUser: $e');

      if (e.toString().contains('API timeout') ||
          e.toString().contains('Connection')) {
        print('DEBUG: Network/timeout error, falling back to cache');

        final cachedUserData = await UserStorage.getUser();
        if (cachedUserData != null) {
          print('DEBUG: Returning cached user data (network error)');
          return UserModel.fromJson(cachedUserData);
        }

        throw Exception('Network error and no cached data available');
      }

      rethrow;
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ));

      final currentToken = await TokenStorage.getToken();
      if (currentToken == null || currentToken.isEmpty) {
        throw Exception('No token available to refresh');
      }

      final response = await refreshDio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentToken',
          },
        ),
      );

      final newToken = response.data['access_token'];
      if (newToken == null) {
        throw Exception('No access_token in response');
      }

      await TokenStorage.saveToken(newToken);
      return newToken;
    } on DioException catch (e) {
      await _clearAuthData();
      throw Exception('Token refresh failed: ${e.response?.statusCode}');
    }
  }

  @override
  Future<bool> validateToken() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      await _dio.get('/auth/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearAuthData();
        return false;
      }
      print('Token validation error: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error during token validation: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      print('Logout API error: ${e.message}');
      if (e.response?.statusCode == 401) {
        return;
      }
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
