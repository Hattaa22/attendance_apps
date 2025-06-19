import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/data/repositories/password_reset_repository.dart';

class OtpController extends ChangeNotifier {
  final PasswordResetRepository _passwordResetRepository = PasswordResetRepositoryImpl();

  // State variables
  String _currentOtp = '';
  bool _isOtpComplete = false;
  bool _isLoading = false;
  String? _generalError;
  
  // Timer for resend functionality
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  // Reset token data
  String? _resetTokenId;
  String _email = '';

  // Getters
  String get currentOtp => _currentOtp;
  bool get isOtpComplete => _isOtpComplete;
  bool get isLoading => _isLoading;
  String? get generalError => _generalError;
  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _canResend;
  String get email => _email;

  // Initialize with email and reset token
  void initialize(String email, {String? resetTokenId}) {
    _email = email;
    _resetTokenId = resetTokenId;
    _startTimer();
  }

  // Update OTP value
  void updateOtp(String otp) {
    _currentOtp = otp;
    _isOtpComplete = otp.length == 6;
    
    // Clear errors when user types
    if (_generalError != null) {
      _generalError = null;
    }
    
    notifyListeners();
  }

  // Validate OTP format
  bool validateOtp() {
    if (_currentOtp.isEmpty) {
      _generalError = 'Please enter the OTP code';
      notifyListeners();
      return false;
    }

    // Use repository validation
    final validation = _passwordResetRepository.validateOtpToken(_currentOtp);
    
    if (!validation['valid']) {
      _generalError = validation['message'];
      notifyListeners();
      return false;
    }

    _generalError = null;
    notifyListeners();
    return true;
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp() async {
    if (_isLoading) return {'success': false, 'message': 'Verification in progress'};

    _setLoading(true);
    _clearErrors();

    try {
      // Validate OTP format first
      if (!validateOtp()) {
        _setLoading(false);
        return {
          'success': false,
          'message': _generalError ?? 'Please enter a valid 6-digit OTP',
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

      // Verify OTP with repository
      final result = await _passwordResetRepository.verifyOtpToken(
        resetTokenId: _resetTokenId!,
        otpToken: _currentOtp,
      );

      if (!result['success']) {
        switch (result['type']) {
          case 'validation':
            _generalError = result['message'];
            break;
          case 'network':
            _generalError = 'Network error. Please check your connection and try again.';
            break;
          case 'password_reset':
            _generalError = result['message'];
            // Check if OTP is expired and can resend
            if (result['can_resend'] == true) {
              _canResend = true;
              _timer?.cancel();
            }
            break;
          default:
            _generalError = result['message'] ?? 'OTP verification failed. Please try again.';
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

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp() async {
    if (_isLoading || !_canResend) {
      return {'success': false, 'message': 'Cannot resend OTP at this time'};
    }

    _setLoading(true);
    _clearErrors();

    try {
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

      // Resend OTP using repository
      final result = await _passwordResetRepository.resendOtp(resetTokenId: _resetTokenId!);

      if (!result['success']) {
        switch (result['type']) {
          case 'network':
            _generalError = 'Network error. Please check your connection and try again.';
            break;
          case 'password_reset':
            _generalError = result['message'];
            if (result['rate_limited'] == true) {
              _generalError = result['retry_suggestion'] ?? 'Please wait before trying again.';
            }
            break;
          default:
            _generalError = result['message'] ?? 'Failed to resend OTP. Please try again.';
        }
        _setLoading(false);
        notifyListeners();
        return result;
      }

      // Success - restart timer
      _startTimer();
      _setLoading(false);
      return result;

    } catch (e) {
      _generalError = 'Failed to resend OTP. Please try again.';
      _setLoading(false);
      notifyListeners();

      return {
        'success': false,
        'message': 'Failed to resend OTP: $e',
        'type': 'unknown'
      };
    }
  }

  // Start countdown timer
  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _canResend = true;
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearErrors() {
    _generalError = null;
    notifyListeners();
  }

  // Clear form data
  void clearFormData() {
    _currentOtp = '';
    _isOtpComplete = false;
    _clearErrors();
    notifyListeners();
  }

  // Get formatted timer text
  String get formattedTimer {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}