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

    // Logout flow tests (disable if you want to keep the session)
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

    // Test 2: Get user (should fail initially)
    print('2. Testing getUser() - Initial state:');
    var userResult = await authService.getUser();
    if (userResult['success']) {
      print('   ❌ User data exists: ${userResult['user']['name']}');
    } else {
      print('   ✅ No user data as expected');
      print('   Message: ${userResult['message']}');
    }
    await _delay();
  }

  Future<void> _testLoginFlow() async {
    print('\n🔐 LOGIN FLOW TESTS');
    print('─' * 30);

    // Test 3: Login with valid credentials
    print('3. Testing login() with credentials:');
    final loginResult = await authService.login('10003', 'password');

    if (loginResult['success']) {
      print('   ✅ Login successful');
      print('   Message: ${loginResult['message']}');
      print(
          '   Token: ${loginResult['token'] != null ? "Token received" : "No token"}');
      print('   User: ${loginResult['user']['name'] ?? "No user name"}');
      print('   NIP: ${loginResult['user']['nip'] ?? "No NIP"}');
    } else {
      print('   ❌ Login failed: ${loginResult['message']}');
    }
    await _delay();
  }

  Future<void> _testPostLoginState() async {
    print('\n📊 POST-LOGIN STATE TESTS');
    print('─' * 30);

    // Test 4: Check if logged in after login
    print('4. Testing isLoggedIn() after login:');
    bool isLoggedIn = await authService.isLoggedIn();
    print(
        '   Result: ${isLoggedIn ? "✅ Successfully logged in" : "❌ Not logged in"}');
    await _delay();

    // Test 5: Get stored user
    print('5. Testing getUser() after login:');
    var userResult = await authService.getUser();

    if (userResult['success']) {
      print('   ✅ User data retrieved');
      print('   NIP: ${userResult['user']['nip'] ?? "N/A"}');
      print('   Name: ${userResult['user']['name'] ?? "N/A"}');
      print('   Email: ${userResult['user']['email'] ?? "N/A"}');
      print('   Department: ${userResult['user']['department'] ?? "N/A"}');
    } else {
      print('   ❌ Failed to get user: ${userResult['message']}');
    }
    await _delay();
  }

  Future<void> _testTokenOperations() async {
    print('\n🔄 TOKEN & USER OPERATIONS');
    print('─' * 30);

    // Test 6: Get current user from API
    print('6. Testing getCurrentUser() from API:');
    var currentUserResult = await authService.getCurrentUser();

    if (currentUserResult['success']) {
      print('   ✅ Current user loaded from API');
      print('   Name: ${currentUserResult['user']['name'] ?? "N/A"}');
      print('   Email: ${currentUserResult['user']['email'] ?? "N/A"}');
    } else {
      print(
          '   ❌ Failed to load current user: ${currentUserResult['message']}');
    }
    await _delay();

    // Test 7: Load user (with fallback to cache)
    print('7. Testing loadUser():');
    var loadUserResult = await authService.loadUser();

    if (loadUserResult['success']) {
      print('   ✅ User loaded successfully');
      print(
          '   Source: ${loadUserResult['user']['name'] != null ? "API or Cache" : "Unknown"}');
    } else {
      print('   ❌ Failed to load user: ${loadUserResult['message']}');
    }
    await _delay();

    // Test 8: Refresh token
    print('8. Testing refreshToken():');
    bool refreshSuccess = await authService.refreshToken();
    print(
        '   Result: ${refreshSuccess ? "✅ Token refreshed successfully" : "❌ Token refresh failed"}');
    await _delay();
  }

  Future<void> _testLogoutFlow() async {
    print('\n🚪 LOGOUT FLOW TESTS');
    print('─' * 30);

    // Test 9: Logout
    print('9. Testing logout():');
    var logoutResult = await authService.logout();

    if (logoutResult['success']) {
      print('   ✅ Logout successful');
      print('   Message: ${logoutResult['message']}');
    } else {
      print('   ❌ Logout failed: ${logoutResult['message']}');
    }
    await _delay();

    // Test 10: Check if logged in after logout
    print('10. Testing isLoggedIn() after logout:');
    bool isLoggedIn = await authService.isLoggedIn();
    print(
        '   Result: ${!isLoggedIn ? "✅ Successfully logged out" : "❌ Still logged in"}');
    await _delay();

    // Test 11: Verify user data cleared
    print('11. Testing getUser() after logout:');
    var userResult = await authService.getUser();

    if (userResult['success']) {
      print('   ❌ User data still exists: ${userResult['user']['name']}');
    } else {
      print('   ✅ User data cleared as expected');
      print('   Message: ${userResult['message']}');
    }
    await _delay();
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
              Icon(Icons.security, size: 64, color: Colors.blue),
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
              SizedBox(height: 16),
              Text(
                "Tests include:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text("• Initial state validation"),
              Text("• Login flow"),
              Text("• Post-login state"),
              Text("• Token operations"),
              Text("• User data retrieval"),
              Text("• Logout flow"),
            ],
          ),
        ),
      ),
    );
  }
}
