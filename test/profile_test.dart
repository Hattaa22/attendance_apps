import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/services/auth_service.dart';
import '../lib/core/data/services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(ProfileTestApp());
}

class ProfileTestApp extends StatelessWidget {
  ProfileTestApp({super.key});

  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();

  Future<void> testProfileMethods() async {
    print('=== Testing ProfileService ===\n');

    // Test get profile
    await _testGetProfile();
    await _delay();

    // Test update name only
    await _testUpdateName();
    await _delay();

    // Test update password only
    await _testUpdatePassword();
    await _delay();

    // Test update both name and password
    await _testUpdateBoth();

    print('\n=== All profile tests completed ===');
  }
  Future<void> _testGetProfile() async {
    print('\n👤 GET PROFILE TEST');
    print('─' * 30);

    final result = await profileService.getProfile();
    if (result['success']) {
      print('✅ Profile loaded successfully');
      final profile = result['profile'];
      print('   NIP: ${profile['nip']}');
      print('   Name: ${profile['name']}');
      print('   Department: ${profile['department'] ?? 'No Department'}');
      print('   Team: ${profile['team_department'] ?? 'No Team'}');
      print('   Manager: ${profile['manager_department'] ?? 'No Manager'}');
    } else {
      print('❌ Failed to get profile: ${result['message']}');
    }
  }

  Future<void> _testUpdateName() async {
    print('\n✏️ UPDATE NAME TEST');
    print('─' * 30);

    final result = await profileService.updateName('Updated Admin User');
    if (result['success']) {
      print('✅ Name updated successfully');
      print('   New name: ${result['profile']['name']}');
    } else {
      print('❌ Failed to update name: ${result['message']}');
    }
  }

  Future<void> _testUpdatePassword() async {
    print('\n🔒 UPDATE PASSWORD TEST');
    print('─' * 30);

    final result = await profileService.updatePassword(
      password: 'newpassword123',
      passwordConfirmation: 'newpassword123',
    );
    if (result['success']) {
      print('✅ Password updated successfully');
    } else {
      print('❌ Failed to update password: ${result['message']}');
    }
  }

  Future<void> _testUpdateBoth() async {
    print('\n🔄 UPDATE NAME AND PASSWORD TEST');
    print('─' * 30);

    final result = await profileService.updateNameAndPassword(
      name: 'Final Admin User',
      password: 'password', // Reset back to original
      passwordConfirmation: 'password',
    );
    if (result['success']) {
      print('✅ Name and password updated successfully');
      print('   Final name: ${result['profile']['name']}');
    } else {
      print('❌ Failed to update profile: ${result['message']}');
    }
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    testProfileMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Service Test"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "Testing ProfileService Methods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Check terminal for detailed results",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "Tests include:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text("• Get profile data"),
              Text("• Update name only"),
              Text("• Update password only"),
              Text("• Update both name & password"),
            ],
          ),
        ),
      ),
    );
  }
}
