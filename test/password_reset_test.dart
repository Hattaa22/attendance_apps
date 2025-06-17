import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/repositories/password_reset_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(PasswordResetTest());
}

class PasswordResetTest extends StatelessWidget {
  PasswordResetTest({super.key});

  // FIX 1: Use PasswordResetRepositoryImpl instead of abstract class
  final PasswordResetRepository passwordResetRepository = PasswordResetRepositoryImpl();
  String? capturedResetTokenId;

  // Make testIdentifiers a class property so all methods can access it
  static const testIdentifiers = [
    'daffamaulanasatria@gmail.com', // Email
    '69', // NIP
  ];

  Future<void> testCompletePasswordResetFlow() async {
    print('=== Testing Complete Password Reset Flow ===\n');

    // Phase 1: Input validation tests
    await _testInputValidation();
    await _delay();

    // Phase 2: Test forgot password with identifier (email or NIP)
    await _testForgotPassword();
    await _delay();

    if (capturedResetTokenId != null) {
      // Phase 3: Test OTP verification
      await _testOtpVerification();
      await _delay();

      // Phase 4: Test resend OTP
      await _testResendOtp();
      await _delay();

      // Phase 5: Test password reset
      await _testPasswordReset();
      await _delay();
    }

    // Phase 6: Test validation helpers
    await _testValidationHelpers();
    await _delay();

    // Phase 7: Test business logic helpers
    await _testBusinessLogicHelpers();

    print('\n🎉 === All password reset tests completed ===');
  }

  Future<void> _testInputValidation() async {
    print('📝 PHASE 1: INPUT VALIDATION TESTS');
    print('═' * 40);

    // Test empty identifier
    print('1.1 Testing empty identifier:');
    var result = await passwordResetRepository.forgotPassword(identifier: '');
    _printResult(result, 'Empty identifier', shouldSucceed: false);

    await _shortDelay();

    // Test invalid email format
    print('1.2 Testing invalid email format:');
    result = await passwordResetRepository.forgotPassword(
        identifier: 'invalid-email');
    _printResult(result, 'Invalid email', shouldSucceed: false);

    await _shortDelay();

    // Test invalid NIP format
    print('1.3 Testing invalid NIP format:');
    result = await passwordResetRepository.forgotPassword(identifier: 'abc123');
    _printResult(result, 'Invalid NIP', shouldSucceed: false);

    await _shortDelay();

    // Test whitespace-only identifier
    print('1.4 Testing whitespace-only identifier:');
    result = await passwordResetRepository.forgotPassword(identifier: '   ');
    _printResult(result, 'Whitespace identifier', shouldSucceed: false);
  }

  Future<void> _testForgotPassword() async {
    print('\n📧 PHASE 2: FORGOT PASSWORD TESTS');
    print('═' * 40);

    for (String identifier in testIdentifiers) {
      print(
          '\n2.${testIdentifiers.indexOf(identifier) + 1} Testing with identifier: "$identifier"');
      print(
          '   Type: ${passwordResetRepository.getIdentifierType(identifier)}');
      print('   Length: ${identifier.length} characters');

      final result = await passwordResetRepository.forgotPassword(
        identifier: identifier,
      );

      if (result['success']) {
        print('   ✅ Forgot password successful');
        print('   Message: ${result['message']}');
        print('   🎯 CAPTURED RESET TOKEN: ${result['reset_token_id']}');
        print('   Identifier type detected: ${result['identifier_type']}');

        capturedResetTokenId = result['reset_token_id'];
        print('   ✅ Token captured for subsequent tests!');
        break; // Stop trying once we get a token
      } else {
        print('   ❌ Forgot password failed: ${result['message']}');
        print('   Error type: ${result['type']}');
        if (result['retryable'] == true) {
          print('   🔄 This error is retryable');
        }
      }
    }

    if (capturedResetTokenId == null) {
      print(
          '\n⚠️  No reset token captured. Using mock token for remaining tests...');
      capturedResetTokenId = '123e4567-e89b-12d3-a456-426614174000';
      print('   Mock token: $capturedResetTokenId');
    }
  }

  Future<void> _testOtpVerification() async {
    print('\n🔢 PHASE 3: OTP VERIFICATION TESTS');
    print('═' * 40);
    print('Using reset token: $capturedResetTokenId');

    // Test invalid OTP formats
    List<Map<String, String>> invalidOtps = [
      {'otp': '', 'desc': 'Empty OTP'},
      {'otp': '12345', 'desc': '5 digits (too short)'},
      {'otp': '1234567', 'desc': '7 digits (too long)'},
      {'otp': '12345a', 'desc': 'Contains letters'},
      {'otp': '12 34 56', 'desc': 'Contains spaces'},
    ];

    for (var testCase in invalidOtps) {
      print(
          '\n3.${invalidOtps.indexOf(testCase) + 1} Testing ${testCase['desc']}:');
      var result = await passwordResetRepository.verifyOtpToken(
        resetTokenId: capturedResetTokenId!,
        otpToken: testCase['otp']!,
      );

      if (!result['success']) {
        print('   ✅ ${testCase['desc']} correctly rejected');
        print('   Message: ${result['message']}');
        print('   Type: ${result['type']}');
      } else {
        print('   ❌ ${testCase['desc']} should be rejected');
      }
    }

    await _shortDelay();

    // Test potentially valid OTP format (but wrong code)
    print('\n3.${invalidOtps.length + 1} Testing valid format but wrong OTP:');
    var result = await passwordResetRepository.verifyOtpToken(
      resetTokenId: capturedResetTokenId!,
      otpToken: '000000', // Valid format but wrong code
    );

    if (!result['success']) {
      print('   ✅ Wrong OTP correctly rejected');
      print('   Message: ${result['message']}');
      print('   Is expired: ${result['is_expired'] ?? false}');
      print('   Is invalid: ${result['is_invalid'] ?? false}');
      print('   Can resend: ${result['can_resend'] ?? false}');
    } else {
      print('   ⚠️  Wrong OTP was accepted (check if this is expected)');
    }

    print('\n📱 For real testing: Check your email/SMS for the 6-digit OTP');
    print('   Then manually test with real OTP code');
  }

  Future<void> _testResendOtp() async {
    print('\n📧 PHASE 4: RESEND OTP TESTS');
    print('═' * 40);

    // Test with invalid reset token first
    print('4.1 Testing resend with invalid token:');
    var result = await passwordResetRepository.resendOtp(
      resetTokenId: 'invalid-token-id',
    );
    _printResult(result, 'Invalid token resend', shouldSucceed: false);

    await _shortDelay();

    // Test with valid token
    print('4.2 Testing resend with valid token:');
    print('   Using reset token: $capturedResetTokenId');

    result = await passwordResetRepository.resendOtp(
      resetTokenId: capturedResetTokenId!,
    );

    if (result['success']) {
      print('   ✅ OTP resent successfully');
      print('   Message: ${result['message']}');
      print('   Resent at: ${result['resent_at']}');
    } else {
      print('   ❌ Failed to resend OTP: ${result['message']}');
      print('   Error type: ${result['type']}');
      print('   Is expired: ${result['is_expired'] ?? false}');
      print('   Rate limited: ${result['rate_limited'] ?? false}');
      print('   Can retry: ${result['can_retry'] ?? false}');
      if (result['retry_suggestion'] != null) {
        print('   Suggestion: ${result['retry_suggestion']}');
      }
    }
  }

  Future<void> _testPasswordReset() async {
    print('\n🔄 PHASE 5: PASSWORD RESET TESTS');
    print('═' * 40);

    // Test password validation scenarios
    List<Map<String, dynamic>> passwordTests = [
      {
        'password': '',
        'confirm': '',
        'desc': 'Empty passwords',
        'shouldSucceed': false,
      },
      {
        'password': '123',
        'confirm': '123',
        'desc': 'Too short password',
        'shouldSucceed': false,
      },
      {
        'password': 'Password123!',
        'confirm': 'DifferentPass123!',
        'desc': 'Passwords don\'t match',
        'shouldSucceed': false,
      },
      {
        'password': 'weakpass',
        'confirm': 'weakpass',
        'desc': 'Weak password',
        'shouldSucceed': true, // Valid but weak
      },
      {
        'password': 'StrongPassword123!',
        'confirm': 'StrongPassword123!',
        'desc': 'Strong password',
        'shouldSucceed': true,
      },
    ];

    for (var testCase in passwordTests) {
      print(
          '\n5.${passwordTests.indexOf(testCase) + 1} Testing ${testCase['desc']}:');

      var result = await passwordResetRepository.resetPassword(
        resetTokenId: capturedResetTokenId!,
        password: testCase['password'],
        passwordConfirmation: testCase['confirm'],
      );

      bool expectedSuccess = testCase['shouldSucceed'];
      String status = result['success'] == expectedSuccess ? '✅' : '❌';

      print('   $status Result: ${result['success'] ? 'Success' : 'Failed'}');
      print('   Message: ${result['message']}');

      if (result['success']) {
        print('   Password strength: ${result['password_strength']}');
        print('   Reset at: ${result['reset_at']}');
      } else {
        print('   Error type: ${result['type']}');
        if (result['suggestions'] != null) {
          print('   Suggestions: ${result['suggestions']}');
        }
      }
    }
  }

  Future<void> _testValidationHelpers() async {
    print('\n✅ PHASE 6: VALIDATION HELPERS TESTS');
    print('═' * 40);

    // Test OTP validation
    print('6.1 OTP Validation Tests:');
    List<Map<String, dynamic>> otpTests = [
      {'otp': '123456', 'valid': true, 'desc': 'Valid 6-digit OTP'},
      {'otp': '12345', 'valid': false, 'desc': '5 digits'},
      {'otp': '1234567', 'valid': false, 'desc': '7 digits'},
      {'otp': '12345a', 'valid': false, 'desc': 'Contains letters'},
      {'otp': '', 'valid': false, 'desc': 'Empty OTP'},
      {
        'otp': '   123456   ',
        'valid': true,
        'desc': 'OTP with whitespace (should be trimmed)'
      },
    ];

    for (var test in otpTests) {
      var validation = passwordResetRepository.validateOtpToken(test['otp']);
      String status = validation['valid'] == test['valid'] ? '✅' : '❌';
      print(
          '   $status ${test['desc']}: ${validation['valid'] ? 'Valid' : 'Invalid'}');
      if (!validation['valid']) {
        print('       Message: ${validation['message']}');
      }
    }

    await _shortDelay();

    // Test identifier type detection
    print('\n6.2 Identifier Type Detection:');
    List<String> testIds = [
      ...testIdentifiers,
      'user@company.co.id',
      'test.email+tag@domain.com',
      '123',
      '987654321',
      'invalid-email',
      'user@',
      '@domain.com',
    ];

    for (String identifier in testIds) {
      String type = passwordResetRepository.getIdentifierType(identifier);
      bool isEmail = passwordResetRepository.isEmailFormat(identifier);
      print('   "$identifier" → Type: $type, IsEmail: $isEmail');
    }

    await _shortDelay();

    // Test password strength validation
    print('\n6.3 Password Strength Tests:');
    List<String> passwords = [
      'weak',
      'password123',
      'Password123',
      'Password123!',
      'VeryStrongP@ssw0rd!',
      '12345678',
      'UPPERCASE',
      'lowercase',
    ];

    for (String password in passwords) {
      var validation =
          passwordResetRepository.validatePassword(password, password);
      if (validation['valid']) {
        print('   "$password":');
        print(
            '     Strength: ${validation['strength']} (${validation['strength_score']}/5)');
        List<String> suggestions = validation['suggestions'] ?? [];
        if (suggestions.isNotEmpty) {
          print('     Suggestions: ${suggestions.join(', ')}');
        }
      } else {
        print('   "$password": ❌ ${validation['message']}');
      }
    }
  }

  Future<void> _testBusinessLogicHelpers() async {
    print('\n🧠 PHASE 7: BUSINESS LOGIC HELPERS');
    print('═' * 40);

    // Test UUID validation
    print('7.1 Reset Token Validation:');
    List<Map<String, dynamic>> tokenTests = [
      {
        'token': '123e4567-e89b-12d3-a456-426614174000',
        'valid': true,
        'desc': 'Valid UUID format'
      },
      {'token': 'invalid-token', 'valid': false, 'desc': 'Invalid format'},
      {'token': '', 'valid': false, 'desc': 'Empty token'},
      {
        'token': '123e4567-e89b-12d3-a456-42661417400', // Missing last digit
        'valid': false,
        'desc': 'Incomplete UUID'
      },
    ];

    for (var test in tokenTests) {
      var validation =
          passwordResetRepository.validateResetToken(test['token']);
      String status = validation['valid'] == test['valid'] ? '✅' : '❌';
      print(
          '   $status ${test['desc']}: ${validation['valid'] ? 'Valid' : 'Invalid'}');
      if (!validation['valid']) {
        print('       Message: ${validation['message']}');
      }
    }

    await _shortDelay();

    // Test password strength checker
    print('\n7.2 Strong Password Checker:');
    List<String> passwordsToCheck = [
      'weak',
      'StrongPassword123!',
      'password',
      'Password123!',
    ];

    for (String password in passwordsToCheck) {
      bool isStrong = passwordResetRepository.isStrongPassword(password);
      print('   "$password": ${isStrong ? '💪 Strong' : '😐 Not strong'}');
    }

    await _shortDelay();

    // Test password requirements info
    print('\n7.3 Password Requirements:');
    var requirements = passwordResetRepository.getPasswordRequirements();
    requirements.forEach((key, value) {
      print('   ${key.replaceAll('_', ' ').toUpperCase()}: $value');
    });
  }

  // Helper methods
  void _printResult(Map<String, dynamic> result, String operation,
      {required bool shouldSucceed}) {
    String status = result['success'] == shouldSucceed ? '✅' : '❌';
    print('   $status $operation: ${result['success'] ? 'Success' : 'Failed'}');
    print('   Message: ${result['message']}');

    if (!result['success']) {
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      if (result['retryable'] == true) {
        print('   🔄 Retryable error');
      }
    }
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _shortDelay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    testCompletePasswordResetFlow();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Password Reset Test"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_reset, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                "Testing Complete Password Reset Flow",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Check terminal for detailed test results",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "Test Phases:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text("📝 Phase 1: Input Validation"),
              Text("📧 Phase 2: Forgot Password"),
              Text("🔢 Phase 3: OTP Verification"),
              Text("📧 Phase 4: Resend OTP"),
              Text("🔄 Phase 5: Password Reset"),
              Text("✅ Phase 6: Validation Helpers"),
              Text("🧠 Phase 7: Business Logic"),
            ],
          ),
        ),
      ),
    );
  }
}
