import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/repositories/leave_repository.dart'; // Changed import
import '../lib/core/data/repositories/auth_repository.dart'; // Changed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(LeaveTestApp());
}

class LeaveTestApp extends StatelessWidget {
  LeaveTestApp({super.key});

  final LeaveRepository leaveRepository =
      LeaveRepositoryImpl(); // Changed to Repository
  final AuthRepository authRepository =
      AuthRepositoryImpl(); // Changed to Repository

  Future<void> testAllMethods() async {
    print('=== Testing LeaveRepository ===\n'); // Updated message

    // Phase 1: Prerequisites and authentication
    await _testPrerequisites();
    await _delay();

    // Phase 2: Leave application validation
    await _testLeaveValidation();
    await _delay();

    // Phase 3: Apply leave tests
    await _testApplyLeave();
    await _delay();

    // Phase 4: Retrieve leaves
    await _testGetMyLeaves();
    await _delay();

    // Phase 5: Leave history and filtering
    await _testLeaveHistory();
    await _delay();

    // Phase 6: Leave by status
    await _testLeavesByStatus();
    await _delay();

    // Phase 7: Leave balance
    await _testLeaveBalance();
    await _delay();

    // Phase 8: Leave statistics
    await _testLeaveStatistics();
    await _delay();

    // Phase 9: Cancel leave
    await _testCancelLeave();
    await _delay();

    // Phase 10: Helper methods and validation
    await _testHelperMethods();

    print(
        '\n🎉 === All leave repository tests completed ==='); // Updated message
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

  Future<void> _testLeaveValidation() async {
    print('\n✅ PHASE 2: LEAVE APPLICATION VALIDATION');
    print('═' * 40);

    // Test valid leave application
    print('2.1 Testing valid leave application:');
    var validResult = await leaveRepository.validateLeaveApplication(
      // Changed
      type: 'paid',
      startDate: DateTime.now().add(Duration(days: 7)),
      endDate: DateTime.now().add(Duration(days: 9)),
      reason: 'Family vacation - well planned trip',
    );

    if (validResult['success']) {
      print('   ✅ Valid leave application passed validation');
      print('   Message: ${validResult['message']}');
      if (validResult['validation'] != null) {
        final validation = validResult['validation'];
        print(
            '   Duration: ${validation['duration']['working_days']} working days');
        print('   Starts in: ${validation['starts_in_days']} days');
      }
    } else {
      print(
          '   ❌ Valid application failed validation: ${validResult['message']}');
    }

    await _shortDelay();

    // Test invalid leave type
    print('2.2 Testing invalid leave type:');
    var invalidTypeResult = await leaveRepository.validateLeaveApplication(
      // Changed
      type: 'invalid_type',
      startDate: DateTime.now().add(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 2)),
      reason: 'Test reason',
    );

    if (!invalidTypeResult['success']) {
      print('   ✅ Invalid leave type correctly rejected');
      print('   Message: ${invalidTypeResult['message']}');
      print('   Field: ${invalidTypeResult['field']}');
    } else {
      print('   ❌ Invalid leave type should be rejected');
    }

    await _shortDelay();

    // Test past start date
    print('2.3 Testing past start date:');
    var pastDateResult = await leaveRepository.validateLeaveApplication(
      // Changed
      type: 'paid',
      startDate: DateTime.now().subtract(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 1)),
      reason: 'Test reason',
    );

    if (!pastDateResult['success']) {
      print('   ✅ Past start date correctly rejected');
      print('   Message: ${pastDateResult['message']}');
    } else {
      print('   ❌ Past start date should be rejected');
    }

    await _shortDelay();

    // Test empty reason
    print('2.4 Testing empty reason:');
    var emptyReasonResult = await leaveRepository.validateLeaveApplication(
      // Changed
      type: 'paid',
      startDate: DateTime.now().add(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 2)),
      reason: '',
    );

    if (!emptyReasonResult['success']) {
      print('   ✅ Empty reason correctly rejected');
      print('   Message: ${emptyReasonResult['message']}');
    } else {
      print('   ❌ Empty reason should be rejected');
    }
  }

  Future<void> _testApplyLeave() async {
    print('\n📝 PHASE 3: APPLY LEAVE TESTS');
    print('═' * 40);

    // Test 1: Apply paid leave
    print('3.1 Testing paid leave application:');
    final paidLeaveResult = await leaveRepository.applyLeave(
      // Changed
      type: 'paid',
      startDate: DateTime.now().add(Duration(days: 7)),
      endDate: DateTime.now().add(Duration(days: 9)),
      reason: 'Family vacation - repository test',
    );

    _printLeaveResult(paidLeaveResult, 'Paid leave application');

    if (paidLeaveResult['success']) {
      print('   Leave ID: ${paidLeaveResult['leave']['id']}');
      print(
          '   Duration: ${paidLeaveResult['duration']['working_days']} working days');
      print('   Submission: ${paidLeaveResult['submission_date']}');
    }

    await _shortDelay();

    // Test 2: Apply sick leave
    print('3.2 Testing sick leave application:');
    final sickLeaveResult = await leaveRepository.applyLeave(
      // Changed
      type: 'sick',
      startDate: DateTime.now().add(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 2)),
      reason: 'Flu and fever - need rest',
    );

    _printLeaveResult(sickLeaveResult, 'Sick leave application');

    await _shortDelay();

    // Test 3: Apply emergency leave
    print('3.3 Testing emergency leave application:');
    final emergencyLeaveResult = await leaveRepository.applyLeave(
      // Changed
      type: 'emergency',
      startDate: DateTime.now().add(Duration(days: 3)),
      endDate: DateTime.now().add(Duration(days: 4)),
      reason: 'Family emergency situation',
    );

    _printLeaveResult(emergencyLeaveResult, 'Emergency leave application');

    await _shortDelay();

    // Test 4: Apply leave with invalid data
    print('3.4 Testing invalid leave application:');
    final invalidLeaveResult = await leaveRepository.applyLeave(
      // Changed
      type: 'invalid',
      startDate: DateTime.now().subtract(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 1)),
      reason: '',
    );

    if (!invalidLeaveResult['success']) {
      print('   ✅ Invalid leave application correctly rejected');
      print('   Message: ${invalidLeaveResult['message']}');
      print('   Type: ${invalidLeaveResult['type']}');
    } else {
      print('   ❌ Invalid leave application should be rejected');
    }
  }

  Future<void> _testGetMyLeaves() async {
    print('\n📋 PHASE 4: GET MY LEAVES TESTS');
    print('═' * 40);

    print('4.1 Testing getMyLeaves():');
    final leavesResult = await leaveRepository.getMyLeaves(); // Changed

    if (leavesResult['success']) {
      print('   ✅ Leaves retrieved successfully');
      print('   Total leaves: ${leavesResult['total']}');
      print('   Message: ${leavesResult['message']}');

      if (leavesResult['leaves'].isNotEmpty) {
        final leaves = leavesResult['leaves'] as List;
        print('   Recent leaves:');
        for (int i = 0; i < leaves.length && i < 3; i++) {
          final leave = leaves[i];
          print(
              '     ${i + 1}. ${leave['type']} (${leave['status']}) - ${leave['start_date']}');
        }
      }

      if (leavesResult['summary'] != null) {
        final summary = leavesResult['summary'];
        print('   Summary:');
        print('     By Status: ${summary['by_status']}');
        print('     By Type: ${summary['by_type']}');
      }

      if (leavesResult['recent_leaves'] != null) {
        final recent = leavesResult['recent_leaves'] as List;
        print('   Recent leaves count: ${recent.length}');
      }
    } else {
      print('   ❌ Failed to get leaves: ${leavesResult['message']}');
      print('   Error type: ${leavesResult['type'] ?? 'Unknown'}');
      print('   Requires login: ${leavesResult['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testLeaveHistory() async {
    print('\n📅 PHASE 5: LEAVE HISTORY TESTS');
    print('═' * 40);

    // Test with date range
    print('5.1 Testing leave history with date range:');
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 30));

    final historyResult = await leaveRepository.getLeaveHistory(
      // Changed
      startDate: startDate,
      endDate: endDate,
    );

    if (historyResult['success']) {
      print('   ✅ Leave history retrieved successfully');
      print('   Total leaves: ${historyResult['total']}');
      print(
          '   Date range: ${historyResult['filters']['start_date']} to ${historyResult['filters']['end_date']}');

      if (historyResult['statistics'] != null) {
        final stats = historyResult['statistics'];
        print('   Statistics: ${stats['by_status']}');
      }
    } else {
      print('   ❌ Failed to get leave history: ${historyResult['message']}');
    }

    await _shortDelay();

    // Test with status filter
    print('5.2 Testing leave history with status filter:');
    final statusHistoryResult = await leaveRepository.getLeaveHistory(
      // Changed
      status: 'approved',
    );

    if (statusHistoryResult['success']) {
      print('   ✅ Filtered leave history retrieved');
      print('   Approved leaves: ${statusHistoryResult['total']}');
    } else {
      print(
          '   ❌ Failed to get filtered history: ${statusHistoryResult['message']}');
    }

    await _shortDelay();

    // Test with invalid date range
    print('5.3 Testing invalid date range:');
    final invalidRangeResult = await leaveRepository.getLeaveHistory(
      // Changed
      startDate: DateTime.now(),
      endDate: DateTime.now().subtract(Duration(days: 1)),
    );

    if (!invalidRangeResult['success']) {
      print('   ✅ Invalid date range correctly rejected');
      print('   Message: ${invalidRangeResult['message']}');
    } else {
      print('   ❌ Invalid date range should be rejected');
    }
  }

  Future<void> _testLeavesByStatus() async {
    print('\n📊 PHASE 6: LEAVES BY STATUS TESTS');
    print('═' * 40);

    // Test pending leaves
    print('6.1 Testing getPendingLeaves():');
    final pendingResult = await leaveRepository.getPendingLeaves(); // Changed
    _printStatusResult(pendingResult, 'Pending');

    await _shortDelay();

    // Test approved leaves
    print('6.2 Testing getApprovedLeaves():');
    final approvedResult = await leaveRepository.getApprovedLeaves(); // Changed
    _printStatusResult(approvedResult, 'Approved');

    await _shortDelay();

    // Test rejected leaves
    print('6.3 Testing getRejectedLeaves():');
    final rejectedResult = await leaveRepository.getRejectedLeaves(); // Changed
    _printStatusResult(rejectedResult, 'Rejected');

    await _shortDelay();

    // Test invalid status
    print('6.4 Testing invalid status:');
    final invalidStatusResult =
        await leaveRepository.getLeavesByStatus('invalid_status'); // Changed
    if (!invalidStatusResult['success']) {
      print('   ✅ Invalid status correctly rejected');
      print('   Message: ${invalidStatusResult['message']}');
    } else {
      print('   ❌ Invalid status should be rejected');
    }
  }

  Future<void> _testLeaveBalance() async {
    print('\n💰 PHASE 7: LEAVE BALANCE TESTS');
    print('═' * 40);

    print('7.1 Testing getLeaveBalance():');
    final balanceResult = await leaveRepository.getLeaveBalance(); // Changed

    if (balanceResult['success']) {
      print('   ✅ Leave balance retrieved successfully');
      print('   Message: ${balanceResult['message']}');

      final balance = balanceResult['balance'];
      print('   Balance Details:');
      print('     Paid leave: ${balance['paid_leave_balance'] ?? 'N/A'} days');
      print('     Sick leave: ${balance['sick_leave_balance'] ?? 'N/A'} days');
      print(
          '     Total available: ${balance['total_available'] ?? 'N/A'} days');
      print(
          '     Usage percentage: ${balance['usage_percentage']?.toStringAsFixed(1) ?? 'N/A'}%');
    } else {
      print('   ❌ Failed to get leave balance: ${balanceResult['message']}');
      print('   Error type: ${balanceResult['type'] ?? 'Unknown'}');
      print('   Requires login: ${balanceResult['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testLeaveStatistics() async {
    print('\n📈 PHASE 8: LEAVE STATISTICS TESTS');
    print('═' * 40);

    print('8.1 Testing getLeaveStatistics():');
    final statsResult = await leaveRepository.getLeaveStatistics(); // Changed

    if (statsResult['success']) {
      print('   ✅ Statistics retrieved successfully');
      print('   Message: ${statsResult['message']}');

      final stats = statsResult['statistics'];
      print('   Overall Statistics:');
      print('     Total: ${stats['total']}');
      print('     By Status: ${stats['by_status']}');
      print('     By Type: ${stats['by_type']}');

      if (stats['this_year'] != null) {
        final thisYear = stats['this_year'];
        print('   This Year:');
        print('     Total: ${thisYear['total']}');
        print('     By Status: ${thisYear['by_status']}');
        print('     By Type: ${thisYear['by_type']}');
      }

      if (stats['this_month'] != null) {
        final thisMonth = stats['this_month'];
        print('   This Month:');
        print('     Total: ${thisMonth['total']}');
        print('     By Status: ${thisMonth['by_status']}');
      }
    } else {
      print('   ❌ Failed to get statistics: ${statsResult['message']}');
      print('   Error type: ${statsResult['type'] ?? 'Unknown'}');
    }
  }

  Future<void> _testCancelLeave() async {
    print('\n❌ PHASE 9: CANCEL LEAVE TESTS');
    print('═' * 40);

    // Test cancel with invalid ID
    print('9.1 Testing cancel with invalid leave ID:');
    final invalidCancelResult =
        await leaveRepository.cancelLeave(-1); // Changed

    if (!invalidCancelResult['success']) {
      print('   ✅ Invalid leave ID correctly rejected');
      print('   Message: ${invalidCancelResult['message']}');
      print('   Type: ${invalidCancelResult['type']}');
    } else {
      print('   ❌ Invalid leave ID should be rejected');
    }

    await _shortDelay();

    // Test cancel with valid ID (this might fail if no pending leaves exist)
    print('9.2 Testing cancel with potentially valid leave ID:');
    final validCancelResult = await leaveRepository.cancelLeave(1); // Changed

    if (validCancelResult['success']) {
      print('   ✅ Leave cancelled successfully');
      print('   Message: ${validCancelResult['message']}');
      print('   Cancelled leave ID: ${validCancelResult['leave']['id']}');
      print('   Cancelled at: ${validCancelResult['cancelled_at']}');
    } else {
      print(
          '   ⚠️  Cancel failed (expected if no pending leaves): ${validCancelResult['message']}');
      print('   Type: ${validCancelResult['type'] ?? 'Unknown'}');
    }
  }

  Future<void> _testHelperMethods() async {
    print('\n🛠️  PHASE 10: HELPER METHODS & VALIDATION');
    print('═' * 40);

    // Test formatting methods
    print('10.1 Testing formatting helper methods:');

    // Test duration formatting
    String duration1 = leaveRepository.formatLeaveDuration(1); // Changed
    String duration7 = leaveRepository.formatLeaveDuration(7); // Changed
    print('   Duration formatting:');
    print('     1 day: $duration1');
    print('     7 days: $duration7');

    // Test status formatting
    String pending = leaveRepository.formatLeaveStatus('pending'); // Changed
    String approved = leaveRepository.formatLeaveStatus('approved'); // Changed
    String rejected = leaveRepository.formatLeaveStatus('rejected'); // Changed
    print('   Status formatting:');
    print('     pending → $pending');
    print('     approved → $approved');
    print('     rejected → $rejected');

    // Test type formatting
    String paid = leaveRepository.formatLeaveType('paid'); // Changed
    String sick = leaveRepository.formatLeaveType('sick'); // Changed
    String emergency = leaveRepository.formatLeaveType('emergency'); // Changed
    print('   Type formatting:');
    print('     paid → $paid');
    print('     sick → $sick');
    print('     emergency → $emergency');

    await _shortDelay();

    print('10.2 Testing validation helper methods:');

    // Test validation methods (these are private but we can test the public validate method)
    var validationTests = [
      {'type': 'paid', 'valid': true, 'desc': 'Valid paid leave type'},
      {'type': 'invalid', 'valid': false, 'desc': 'Invalid leave type'},
    ];

    for (var test in validationTests) {
      var result = await leaveRepository.validateLeaveApplication(
        // Changed
        type: test['type'] as String,
        startDate: DateTime.now().add(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 2)),
        reason: 'Test reason',
      );

      bool isValid = result['success'] == test['valid'];
      print(
          '   ${isValid ? "✅" : "❌"} ${test['desc']}: ${result['success'] ? "Valid" : "Invalid"}');
    }
  }

  // Helper methods for test result printing
  void _printLeaveResult(Map<String, dynamic> result, String operation) {
    if (result['success']) {
      print('   ✅ $operation successful');
      print('   Message: ${result['message']}');
    } else {
      print('   ❌ $operation failed: ${result['message']}');
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

  void _printStatusResult(Map<String, dynamic> result, String status) {
    if (result['success']) {
      print('   ✅ $status leaves: ${result['total']}');
      if (result['statistics'] != null) {
        print('   Statistics: ${result['statistics']['by_status']}');
      }
    } else {
      print('   ❌ Failed to get $status leaves: ${result['message']}');
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
    testAllMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Leave Repository Test"), // Updated title
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
                "Testing LeaveRepository Methods", // Updated text
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
              Text("📝 Phase 3: Apply Leave"),
              Text("📋 Phase 4: Get My Leaves"),
              Text("📅 Phase 5: Leave History"),
              Text("📊 Phase 6: Leaves by Status"),
              Text("💰 Phase 7: Leave Balance"),
              Text("📈 Phase 8: Statistics"),
              Text("❌ Phase 9: Cancel Leave"),
              Text("🛠️  Phase 10: Helper Methods"),
            ],
          ),
        ),
      ),
    );
  }
}
