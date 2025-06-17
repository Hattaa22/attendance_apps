import 'package:flutter/material.dart';
import '../../../../core/data/repositories/auth_repository.dart';

class LoginController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isFormValid = false;

  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get generalError => _generalError;
  bool get isFormValid => _isFormValid;

  LoginController() {
    emailController.addListener(_updateFormState);
    passwordController.addListener(_updateFormState);
  }

  void _updateFormState() {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    _emailError = null;
    _passwordError = null;
    _generalError = null;

    _isFormValid = identifier.isNotEmpty && password.isNotEmpty;

    notifyListeners();
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    _generalError = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login() async {
    if (_isLoading) return {'success': false, 'message': 'Login in progress'};

    _setLoading(true);
    clearErrors();

    try {
      final identifier = emailController.text.trim();
      final password = passwordController.text.trim();

      if (identifier.isEmpty) {
        _emailError = 'Email or NIP is required';
        _setLoading(false);
        notifyListeners();
        return {
          'success': false,
          'message': 'Email or NIP is required',
          'type': 'validation'
        };
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
        _setLoading(false);
        notifyListeners();
        return {
          'success': false,
          'message': 'Password is required',
          'type': 'validation'
        };
      }

      final repositoryValidation =
          _authRepository.validateLoginInput(identifier, password);
      if (!repositoryValidation['valid']) {
        if (repositoryValidation['field'] == 'identifier') {
          _emailError = repositoryValidation['message'];
        } else if (repositoryValidation['field'] == 'password') {
          _passwordError = repositoryValidation['message'];
        } else {
          _generalError = repositoryValidation['message'];
        }

        _setLoading(false);
        notifyListeners();
        return {
          'success': false,
          'message': repositoryValidation['message'],
          'type': 'validation'
        };
      }

      final result = await _authRepository.login(identifier, password);

      if (!result['success']) {
        switch (result['type']) {
          case 'validation':
            _generalError = result['message'];
            break;
          case 'unauthorized':
            _generalError = result['message'] ?? 'Invalid credentials';
            break;
          case 'network':
            _generalError =
                'Network error. Please check your connection and try again.';
            break;
          default:
            _generalError =
                result['message'] ?? 'Login failed. Please try again.';
        }
        _setLoading(false);
        notifyListeners();
        return result;
      }

      _setLoading(false);
      clearFormData();
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearFormData() {
    emailController.clear();
    passwordController.clear();
    clearErrors();
    _isFormValid = false;
    notifyListeners();
  }

  Future<bool> checkAuthentication() async {
    return await _authRepository.isAuthenticated();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
