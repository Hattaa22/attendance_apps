import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/services/attendance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AttendanceService attendanceService = AttendanceService();

  Future<void> testAllMethods() async {
    print('=== Testing AttendanceService ===\n');
    await _delay();

    // Test clock-out WITHOUT clock-in first
    await _testClockOutWithoutClockIn();

    // Then test clock-in
    await _testClockIn();

    // Then test clock-out WITH active clock-in
    await _testClockOut();

    print('=== All tests completed ===');
  }

  Future<void> _testClockOutWithoutClockIn() async {
    print('🚫 CLOCK-OUT WITHOUT CLOCK-IN TEST');
    print('─' * 35);

    // Test 1: Clock-out without active clock-in (should fail)
    print('1. Testing clockOut() without active clock-in:');
    final clockOutResult = await attendanceService.clockOut(
      latitude: -6.2088,
      longitude: 106.8456,
      waktu: DateTime.now(),
    );

    if (clockOutResult['success']) {
      print('   ⚠️  Clock-out successful (unexpected)');
      print('   Message: ${clockOutResult['message']}');
    } else {
      print('   ✅ Clock-out failed as expected');
      print('   Message: ${clockOutResult['message']}');
    }
    await _delay();
  }

  Future<void> _testClockIn() async {
    print('\n🕐 CLOCK-IN TESTS');
    print('─' * 30);

    // Test 2: Valid clock-in
    print('2. Testing clockIn() with valid location:');
    final clockInResult = await attendanceService.clockIn(
      latitude: -6.2088,
      longitude: 106.8456,
      waktu: DateTime.now(),
    );

    if (clockInResult['success']) {
      print('   ✅ Clock-in successful');
      print('   Message: ${clockInResult['message']}');
      print('   Status: ${clockInResult['attendance']['status']}');
    } else {
      print('   ❌ Clock-in failed: ${clockInResult['message']}');
    }
    await _delay();
  }

  Future<void> _testClockOut() async {
    print('\n🕕 CLOCK-OUT TESTS');
    print('─' * 30);

    // Test 3: Valid clock-out (after clock-in)
    print('3. Testing clockOut() with active clock-in:');
    final clockOutResult = await attendanceService.clockOut(
      latitude: -6.2088,
      longitude: 106.8456,
      waktu: DateTime.now(),
    );

    if (clockOutResult['success']) {
      print('   ✅ Clock-out successful');
      print('   Message: ${clockOutResult['message']}');
      print('   Status: ${clockOutResult['attendance']['status']}');
    } else {
      print('   ❌ Clock-out failed: ${clockOutResult['message']}');
    }
    await _delay();

    // Test 4: Try clock-out again (should fail - already clocked out)
    print('4. Testing clockOut() when already clocked out:');
    final clockOutResult2 = await attendanceService.clockOut(
      latitude: -6.2088,
      longitude: 106.8456,
      waktu: DateTime.now(),
    );

    if (clockOutResult2['success']) {
      print('   ⚠️  Clock-out successful (unexpected - already clocked out)');
    } else {
      print('   ✅ Clock-out failed as expected (already clocked out)');
      print('   Message: ${clockOutResult2['message']}');
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
          title: const Text("AttendanceService Test"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                "Testing AttendanceService Methods",
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
              Text("• Clock-in functionality"),
              Text("• Clock-out functionality"),
              Text("• Attendance history"),
              Text("• Today's attendance"),
              Text("• Attendance summary"),
              Text("• Location eligibility"),
            ],
          ),
        ),
      ),
    );
  }
}
