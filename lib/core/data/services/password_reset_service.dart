import '../repositories/password_reset_repository.dart';
import '../models/password_reset_model.dart';

class PasswordResetService {
  static final PasswordResetService _instance =
      PasswordResetService._internal();
  factory PasswordResetService() => _instance;

  late PasswordResetRepository _repository;

  PasswordResetService._internal() {
    _repository = PasswordResetRepositoryImpl();
  }

  PasswordResetService.withRepository(this._repository);

  Future<Map<String, dynamic>> forgotPassword({
    required String identifier,
  }) async {
    try {
      final request = ForgotPasswordRequest(identifier: identifier);

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid identifier',
        };
      }

      final response = await _repository.forgotPassword(request);

      return {
        'success': true,
        'message': response.message,
        'reset_token_id': response.resetTokenId,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtpToken({
    required String resetTokenId,
    required String otpToken,
  }) async {
    try {
      final request = VerifyTokenRequest(
        resetTokenId: resetTokenId,
        token: otpToken,
      );

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid token data',
        };
      }

      final response = await _repository.verifyToken(request);

      return {
        'success': true,
        'message': response.message,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Detect specific error types
      bool isExpired = errorMessage.contains('expired') ||
          errorMessage.contains('kadaluarsa');
      bool isInvalid =
          errorMessage.contains('Invalid') || errorMessage.contains('salah');

      return {
        'success': false,
        'message': errorMessage,
        'is_expired': isExpired,
        'is_invalid': isInvalid,
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetTokenId,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final request = ResetPasswordRequest(
        resetTokenId: resetTokenId,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid reset data',
        };
      }

      final response = await _repository.resetPassword(request);

      return {
        'success': true,
        'message': response.message,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp({
    required String resetTokenId,
  }) async {
    try {
      final request = ResendOtpRequest(resetTokenId: resetTokenId);

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid token',
        };
      }

      final response = await _repository.resendOtp(request);

      return {
        'success': true,
        'message': response.message,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      bool isExpired = errorMessage.contains('expired:true');
      bool rateLimited = errorMessage.contains('rateLimited:true');
      String cleanMessage = errorMessage.split('|').first;

      return {
        'success': false,
        'message': cleanMessage,
        'is_expired': isExpired,
        'rate_limited': rateLimited,
      };
    }
  }

  // Helper method to validate OTP format
  Map<String, dynamic> validateOtpToken(String otpToken) {
    if (otpToken.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'OTP is required',
      };
    }

    if (otpToken.length != 6) {
      return {
        'valid': false,
        'message': 'OTP must be 6 digits',
      };
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otpToken)) {
      return {
        'valid': false,
        'message': 'OTP must contain only numbers',
      };
    }

    return {
      'valid': true,
      'message': 'OTP format is valid',
    };
  }

  bool isEmailFormat(String identifier) {
    return identifier.contains('@') && identifier.contains('.');
  }

  String getIdentifierType(String identifier) {
    return isEmailFormat(identifier) ? 'email' : 'NIP';
  }

  Map<String, dynamic> validatePassword(
      String password, String confirmPassword) {
    if (password.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'Password is required',
      };
    }

    if (password.length < 6) {
      return {
        'valid': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    if (password != confirmPassword) {
      return {
        'valid': false,
        'message': 'Passwords do not match',
      };
    }

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    List<String> suggestions = [];
    if (!hasUpperCase) suggestions.add('uppercase letter');
    if (!hasLowerCase) suggestions.add('lowercase letter');
    if (!hasDigits) suggestions.add('number');
    if (!hasSpecialCharacters) suggestions.add('special character');

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;
    if (password.length >= 8) strength++;

    String strengthText = 'Weak';
    if (strength >= 4)
      strengthText = 'Strong';
    else if (strength >= 2) strengthText = 'Medium';

    return {
      'valid': true,
      'message': 'Password is valid',
      'strength': strengthText,
      'strength_score': strength,
      'suggestions': suggestions,
    };
  }

  bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(uuid);
  }

  Map<String, dynamic> validateResetToken(String resetTokenId) {
    if (resetTokenId.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'Reset token is required',
      };
    }

    if (!isValidUuid(resetTokenId)) {
      return {
        'valid': false,
        'message': 'Invalid reset token format',
      };
    }

    return {
      'valid': true,
      'message': 'Reset token is valid',
    };
  }
}
