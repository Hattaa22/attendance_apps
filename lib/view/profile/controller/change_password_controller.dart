import 'package:flutter/material.dart';
import '../../../core/data/repositories/profile_repository.dart';

class ChangePasswordController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();

  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isFormFilled = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;
  bool get obscureOld => _obscureOld;
  bool get obscureNew => _obscureNew;
  bool get obscureConfirm => _obscureConfirm;
  bool get isFormFilled => _isFormFilled;

  void initialize() {
    print('ChangePasswordController: Initializing...');
    _setupListeners();
  }

  void _setupListeners() {
    oldPasswordController.addListener(_updateFormState);
    newPasswordController.addListener(_updateFormState);
    confirmPasswordController.addListener(_updateFormState);
  }

  void _updateFormState() {
    final isFormValid = oldPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;

    if (_isFormFilled != isFormValid) {
      _isFormFilled = isFormValid;
      notifyListeners();
    }
  }

  void toggleOldPasswordVisibility() {
    _obscureOld = !_obscureOld;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  Map<String, dynamic> _validatePasswords() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      return {
        'valid': false,
        'message': 'New password is required',
        'field': 'new_password'
      };
    }

    if (confirmPassword.isEmpty) {
      return {
        'valid': false,
        'message': 'Password confirmation is required',
        'field': 'confirm_password'
      };
    }

    if (newPassword != confirmPassword) {
      return {
        'valid': false,
        'message': 'Passwords do not match',
        'field': 'confirm_password'
      };
    }

    if (newPassword.length < 4) {
      return {
        'valid': false,
        'message': 'Password must be at least 8 characters long',
        'field': 'new_password'
      };
    }

    return {
      'valid': true,
      'message': 'Passwords are valid'
    };
  }

  Future<Map<String, dynamic>> changePassword(BuildContext context) async {
    if (_isLoading) {
      return {'success': false, 'message': 'Password change in progress'};
    }

    if (!_isFormFilled) {
      const message = 'Please fill in all fields';
      _showErrorMessage(context, message);
      return {'success': false, 'message': message};
    }

    final validation = _validatePasswords();
    if (!validation['valid']) {
      _showErrorMessage(context, validation['message']);
      return {
        'success': false,
        'message': validation['message'],
        'field': validation['field']
      };
    }

    _setLoading(true);
    _clearError();
    _isSuccess = false;

    try {
      print('ChangePasswordController: Changing password...');

      final result = await _profileRepository.updatePassword(
        password: newPasswordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
      );

      print('ChangePasswordController: Repository result: $result');

      if (!result['success']) {
        _error = result['message'] ?? 'Failed to change password';
        
        // Handle specific error types
        if (result['requiresLogin'] == true) {
          _error = 'Please login to change your password';
        } else if (result['type'] == 'validation') {
          _error = result['message'] ?? 'Password validation failed';
        } else if (result['type'] == 'network') {
          _error = 'Network error. Please check your connection and try again.';
        }

        _showErrorMessage(context, _error!);
        _setLoading(false);
        return result;
      }

      _isSuccess = true;
      _clearForm();
      
      print('ChangePasswordController: Password changed successfully');
      _showSuccessMessage(context, 'Password changed successfully');
      
      _setLoading(false);
      return result;

    } catch (e) {
      print('ChangePasswordController: Change password error - $e');
      _error = 'An unexpected error occurred while changing password.';
      _showErrorMessage(context, _error!);
      _setLoading(false);

      return {
        'success': false,
        'message': 'Failed to change password: $e',
        'type': 'unknown'
      };
    }
  }

  Map<String, bool> getPasswordValidation(String password) {
    return {
      'length': password.length >= 4,
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'lowercase': password.contains(RegExp(r'[a-z]')),
      'number': password.contains(RegExp(r'[0-9]')),
    };
  }

  String getPasswordStrength(String password) {
    if (password.isEmpty) return 'None';
    
    final validation = getPasswordValidation(password);
    final validCount = validation.values.where((v) => v).length;
    
    if (validCount < 2) return 'Weak';
    return 'Strong';
  }

  Color getPasswordStrengthColor(String password) {
    final strength = getPasswordStrength(password);
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _updateFormState();
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    oldPasswordController.removeListener(_updateFormState);
    newPasswordController.removeListener(_updateFormState);
    confirmPasswordController.removeListener(_updateFormState);
    
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    
    super.dispose();
  }
}