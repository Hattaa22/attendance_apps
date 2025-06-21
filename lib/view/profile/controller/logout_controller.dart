import 'package:flutter/material.dart';
import '../../../core/data/repositories/auth_repository.dart';

class LogoutController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Logout method
  Future<Map<String, dynamic>> logout() async {
    if (_isLoading) return {'success': false, 'message': 'Logout in progress'};

    _setLoading(true);
    _clearError();

    try {
      print('LogoutController: Starting logout process');

      final isAuth = await _authRepository.isAuthenticated();
      print('LogoutController: User authenticated: $isAuth');

      if (!isAuth) {
        print('LogoutController: User already logged out');
        _setLoading(false);
        return {
          'success': true,
          'message': 'Already logged out',
          'already_logged_out':
              true,
        };
      }

      // Call repository logout method
      final result = await _authRepository.logout();
      print('LogoutController: Repository result: $result');

      if (!result['success']) {
        _error = result['message'] ?? 'Logout failed. Please try again.';
        _setLoading(false);
        notifyListeners();
        return result;
      }

      // Success
      print('LogoutController: Logout successful');
      _setLoading(false);
      return result;
    } catch (e) {
      print('LogoutController: Logout error - $e');
      _error = 'An unexpected error occurred during logout.';
      _setLoading(false);
      notifyListeners();

      return {
        'success': false,
        'message': 'Logout failed: $e',
        'type': 'unknown'
      };
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      return await _authRepository.isAuthenticated();
    } catch (e) {
      print('LogoutController: Auth check error - $e');
      return false;
    }
  }

  // Clear auth data (force logout)
  Future<void> clearAuthData() async {
    try {
      await _authRepository.clearAuthData();
      print('LogoutController: Auth data cleared');
    } catch (e) {
      print('LogoutController: Clear auth data error - $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get current user info (for display purposes)
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await _authRepository.getUser();
    } catch (e) {
      print('LogoutController: Get user error - $e');
      return {
        'success': false,
        'message': 'Failed to get user info',
      };
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
