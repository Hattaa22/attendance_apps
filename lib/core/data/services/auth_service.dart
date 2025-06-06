import '../repositories/auth_repository.dart';
import 'token_storage.dart';
import 'user_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  late AuthRepository _repository;

  AuthService._internal() {
    _repository = AuthRepositoryImpl();
  }

  AuthService.withRepository(this._repository);

  Future<Map<String, dynamic>> login(String nip, String password) async {
    try {
      final loginResponse = await _repository.login(nip, password);

      return {
        'success': true,
        'message': 'Login successful',
        'data': loginResponse.toJson(),
        'user': loginResponse.user.toJson(),
        'token': loginResponse.accessToken,
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
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
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
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
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
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
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
        errorMessage.contains('Unauthorized');
  }

  // Legacy method
  // Future<bool> isLoggedIn() async {
  //   return await isAuthenticated();
  // }
}
