import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/password_reset_model.dart';

class PasswordResetException implements Exception {
  final String message;
  PasswordResetException(this.message);

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

class PasswordResetService {
  static final PasswordResetService _instance =
      PasswordResetService._internal();
  factory PasswordResetService() => _instance;
  PasswordResetService._internal();

  final Dio _dio = ApiService().dio;

  Future<ForgotPasswordResponse> forgotPassword(
      ForgotPasswordRequest request) async {
    try {
      print('DEBUG: About to send forgot password request');
      print('DEBUG: Request data: ${request.toJson()}');

      final response = await _dio
          .post('/auth/forgot-password', data: request.toJson())
          .timeout(Duration(seconds: 15));

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');

      if (response.data == null) {
        throw PasswordResetException('Empty response from server');
      }

      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('DEBUG: DioException caught');
      print('DEBUG: Status code: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');
      print('DEBUG: Request data: ${e.requestOptions.data}');

      String errorMessage = 'Failed to send reset request';

      if (e.response?.statusCode == 404) {
        throw PasswordResetException('User not found');
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('identifier')) {
          final identifierErrors = errors['identifier'];
          errorMessage = identifierErrors is List
              ? identifierErrors.first
              : identifierErrors;
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 429) {
        throw PasswordResetException(
            'Too many requests. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Unable to connect to server - please check your internet connection');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw PasswordResetException(errorMessage);
      }

      throw NetworkException('Network error occurred');
    } catch (e) {
      if (e is PasswordResetException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      print('DEBUG: Other exception: $e');
      throw PasswordResetException('Failed to send reset request: $e');
    }
  }

  Future<VerifyTokenResponse> verifyToken(VerifyTokenRequest request) async {
    try {
      final response = await _dio
          .post('/auth/verify-token', data: request.toJson())
          .timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw PasswordResetException('Empty response from server');
      }

      return VerifyTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Token verification failed';

      if (e.response?.statusCode == 404) {
        throw PasswordResetException('Reset token not found');
      } else if (e.response?.statusCode == 400) {
        if (e.response?.data['message']?.contains('kadaluarsa')) {
          throw PasswordResetException('Token has expired');
        } else if (e.response?.data['message']?.contains('salah')) {
          throw PasswordResetException('Invalid OTP token');
        } else {
          errorMessage = e.response?.data['message'] ?? 'Invalid token';
          throw PasswordResetException(errorMessage);
        }
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('token')) {
          final tokenErrors = errors['token'];
          errorMessage = tokenErrors is List ? tokenErrors.first : tokenErrors;
        } else if (errors.containsKey('reset_token_id')) {
          final resetTokenErrors = errors['reset_token_id'];
          errorMessage = resetTokenErrors is List
              ? resetTokenErrors.first
              : resetTokenErrors;
        }
        throw ValidationException(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw PasswordResetException(errorMessage);
      }

      throw PasswordResetException('Token verification failed');
    } catch (e) {
      if (e is PasswordResetException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw PasswordResetException('Token verification failed: $e');
    }
  }

  Future<PasswordResetResponse> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final response = await _dio
          .post('/auth/reset-password', data: request.toJson())
          .timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw PasswordResetException('Empty response from server');
      }

      return PasswordResetResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Password reset failed';

      if (e.response?.statusCode == 404) {
        if (e.response?.data['message']?.contains('Token tidak ditemukan')) {
          throw PasswordResetException('Reset token not found or expired');
        } else if (e.response?.data['message']
            ?.contains('User tidak ditemukan')) {
          throw PasswordResetException('User not found');
        } else {
          throw PasswordResetException('Reset token or user not found');
        }
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('password')) {
          final passwordErrors = errors['password'];
          errorMessage =
              passwordErrors is List ? passwordErrors.first : passwordErrors;
        } else if (errors.containsKey('reset_token_id')) {
          final tokenErrors = errors['reset_token_id'];
          errorMessage = tokenErrors is List ? tokenErrors.first : tokenErrors;
        } else {
          errorMessage = 'Validation failed';
        }
        throw ValidationException(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw PasswordResetException(errorMessage);
      }

      throw PasswordResetException('Password reset failed');
    } catch (e) {
      if (e is PasswordResetException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw PasswordResetException('Password reset failed: $e');
    }
  }

  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _dio
          .post('/auth/resend-otp', data: request.toJson())
          .timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw PasswordResetException('Empty response from server');
      }

      return ResendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Failed to resend OTP';

      if (e.response?.statusCode == 404) {
        throw PasswordResetException('Reset token not found');
      } else if (e.response?.statusCode == 410) {
        errorMessage = e.response?.data['message'] ?? 'Reset token has expired';
        throw PasswordResetException('$errorMessage|expired:true');
      } else if (e.response?.statusCode == 429) {
        errorMessage = e.response?.data['message'] ??
            'Please wait before requesting OTP again';
        throw PasswordResetException('$errorMessage|rateLimited:true');
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('reset_token_id')) {
          final tokenErrors = errors['reset_token_id'];
          errorMessage = tokenErrors is List ? tokenErrors.first : tokenErrors;
        }
        throw ValidationException(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw PasswordResetException(errorMessage);
      }

      throw PasswordResetException('Failed to resend OTP');
    } catch (e) {
      if (e is PasswordResetException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw PasswordResetException('Failed to resend OTP: $e');
    }
  }
}
