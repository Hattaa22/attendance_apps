import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fortis_apps/core/data/storages/token_storage.dart';
import '../services/api_service.dart';
import '../models/auth_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = ApiService().dio;

  Future<LoginResponse> login(String identifier, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      }).timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw AuthException('Empty response from server');
      }

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Login failed';

      if (e.response?.statusCode == 422 && e.response?.data != null) {
        // Validation errors
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
        } else if (errors is Map && errors.containsKey('message')) {
          errorMessage = errors['message'];
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid email/NIP or password');
      } else if (e.response?.statusCode == 429) {
        throw AuthException('Too many login attempts. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Unable to connect to server - please check your internet connection');
      } else if (e.response?.data is Map) {
        errorMessage = e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Invalid credentials';
        throw AuthException(errorMessage);
      }

      throw NetworkException('Login failed: Network error');
    } catch (e) {
      if (e is AuthException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw AuthException('Login failed: $e');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response =
          await _dio.get('/auth/me').timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw AuthException('Empty response from server');
      }

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw AuthException(
          e.response?.data['message'] ?? 'Failed to get user data');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw AuthException('Failed to get user data: $e');
    }
  }

  Future<String> refreshToken() async {
    try {
      final response =
          await _dio.post('/auth/refresh').timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw AuthException('Empty response from server');
      }

      final newToken = response.data['access_token'];
      if (newToken == null) {
        throw AuthException('No access_token in response');
      }

      return newToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token refresh failed: Invalid token');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout during token refresh');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server for token refresh');
      }

      throw AuthException('Token refresh failed: ${e.response?.statusCode}');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) rethrow;
      throw AuthException('Token refresh failed: $e');
    }
  }

  Future<bool> validateToken() async {
    try {
      await _dio.get('/auth/me').timeout(Duration(seconds: 5));
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false; // Invalid token, but not an error
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('Network error during token validation');
      }

      // Other errors
      throw AuthException('Token validation error: ${e.message}');
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw AuthException('Unexpected error during token validation: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout').timeout(Duration(seconds: 10));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('Network error during logout: ${e.message}');
        return;
      }

      print('Logout API error: ${e.message}');
    } catch (e) {
      print('Unexpected logout error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await TokenStorage.getToken();
    } catch (e) {
      return null;
    }
  }
}
