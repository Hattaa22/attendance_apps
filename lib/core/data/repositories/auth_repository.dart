import 'dart:async';
import '../models/auth_model.dart';
import '../services/auth_service.dart';
import '../storages/token_storage.dart';
import '../storages/user_storage.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String identifier, String password);
  Future<Map<String, dynamic>> getCurrentUser();
  Future<Map<String, dynamic>> getUser();
  Future<Map<String, dynamic>> loadUser();
  Future<Map<String, dynamic>> logout();
  Future<bool> refreshToken();
  Future<bool> isAuthenticated();
  Future<bool> isValidSession();
  Future<Map<String, dynamic>> checkSession();
  Future<void> clearAuthData();
  Future<void> requireAuthentication([String? customMessage]);
  Future<void> handle401();
  bool isAuthError(String errorMessage);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service = AuthService();

  @override
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      if (identifier.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Email or NIP is required',
          'type': 'validation',
        };
      }

      if (password.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Password is required',
          'type': 'validation',
        };
      }

      identifier = identifier.trim();
      if (identifier.length < 2) {
        return {
          'success': false,
          'message': 'Email or NIP is too short',
          'type': 'validation',
        };
      }

      if (password.length < 3) {
        return {
          'success': false,
          'message': 'Password is too short',
          'type': 'validation',
        };
      }

      final loginResponse = await _service.login(identifier, password);

      await _storeAuthData(loginResponse);

      return {
        'success': true,
        'message': 'Login successful',
        'data': loginResponse.toJson(),
        'user': loginResponse.user.toJson(),
        'token': loginResponse.accessToken,
        'expires_in': loginResponse.expiresIn,
        'login_time': DateTime.now().toIso8601String(),
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on UnauthorizedException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'unauthorized',
        'can_retry': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'auth_error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
        'type': 'unknown',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      if (!await isAuthenticated()) {
        return {
          'success': false,
          'message': 'User not authenticated',
          'requiresLogin': true,
        };
      }

      final user =
          await _service.getCurrentUser().timeout(Duration(seconds: 5));

      await UserStorage.saveUser(user.toJson());

      return {
        'success': true,
        'user': user.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      };
    } on TimeoutException catch (e) {
      print('Get current user timeout - falling back to cache');
      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        return {
          'success': true,
          'user': cachedUserData,
          'fromCache': true,
          'timeout': true,
        };
      }
      return {
        'success': false,
        'message': 'Request timeout and no cached data available',
        'requiresLogin': false,
        'timeout': true,
      };
    } on UnauthorizedException catch (e) {
      await _handleSessionExpired();
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
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': _isAuthError(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get user: $e',
        'requiresLogin': false,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getUser() async {
    try {
      final result = await getCurrentUser().timeout(Duration(seconds: 5));

      if (result['success']) {
        return result;
      }

      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        return {
          'success': true,
          'user': cachedUserData,
          'fromCache': true,
        };
      }

      return result;
    } on TimeoutException catch (e) {
      print('Get user timeout - using cache only');
      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        return {
          'success': true,
          'user': cachedUserData,
          'fromCache': true,
          'timeout': true,
        };
      }

      return {
        'success': false,
        'message': 'Request timeout and no user data available',
        'requiresLogin': true,
        'timeout': true,
      };
    } catch (e) {
      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        return {
          'success': true,
          'user': cachedUserData,
          'fromCache': true,
        };
      }

      return {
        'success': false,
        'message': 'No user data available: $e',
        'requiresLogin': true,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> loadUser() async {
    try {
      final cachedUserData = await UserStorage.getUser();
      if (cachedUserData != null) {
        _refreshUserInBackground();
        return {
          'success': true,
          'user': cachedUserData,
          'fromCache': true,
        };
      }

      return await getCurrentUser().timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Failed to load user: timeout',
        'requiresLogin': true,
        'timeout': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load user: $e',
        'requiresLogin': true,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    try {
      await _service.logout().timeout(Duration(seconds: 5));

      await clearAuthData();

      return {
        'success': true,
        'message': 'Logged out successfully',
        'logout_time': DateTime.now().toIso8601String(),
      };
    } on TimeoutException catch (e) {
      print('Logout timeout - clearing local data anyway');
      await clearAuthData();

      return {
        'success': true,
        'message': 'Logged out successfully',
        'warning': 'Server logout timed out',
      };
    } catch (e) {
      print('Logout error: $e - clearing local data anyway');
      await clearAuthData();

      return {
        'success': true,
        'message': 'Logged out successfully',
        'warning': 'Server logout may have failed',
      };
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      if (!await isAuthenticated()) {
        return false;
      }

      final newToken =
          await _service.refreshToken().timeout(Duration(seconds: 10));

      await TokenStorage.saveToken(newToken);
      return true;
    } on TimeoutException catch (e) {
      print('Token refresh timeout: $e');
      return false;
    } on UnauthorizedException catch (e) {
      await _handleSessionExpired();
      return false;
    } on NetworkException catch (e) {
      print('Network error during token refresh: $e');
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await TokenStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isValidSession() async {
    try {
      if (!await isAuthenticated()) {
        return false;
      }

      return await _service.validateToken().timeout(Duration(seconds: 5));
    } on UnauthorizedException catch (e) {
      await _handleSessionExpired();
      return false;
    } on TimeoutException catch (e) {
      print('Session validation timeout - assuming valid for offline use');
      return false;
    } on NetworkException catch (e) {
      print('Network error during session validation: $e');
      return false;
    } catch (e) {
      print('Session validation error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> checkSession() async {
    try {
      if (!await isAuthenticated()) {
        return {
          'valid': false,
          'message': 'No authentication token found',
          'requiresLogin': true,
        };
      }

      final isValid =
          await _service.validateToken().timeout(Duration(seconds: 5));

      if (!isValid) {
        await _handleSessionExpired();
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
        'checked_at': DateTime.now().toIso8601String(),
      };
    } on TimeoutException catch (e) {
      print('Session check timeout - assuming valid for offline use');
      return {
        'valid': false,
        'message': 'Session validation timeout',
        'networkError': true,
        'timeout': true,
      };
    } on UnauthorizedException catch (e) {
      await _handleSessionExpired();
      return {
        'valid': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'valid': false,
        'message': e.message,
        'networkError': true,
        'retryable': true,
      };
    } catch (e) {
      return {
        'valid': false,
        'message': 'Failed to validate session: $e',
        'networkError': true,
      };
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await TokenStorage.clearToken();
      await UserStorage.clearUser();
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  @override
  Future<void> requireAuthentication([String? customMessage]) async {
    if (!await isAuthenticated()) {
      throw Exception(
          customMessage ?? 'User not authenticated - please login first');
    }
  }

  @override
  Future<void> handle401() async {
    await _handleSessionExpired();
    throw Exception('Session expired - please login again');
  }

  @override
  bool isAuthError(String errorMessage) {
    return _isAuthError(errorMessage);
  }

  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    await TokenStorage.saveToken(loginResponse.accessToken);
    await UserStorage.saveUser(loginResponse.user.toJson());
  }

  Future<void> _handleSessionExpired() async {
    await clearAuthData();
  }

  bool _isAuthError(String errorMessage) {
    return errorMessage.contains('not authenticated') ||
        errorMessage.contains('Session expired') ||
        errorMessage.contains('Unauthorized') ||
        errorMessage.contains('token is invalid');
  }

  void _refreshUserInBackground() {
    getCurrentUser().timeout(Duration(seconds: 10)).catchError((e) {
      print('Background user refresh failed or timeout: $e');
    });
  }

  bool isValidEmailFormat(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool isValidNIPFormat(String nip) {
    return RegExp(r'^\d{2,10}$').hasMatch(nip);
  }

  String getIdentifierType(String identifier) {
    return identifier.contains('@') ? 'email' : 'NIP';
  }

  Map<String, dynamic> validateLoginInput(String identifier, String password) {
    if (identifier.trim().isEmpty) {
      return {'valid': false, 'message': 'Email or NIP is required'};
    }

    if (password.trim().isEmpty) {
      return {'valid': false, 'message': 'Password is required'};
    }

    identifier = identifier.trim();
    if (identifier.contains('@') && !isValidEmailFormat(identifier)) {
      return {'valid': false, 'message': 'Please enter a valid email address'};
    }

    if (!identifier.contains('@') && !isValidNIPFormat(identifier)) {
      return {'valid': false, 'message': 'Please enter a valid NIP'};
    }

    if (password.length < 3) {
      return {'valid': false, 'message': 'Password is too short'};
    }

    return {'valid': true, 'message': 'Valid input'};
  }
}
