import 'package:flutter/material.dart';
import '../../../../core/data/repositories/password_reset_repository.dart';

class ResetPasswordController extends ChangeNotifier {
  final PasswordResetRepository _passwordResetRepository = PasswordResetRepositoryImpl();

  // Form controller
  final TextEditingController emailController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String? _emailError;
  String? _generalError;
  bool _isFormValid = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get generalError => _generalError;
  bool get isFormValid => _isFormValid;

  ResetPasswordController() {
    emailController.addListener(_updateFormState);
  }

  void _updateFormState() {
    _validateForm();
    notifyListeners();
  }

  void _validateForm() {
    // Clear previous errors when typing
    _emailError = null;
    _generalError = null;

    final identifier = emailController.text.trim();

    // Basic form validation - check if field is not empty
    _isFormValid = identifier.isNotEmpty;
  }

  // Validate identifier (email or NIP)
  bool validateIdentifier() {
    final identifier = emailController.text.trim();
    
    if (identifier.isEmpty) {
      _emailError = 'Email or NIP is required';
      notifyListeners();
      return false;
    }

    // Use repository validation
    final validation = _passwordResetRepository.getIdentifierType(identifier);
    
    // Additional validation using repository methods
    if (identifier.contains('@')) {
      if (!_passwordResetRepository.isEmailFormat(identifier)) {
        _emailError = 'Please enter a valid email address';
        notifyListeners();
        return false;
      }
    } else {
      // Basic NIP validation (you can enhance this)
      if (identifier.length < 2) {
        _emailError = 'Please enter a valid NIP';
        notifyListeners();
        return false;
      }
    }

    _emailError = null;
    notifyListeners();
    return true;
  }

  // Clear all errors
  void clearErrors() {
    _emailError = null;
    _generalError = null;
    notifyListeners();
  }

  // Send reset password request
  Future<Map<String, dynamic>> sendResetRequest() async {
    if (_isLoading) return {'success': false, 'message': 'Request in progress'};

    _setLoading(true);
    clearErrors();

    try {
      final identifier = emailController.text.trim();

      // Validate identifier first
      if (!validateIdentifier()) {
        _setLoading(false);
        return {
          'success': false,
          'message': _emailError ?? 'Please enter a valid email or NIP',
          'type': 'validation'
        };
      }

      // Send forgot password request
      final result = await _passwordResetRepository.forgotPassword(identifier: identifier);

      if (!result['success']) {
        switch (result['type']) {
          case 'validation':
            _emailError = result['message'];
            break;
          case 'network':
            _generalError = 'Network error. Please check your connection and try again.';
            break;
          default:
            _generalError = result['message'] ?? 'Failed to send reset request. Please try again.';
        }
        _setLoading(false);
        notifyListeners();
        return result;
      }

      // Success
      _setLoading(false);
      return result;

    } catch (e) {
      _generalError = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      notifyListeners();

      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'type': 'unknown'
      };
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear form data
  void clearFormData() {
    emailController.clear();
    clearErrors();
    _isFormValid = false;
    notifyListeners();
  }

  // Get identifier type display text
  String getIdentifierTypeText() {
    final identifier = emailController.text.trim();
    if (identifier.isEmpty) return 'Email or NIP';
    
    return _passwordResetRepository.getIdentifierType(identifier);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}