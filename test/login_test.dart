import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/repositories/auth_repository.dart'; // Changed import
import 'package:fortis_apps/core/data/storages/token_storage.dart';
import 'package:fortis_apps/core/data/storages/user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(LoginTest());
}

class LoginTest extends StatelessWidget {
  LoginTest({super.key});

  final AuthRepository authRepository =
      AuthRepositoryImpl(); // Changed from AuthService to AuthRepository

  Future<void> testCompleteAuthFlow() async {
    print('=== Testing Complete Auth Repository Flow ===\n'); // Updated message

    // Phase 1: Initial state and validation
    await _testInitialState();
    await _delay();

    // Phase 2: Input validation tests
    await _testInputValidation();
    await _delay();

    // Phase 3: Login flow with real credentials
    await _testLoginFlow();
    await _delay();

    // Phase 4: Post-login operations
    await _testPostLoginOperations();
    await _delay();

    // Phase 5: Session management
    await _testSessionManagement();
    await _delay();

    // Phase 6: Token operations
    await _testTokenOperations();
    await _delay();

    // Phase 7: User data operations
    await _testUserDataOperations();
    await _delay();

    // Phase 8: Error handling scenarios
    // await _testErrorHandling();
    // await _delay();

    // Phase 9: Logout flow (optional - uncomment to test)
    await _testLogoutFlow();

    print(
        '\n🎉 === All Auth Repository tests completed ==='); // Updated message
  }

  Future<void> _testInitialState() async {
    print('🔍 PHASE 1: INITIAL STATE TESTS');
    print('═' * 40);

    // Test authentication status
    print('1.1 Testing initial authentication state:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Is authenticated: ${isAuthenticated ? "❌ Already logged in" : "✅ Not authenticated"}');

    // Test session validity
    print('1.2 Testing initial session validity:');
    bool isValidSession = await authRepository.isValidSession(); // Changed
    print(
        '   Session valid: ${isValidSession ? "❌ Session exists" : "✅ No valid session"}');

    // Test user data availability
    print('1.3 Testing initial user data:');
    var userResult = await authRepository.getUser(); // Changed
    if (userResult['success']) {
      print('   ❌ User data exists: ${userResult['user']['name']}');
      print('   From cache: ${userResult['fromCache'] ?? false}');
    } else {
      print('   ✅ No user data as expected');
      print('   Message: ${userResult['message']}');
      print('   Requires login: ${userResult['requiresLogin'] ?? false}');
    }

    // Test session check
    print('1.4 Testing session check:');
    var sessionResult = await authRepository.checkSession(); // Changed
    print(
        '   Session valid: ${sessionResult['valid'] ? "❌" : "✅"} ${sessionResult['message']}');
    print('   Requires login: ${sessionResult['requiresLogin'] ?? false}');
  }

  Future<void> _testInputValidation() async {
    print('\n📝 PHASE 2: INPUT VALIDATION TESTS');
    print('═' * 40);

    // Test empty identifier
    print('2.1 Testing empty identifier:');
    var result = await authRepository.login('', 'password123'); // Changed
    _printLoginResult(result, shouldSucceed: false);

    await _shortDelay();

    // Test empty password
    print('2.2 Testing empty password:');
    result = await authRepository.login('test@example.com', ''); // Changed
    _printLoginResult(result, shouldSucceed: false);

    await _shortDelay();

    // Test whitespace-only inputs
    print('2.3 Testing whitespace-only identifier:');
    result = await authRepository.login('   ', 'password123'); // Changed
    _printLoginResult(result, shouldSucceed: false);

    await _shortDelay();

    // Test both empty
    print('2.4 Testing both fields empty:');
    result = await authRepository.login('', ''); // Changed
    _printLoginResult(result, shouldSucceed: false);
  }

  Future<void> _testLoginFlow() async {
    print('\n🔐 PHASE 3: LOGIN FLOW TESTS');
    print('═' * 40);

    // Test with invalid credentials first
    print('3.1 Testing login with invalid credentials:');
    var invalidResult = await authRepository.login(
        'invalid@test.com', 'wrongpassword'); // Changed
    _printLoginResult(invalidResult, shouldSucceed: false);

    await _shortDelay();

    // Test with email identifier
    print('3.2 Testing login with email identifier:');
    var emailResult =
        await authRepository.login('10001', 'password'); // Changed
    bool emailLoginSuccess =
        _printLoginResult(emailResult, shouldSucceed: true);

    await _shortDelay();

    // If email login failed, try with NIP
    if (!emailLoginSuccess) {
      print('3.3 Testing login with NIP identifier:');
      var nipResult =
          await authRepository.login('69', 'password123'); // Changed
      _printLoginResult(nipResult, shouldSucceed: true);
    }

    // Verify token storage after successful login
    await _verifyTokenStorage();
  }

  Future<void> _testPostLoginOperations() async {
    print('\n📊 PHASE 4: POST-LOGIN OPERATIONS');
    print('═' * 40);

    // Test authentication status after login
    print('4.1 Testing authentication status after login:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Is authenticated: ${isAuthenticated ? "✅ Successfully authenticated" : "❌ Not authenticated"}');

    // Test session validity after login
    print('4.2 Testing session validity after login:');
    bool isValidSession = await authRepository.isValidSession(); // Changed
    print(
        '   Session valid: ${isValidSession ? "✅ Valid session" : "❌ Invalid session"}');

    // Test session check after login
    print('4.3 Testing detailed session check:');
    var sessionResult = await authRepository.checkSession(); // Changed
    print(
        '   Session status: ${sessionResult['valid'] ? "✅ Valid" : "❌ Invalid"}');
    print('   Message: ${sessionResult['message']}');
    if (sessionResult['sessionExpired'] == true) {
      print('   ⚠️  Session expired detected');
    }
    if (sessionResult['networkError'] == true) {
      print('   ⚠️  Network error detected');
    }
  }

  Future<void> _testSessionManagement() async {
    print('\n🔄 PHASE 5: SESSION MANAGEMENT TESTS');
    print('═' * 40);

    // Test require authentication (should pass if logged in)
    print('5.1 Testing require authentication:');
    try {
      await authRepository.requireAuthentication(); // Changed
      print('   ✅ Authentication requirement passed');
    } catch (e) {
      print('   ❌ Authentication requirement failed: $e');
    }

    // Test require authentication with custom message
    print('5.2 Testing require authentication with custom message:');
    try {
      await authRepository
          .requireAuthentication('Custom auth message for testing'); // Changed
      print('   ✅ Custom authentication requirement passed');
    } catch (e) {
      print('   ❌ Custom authentication requirement failed: $e');
    }

    // Test auth error detection
    print('5.3 Testing auth error detection:');
    List<String> testMessages = [
      'not authenticated',
      'Session expired',
      'Unauthorized access',
      'token is invalid',
      'regular error message'
    ];

    for (String message in testMessages) {
      bool isAuthError = authRepository.isAuthError(message); // Changed
      String expected = message.contains('regular')
          ? '❌ Not auth error'
          : '✅ Auth error detected';
      print(
          '   "$message": ${isAuthError ? "✅ Auth error" : "❌ Not auth error"} $expected');
    }
  }

  Future<void> _testTokenOperations() async {
    print('\n🎫 PHASE 6: TOKEN OPERATIONS');
    print('═' * 40);

    // Test token refresh
    print('6.1 Testing token refresh:');
    bool refreshSuccess = await authRepository.refreshToken(); // Changed
    print('   Token refresh: ${refreshSuccess ? "✅ Success" : "❌ Failed"}');

    if (refreshSuccess) {
      await _verifyTokenStorage();
    }

    await _shortDelay();

    // Test authentication after token refresh
    print('6.2 Testing authentication after token refresh:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Is authenticated: ${isAuthenticated ? "✅ Still authenticated" : "❌ Lost authentication"}');
  }

  Future<void> _testUserDataOperations() async {
    print('\n👤 PHASE 7: USER DATA OPERATIONS');
    print('═' * 40);

    // Test get user (with cache fallback)
    print('7.1 Testing getUser() with cache fallback:');
    var userResult = await authRepository.getUser(); // Changed
    _printUserResult(userResult, 'getUser');

    await _shortDelay();

    // Test get current user (fresh from API)
    print('7.2 Testing getCurrentUser() from API:');
    var currentUserResult = await authRepository.getCurrentUser(); // Changed
    _printUserResult(currentUserResult, 'getCurrentUser');

    await _shortDelay();

    // Test load user (optimized for app startup)
    print('7.3 Testing loadUser() for app startup:');
    var loadUserResult = await authRepository.loadUser(); // Changed
    _printUserResult(loadUserResult, 'loadUser');
  }

  Future<void> _testErrorHandling() async {
    print('\n⚠️  PHASE 8: ERROR HANDLING TESTS');
    print('═' * 40);

    // Test 401 handling (simulate by calling handle401)
    print('8.1 Testing 401 error handling:');
    try {
      await authRepository.handle401(); // Changed
      print('   ❌ handle401() should have thrown an exception');
    } catch (e) {
      print('   ✅ handle401() correctly threw exception: $e');

      // Verify auth data was cleared
      bool stillAuthenticated =
          await authRepository.isAuthenticated(); // Changed
      print('   Auth data cleared: ${!stillAuthenticated ? "✅ Yes" : "❌ No"}');
    }

    await _shortDelay();

    // Test authentication status after 401 handling
    print('8.2 Testing authentication status after 401:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Is authenticated: ${isAuthenticated ? "❌ Still authenticated" : "✅ Properly logged out"}');
  }

  Future<void> _testLogoutFlow() async {
    print('\n🚪 PHASE 9: LOGOUT FLOW TESTS');
    print('═' * 40);

    // Test logout
    print('9.1 Testing logout:');
    var logoutResult = await authRepository.logout(); // Changed

    if (logoutResult['success']) {
      print('   ✅ Logout successful');
      print('   Message: ${logoutResult['message']}');
      if (logoutResult['warning'] != null) {
        print('   ⚠️  Warning: ${logoutResult['warning']}');
      }
    } else {
      print('   ❌ Logout failed: ${logoutResult['message']}');
    }

    await _shortDelay();

    // Test authentication status after logout
    print('9.2 Testing authentication status after logout:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Is authenticated: ${!isAuthenticated ? "✅ Successfully logged out" : "❌ Still authenticated"}');

    // Test session validity after logout
    print('9.3 Testing session validity after logout:');
    bool isValidSession = await authRepository.isValidSession(); // Changed
    print(
        '   Session valid: ${!isValidSession ? "✅ Session invalidated" : "❌ Session still valid"}');

    // Test user data after logout
    print('9.4 Testing user data after logout:');
    var userResult = await authRepository.getUser(); // Changed
    if (userResult['success']) {
      print('   ❌ User data still exists: ${userResult['user']['name']}');
    } else {
      print('   ✅ User data cleared');
      print('   Message: ${userResult['message']}');
      print('   Requires login: ${userResult['requiresLogin'] ?? false}');
    }

    // Test storage clearing
    await _verifyStorageCleared();
  }

  // Helper methods
  bool _printLoginResult(Map<String, dynamic> result,
      {required bool shouldSucceed}) {
    String status = result['success'] == shouldSucceed ? '✅' : '❌';
    print(
        '   $status ${result['success'] ? 'Success' : 'Failed'}: ${result['message']}');

    if (result['success']) {
      print('   User: ${result['user']?['name'] ?? 'No name'}');
      print('   Email: ${result['user']?['email'] ?? 'No email'}');
      print('   NIP: ${result['user']?['nip'] ?? 'No NIP'}');
      print('   Token length: ${result['token']?.length ?? 0}');
      print('   Expires in: ${result['expires_in'] ?? 'Not specified'}');
      return true;
    } else {
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      return false;
    }
  }

  void _printUserResult(Map<String, dynamic> result, String method) {
    if (result['success']) {
      print('   ✅ $method successful');
      print('   Name: ${result['user']?['name'] ?? 'N/A'}');
      print('   Email: ${result['user']?['email'] ?? 'N/A'}');
      print('   NIP: ${result['user']?['nip'] ?? 'N/A'}');
      print('   Department: ${result['user']?['department'] ?? 'N/A'}');

      if (result['fromCache'] == true) {
        print('   📋 Source: Cache');
      }
      if (result['sessionExpired'] == true) {
        print('   ⚠️  Session expired detected');
      }
    } else {
      print('   ❌ $method failed: ${result['message']}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
    }
  }

  Future<void> _verifyTokenStorage() async {
    print('   🔍 Verifying token storage...');
    final savedToken = await TokenStorage.getToken();
    print('   Token saved: ${savedToken != null ? "✅ Yes" : "❌ No"}');
    if (savedToken != null && savedToken.length > 20) {
      print('   Token preview: ${savedToken.substring(0, 20)}...');
    }
  }

  Future<void> _verifyStorageCleared() async {
    print('9.5 Verifying storage cleared:');

    final token = await TokenStorage.getToken();
    final userData = await UserStorage.getUser();

    print('   Token cleared: ${token == null ? "✅ Yes" : "❌ No"}');
    print('   User data cleared: ${userData == null ? "✅ Yes" : "❌ No"}');
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _shortDelay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    testCompleteAuthFlow();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Auth Repository Test"), // Updated title
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_outlined, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                "Testing Complete Auth Repository Flow", // Updated text
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
              Text("🔍 Phase 1: Initial State"),
              Text("📝 Phase 2: Input Validation"),
              Text("🔐 Phase 3: Login Flow"),
              Text("📊 Phase 4: Post-Login Operations"),
              Text("🔄 Phase 5: Session Management"),
              Text("🎫 Phase 6: Token Operations"),
              Text("👤 Phase 7: User Data Operations"),
              Text("⚠️  Phase 8: Error Handling"),
              Text("🚪 Phase 9: Logout Flow (Optional)"),
            ],
          ),
        ),
      ),
    );
  }
}
