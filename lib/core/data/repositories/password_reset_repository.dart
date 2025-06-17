import '../services/password_reset_service.dart';
import '../models/password_reset_model.dart';

abstract class PasswordResetRepository {
  Future<Map<String, dynamic>> forgotPassword({required String identifier});
  Future<Map<String, dynamic>> verifyOtpToken({
    required String resetTokenId,
    required String otpToken,
  });
  Future<Map<String, dynamic>> resetPassword({
    required String resetTokenId,
    required String password,
    required String passwordConfirmation,
  });
  Future<Map<String, dynamic>> resendOtp({required String resetTokenId});
  String getIdentifierType(String identifier);
  bool isEmailFormat(String identifier);
  Map<String, dynamic> validateOtpToken(String otpToken);
  Map<String, dynamic> validatePassword(
      String password, String confirmPassword);
  Map<String, dynamic> validateResetToken(String resetTokenId);
  bool isStrongPassword(String password);
  Map<String, String> getPasswordRequirements();
}

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetService _service = PasswordResetService();

  @override
  Future<Map<String, dynamic>> forgotPassword(
      {required String identifier}) async {
    try {
      final validation = _validateIdentifier(identifier);
      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'type': 'validation',
        };
      }

      final request = ForgotPasswordRequest(identifier: identifier);

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid identifier',
          'type': 'validation',
        };
      }

      final response = await _service.forgotPassword(request);

      return {
        'success': true,
        'message': response.message,
        'reset_token_id': response.resetTokenId,
        'identifier_type': getIdentifierType(identifier),
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on PasswordResetException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'password_reset',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtpToken({
    required String resetTokenId,
    required String otpToken,
  }) async {
    try {
      final tokenValidation = validateResetToken(resetTokenId);
      if (!tokenValidation['valid']) {
        return {
          'success': false,
          'message': tokenValidation['message'],
          'type': 'validation',
        };
      }

      final otpValidation = validateOtpToken(otpToken);
      if (!otpValidation['valid']) {
        return {
          'success': false,
          'message': otpValidation['message'],
          'type': 'validation',
        };
      }

      final request = VerifyTokenRequest(
        resetTokenId: resetTokenId,
        token: otpToken,
      );

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid token data',
          'type': 'validation',
        };
      }

      final response = await _service.verifyToken(request);

      return {
        'success': true,
        'message': response.message,
        'verified_at': DateTime.now().toIso8601String(),
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on PasswordResetException catch (e) {
      bool isExpired =
          e.message.contains('expired') || e.message.contains('kadaluarsa');
      bool isInvalid =
          e.message.contains('Invalid') || e.message.contains('salah');

      return {
        'success': false,
        'message': e.message,
        'type': 'password_reset',
        'is_expired': isExpired,
        'is_invalid': isInvalid,
        'can_resend': isExpired,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Token verification failed',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String resetTokenId,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final tokenValidation = validateResetToken(resetTokenId);
      if (!tokenValidation['valid']) {
        return {
          'success': false,
          'message': tokenValidation['message'],
          'type': 'validation',
        };
      }

      final passwordValidation =
          validatePassword(password, passwordConfirmation);
      if (!passwordValidation['valid']) {
        return {
          'success': false,
          'message': passwordValidation['message'],
          'type': 'validation',
          'password_strength': passwordValidation['strength'],
          'suggestions': passwordValidation['suggestions'],
        };
      }

      final request = ResetPasswordRequest(
        resetTokenId: resetTokenId,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid reset data',
          'type': 'validation',
        };
      }

      final response = await _service.resetPassword(request);

      return {
        'success': true,
        'message': response.message,
        'reset_at': DateTime.now().toIso8601String(),
        'password_strength': passwordValidation['strength'],
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on PasswordResetException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'password_reset',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp({required String resetTokenId}) async {
    try {
      final tokenValidation = validateResetToken(resetTokenId);
      if (!tokenValidation['valid']) {
        return {
          'success': false,
          'message': tokenValidation['message'],
          'type': 'validation',
        };
      }

      final request = ResendOtpRequest(resetTokenId: resetTokenId);

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid token',
          'type': 'validation',
        };
      }

      final response = await _service.resendOtp(request);

      return {
        'success': true,
        'message': response.message,
        'resent_at': DateTime.now().toIso8601String(),
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on PasswordResetException catch (e) {
      bool isExpired = e.message.contains('expired:true');
      bool rateLimited = e.message.contains('rateLimited:true');
      String cleanMessage = e.message.split('|').first;

      return {
        'success': false,
        'message': cleanMessage,
        'type': 'password_reset',
        'is_expired': isExpired,
        'rate_limited': rateLimited,
        'can_retry': !rateLimited, // Can retry if not rate limited
        'retry_suggestion': rateLimited
            ? 'Please wait a few minutes before trying again'
            : isExpired
                ? 'Please start the password reset process again'
                : 'Please check your reset token',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to resend OTP',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _validateIdentifier(String identifier) {
    if (identifier.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'Email or NIP is required',
      };
    }

    identifier = identifier.trim();

    if (identifier.contains('@')) {
      if (!_isValidEmail(identifier)) {
        return {
          'valid': false,
          'message': 'Please enter a valid email address',
        };
      }
    } else {
      if (!_isValidNIP(identifier)) {
        return {
          'valid': false,
          'message': 'Please enter a valid NIP',
        };
      }
    }

    return {
      'valid': true,
      'message': 'Valid identifier',
    };
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isValidNIP(String nip) {
    return RegExp(r'^\d{2,10}$').hasMatch(nip);
  }

  Map<String, dynamic> validateOtpToken(String otpToken) {
    if (otpToken.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'OTP is required',
      };
    }

    otpToken = otpToken.trim();

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

    String strengthText = password.length >= 8 ? 'Good' : 'Basic';

    return {
      'valid': true,
      'message': 'Password is valid',
      'strength': strengthText,
    };
  }

  bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(uuid);
  }

  @override
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

  String formatPasswordStrength(Map<String, dynamic> validation) {
    if (!validation['valid']) return validation['message'];

    String strength = validation['strength'];
    return 'Password strength: $strength';
  }

  bool isStrongPassword(String password) {
    return password.length >= 8;
  }

  Map<String, String> getPasswordRequirements() {
    return {
      'minimum_length': '6 characters',
      'recommended_length': '8+ characters',
      'requirements': 'Must be at least 6 characters long',
    };
  }
}
