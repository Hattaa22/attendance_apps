import 'package:flutter/material.dart';
import '../../../../core/data/repositories/password_reset_repository.dart';

class NewPasswordController extends ChangeNotifier {
  final PasswordResetRepository _passwordResetRepository =
      PasswordResetRepositoryImpl();

  // Form controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State variables
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;
  bool _isFormValid = false;
  bool _passwordsMatch = true;

  // Session data
  String? _resetTokenId;
  String _email = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get generalError => _generalError;
  bool get isFormValid => _isFormValid;
  bool get passwordsMatch => _passwordsMatch;
  String get email => _email;

  // Initialize with session data
  void initialize(String email, {String? resetTokenId}) {
    _email = email;
    _resetTokenId = resetTokenId;
  }

  NewPasswordController() {
    passwordController.addListener(_updateFormState);
    confirmPasswordController.addListener(_updateFormState);
  }

  void _updateFormState() {
    _validateForm();
    notifyListeners();
  }

  void _validateForm() {
    // Clear previous errors when typing
    _passwordError = null;
    _confirmPasswordError = null;
    _generalError = null;

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate password strength using repository (with both arguments)
    if (password.isNotEmpty) {
      final passwordValidation = _passwordResetRepository.validatePassword(
        password,
        confirmPassword, // ✅ Fixed: Now passing both arguments
      );
      if (!passwordValidation['valid']) {
        _passwordError = passwordValidation['message'];
      }
    }

    // Check if passwords match
    if (confirmPassword.isNotEmpty) {
      _passwordsMatch = password == confirmPassword;
      if (!_passwordsMatch) {
        _confirmPasswordError = 'Passwords do not match';
      }
    } else {
      _passwordsMatch = true; // Reset match status if confirm field is empty
    }

    // Check if form is valid
    _isFormValid = password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        _passwordsMatch &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  // Validate password strength
  bool validatePassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      _passwordError = 'New password is required';
      notifyListeners();
      return false;
    }

    // ✅ Fixed: Use repository validation with both arguments
    final validation =
        _passwordResetRepository.validatePassword(password, confirmPassword);

    if (!validation['valid']) {
      _passwordError = validation['message'];
      notifyListeners();
      return false;
    }

    _passwordError = null;
    notifyListeners();
    return true;
  }

  // Validate password confirmation
  bool validatePasswordConfirmation() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
      _passwordsMatch = false;
      notifyListeners();
      return false;
    }

    _confirmPasswordError = null;
    _passwordsMatch = true;
    notifyListeners();
    return true;
  }

  // Clear all errors
  void clearErrors() {
    _passwordError = null;
    _confirmPasswordError = null;
    _generalError = null;
    notifyListeners();
  }

  // Save new password
  Future<Map<String, dynamic>> saveNewPassword() async {
    if (_isLoading) return {'success': false, 'message': 'Save in progress'};

    _setLoading(true);
    clearErrors();

    try {
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      // Validate password
      if (!validatePassword()) {
        _setLoading(false);
        return {
          'success': false,
          'message': _passwordError ?? 'Please enter a valid password',
          'type': 'validation'
        };
      }

      // Validate password confirmation
      if (!validatePasswordConfirmation()) {
        _setLoading(false);
        return {
          'success': false,
          'message': _confirmPasswordError ?? 'Please confirm your password',
          'type': 'validation'
        };
      }

      // Check if we have reset token
      if (_resetTokenId == null || _resetTokenId!.isEmpty) {
        _generalError = 'Invalid session. Please start the process again.';
        _setLoading(false);
        notifyListeners();
        return {
          'success': false,
          'message': 'Invalid session. Please start the process again.',
          'type': 'session'
        };
      }

      // ✅ Fixed: Reset password using repository with correct arguments
      final result = await _passwordResetRepository.resetPassword(
        resetTokenId: _resetTokenId!,
        password: password, // ✅ Added missing argument
        passwordConfirmation: confirmPassword, // ✅ Added missing argument
      );

      if (!result['success']) {
        switch (result['type']) {
          case 'validation':
            // Handle field-specific validation errors
            if (result['field'] == 'password') {
              _passwordError = result['message'];
            } else if (result['field'] == 'confirm_password') {
              _confirmPasswordError = result['message'];
            } else {
              _generalError = result['message'];
            }
            break;
          case 'password_reset':
            _generalError = result['message'];
            // Check if token is expired
            if (result['token_expired'] == true) {
              _generalError =
                  'Reset session has expired. Please start the process again.';
            }
            break;
          case 'network':
            _generalError =
                'Network error. Please check your connection and try again.';
            break;
          default:
            _generalError = result['message'] ??
                'Failed to save password. Please try again.';
        }
        _setLoading(false);
        notifyListeners();
        return result;
      }

      // Success
      _setLoading(false);
      clearFormData(); // Clear form on successful save
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
    passwordController.clear();
    confirmPasswordController.clear();
    clearErrors();
    _isFormValid = false;
    _passwordsMatch = true;
    notifyListeners();
  }

  // ✅ Fixed: Get password strength with both arguments
  Map<String, dynamic> getPasswordStrength() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      return {'strength': 'none', 'message': '', 'color': Colors.grey};
    }

    // Use repository validation to get strength
    final validation =
        _passwordResetRepository.validatePassword(password, confirmPassword);

    if (!validation['valid']) {
      return {
        'strength': 'weak',
        'message': validation['message'],
        'color': Colors.red
      };
    }

    // Get strength from repository response
    String strength = validation['strength'] ?? 'Basic';
    Color color = strength == 'Good' ? Colors.green : Colors.orange;

    return {
      'strength': strength.toLowerCase(),
      'message': 'Password strength: $strength',
      'color': color
    };
  }

  // ✅ Added: Get password requirements from repository
  List<Map<String, dynamic>> getPasswordRequirements() {
    final password = passwordController.text;
    final requirements = _passwordResetRepository.getPasswordRequirements();

    return [
      {
        'requirement': 'At least ${requirements['minimum_length']}',
        'valid': password.length >= 6,
      },
      {
        'requirement': 'Recommended: ${requirements['recommended_length']}',
        'valid': password.length >= 8,
      },
    ];
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
