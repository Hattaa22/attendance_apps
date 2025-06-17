import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/repositories/auth_repository.dart'; // Changed import
import '../lib/core/data/repositories/profile_repository.dart'; // Changed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(ProfileTestApp());
}

class ProfileTestApp extends StatelessWidget {
  ProfileTestApp({super.key});

  final AuthRepository authRepository =
      AuthRepositoryImpl(); // Changed to Repository
  final ProfileRepository profileRepository =
      ProfileRepositoryImpl(); // Changed to Repository

  Future<void> testProfileMethods() async {
    print('=== Testing ProfileRepository ===\n'); // Updated message

    // Phase 1: Prerequisites and authentication
    await _testPrerequisites();
    await _delay();

    // Phase 2: Profile validation
    await _testProfileValidation();
    await _delay();

    // Phase 3: Get profile
    await _testGetProfile();
    await _delay();

    // Phase 4: Update name only
    await _testUpdateName();
    await _delay();

    // Phase 5: Update password only
    await _testUpdatePassword();
    await _delay();

    // Phase 6: Update both name and password
    await _testUpdateBoth();
    await _delay();

    // Phase 7: Profile picture update
    await _testUpdateProfilePicture();
    await _delay();

    // Phase 9: Helper methods and validation
    await _testHelperMethods();

    print(
        '\n🎉 === All profile repository tests completed ==='); // Updated message
  }

  Future<void> _testPrerequisites() async {
    print('🔍 PHASE 1: PREREQUISITES & AUTHENTICATION');
    print('═' * 40);

    // Check authentication status
    print('1.1 Checking authentication status:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Authentication status: ${isAuthenticated ? "✅ Authenticated" : "❌ Not authenticated"}');

    if (!isAuthenticated) {
      print('   ⚠️  Some tests may fail without authentication');
      print('   Consider running login test first');
    }

    // Test session validity
    print('1.2 Checking session validity:');
    bool isValidSession = await authRepository.isValidSession(); // Changed
    print('   Session valid: ${isValidSession ? "✅ Valid" : "❌ Invalid"}');
  }

  Future<void> _testProfileValidation() async {
    print('\n✅ PHASE 2: PROFILE VALIDATION');
    print('═' * 40);

    // Test valid profile update
    print('2.1 Testing valid profile update validation:');
    var validResult = await profileRepository.validateProfileUpdate(
      // Changed
      name: 'John Doe Smith',
      password: 'NewPassword123',
      passwordConfirmation: 'NewPassword123',
    );

    if (validResult['success']) {
      print('   ✅ Valid profile update passed validation');
      print('   Message: ${validResult['message']}');
      if (validResult['validation'] != null) {
        final validation = validResult['validation'];
        print('   Name valid: ${validation['name_valid']}');
        print('   Password required: ${validation['password_required']}');
        print('   Password valid: ${validation['password_valid']}');
      }
    } else {
      print(
          '   ❌ Valid profile update failed validation: ${validResult['message']}');
    }

    await _shortDelay();

    // Test invalid name
    print('2.2 Testing invalid name:');
    var invalidNameResult = await profileRepository.validateProfileUpdate(
      // Changed
      name: 'A', // Too short
    );

    if (!invalidNameResult['success']) {
      print('   ✅ Invalid name correctly rejected');
      print('   Message: ${invalidNameResult['message']}');
      print('   Field: ${invalidNameResult['field']}');
    } else {
      print('   ❌ Invalid name should be rejected');
    }

    await _shortDelay();

    // Test password mismatch
    print('2.3 Testing password confirmation mismatch:');
    var mismatchResult = await profileRepository.validateProfileUpdate(
      // Changed
      name: 'Valid Name',
      password: 'Password123',
      passwordConfirmation: 'DifferentPassword',
    );

    if (!mismatchResult['success']) {
      print('   ✅ Password mismatch correctly rejected');
      print('   Message: ${mismatchResult['message']}');
    } else {
      print('   ❌ Password mismatch should be rejected');
    }

    await _shortDelay();

    // Test weak password
    print('2.4 Testing weak password:');
    var weakPasswordResult = await profileRepository.validateProfileUpdate(
      // Changed
      name: 'Valid Name',
      password: 'weak', // Too short and no uppercase/numbers
      passwordConfirmation: 'weak',
    );

    if (!weakPasswordResult['success']) {
      print('   ✅ Weak password correctly rejected');
      print('   Message: ${weakPasswordResult['message']}');
    } else {
      print('   ❌ Weak password should be rejected');
    }
  }

  Future<void> _testGetProfile() async {
    print('\n👤 PHASE 3: GET PROFILE TEST');
    print('═' * 40);

    print('3.1 Testing getProfile():');
    final result = await profileRepository.getProfile(); // Changed

    if (result['success']) {
      print('   ✅ Profile loaded successfully');
      print('   Message: ${result['message']}');
      print('   Last updated: ${result['last_updated']}');

      final profile = result['profile'];
      print('   Profile Details:');
      print('     NIP: ${profile['nip']}');
      print('     Name: ${profile['name']}');
      print('     Display Name: ${profile['display_name']}');
      print('     Initials: ${profile['initials']}');
      print('     Email: ${profile['email']}');
      print('     Department: ${profile['department'] ?? 'No Department'}');
      print('     Team: ${profile['team_department'] ?? 'No Team'}');
      print('     Manager: ${profile['manager_department'] ?? 'No Manager'}');
      print(
          '     Profile Completeness: ${profile['profile_completeness']?.toStringAsFixed(1) ?? '0'}%');
      print('     Last Seen: ${profile['last_seen']}');
    } else {
      print('   ❌ Failed to get profile: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
      if (result['sessionExpired'] == true) {
        print('   ⚠️  Session expired detected');
      }
    }
  }

  Future<void> _testUpdateName() async {
    print('\n✏️ PHASE 4: UPDATE NAME TEST');
    print('═' * 40);

    print('4.1 Testing updateName():');
    final result = await profileRepository
        .updateName('Updated Admin User - Repository Test'); // Changed

    if (result['success']) {
      print('   ✅ Name updated successfully');
      print('   Message: ${result['message']}');
      print('   Updated fields: ${result['updated_fields']}');
      print('   Updated at: ${result['updated_at']}');

      final profile = result['profile'];
      print('   Profile Updates:');
      print('     New name: ${profile['name']}');
      print('     Display name: ${profile['display_name']}');
      print('     Initials: ${profile['initials']}');
      print(
          '     Profile completeness: ${profile['profile_completeness']?.toStringAsFixed(1)}%');
    } else {
      print('   ❌ Failed to update name: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Field: ${result['field'] ?? 'Unknown'}');
    }

    await _shortDelay();

    // Test invalid name update
    print('4.2 Testing invalid name update:');
    final invalidResult =
        await profileRepository.updateName('A'); // Changed - too short

    if (!invalidResult['success']) {
      print('   ✅ Invalid name correctly rejected');
      print('   Message: ${invalidResult['message']}');
      print('   Field: ${invalidResult['field']}');
    } else {
      print('   ❌ Invalid name should be rejected');
    }
  }

  Future<void> _testUpdatePassword() async {
    print('\n🔒 PHASE 5: UPDATE PASSWORD TEST');
    print('═' * 40);

    print('5.1 Testing updatePassword():');
    final result = await profileRepository.updatePassword(
      // Changed
      password: 'NewPassword123',
      passwordConfirmation: 'NewPassword123',
    );

    if (result['success']) {
      print('   ✅ Password updated successfully');
      print('   Message: ${result['message']}');
      print('   Updated fields: ${result['updated_fields']}');
      print('   Updated at: ${result['updated_at']}');

      final profile = result['profile'];
      print('   Profile Updates:');
      print('     Name preserved: ${profile['name']}');
      print(
          '     Profile completeness: ${profile['profile_completeness']?.toStringAsFixed(1)}%');
    } else {
      print('   ❌ Failed to update password: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Field: ${result['field'] ?? 'Unknown'}');
    }

    await _shortDelay();

    // Test password mismatch
    print('5.2 Testing password confirmation mismatch:');
    final mismatchResult = await profileRepository.updatePassword(
      // Changed
      password: 'Password123',
      passwordConfirmation: 'DifferentPassword',
    );

    if (!mismatchResult['success']) {
      print('   ✅ Password mismatch correctly rejected');
      print('   Message: ${mismatchResult['message']}');
    } else {
      print('   ❌ Password mismatch should be rejected');
    }
  }

  Future<void> _testUpdateBoth() async {
    print('\n🔄 PHASE 6: UPDATE NAME AND PASSWORD TEST');
    print('═' * 40);

    print('6.1 Testing updateNameAndPassword():');
    final result = await profileRepository.updateNameAndPassword(
      // Changed
      name: 'Final Admin User - Repository',
      password: 'FinalPassword123',
      passwordConfirmation: 'FinalPassword123',
    );

    if (result['success']) {
      print('   ✅ Name and password updated successfully');
      print('   Message: ${result['message']}');
      print('   Updated fields: ${result['updated_fields']}');
      print('   Updated at: ${result['updated_at']}');

      final profile = result['profile'];
      print('   Profile Updates:');
      print('     Final name: ${profile['name']}');
      print('     Display name: ${profile['display_name']}');
      print('     Initials: ${profile['initials']}');
      print(
          '     Profile completeness: ${profile['profile_completeness']?.toStringAsFixed(1)}%');
    } else {
      print('   ❌ Failed to update profile: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
    }

    await _shortDelay();

    // Reset back to original for consistency
    print('6.2 Resetting to original credentials:');
    final resetResult = await profileRepository.updateNameAndPassword(
      // Changed
      name: 'Admin User',
      password: 'password', // Reset back to original
      passwordConfirmation: 'password',
    );

    if (resetResult['success']) {
      print('   ✅ Profile reset to original state');
      print('   Name: ${resetResult['profile']['name']}');
    } else {
      print('   ⚠️  Could not reset to original: ${resetResult['message']}');
    }
  }

  Future<void> _testUpdateProfilePicture() async {
    print('\n📷 PHASE 7: UPDATE PROFILE PICTURE TEST');
    print('═' * 40);

    // Test invalid file path
    print('7.1 Testing invalid image file:');
    final invalidFileResult =
        await profileRepository.updateProfilePicture(''); // Changed

    if (!invalidFileResult['success']) {
      print('   ✅ Invalid file path correctly rejected');
      print('   Message: ${invalidFileResult['message']}');
      print('   Field: ${invalidFileResult['field']}');
    } else {
      print('   ❌ Invalid file path should be rejected');
    }

    await _shortDelay();

    // Test invalid file format
    print('7.2 Testing invalid file format:');
    final invalidFormatResult = await profileRepository
        .updateProfilePicture('/path/to/file.txt'); // Changed

    if (!invalidFormatResult['success']) {
      print('   ✅ Invalid file format correctly rejected');
      print('   Message: ${invalidFormatResult['message']}');
    } else {
      print('   ❌ Invalid file format should be rejected');
    }

    await _shortDelay();

    // Test valid file format (this will fail at API level but validation should pass)
    print('7.3 Testing valid file format (validation only):');
    final validFormatResult = await profileRepository
        .updateProfilePicture('/path/to/profile.jpg'); // Changed

    // This will likely fail at API level but we can check the validation
    print('   Note: API call expected to fail, but validation should pass');
    if (!validFormatResult['success']) {
      if (validFormatResult['type'] == 'validation') {
        print('   ❌ Valid file format incorrectly rejected at validation');
      } else {
        print(
            '   ✅ Valid file format passed validation, failed at API level (expected)');
        print('   Message: ${validFormatResult['message']}');
        print('   Type: ${validFormatResult['type']}');
      }
    } else {
      print('   ✅ Profile picture updated successfully');
      print('   Uploaded at: ${validFormatResult['uploaded_at']}');
    }
  }

  Future<void> _testHelperMethods() async {
    await _shortDelay();

    print('9.3 Testing validation methods (through public methods):');

    // Test validation through public validate method
    var validationTests = [
      {'name': 'John Doe', 'valid': true, 'desc': 'Valid name'},
      {'name': 'A', 'valid': false, 'desc': 'Too short name'},
      {
        'name':
            'Very Long Name That Exceeds The Maximum Character Limit Set For Names In The System',
        'valid': false,
        'desc': 'Too long name'
      },
      {'name': 'John123', 'valid': false, 'desc': 'Name with numbers'},
    ];

    for (var test in validationTests) {
      var result = await profileRepository.validateProfileUpdate(
        // Changed
        name: test['name'] as String,
      );

      bool isValid = result['success'] == test['valid'];
      print(
          '   ${isValid ? "✅" : "❌"} ${test['desc']}: ${result['success'] ? "Valid" : "Invalid"}');
      if (!result['success']) {
        print('     Reason: ${result['message']}');
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
    testProfileMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Repository Test"), // Updated title
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 64, color: Colors.indigo),
              SizedBox(height: 16),
              Text(
                "Testing ProfileRepository Methods", // Updated text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Check terminal for detailed results",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "Test Phases:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text("🔍 Phase 1: Prerequisites"),
              Text("✅ Phase 2: Validation"),
              Text("👤 Phase 3: Get Profile"),
              Text("✏️ Phase 4: Update Name"),
              Text("🔒 Phase 5: Update Password"),
              Text("🔄 Phase 6: Update Both"),
              Text("📷 Phase 7: Profile Picture"),
              Text("📊 Phase 8: Statistics"),
              Text("🛠️  Phase 9: Helper Methods"),
            ],
          ),
        ),
      ),
    );
  }
}
