import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/services/leave_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final LeaveService leaveService = LeaveService();

  Future<void> testAllMethods() async {
    print('=== Testing LeaveService ===\n');
    await _delay();

    // Test apply leave
    await _testApplyLeave();

    // Test get my leaves
    await _testGetMyLeaves();

    // Test leave statistics
    await _testLeaveStatistics();

    print('=== All leave tests completed ===');
  }

  Future<void> _testApplyLeave() async {
    print('📝 APPLY LEAVE TESTS');
    print('─' * 30);

    // Test 1: Apply paid leave
    print('1. Testing applyLeave() - Paid leave:');
    final paidLeaveResult = await leaveService.applyLeave(
      type: 'paid',
      startDate: DateTime.now().add(Duration(days: 7)),
      endDate: DateTime.now().add(Duration(days: 9)),
      reason: 'Liburan keluarga',
    );

    if (paidLeaveResult['success']) {
      print('   ✅ Paid leave application successful');
      print('   Message: ${paidLeaveResult['message']}');
      print('   Leave ID: ${paidLeaveResult['leave']['id']}');
    } else {
      print(
          '   ❌ Paid leave application failed: ${paidLeaveResult['message']}');
    }
    await _delay();

    // Test 2: Apply sick leave
    print('2. Testing applyLeave() - Sick leave:');
    final sickLeaveResult = await leaveService.applyLeave(
      type: 'sick',
      startDate: DateTime.now().add(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 2)),
      reason: 'Demam dan flu',
    );

    if (sickLeaveResult['success']) {
      print('   ✅ Sick leave application successful');
      print('   Message: ${sickLeaveResult['message']}');
    } else {
      print(
          '   ❌ Sick leave application failed: ${sickLeaveResult['message']}');
    }
    await _delay();
  }

  Future<void> _testGetMyLeaves() async {
    print('\n📋 GET LEAVES TESTS');
    print('─' * 30);

    // Test 3: Get all my leaves
    print('3. Testing getMyLeaves():');
    final leavesResult = await leaveService.getMyLeaves();

    if (leavesResult['success']) {
      print('   ✅ Leaves retrieved successfully');
      print('   Total leaves: ${leavesResult['total']}');

      if (leavesResult['leaves'].isNotEmpty) {
        final firstLeave = leavesResult['leaves'][0];
        print(
            '   Latest leave: ${firstLeave['type']} (${firstLeave['status']})');
      }
    } else {
      print('   ❌ Failed to get leaves: ${leavesResult['message']}');
    }
    await _delay();

    // Test 4: Get pending leaves
    print('4. Testing getPendingLeaves():');
    final pendingResult = await leaveService.getPendingLeaves();

    if (pendingResult['success']) {
      print('   ✅ Pending leaves: ${pendingResult['total']}');
    } else {
      print('   ❌ Failed to get pending leaves: ${pendingResult['message']}');
    }
    await _delay();
  }

  Future<void> _testLeaveStatistics() async {
    print('\n📊 LEAVE STATISTICS TESTS');
    print('─' * 30);

    // Test 5: Get leave statistics
    print('5. Testing getLeaveStatistics():');
    final statsResult = await leaveService.getLeaveStatistics();

    if (statsResult['success']) {
      print('   ✅ Statistics retrieved successfully');
      final stats = statsResult['statistics'];
      print('   Total: ${stats['total']}');
      print('   Pending: ${stats['pending']}');
      print('   Approved: ${stats['approved']}');
      print('   Rejected: ${stats['rejected']}');
      print('   Paid leaves: ${stats['paid_leaves']}');
      print('   Sick leaves: ${stats['sick_leaves']}');
    } else {
      print('   ❌ Failed to get statistics: ${statsResult['message']}');
    }
    await _delay();
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    testAllMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("LeaveService Test"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.beach_access, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                "Testing LeaveService Methods",
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
              Text("• Apply paid leave"),
              Text("• Apply sick leave"),
              Text("• Get my leaves"),
              Text("• Get pending leaves"),
              Text("• Leave statistics"),
            ],
          ),
        ),
      ),
    );
  }
}
