import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/services/password_reset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(PasswordResetTest());
}

class PasswordResetTest extends StatelessWidget {
  PasswordResetTest({super.key});

  final PasswordResetService passwordResetService = PasswordResetService();
  String? capturedResetTokenId;

  // Make testIdentifiers a class property so all methods can access it
  static const testIdentifiers = [
    'daffamaulanasatria@gmail.com', // Email
    '69', // NIP
  ];

  Future<void> testCompletePasswordResetFlow() async {
    print('=== Testing Complete Password Reset Flow ===\n');

    // Step 1: Test forgot password with identifier (email or NIP)
    await _testForgotPassword();
    await _delay();

    if (capturedResetTokenId != null) {
      // Step 2: Test OTP verification
      await _testOtpVerification();
      await _delay();

      // Step 3: Test resend OTP
      await _testResendOtp();
      await _delay();

      // Step 4: Test password reset
      await _testPasswordReset();
    }

    // Step 5: Test validation helpers
    await _testValidationHelpers();

    print('\n=== All password reset tests completed ===');
  }

  Future<void> _testForgotPassword() async {
    print('📧 FORGOT PASSWORD TEST');
    print('─' * 30);

    for (String identifier in testIdentifiers) {
      print(
          '\nTesting with identifier: "$identifier" (${passwordResetService.getIdentifierType(identifier)})');
      print('Identifier length: ${identifier.length}');
      print('Identifier bytes: ${identifier.codeUnits}');

      final result = await passwordResetService.forgotPassword(
        identifier: identifier,
      );

      if (result['success']) {
        print('✅ Forgot password successful');
        print('   Message: ${result['message']}');
        print('🎯 CAPTURED RESET TOKEN: ${result['reset_token_id']}');

        capturedResetTokenId = result['reset_token_id'];
        print('   Use this token for subsequent tests!');
        break; // Stop trying once we get a token
      } else {
        print('❌ Forgot password failed: ${result['message']}');
        print('   Full response: $result'); // See full error details
      }
    }

    if (capturedResetTokenId == null) {
      print(
          '\n⚠️  No reset token captured. Using mock token for remaining tests...');
      capturedResetTokenId = '123e4567-e89b-12d3-a456-426614174000';
    }
  }

  Future<void> _testOtpVerification() async {
    print('\n🔢 OTP VERIFICATION TEST');
    print('─' * 30);
    print('Using reset token: $capturedResetTokenId');

    // Test invalid OTP first
    print('\nTesting with invalid OTP...');
    var result = await passwordResetService.verifyOtpToken(
      resetTokenId: capturedResetTokenId!,
      otpToken: '000000', // Invalid OTP
    );

    if (result['success']) {
      print('⚠️  Invalid OTP was accepted (this shouldn\'t happen)');
    } else {
      print('✅ Invalid OTP correctly rejected: ${result['message']}');
      print('   Is expired: ${result['is_expired'] ?? false}');
      print('   Is invalid: ${result['is_invalid'] ?? false}');
    }

    // Test with valid OTP (you would need to check your email for the real OTP)
    print('\nFor real testing, check your email for the 6-digit OTP');
    print(
        'Then manually test with: passwordResetService.verifyOtpToken(resetTokenId, realOtp)');
  }

  Future<void> _testResendOtp() async {
    print('\n📧 RESEND OTP TEST');
    print('─' * 30);
    print('Using reset token: $capturedResetTokenId');

    final result = await passwordResetService.resendOtp(
      resetTokenId: capturedResetTokenId!,
    );

    if (result['success']) {
      print('✅ OTP resent successfully');
      print('   Message: ${result['message']}');
    } else {
      print('❌ Failed to resend OTP: ${result['message']}');
      print('   Expired: ${result['is_expired'] ?? false}');
      print('   Rate limited: ${result['rate_limited'] ?? false}');
    }
  }

  Future<void> _testPasswordReset() async {
    print('\n🔄 PASSWORD RESET TEST');
    print('─' * 30);
    print('Using reset token: $capturedResetTokenId');

    final result = await passwordResetService.resetPassword(
      resetTokenId: capturedResetTokenId!,
      password: 'NewPassword123!',
      passwordConfirmation: 'NewPassword123!',
    );

    if (result['success']) {
      print('✅ Password reset successfully');
      print('   Message: ${result['message']}');
    } else {
      print('❌ Failed to reset password: ${result['message']}');
    }
  }

  Future<void> _testValidationHelpers() async {
    print('\n✅ VALIDATION HELPERS TEST');
    print('─' * 30);

    // Test OTP validation
    print('OTP Validation Tests:');
    var validation = passwordResetService.validateOtpToken('12345');
    print(
        '  5 digits: ${validation['valid'] ? '✅' : '❌'} ${validation['message']}');

    validation = passwordResetService.validateOtpToken('123456');
    print(
        '  6 digits: ${validation['valid'] ? '✅' : '❌'} ${validation['message']}');

    validation = passwordResetService.validateOtpToken('12345a');
    print(
        '  Non-numeric: ${validation['valid'] ? '✅' : '❌'} ${validation['message']}');

    // Test identifier type detection - NOW USES YOUR ACTUAL DATA
    print('\nIdentifier Type Detection:');
    for (String identifier in testIdentifiers) {
      print(
          '  $identifier: ${passwordResetService.getIdentifierType(identifier)}');
    }

    // Test password validation
    print('\nPassword Validation:');
    validation =
        passwordResetService.validatePassword('Password123!', 'Password123!');
    print(
        '  Strong password: ${validation['valid'] ? '✅' : '❌'} ${validation['message']}');
    if (validation['valid']) {
      print(
          '    Strength: ${validation['strength']} (${validation['strength_score']}/5)');
    }
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    testCompletePasswordResetFlow();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Password Reset Test"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_reset, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "Testing Complete Password Reset Flow",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Check terminal for detailed results",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "Complete Flow Tests:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text("• 1. Forgot password (email/NIP)"),
              Text("• 2. OTP verification"),
              Text("• 3. Resend OTP"),
              Text("• 4. Password reset"),
              Text("• 5. Validation helpers"),
            ],
          ),
        ),
      ),
    );
  }
}
