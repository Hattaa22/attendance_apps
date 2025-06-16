class ForgotPasswordRequest {
  final String identifier;

  ForgotPasswordRequest({
    required this.identifier,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'identifier': identifier,
    };

    // DEBUG: Print what we're sending
    print('DEBUG ForgotPasswordRequest.toJson(): $json');
    print('DEBUG identifier value: "$identifier"');
    print('DEBUG identifier length: ${identifier.length}');

    return json;
  }

  bool get isValid => identifier.trim().isNotEmpty;

  String? get validationError {
    if (identifier.trim().isEmpty) return 'Email or NIP is required';
    return null;
  }
}

class ForgotPasswordResponse {
  final String message;
  final String resetTokenId;
  final bool success;

  ForgotPasswordResponse({
    required this.message,
    required this.resetTokenId,
    required this.success,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'].toString(),
      resetTokenId: json['reset_token_id'].toString(),
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reset_token_id': resetTokenId,
      'success': success,
    };
  }
}

class VerifyTokenRequest {
  final String resetTokenId;
  final String token;

  VerifyTokenRequest({
    required this.resetTokenId,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token_id': resetTokenId,
      'token': token,
    };
  }

  bool get isValid {
    if (resetTokenId.trim().isEmpty) return false;
    if (token.trim().isEmpty) return false;
    if (token.length != 6) return false;
    return true;
  }

  String? get validationError {
    if (resetTokenId.trim().isEmpty) return 'Reset token is required';
    if (token.trim().isEmpty) return 'OTP token is required';
    if (token.length != 6) return 'OTP must be 6 digits';
    return null;
  }
}

class VerifyTokenResponse {
  final String message;
  final bool success;

  VerifyTokenResponse({
    required this.message,
    required this.success,
  });

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) {
    return VerifyTokenResponse(
      message: json['message'].toString(),
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}

class ResetPasswordRequest {
  final String resetTokenId;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequest({
    required this.resetTokenId,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token_id': resetTokenId,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  bool get isValid {
    if (resetTokenId.trim().isEmpty) return false;
    if (password.trim().isEmpty) return false;
    if (password.length < 6) return false;
    if (password != passwordConfirmation) return false;
    return true;
  }

  String? get validationError {
    if (resetTokenId.trim().isEmpty) return 'Reset token is required';
    if (password.trim().isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != passwordConfirmation) return 'Passwords do not match';
    return null;
  }
}

class ResendOtpRequest {
  final String resetTokenId;

  ResendOtpRequest({
    required this.resetTokenId,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token_id': resetTokenId,
    };
  }

  bool get isValid => resetTokenId.trim().isNotEmpty;
  String? get validationError => isValid ? null : 'Reset token is required';
}

class PasswordResetResponse {
  final String message;
  final bool success;

  PasswordResetResponse({
    required this.message,
    required this.success,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'].toString(),
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}

class ResendOtpResponse {
  final String message;
  final bool success;
  final bool isExpired;
  final bool rateLimited;

  ResendOtpResponse({
    required this.message,
    required this.success,
    this.isExpired = false,
    this.rateLimited = false,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      message: json['message'].toString(),
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'is_expired': isExpired,
      'rate_limited': rateLimited,
    };
  }
}
