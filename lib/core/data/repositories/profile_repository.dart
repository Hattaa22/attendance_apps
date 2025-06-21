import '../services/auth_service.dart' show UnauthorizedException, NetworkException;
import '../services/profile_service.dart' show ProfileException, ProfileService, ValidationException;
import '../models/profile_model.dart';
import '../repositories/auth_repository.dart';

abstract class ProfileRepository {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? password,
    String? passwordConfirmation,
  });
  Future<Map<String, dynamic>> updateName(String name);
  Future<Map<String, dynamic>> updatePassword({
    required String password,
    required String passwordConfirmation,
  });
  Future<Map<String, dynamic>> updateNameAndPassword({
    required String name,
    required String password,
    required String passwordConfirmation,
  });
  Future<Map<String, dynamic>> validateProfileUpdate({
    required String name,
    String? password,
    String? passwordConfirmation,
  });
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service = ProfileService();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view profile',
          'requiresLogin': true,
        };
      }

      final profile = await _service.getProfile();

      final processedProfile = _processProfileData(profile);

      return {
        'success': true,
        'profile': processedProfile,
        'message': 'Profile loaded successfully',
        'last_updated': DateTime.now().toIso8601String(),
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on ProfileException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load profile',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to update profile',
          'requiresLogin': true,
        };
      }

      final validation = _validateProfileData(
        name: name,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'type': 'validation',
          'field': validation['field'],
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
          'type': 'validation',
        };
      }

      final updatedProfile = await _service.updateProfile(request);

      final processedProfile = _processProfileData(updatedProfile);

      return {
        'success': true,
        'profile': processedProfile,
        'message': 'Profile updated successfully',
        'updated_fields': _getUpdatedFields(name, password),
        'updated_at': DateTime.now().toIso8601String(),
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on ProfileException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateName(String name) async {
    try {
      if (!_isValidName(name)) {
        return {
          'success': false,
          'message': 'Name must be between 2 and 50 characters',
          'type': 'validation',
          'field': 'name',
        };
      }

      return await updateProfile(name: name);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update name',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
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

      final passwordValidation =
          _validatePassword(password, passwordConfirmation);
      if (!passwordValidation['valid']) {
        return {
          'success': false,
          'message': passwordValidation['message'],
          'type': 'validation',
          'field': 'password',
        };
      }

      return await updateProfile(
        name: currentName,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update password',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
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

  @override
  Future<Map<String, dynamic>> validateProfileUpdate({
    required String name,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to validate profile update',
          'requiresLogin': true,
        };
      }

      final validation = _validateProfileData(
        name: name,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'type': 'validation',
          'field': validation['field'],
        };
      }

      return {
        'success': true,
        'message': 'Profile data is valid',
        'validation': {
          'name_valid': _isValidName(name),
          'password_required': password != null && password.isNotEmpty,
          'password_valid': password == null ||
              _validatePassword(password, passwordConfirmation ?? '')['valid'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate profile update',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _validateProfileData({
    required String name,
    String? password,
    String? passwordConfirmation,
  }) {
    if (!_isValidName(name)) {
      return {
        'valid': false,
        'message':
            'Name must be between 2 and 50 characters and contain only letters and spaces',
        'field': 'name',
      };
    }

    if (password != null && password.isNotEmpty) {
      final passwordValidation =
          _validatePassword(password, passwordConfirmation ?? '');
      if (!passwordValidation['valid']) {
        return {
          'valid': false,
          'message': passwordValidation['message'],
          'field': 'password',
        };
      }
    }

    return {
      'valid': true,
      'message': 'Profile data is valid',
    };
  }

  Map<String, dynamic> _validatePassword(
      String password, String passwordConfirmation) {
    if (password.length < 4) {
      return {
        'valid': false,
        'message': 'Password must be at least 8 characters long',
      };
    }

    if (password.length > 255) {
      return {
        'valid': false,
        'message': 'Password must be less than 255 characters',
      };
    }

    if (password != passwordConfirmation) {
      return {
        'valid': false,
        'message': 'Password confirmation does not match',
      };
    }

    if (!_hasNumber(password)) {
      return {
        'valid': false,
        'message': 'Password must contain at least one number',
      };
    }

    return {
      'valid': true,
      'message': 'Password is valid',
    };
  }

  Map<String, dynamic> _processProfileData(ProfileModel profile) {
    final profileJson = profile.toJson();

    profileJson['display_name'] = _formatDisplayName(profile.name);
    profileJson['initials'] = _getInitials(profile.name);
    profileJson['last_seen'] = DateTime.now().toIso8601String();

    return profileJson;
  }

  List<String> _getUpdatedFields(String name, String? password) {
    List<String> updatedFields = ['name'];
    if (password != null && password.isNotEmpty) {
      updatedFields.add('password');
    }
    return updatedFields;
  }

  String _formatDisplayName(String name) {
    if (name.isEmpty) return 'User';

    // Capitalize each word
    return name
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }

  bool _isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.length < 2 || name.length > 50) return false;

    final nameRegex = RegExp(r"^[a-zA-Z\s\'\-]+$");
    return nameRegex.hasMatch(name);
  }

  bool _hasUppercase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool _hasLowercase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  bool _hasSpecialCharacter(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
