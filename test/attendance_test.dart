import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/repositories/attendance_repository.dart';
import '../lib/core/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(AttendanceTestApp());
}

class AttendanceTestApp extends StatelessWidget {
  AttendanceTestApp({super.key});

  final AttendanceRepository attendanceRepository = AttendanceRepositoryImpl();
  final AuthRepository authRepository = AuthRepositoryImpl();

  // Test coordinates (Jakarta area)
  static const double validLatitude = -6.2088;
  static const double validLongitude = 106.8456;

  Future<void> testCompleteAttendanceFlow() async {
    print('=== Testing Complete Attendance Repository Flow ===\n');

    await _testPrerequisites();
    await _delay();

    await _testInputValidation();
    await _delay();

    await _testAttendanceStatus();
    await _delay();

    await _testClockInFlow();
    await _delay();

    await _testClockOutFlow();
    await _delay();

    await _testAttendanceHistory();
    await _delay();

    await _testErrorHandling();
    await _delay();

    await _testHelperMethods();
    await _delay();

    await _testGetFullHistory();

    print('\n🎉 === All Attendance Repository tests completed ===');
  }

  Future<void> _testPrerequisites() async {
    print('🔍 PHASE 1: PREREQUISITES & SETUP');
    print('═' * 40);

    print('1.1 Checking authentication status:');
    bool isAuthenticated = await authRepository.isAuthenticated();
    print(
        '   Authentication status: ${isAuthenticated ? "✅ Authenticated" : "❌ Not authenticated"}');

    if (!isAuthenticated) {
      print(
          '   ⚠️  Running limited tests (authentication required for full tests)');
    }

    print('1.2 Checking initial attendance state:');
    try {
      // ✅ Use the correct method name
      var todayResult = await attendanceRepository.getTodayAttendanceStatus();

      print('   Has clocked in: ${todayResult['hasClockedIn'] ?? false}');
      print('   Has clocked out: ${todayResult['hasClockedOut'] ?? false}');
      print('   Clock-in time: ${todayResult['clockInTime'] ?? 'None'}');
      print('   Clock-out time: ${todayResult['clockOutTime'] ?? 'None'}');

      final records = todayResult['records'] ?? [];
      print('   Today\'s records count: ${records.length}');

      if (records.isNotEmpty) {
        print('   Records:');
        for (int i = 0; i < records.length; i++) {
          final record = records[i];
          print('     ${i + 1}. ${record['type']} at ${record['waktu']}');
        }
      } else {
        print('   ✅ No attendance record for today (clean slate)');
      }
    } catch (e) {
      print('   ❌ Failed to get today\'s attendance: $e');
    }
  }

  Future<void> _testInputValidation() async {
    print('\n📝 PHASE 2: INPUT VALIDATION TESTS');
    print('═' * 40);

    print('2.1 Testing coordinate validation:');

    // Test valid coordinates
    var validValidation = attendanceRepository.validateClockInData(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Valid coordinates: ${validValidation['valid'] ? "✅" : "❌"} ${validValidation['message']}');

    // Test invalid latitude
    var invalidLatValidation = attendanceRepository.validateClockInData(
      latitude: 95.0, // Invalid
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Invalid latitude: ${!invalidLatValidation['valid'] ? "✅" : "❌"} ${invalidLatValidation['message']}');

    // Test invalid longitude
    var invalidLngValidation = attendanceRepository.validateClockInData(
      latitude: validLatitude,
      longitude: 185.0, // Invalid
      waktu: DateTime.now(),
    );
    print(
        '   Invalid longitude: ${!invalidLngValidation['valid'] ? "✅" : "❌"} ${invalidLngValidation['message']}');

    await _shortDelay();

    print('2.2 Testing time validation:');

    // Test future time
    var futureValidation = attendanceRepository.validateClockInData(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().add(Duration(hours: 1)),
    );
    print(
        '   Future time: ${!futureValidation['valid'] ? "✅" : "❌"} ${futureValidation['message']}');

    // Test very old time
    var oldValidation = attendanceRepository.validateClockInData(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().subtract(Duration(hours: 25)),
    );
    print(
        '   Old time (25h ago): ${!oldValidation['valid'] ? "✅" : "❌"} ${oldValidation['message']}');
  }

  Future<void> _testAttendanceStatus() async {
    print('\n📊 PHASE 3: ATTENDANCE STATUS');
    print('═' * 40);

    print('3.1 Getting today\'s attendance status:');
    try {
      var statusResult = await attendanceRepository.getTodayAttendanceStatus();

      print('   ✅ Status retrieved successfully');
      print('   Has clocked in: ${statusResult['hasClockedIn'] ?? false}');
      print('   Has clocked out: ${statusResult['hasClockedOut'] ?? false}');
      print('   Clock-in time: ${statusResult['clockInTime'] ?? 'None'}');
      print('   Clock-out time: ${statusResult['clockOutTime'] ?? 'None'}');

      final records = statusResult['records'] ?? [];
      print('   Today\'s records count: ${records.length}');

      if (records.isNotEmpty) {
        print('   Records details:');
        for (final record in records) {
          print('     Type: ${record['type']}, Time: ${record['waktu']}');
        }
      }
    } catch (e) {
      print('   ❌ Failed to get status: $e');
    }
  }

  Future<void> _testClockInFlow() async {
    print('\n🕐 PHASE 4: CLOCK-IN FLOW TESTS');
    print('═' * 40);

    print('4.1 Testing clock-in with invalid coordinates:');
    var invalidResult = await attendanceRepository.clockIn(
      latitude: 95.0, // Invalid latitude
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (!invalidResult['success']) {
      print('   ✅ Invalid coordinates rejected');
      print('   Message: ${invalidResult['message']}');
      print('   Type: ${invalidResult['type']}');
    } else {
      print('   ❌ Invalid coordinates should be rejected');
    }

    await _shortDelay();

    print('4.2 Testing clock-in with future time:');
    var futureResult = await attendanceRepository.clockIn(
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

    print('4.3 Testing valid clock-in:');
    var clockInResult = await attendanceRepository.clockIn(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (clockInResult['success']) {
      print('   ✅ Clock-in successful');
      print('   Time: ${clockInResult['clockInTime']}');
      if (clockInResult['attendance'] != null) {
        final attendance = clockInResult['attendance'];
        print('   Attendance ID: ${attendance['id'] ?? 'N/A'}');
      }
    } else {
      print('   ${_getStatusIcon(clockInResult)} ${clockInResult['message']}');
      if (clockInResult['alreadyClockedIn'] == true) {
        print('   ℹ️  Already clocked in today');
      }
      if (clockInResult['requiresLogin'] == true) {
        print('   🔐 Authentication required');
      }
    }

    await _shortDelay();

    print('4.4 Testing duplicate clock-in:');
    var duplicateResult = await attendanceRepository.clockIn(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (!duplicateResult['success'] &&
        (duplicateResult['alreadyClockedIn'] == true ||
            duplicateResult['type'] == 'business_rule')) {
      print('   ✅ Duplicate clock-in correctly prevented');
      print('   Message: ${duplicateResult['message']}');
    } else {
      print('   ⚠️  Clock-in result: ${duplicateResult['message']}');
    }
  }

  Future<void> _testClockOutFlow() async {
    print('\n🕕 PHASE 5: CLOCK-OUT FLOW TESTS');
    print('═' * 40);

    print('5.1 Checking current attendance status:');
    var todayStatus = await attendanceRepository.getTodayAttendanceStatus();

    bool hasClockIn = todayStatus['hasClockedIn'] ?? false;
    bool hasClockOut = todayStatus['hasClockedOut'] ?? false;

    print('   Has clocked in: ${hasClockIn ? "✅ Yes" : "❌ No"}');
    print('   Has clocked out: ${hasClockOut ? "✅ Yes" : "❌ No"}');

    await _shortDelay();

    print('5.2 Testing clock-out:');
    var clockOutResult = await attendanceRepository.clockOut(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );

    if (clockOutResult['success']) {
      print('   ✅ Clock-out successful');
      print('   Time: ${clockOutResult['clockOutTime']}');

      if (clockOutResult['workDuration'] != null) {
        final duration = clockOutResult['workDuration'];
        print('   Work duration: ${duration['formatted']}');
      }
    } else {
      print(
          '   ${_getStatusIcon(clockOutResult)} ${clockOutResult['message']}');

      if (clockOutResult['needsClockIn'] == true) {
        print('   ℹ️  Must clock in first');
      }
      if (clockOutResult['alreadyClockedOut'] == true) {
        print('   ℹ️  Already clocked out today');
      }
      if (clockOutResult['requiresLogin'] == true) {
        print('   🔐 Authentication required');
      }
    }

    await _shortDelay();

    if (clockOutResult['success']) {
      print('5.3 Testing duplicate clock-out:');
      var duplicateResult = await attendanceRepository.clockOut(
        latitude: validLatitude,
        longitude: validLongitude,
        waktu: DateTime.now(),
      );

      if (!duplicateResult['success'] &&
          (duplicateResult['alreadyClockedOut'] == true ||
              duplicateResult['type'] == 'business_rule')) {
        print('   ✅ Duplicate clock-out correctly prevented');
      } else {
        print('   ❌ Duplicate should be prevented');
      }
    }

    await _shortDelay();

    print('5.4 Final status check:');
    var finalStatus = await attendanceRepository.getTodayAttendanceStatus();
    print('   Final clocked in: ${finalStatus['hasClockedIn'] ?? false}');
    print('   Final clocked out: ${finalStatus['hasClockedOut'] ?? false}');
  }

  Future<void> _testAttendanceHistory() async {
    print('\n📊 PHASE 6: ATTENDANCE HISTORY');
    print('═' * 40);

    print('6.1 Testing attendance history retrieval:');
    try {
      var historyResult =
          await attendanceRepository.getAttendanceHistory(limit: 5);

      if (historyResult['success']) {
        print('   ✅ History retrieved successfully');
        print('   Records count: ${historyResult['count'] ?? 0}');

        final records = historyResult['records'] ?? [];
        if (records.isNotEmpty) {
          print('   Recent records:');
          for (int i = 0; i < records.length && i < 3; i++) {
            final record = records[i];
            print('     ${i + 1}. ${record['type']} at ${record['waktu']}');
          }
        }
      } else {
        print('   ❌ Failed to get history: ${historyResult['message']}');
      }
    } catch (e) {
      print('   ❌ Exception getting history: $e');
    }

    await _shortDelay();

    print('6.2 Testing history with date range:');
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 7));

      var rangeResult = await attendanceRepository.getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (rangeResult['success']) {
        print('   ✅ Date range query successful');
        print('   Records in last 7 days: ${rangeResult['count'] ?? 0}');
      } else {
        print('   ❌ Date range query failed: ${rangeResult['message']}');
      }
    } catch (e) {
      print('   ❌ Exception in date range query: $e');
    }
  }

  Future<void> _testErrorHandling() async {
    print('\n⚠️  PHASE 7: ERROR HANDLING');
    print('═' * 40);

    print('7.1 Testing extreme coordinate values:');
    var extremeResult = await attendanceRepository.clockIn(
      latitude: 999.0,
      longitude: -999.0,
      waktu: DateTime.now(),
    );

    if (!extremeResult['success']) {
      print('   ✅ Extreme coordinates handled gracefully');
      print('   Message: ${extremeResult['message']}');
      print('   Type: ${extremeResult['type'] ?? 'Unknown'}');
    }

    await _shortDelay();

    print('7.2 Testing very old timestamp:');
    var oldTimeResult = await attendanceRepository.clockIn(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now().subtract(Duration(days: 2)),
    );

    if (!oldTimeResult['success']) {
      print('   ✅ Old timestamp handled gracefully');
      print('   Message: ${oldTimeResult['message']}');
    }

    await _shortDelay();

    print('7.3 Testing error response structure:');
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
    print('\n🛠️  PHASE 8: HELPER METHODS');
    print('═' * 40);

    print('8.1 Testing validation helpers:');

    // Valid data
    var validValidation = attendanceRepository.validateClockInData(
      latitude: validLatitude,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Valid clock-in data: ${validValidation['valid'] ? "✅" : "❌"} ${validValidation['message']}');

    // Invalid data
    var invalidValidation = attendanceRepository.validateClockOutData(
      latitude: 999.0,
      longitude: validLongitude,
      waktu: DateTime.now(),
    );
    print(
        '   Invalid clock-out data: ${!invalidValidation['valid'] ? "✅" : "❌"} ${invalidValidation['message']}');

    await _shortDelay();

    print('8.2 Testing duration formatting:');
    Map<int, String> expectedFormats = {
      0: '0h 0m',
      45: '0h 45m',
      60: '1h 0m',
      125: '2h 5m',
      480: '8h 0m',
    };

    bool allFormatCorrect = true;
    expectedFormats.forEach((minutes, expected) {
      String actual = attendanceRepository.formatWorkDuration(minutes);
      bool correct = actual == expected;
      if (!correct) allFormatCorrect = false;
      print(
          '   ${minutes}min → $actual ${correct ? "✅" : "❌ (expected: $expected)"}');
    });

    print(
        '   Overall formatting: ${allFormatCorrect ? "✅ All correct" : "❌ Some incorrect"}');
  }

  Future<void> _testGetFullHistory() async {
    print('\n📚 TESTING: Get Full Attendance History');
    print('═' * 40);

    print('Getting ALL attendance records (no filters):');
    try {
      var fullHistoryResult = await attendanceRepository.getAttendanceHistory();

      if (fullHistoryResult['success']) {
        print('   ✅ Full history retrieved successfully');
        print('   Total records: ${fullHistoryResult['count'] ?? 0}');

        final records = fullHistoryResult['records'] ?? [];
        final attendance = fullHistoryResult['attendance'] ?? [];

        print('   Records array length: ${records.length}');
        print('   Attendance array length: ${attendance.length}');

        if (records.isNotEmpty) {
          print('   First 3 records:');
          for (int i = 0; i < records.length && i < 3; i++) {
            final record = records[i];
            print(
                '     ${i + 1}. ID: ${record['id']}, Type: ${record['type']}, Time: ${record['waktu']}');
          }
        } else {
          print('   ⚠️  No records found in history');
        }

        // Test statistics
        final stats = fullHistoryResult['statistics'];
        if (stats != null) {
          print('   Statistics:');
          print('     Total days: ${stats['totalDays']}');
          print('     Present days: ${stats['presentDays']}');
          print('     On-time days: ${stats['onTimeDays']}');
          print('     Late days: ${stats['lateDays']}');
          print(
              '     Average work hours: ${stats['averageWorkHours']?.toStringAsFixed(1)}h');
        }
      } else {
        print('   ❌ Failed to get history: ${fullHistoryResult['message']}');
      }
    } catch (e) {
      print('   ❌ Exception getting full history: $e');
    }

    await _shortDelay();

    print('Getting last 3 records only:');
    try {
      var limitedResult =
          await attendanceRepository.getAttendanceHistory(limit: 3);

      if (limitedResult['success']) {
        print('   ✅ Limited history retrieved');
        print('   Records with limit=3: ${limitedResult['count']}');

        final records = limitedResult['records'] ?? [];
        for (int i = 0; i < records.length; i++) {
          final record = records[i];
          print('     ${i + 1}. ${record['type']} at ${record['waktu']}');
        }
      } else {
        print('   ❌ Failed limited query: ${limitedResult['message']}');
      }
    } catch (e) {
      print('   ❌ Exception in limited query: $e');
    }
  }

  // Helper methods
  String _getStatusIcon(Map<String, dynamic> result) {
    if (result['success'] == true) return '✅';
    if (result['requiresLogin'] == true) return '🔐';
    if (result['type'] == 'validation') return '⚠️';
    if (result['type'] == 'business_rule') return 'ℹ️';
    if (result['type'] == 'network') return '🌐';
    return '❌';
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> _shortDelay() async {
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    // Start test automatically
    Future.delayed(Duration(milliseconds: 500), () {
      testCompleteAttendanceFlow();
    });

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Attendance Repository Test"),
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
                "Testing Complete Attendance Repository Flow",
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
              Text("📊 Phase 3: Attendance Status"),
              Text("🕐 Phase 4: Clock-in Flow"),
              Text("🕕 Phase 5: Clock-out Flow"),
              Text("📊 Phase 6: Attendance History"),
              Text("⚠️  Phase 7: Error Handling"),
              Text("🛠️  Phase 8: Helper Methods"),
              SizedBox(height: 16),
              Text(
                "Updated to use correct repository methods",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
