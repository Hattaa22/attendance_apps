import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/repositories/attendance_repository.dart'; // Changed import
import '../lib/core/data/repositories/auth_repository.dart'; // Changed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(AttendanceTestApp());
}

class AttendanceTestApp extends StatelessWidget {
  AttendanceTestApp({super.key});

  final AttendanceRepository attendanceRepository =
      AttendanceRepositoryImpl(); // Changed to Repository
  final AuthRepository authRepository =
      AuthRepositoryImpl(); // Changed to Repository

  // Test coordinates (Jakarta area)
  static const double validLatitude = -6.2088;
  static const double validLongitude = 106.8456;

  Future<void> testCompleteAttendanceFlow() async {
    print(
        '=== Testing Complete Attendance Repository Flow ===\n'); // Updated message

    // Phase 1: Prerequisites and authentication
    await _testPrerequisites();
    await _delay();

    // Phase 2: Input validation tests
    await _testInputValidation();
    await _delay();

    // Phase 3: Authentication requirements
    await _testAuthenticationRequirements();
    await _delay();

    // Phase 4: Clock-in flow and edge cases
    await _testClockInFlow();
    await _delay();

    // Phase 5: Clock-out flow and edge cases
    await _testClockOutFlow();
    await _delay();

    // Phase 6: Attendance history and data retrieval
    await _testAttendanceDataRetrieval();
    await _delay();

    // Phase 7: Business logic validation
    await _testBusinessLogicValidation();
    await _delay();

    // Phase 8: Error handling scenarios
    await _testErrorHandling();
    await _delay();

    // Phase 9: Helper methods and utilities
    await _testHelperMethods();

    print(
        '\n🎉 === All Attendance Repository tests completed ==='); // Updated message
  }

  Future<void> _testPrerequisites() async {
    print('🔍 PHASE 1: PREREQUISITES & SETUP');
    print('═' * 40);

    // Check authentication status
    print('1.1 Checking authentication status:');
    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed
    print(
        '   Authentication status: ${isAuthenticated ? "✅ Authenticated" : "❌ Not authenticated"}');

    if (!isAuthenticated) {
      print(
          '   ⚠️  Running limited tests (authentication required for full tests)');
    }

    // Test initial attendance state
    print('1.2 Checking initial attendance state:');
    var todayResult =
        await attendanceRepository.getTodayAttendance(); // Changed
    if (todayResult['success']) {
      final attendance = todayResult['attendance'];
      if (attendance != null) {
        print('   📋 Today\'s attendance exists:');
        print('   Clock-in: ${attendance['clock_in'] ?? 'Not clocked in'}');
        print('   Clock-out: ${attendance['clock_out'] ?? 'Not clocked out'}');
        print('   Status: ${todayResult['status']}');
      } else {
        print('   ✅ No attendance record for today (clean slate)');
      }
    } else {
      print(
          '   ❌ Failed to get today\'s attendance: ${todayResult['message']}');
      print('   Requires login: ${todayResult['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testInputValidation() async {
    print('\n📝 PHASE 2: INPUT VALIDATION TESTS');
    print('═' * 40);

    // Test coordinate validation helper
    print('2.1 Testing coordinate validation helper:');
    List<Map<String, dynamic>> testCoordinates = [
      {
        'lat': validLatitude,
        'lng': validLongitude,
        'valid': true,
        'desc': 'Valid Jakarta coordinates'
      },
      {
        'lat': 91.0,
        'lng': validLongitude,
        'valid': false,
        'desc': 'Invalid latitude (>90)'
      },
      {
        'lat': -91.0,
        'lng': validLongitude,
        'valid': false,
        'desc': 'Invalid latitude (<-90)'
      },
      {
        'lat': validLatitude,
        'lng': 181.0,
        'valid': false,
        'desc': 'Invalid longitude (>180)'
      },
      {
        'lat': validLatitude,
        'lng': -181.0,
        'valid': false,
        'desc': 'Invalid longitude (<-180)'
      },
      {
        'lat': null,
        'lng': validLongitude,
        'valid': false,
        'desc': 'Null latitude'
      },
      {
        'lat': validLatitude,
        'lng': null,
        'valid': false,
        'desc': 'Null longitude'
      },
    ];

    await _shortDelay();

    // Test validation methods
    print('2.2 Testing clock-in data validation:');
    var validation = attendanceRepository.validateClockInData(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Valid coordinates: ${validation['valid'] ? "✅" : "❌"} ${validation['message']}');

    // Test invalid time (future)
    var futureValidation = attendanceRepository.validateClockInData(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().add(Duration(hours: 1)),
    );
    print(
        '   Future time: ${!futureValidation['valid'] ? "✅" : "❌"} ${futureValidation['message']}');

    // Test very old time
    var oldValidation = attendanceRepository.validateClockInData(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().subtract(Duration(hours: 25)),
    );
    print(
        '   Old time (25h ago): ${!oldValidation['valid'] ? "✅" : "❌"} ${oldValidation['message']}');
  }

  Future<void> _testAuthenticationRequirements() async {
    print('\n🔐 PHASE 3: AUTHENTICATION REQUIREMENTS');
    print('═' * 40);

    bool isAuthenticated = await authRepository.isAuthenticated(); // Changed

    if (!isAuthenticated) {
      print('3.1 Testing clock-in without authentication:');
      var result = await attendanceRepository.clockIn(
        // Changed
        latitude: validLatitude,
        longitude: validLongitude,
        waktu: DateTime.now(),
      );

      if (!result['success'] && result['requiresLogin'] == true) {
        print('   ✅ Clock-in correctly requires authentication');
        print('   Message: ${result['message']}');
      } else {
        print('   ❌ Clock-in should require authentication');
      }

      await _shortDelay();

      print('3.2 Testing other methods without authentication:');

      var historyResult =
          await attendanceRepository.getAttendanceHistory(); // Changed
      print(
          '   History requires auth: ${!historyResult['success'] && historyResult['requiresLogin'] == true ? "✅" : "❌"}');

      var statusResult =
          await attendanceRepository.getAttendanceStatus(); // Changed
      print(
          '   Status requires auth: ${!statusResult['success'] && statusResult['requiresLogin'] == true ? "✅" : "❌"}');

      print('\n   ⚠️  Skipping authenticated tests (please login first)');
      return;
    }

    print('3.1 ✅ User is authenticated - proceeding with full tests');
  }

  Future<void> _testClockInFlow() async {
    print('\n🕐 PHASE 4: CLOCK-IN FLOW TESTS');
    print('═' * 40);

    // Test invalid coordinates first
    print('4.1 Testing clock-in with invalid coordinates:');
    var invalidResult = await attendanceRepository.clockIn(
      // Changed
      latitude: 95.0, // Invalid latitude
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (!invalidResult['success']) {
      print('   ✅ Invalid coordinates rejected');
      print('   Message: ${invalidResult['message']}');
    } else {
      print('   ❌ Invalid coordinates should be rejected');
    }

    await _shortDelay();

    // Test clock-in with future time
    print('4.2 Testing clock-in with future time:');
    var futureResult = await attendanceRepository.clockIn(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().add(Duration(hours: 1)),
    );

    if (!futureResult['success']) {
      print('   ✅ Future time rejected');
      print('   Message: ${futureResult['message']}');
    } else {
      print('   ❌ Future time should be rejected');
    }

    await _shortDelay();

    // Test valid clock-in
    print('4.3 Testing valid clock-in:');
    var clockInResult = await attendanceRepository.clockIn(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    _printAttendanceResult(clockInResult, 'Clock-in', shouldSucceed: true);

    if (clockInResult['success']) {
      print('   Clock-in time: ${clockInResult['clockInTime']}');
      if (clockInResult['attendance'] != null) {
        final attendance = clockInResult['attendance'];
        print('   Attendance ID: ${attendance['id'] ?? 'N/A'}');
        print(
            '   Location: ${attendance['latitude']}, ${attendance['longitude']}');
      }
    }

    await _shortDelay();

    // Test duplicate clock-in
    print('4.4 Testing duplicate clock-in (should fail):');
    var duplicateResult = await attendanceRepository.clockIn(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (!duplicateResult['success'] &&
        duplicateResult['alreadyClockedIn'] == true) {
      print('   ✅ Duplicate clock-in correctly prevented');
      print('   Message: ${duplicateResult['message']}');
      print('   Original clock-in time: ${duplicateResult['clockInTime']}');
    } else {
      print('   ❌ Duplicate clock-in should be prevented');
    }
  }

  Future<void> _testClockOutFlow() async {
    print('\n🕕 PHASE 5: CLOCK-OUT FLOW TESTS');
    print('═' * 40);

    // First check if there's an active clock-in
    print('5.1 Checking current attendance status:');
    var todayResult =
        await attendanceRepository.getTodayAttendance(); // Changed

    bool hasActiveClockin = false;
    if (todayResult['success'] && todayResult['attendance'] != null) {
      final attendance = todayResult['attendance'];
      hasActiveClockin =
          attendance['clock_in'] != null && attendance['clock_out'] == null;
      print('   Has active clock-in: ${hasActiveClockin ? "✅ Yes" : "❌ No"}');

      if (attendance['clock_in'] != null) {
        print('   Clock-in time: ${attendance['clock_in']}');
      }
      if (attendance['clock_out'] != null) {
        print('   Clock-out time: ${attendance['clock_out']}');
      }
    }

    await _shortDelay();

    if (!hasActiveClockin) {
      print('5.2 Testing clock-out without active clock-in:');
      var clockOutResult = await attendanceRepository.clockOut(
        // Changed
        latitude: validLatitude,
        longitude: validLongitude,
        waktu: DateTime.now(),
      );

      if (!clockOutResult['success'] &&
          clockOutResult['needsClockIn'] == true) {
        print('   ✅ Clock-out correctly requires active clock-in');
        print('   Message: ${clockOutResult['message']}');
      } else {
        print('   ❌ Clock-out should require active clock-in');
      }
      return;
    }

    // Test valid clock-out
    print('5.2 Testing valid clock-out:');
    var clockOutResult = await attendanceRepository.clockOut(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    _printAttendanceResult(clockOutResult, 'Clock-out', shouldSucceed: true);

    if (clockOutResult['success']) {
      print('   Clock-out time: ${clockOutResult['clockOutTime']}');
      if (clockOutResult['workDuration'] != null) {
        final duration = clockOutResult['workDuration'];
        print(
            '   Work duration: ${duration['formatted']} (${duration['totalMinutes']} minutes)');
      }
    }

    await _shortDelay();

    // Test duplicate clock-out
    print('5.3 Testing duplicate clock-out (should fail):');
    var duplicateResult = await attendanceRepository.clockOut(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (!duplicateResult['success'] &&
        duplicateResult['alreadyClockedOut'] == true) {
      print('   ✅ Duplicate clock-out correctly prevented');
      print('   Message: ${duplicateResult['message']}');
      if (duplicateResult['clockOutTime'] != null) {
        print('   Original clock-out time: ${duplicateResult['clockOutTime']}');
      }
    } else {
      print('   ❌ Duplicate clock-out should be prevented');
    }
  }

  Future<void> _testAttendanceDataRetrieval() async {
    print('\n📊 PHASE 6: ATTENDANCE DATA RETRIEVAL');
    print('═' * 40);

    // Test today's attendance
    print('6.1 Testing today\'s attendance retrieval:');
    var todayResult =
        await attendanceRepository.getTodayAttendance(); // Changed

    if (todayResult['success']) {
      print('   ✅ Today\'s attendance retrieved successfully');
      print('   Has clocked in: ${todayResult['hasClockedIn'] ?? false}');
      print('   Has clocked out: ${todayResult['hasClockedOut'] ?? false}');
      print('   Status: ${todayResult['status']}');

      if (todayResult['attendance'] != null) {
        final attendance = todayResult['attendance'];
        print('   Clock-in: ${attendance['clock_in'] ?? 'Not clocked in'}');
        print('   Clock-out: ${attendance['clock_out'] ?? 'Not clocked out'}');
      }
    } else {
      print(
          '   ❌ Failed to get today\'s attendance: ${todayResult['message']}');
    }

    await _shortDelay();

    // Test attendance history
    print('6.2 Testing attendance history retrieval:');
    var historyResult =
        await attendanceRepository.getAttendanceHistory(limit: 5); // Changed

    if (historyResult['success']) {
      print('   ✅ Attendance history retrieved successfully');
      print('   Records count: ${historyResult['count']}');

      if (historyResult['statistics'] != null) {
        final stats = historyResult['statistics'];
        print('   Statistics:');
        print('     Total days: ${stats['totalDays']}');
        print('     Present days: ${stats['presentDays']}');
        print('     On-time days: ${stats['onTimeDays']}');
        print('     Late days: ${stats['lateDays']}');
        print(
            '     Average work hours: ${stats['averageWorkHours']?.toStringAsFixed(2)}');
        print(
            '     Attendance rate: ${stats['attendanceRate']?.toStringAsFixed(1)}%');
      }
    } else {
      print(
          '   ❌ Failed to get attendance history: ${historyResult['message']}');
    }

    await _shortDelay();

    // Test attendance history with date range
    print('6.3 Testing attendance history with date range:');
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 7));

    var rangeResult = await attendanceRepository.getAttendanceHistory(
      // Changed
      startDate: startDate,
      endDate: endDate,
    );

    if (rangeResult['success']) {
      print('   ✅ Date range query successful');
      print('   Records in last 7 days: ${rangeResult['count']}');
    } else {
      print('   ❌ Date range query failed: ${rangeResult['message']}');
    }

    await _shortDelay();

    // Test attendance status
    print('6.4 Testing attendance status:');
    var statusResult =
        await attendanceRepository.getAttendanceStatus(); // Changed

    if (statusResult['success']) {
      print('   ✅ Attendance status retrieved successfully');
      if (statusResult['status'] != null) {
        final status = statusResult['status'];
        print('   Status data: ${status.keys.join(', ')}');
      }
    } else {
      print('   ❌ Failed to get attendance status: ${statusResult['message']}');
    }
  }

  Future<void> _testBusinessLogicValidation() async {
    print('\n🧠 PHASE 7: BUSINESS LOGIC VALIDATION');
    print('═' * 40);

    // Test date range validation
    print('7.1 Testing date range validation:');
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    var invalidRangeResult = await attendanceRepository.getAttendanceHistory(
      // Changed
      startDate: tomorrow,
      endDate: today,
    );

    if (!invalidRangeResult['success']) {
      print('   ✅ Invalid date range correctly rejected');
      print('   Message: ${invalidRangeResult['message']}');
    } else {
      print('   ❌ Invalid date range should be rejected');
    }

    await _shortDelay();

    // Test coordinate validation edge cases
    print('7.2 Testing coordinate edge cases:');
    List<Map<String, dynamic>> edgeCases = [
      {
        'lat': 90.0,
        'lng': 180.0,
        'valid': true,
        'desc': 'Maximum valid coordinates'
      },
      {
        'lat': -90.0,
        'lng': -180.0,
        'valid': true,
        'desc': 'Minimum valid coordinates'
      },
      {'lat': 0.0, 'lng': 0.0, 'valid': true, 'desc': 'Zero coordinates'},
    ];
    await _shortDelay();

    // Test work duration formatting
    print('7.3 Testing work duration formatting:');
    List<int> testMinutes = [
      0,
      30,
      60,
      90,
      480,
      540
    ]; // 0min, 30min, 1h, 1.5h, 8h, 9h

    for (int minutes in testMinutes) {
      String formatted =
          attendanceRepository.formatWorkDuration(minutes); // Changed
      print('   ${minutes} minutes → $formatted');
    }
  }

  Future<void> _testErrorHandling() async {
    print('\n⚠️  PHASE 8: ERROR HANDLING SCENARIOS');
    print('═' * 40);

    // Test extreme coordinate values
    print('8.1 Testing extreme coordinate values:');
    var extremeResult = await attendanceRepository.clockIn(
      // Changed
      latitude: 999.0,
      longitude: -999.0,
      waktu: DateTime.now(),
    );

    if (!extremeResult['success']) {
      print('   ✅ Extreme coordinates handled gracefully');
      print('   Message: ${extremeResult['message']}');
      print('   Error type: ${extremeResult['type'] ?? 'Unknown'}');
    }

    await _shortDelay();

    // Test very old timestamp
    print('8.2 Testing very old timestamp:');
    var oldTimeResult = await attendanceRepository.clockIn(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().subtract(Duration(days: 2)),
    );

    if (!oldTimeResult['success']) {
      print('   ✅ Old timestamp handled gracefully');
      print('   Message: ${oldTimeResult['message']}');
    }

    await _shortDelay();

    // Test various error response types
    print('8.3 Testing error response structure:');
    List<Map<String, dynamic>> errorTests = [extremeResult, oldTimeResult];

    for (var result in errorTests) {
      if (!result['success']) {
        print('   Error response contains:');
        print('     success: ${result.containsKey('success')}');
        print('     message: ${result.containsKey('message')}');
        print('     requiresLogin: ${result.containsKey('requiresLogin')}');
        print('     type: ${result.containsKey('type')}');
        break;
      }
    }
  }

  Future<void> _testHelperMethods() async {
    print('\n🛠️  PHASE 9: HELPER METHODS & UTILITIES');
    print('═' * 40);

    // Test validation helpers
    print('9.1 Testing validation helpers:');

    // Valid data
    var validValidation = attendanceRepository.validateClockInData(
      // Changed
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Valid data: ${validValidation['valid'] ? "✅" : "❌"} ${validValidation['message']}');

    // Invalid data
    var invalidValidation = attendanceRepository.validateClockOutData(
      // Changed
      latitude: 999.0,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Invalid data: ${!invalidValidation['valid'] ? "✅" : "❌"} ${invalidValidation['message']}');

    await _shortDelay();

    // Test duration formatting
    print('9.3 Testing duration formatting utility:');
    Map<int, String> expectedFormats = {
      0: '0h 0m',
      45: '0h 45m',
      60: '1h 0m',
      125: '2h 5m',
      480: '8h 0m',
    };

    bool allFormatCorrect = true;
    expectedFormats.forEach((minutes, expected) {
      String actual =
          attendanceRepository.formatWorkDuration(minutes); // Changed
      bool correct = actual == expected;
      if (!correct) allFormatCorrect = false;
      print(
          '   ${minutes}min → $actual ${correct ? "✅" : "❌ (expected: $expected)"}');
    });

    print(
        '   Overall formatting: ${allFormatCorrect ? "✅ All correct" : "❌ Some incorrect"}');
  }

  // Helper methods stay the same
  void _printAttendanceResult(Map<String, dynamic> result, String operation,
      {required bool shouldSucceed}) {
    String status = result['success'] == shouldSucceed ? '✅' : '❌';
    print(
        '   $status $operation ${result['success'] ? 'successful' : 'failed'}: ${result['message']}');

    if (!result['success']) {
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');

      if (result['sessionExpired'] == true) {
        print('   ⚠️  Session expired detected');
      }
      if (result['retryable'] == true) {
        print('   🔄 Operation is retryable');
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
    testCompleteAttendanceFlow();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
              "Complete Attendance Repository Test"), // Updated title
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_outlined, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "Testing Complete Attendance Repository Flow", // Updated text
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
              Text("🔍 Phase 1: Prerequisites & Setup"),
              Text("📝 Phase 2: Input Validation"),
              Text("🔐 Phase 3: Authentication Requirements"),
              Text("🕐 Phase 4: Clock-in Flow"),
              Text("🕕 Phase 5: Clock-out Flow"),
              Text("📊 Phase 6: Data Retrieval"),
              Text("🧠 Phase 7: Business Logic"),
              Text("⚠️  Phase 8: Error Handling"),
              Text("🛠️  Phase 9: Helper Methods"),
            ],
          ),
        ),
      ),
    );
  }
}
