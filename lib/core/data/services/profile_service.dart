import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/profile_model.dart';

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);

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

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final Dio _dio = ApiService().dio;

  Future<ProfileModel> getProfile() async {
    try {
      final response =
          await _dio.get('/profile').timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw ProfileException('Empty response from server');
      }

      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw ProfileException('Profile not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw ProfileException(
          e.response?.data['message'] ?? 'Failed to get profile data');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw ProfileException('Failed to get profile data: $e');
    }
  }

  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio
          .put('/profile', data: request.toJson())
          .timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw ProfileException('Empty response from server');
      }

      if (response.data['user'] == null) {
        throw ProfileException('Invalid response format: missing user data');
      }

      return ProfileModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Handle validation errors
        if (e.response?.data != null && e.response?.data is Map) {
          final errors = e.response?.data as Map<String, dynamic>;

          // Check for specific field errors
          if (errors.containsKey('name')) {
            final nameErrors = errors['name'];
            final errorMessage = nameErrors is List && nameErrors.isNotEmpty
                ? nameErrors.first.toString()
                : 'Invalid name';
            throw ValidationException(errorMessage);
          }

          if (errors.containsKey('password')) {
            final passwordErrors = errors['password'];
            final errorMessage =
                passwordErrors is List && passwordErrors.isNotEmpty
                    ? passwordErrors.first.toString()
                    : 'Invalid password';
            throw ValidationException(errorMessage);
          }

          if (errors.containsKey('password_confirmation')) {
            final confirmationErrors = errors['password_confirmation'];
            final errorMessage =
                confirmationErrors is List && confirmationErrors.isNotEmpty
                    ? confirmationErrors.first.toString()
                    : 'Password confirmation does not match';
            throw ValidationException(errorMessage);
          }

          // Generic validation error
          final firstError = errors.values.firstOrNull;
          if (firstError != null) {
            final errorMessage = firstError is List && firstError.isNotEmpty
                ? firstError.first.toString()
                : firstError.toString();
            throw ValidationException(errorMessage);
          }
        }

        throw ValidationException(
            e.response?.data['message'] ?? 'Validation failed');
      } else if (e.response?.statusCode == 400) {
        throw ProfileException(e.response?.data['message'] ?? 'Bad request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw ProfileException(
          e.response?.data['message'] ?? 'Failed to update profile');
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ProfileException('Failed to update profile: $e');
    }
  }

  Future<ProfileModel> updateProfilePicture(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio
          .post('/profile/picture', data: formData)
          .timeout(Duration(seconds: 30)); // Longer timeout for file upload

      if (response.data == null) {
        throw ProfileException('Empty response from server');
      }

      if (response.data['user'] == null) {
        throw ProfileException('Invalid response format: missing user data');
      }

      return ProfileModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Handle file validation errors
        if (e.response?.data != null && e.response?.data is Map) {
          final errors = e.response?.data as Map<String, dynamic>;

          if (errors.containsKey('profile_picture')) {
            final pictureErrors = errors['profile_picture'];
            final errorMessage =
                pictureErrors is List && pictureErrors.isNotEmpty
                    ? pictureErrors.first.toString()
                    : 'Invalid profile picture';
            throw ValidationException(errorMessage);
          }
        }

        throw ValidationException(
            e.response?.data['message'] ?? 'Invalid file format or size');
      } else if (e.response?.statusCode == 413) {
        throw ValidationException('File size too large');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Upload timeout - please check your connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw ProfileException(
          e.response?.data['message'] ?? 'Failed to update profile picture');
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ProfileException('Failed to update profile picture: $e');
    }
  }
}
