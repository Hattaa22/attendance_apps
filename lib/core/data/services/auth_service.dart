import '../repositories/auth_repository.dart';
import '../storages/token_storage.dart';
import '../storages/user_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  late AuthRepository _repository;

  AuthService._internal() {
    _repository = AuthRepositoryImpl();
  }

  AuthService.withRepository(this._repository);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final loginResponse = await _repository.login(identifier, password);

      return {
        'success': true,
        'message': 'Login successful',
        'data': loginResponse.toJson(),
        'user': loginResponse.user.toJson(),
        'token': loginResponse.accessToken,
        'expires_in': loginResponse.expiresIn,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();

      return {
        'success': true,
        'user': user.toJson(),
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final user = await _repository.refreshUser();

      return {
        'success': true,
        'user': user.toJson(),
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (errorMessage.contains('Session expired') ||
          errorMessage.contains('token is invalid')) {
        return {
          'success': false,
          'message': errorMessage,
          'requiresLogin': true,
          'sessionExpired': true,
        };
      }

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> loadUser() async {
    try {
      final user = await _repository.getCurrentUser();

      return {
        'success': true,
        'user': user.toJson(),
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await _repository.logout();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  Future<bool> refreshToken() async {
    try {
      await _repository.refreshToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await TokenStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isValidSession() async {
    if (!await isAuthenticated()) {
      return false;
    }

    return await _repository.validateToken();
  }

  Future<Map<String, dynamic>> checkSession() async {
    try {
      if (!await isAuthenticated()) {
        return {
          'valid': false,
          'message': 'No authentication token found',
          'requiresLogin': true,
        };
      }

      final isValid = await _repository.validateToken();

      if (!isValid) {
        return {
          'valid': false,
          'message': 'Session has expired',
          'requiresLogin': true,
          'sessionExpired': true,
        };
      }

      return {
        'valid': true,
        'message': 'Session is valid',
      };
    } catch (e) {
      return {
        'valid': false,
        'message': 'Failed to validate session: ${e.toString()}',
      };
    }
  }

  Future<void> clearAuthData() async {
    try {
      await TokenStorage.clearToken();
      await UserStorage.clearUser();
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  Future<void> requireAuthentication([String? customMessage]) async {
    if (!await isAuthenticated()) {
      throw Exception(
          customMessage ?? 'User not authenticated - please login first');
    }
  }

  Future<void> handle401() async {
    await clearAuthData();
    throw Exception('Session expired - please login again');
  }

  bool isAuthError(String errorMessage) {
    return errorMessage.contains('not authenticated') ||
        errorMessage.contains('Session expired') ||
        errorMessage.contains('Unauthorized') ||
        errorMessage.contains('token is invalid');
  }
}
