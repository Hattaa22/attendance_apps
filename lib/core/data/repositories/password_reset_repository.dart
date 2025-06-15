import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/password_reset_model.dart';

abstract class PasswordResetRepository {
  Future<ForgotPasswordResponse> forgotPassword(ForgotPasswordRequest request);
  Future<VerifyTokenResponse> verifyToken(VerifyTokenRequest request);
  Future<PasswordResetResponse> resetPassword(ResetPasswordRequest request);
  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request);
}

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final Dio _dio;

  PasswordResetRepositoryImpl() : _dio = ApiService().dio;

  @override
  Future<ForgotPasswordResponse> forgotPassword(
      ForgotPasswordRequest request) async {
    try {
      print('DEBUG: About to send forgot password request');
      print('DEBUG: Request data: ${request.toJson()}');

      final response =
          await _dio.post('/auth/forgot-password', data: request.toJson());

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');

      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('DEBUG: DioException caught');
      print('DEBUG: Status code: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');
      print('DEBUG: Request data: ${e.requestOptions.data}');

      String errorMessage = 'Failed to send reset request';

      if (e.response?.statusCode == 404) {
        errorMessage = 'User not found';
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('identifier')) {
          final identifierErrors = errors['identifier'];
          errorMessage = identifierErrors is List
              ? identifierErrors.first
              : identifierErrors;
        }
      } else if (e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('DEBUG: Other exception: $e');
      throw Exception('Failed to send reset request: $e');
    }
  }

  @override
  Future<VerifyTokenResponse> verifyToken(VerifyTokenRequest request) async {
    try {
      final response = await _dio.post('/auth/verify-token', data: request.toJson());

      return VerifyTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Token verification failed';

      if (e.response?.statusCode == 404) {
        errorMessage = 'Reset token not found';
      } else if (e.response?.statusCode == 400) {
        if (e.response?.data['message']?.contains('kadaluarsa')) {
          errorMessage = 'Token has expired';
        } else if (e.response?.data['message']?.contains('salah')) {
          errorMessage = 'Invalid OTP token';
        } else {
          errorMessage = e.response?.data['message'] ?? 'Invalid token';
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
      } else if (e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Token verification failed: $e');
    }
  }

  @override
  Future<PasswordResetResponse> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final response =
          await _dio.post('/auth/reset-password', data: request.toJson());

      return PasswordResetResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Password reset failed';

      if (e.response?.statusCode == 404) {
        if (e.response?.data['message'].contains('Token tidak ditemukan')) {
          errorMessage = 'Reset token not found or expired';
        } else if (e.response?.data['message']
            .contains('User tidak ditemukan')) {
          errorMessage = 'User not found';
        } else {
          errorMessage = 'Reset token or user not found';
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
      } else if (e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _dio.post('/auth/resend-otp', data: request.toJson());

      return ResendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Failed to resend OTP';
      bool isExpired = false;
      bool rateLimited = false;

      if (e.response?.statusCode == 404) {
        errorMessage = 'Reset token not found';
      } else if (e.response?.statusCode == 410) {
        errorMessage = e.response?.data['message'] ?? 'Reset token has expired';
        isExpired = true;
      } else if (e.response?.statusCode == 429) {
        errorMessage = e.response?.data['message'] ??
            'Please wait before requesting OTP again';
        rateLimited = true;
      } else if (e.response?.statusCode == 422 &&
          e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        if (errors.containsKey('reset_token_id')) {
          final tokenErrors = errors['reset_token_id'];
          errorMessage = tokenErrors is List ? tokenErrors.first : tokenErrors;
        }
      } else if (e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw Exception(
          '$errorMessage|expired:$isExpired|rateLimited:$rateLimited');
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }
}
