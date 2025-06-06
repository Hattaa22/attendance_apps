import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';
import 'auth_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  late ProfileRepository _repository;
  final AuthService _authService;

  ProfileService._internal() : _authService = AuthService() {
    _repository = ProfileRepositoryImpl();
  }


  ProfileService.withRepository(this._repository) : _authService = AuthService();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view profile',
          'requiresLogin': true,
        };
      }

      final profile = await _repository.getProfile();

      return {
        'success': true,
        'profile': profile.toJson(),
        'message': 'Profile loaded successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to update profile',
          'requiresLogin': true,
        };
      }

      final request = UpdateProfileRequest(
        name: name,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid profile data',
        };
      }

      final updatedProfile = await _repository.updateProfile(request);

      return {
        'success': true,
        'profile': updatedProfile.toJson(),
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> updateName(String name) async {
    return await updateProfile(name: name);
  }

  Future<Map<String, dynamic>> updatePassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final profileResult = await getProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      final currentName = profileResult['profile']['name'];

      return await updateProfile(
        name: currentName,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update password: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateNameAndPassword({
    required String name,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await updateProfile(
      name: name,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
