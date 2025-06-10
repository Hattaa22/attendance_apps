import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(UpdateProfileRequest request);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;
  final AuthService _authService;

  ProfileRepositoryImpl() : _dio = ApiService().dio, _authService = AuthService();

  @override
  Future<ProfileModel> getProfile() async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.get('/profile');
      final profile = ProfileModel.fromJson(response.data);

      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to get profile data');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to get profile data: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.put('/profile', data: request.toJson());

      final profileData = response.data['user'];
      final profile = ProfileModel.fromJson(profileData);

      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      if (e.response?.statusCode == 422 && e.response?.data != null) {
        final errors = e.response?.data as Map<String, dynamic>;

        if (errors.containsKey('name')) {
          final nameErrors = errors['name'] as List;
          throw Exception(nameErrors.first);
        }

        if (errors.containsKey('password')) {
          final passwordErrors = errors['password'] as List;
          throw Exception(passwordErrors.first);
        }

        final firstError = errors.values.first;
        final errorMessage = firstError is List ? firstError.first : firstError;
        throw Exception(errorMessage);
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to update profile');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to update profile: $e');
    }
  }
}
