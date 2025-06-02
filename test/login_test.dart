import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthService authService = AuthService();

  Future<void> testAllMethods() async {
    print('=== Testing AuthService ===\n');
    await _delay();

    // Initial state tests
    await _testInitialState();

    // Login flow tests
    await _testLoginFlow();

    // Post-login state tests
    await _testPostLoginState();

    // Token and user operations
    await _testTokenOperations();

    // Logout flow tests (disable if you want to keep the session like if you want to test the app after login)
    await _testLogoutFlow();

    print('=== All tests completed ===');
  }

  Future<void> _testInitialState() async {
    print('📋 INITIAL STATE TESTS');
    print('─' * 30);

    // Test 1: Check if logged in (should be false initially)
    print('1. Testing isLoggedIn() - Initial state:');
    bool isLoggedIn = await authService.isLoggedIn();
    print(
        '   Result: ${isLoggedIn ? "❌ Already logged in" : "✅ Not logged in"}');
    await _delay();

    // Test 3: Get user (should be null initially)
    print('3. Testing getUser() - Initial state:');
    var user = await authService.getUser();
    print(
        '   Result: ${user == null ? "✅ No user data" : "❌ User exists: $user"}');
    await _delay();
  }

  Future<void> _testLoginFlow() async {
    print('\n🔐 LOGIN FLOW TESTS');
    print('─' * 30);

    // Test 4: Login with valid credentials
    print('4. Testing login() with credentials:');
    final loginResult = await authService.login('10003', 'password');
    if (loginResult['success']) {
      print('   ✅ Login successful');
      print(
          '   Token: ${loginResult['data']['access_token'] != null ? "Token received" : "No token"}');
      print(
          '   User: ${loginResult['data']['user'] != null ? "User data received" : "No user data"}');
    } else {
      print('   ❌ Login failed: ${loginResult['message']}');
    }
    await _delay();
  }

  Future<void> _testPostLoginState() async {
    print('\n📊 POST-LOGIN STATE TESTS');
    print('─' * 30);

    // Test 5: Check if logged in after login
    print('5. Testing isLoggedIn() after login:');
    bool isLoggedIn = await authService.isLoggedIn();
    print(
        '   Result: ${isLoggedIn ? "✅ Successfully logged in" : "❌ Not logged in"}');
    await _delay();

    // Test 6: Get token after login
    print('6. Testing getToken() after login:');
    bool? token = await authService.isLoggedIn();
    print(
        '   Result: ${token == true ? "✅ Token exists" : "❌ No token found"}');
    await _delay();

    // Test 7: Get stored user
    print('7. Testing getUser() after login:');
    var user = await authService.getUser();
    print(
        '   Result: ${user != null ? "✅ User data exists" : "❌ No user data"}');
    if (user != null) {
      print('   nip: ${user['nip'] ?? "N/A"}');
      print('   User Name: ${user['name'] ?? "N/A"}');
    }
    await _delay();
  }

  Future<void> _testTokenOperations() async {
    print('\n🔄 TOKEN & USER OPERATIONS');
    print('─' * 30);

    // Test 8: Load user from API
    print('8. Testing loadUser() from API:');
    try {
      var loadedUser = await authService.loadUser();
      print(
          '   Result: ${loadedUser != null ? "✅ User loaded from API" : "❌ Failed to load user from API"}');
      if (loadedUser != null) {
        print('   Data: $loadedUser');
      }
    } catch (e) {
      print('   ❌ Error loading user: $e');
    }
    await _delay();

    // Test 9: Refresh token
    print('9. Testing refreshToken():');
    try {
      bool refreshSuccess = await authService.refreshToken();
      print(
          '   Result: ${refreshSuccess ? "✅ Token refreshed successfully" : "❌ Token refresh failed"}');
    } catch (e) {
      print('   ❌ Error refreshing token: $e');
    }
    await _delay();
  }

  Future<void> _testLogoutFlow() async {
    print('\n🚪 LOGOUT FLOW TESTS');
    print('─' * 30);

    // Test 10: Logout
    print('10. Testing logout():');
    try {
      await authService.logout();
      print('    ✅ Logout completed successfully');
    } catch (e) {
      print('    ❌ Error during logout: $e');
    }
    await _delay();

    // Test 11: Check if logged in after logout
    print('11. Testing isLoggedIn() after logout:');
    bool isLoggedIn = await authService.isLoggedIn();
    print(
        '    Result: ${!isLoggedIn ? "✅ Successfully logged out" : "❌ Still logged in"}');
    await _delay();

    // Test 13: Verify user data cleared
    print('13. Testing getUser() after logout:');
    var user = await authService.getUser();
    print(
        '    Result: ${user == null ? "✅ User data cleared" : "❌ User data still exists"}');
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    testAllMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("AuthService Test"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "Testing AuthService Methods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Check terminal for detailed results",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
