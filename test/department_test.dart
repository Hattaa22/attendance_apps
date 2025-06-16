import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/repositories/auth_repository.dart'; // Changed import
import '../lib/core/data/repositories/department_repository.dart'; // Changed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(DepartmentTestApp());
}

class DepartmentTestApp extends StatelessWidget {
  DepartmentTestApp({super.key});

  final AuthRepository authRepository =
      AuthRepositoryImpl(); // Changed to Repository
  final DepartmentRepository departmentRepository =
      DepartmentRepositoryImpl(); // Changed to Repository

  Future<void> testDepartmentMethods() async {
    print('=== Testing DepartmentRepository ===\n'); // Updated message

    // Phase 1: Prerequisites and authentication
    await _testPrerequisites();
    await _delay();

    // Phase 2: Basic department operations
    await _testGetDepartments();
    await _delay();

    // Phase 3: Team department operations
    await _testGetTeamDepartments();
    await _delay();

    // Phase 4: User operations
    await _testGetUsersFromTeams();
    await _delay();

    // Phase 5: Combined operations
    await _testDepartmentWithTeams();
    await _delay();

    // Phase 6: Meeting creation data
    await _testMeetingCreationData();
    await _delay();

    // Phase 7: Validation operations
    await _testValidateMeetingParticipants();
    await _delay();

    // Phase 8: Meeting creation tests
    await _testCreateOnlineMeeting();
    await _delay();

    await _testCreateOfflineMeeting();
    await _delay();

    // Phase 9: Statistics and analytics
    await _testDepartmentStatistics();
    await _delay();

    // Phase 10: Helper methods and edge cases
    await _testHelperMethods();

    print(
        '\n🎉 === All department repository tests completed ==='); // Updated message
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

  Future<void> _testGetDepartments() async {
    print('\n🏢 PHASE 2: GET DEPARTMENTS TEST');
    print('═' * 40);

    final result = await departmentRepository.getDepartments(); // Changed
    if (result['success']) {
      print('✅ Departments loaded successfully');
      print('   Total departments: ${result['total']}');
      print('   Message: ${result['message']}');

      final departments = result['departments'] as List;
      if (departments.isNotEmpty) {
        print('   First department:');
        final firstDept = departments[0];
        print(
            '     Name: ${firstDept['nama_department'] ?? firstDept['department']}');
        print('     ID: ${firstDept['id']}');
        print(
            '     Manager: ${firstDept['manager_department'] ?? 'No Manager'}');
        print('     Created: ${firstDept['created_at'] ?? 'N/A'}');
      }

      // Business logic: Test department data structure
      print('   Data structure validation:');
      for (int i = 0; i < departments.length && i < 3; i++) {
        final dept = departments[i];
        print(
            '     Department ${i + 1}: ${dept['nama_department'] ?? dept['department']}');
      }
    } else {
      print('❌ Failed to get departments: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
      print('   Session expired: ${result['sessionExpired'] ?? false}');
    }
  }

  Future<void> _testGetTeamDepartments() async {
    print('\n👥 PHASE 3: GET TEAM DEPARTMENTS TEST');
    print('═' * 40);

    // Test invalid department ID first
    print('3.1 Testing invalid department ID:');
    var invalidResult =
        await departmentRepository.getTeamDepartments(-1); // Changed
    if (!invalidResult['success']) {
      print('   ✅ Invalid department ID rejected correctly');
      print('   Message: ${invalidResult['message']}');
      print('   Type: ${invalidResult['type']}');
    } else {
      print('   ❌ Invalid department ID should be rejected');
    }

    await _shortDelay();

    // Test with valid department ID
    print('3.2 Testing valid department ID (1):');
    final result = await departmentRepository.getTeamDepartments(1); // Changed
    if (result['success']) {
      print('✅ Team departments loaded successfully');
      print('   Total teams: ${result['total']}');
      print('   Department ID: ${result['department_id']}');
      print('   Message: ${result['message']}');

      final teams = result['teams'] as List;
      if (teams.isNotEmpty) {
        print('   Teams in department:');
        for (int i = 0; i < teams.length && i < 3; i++) {
          final team = teams[i];
          print(
              '     ${i + 1}. ${team['nama_team'] ?? team['name']} (ID: ${team['id']})');
        }
      } else {
        print('   ⚠️  No teams found in this department');
      }
    } else {
      print('❌ Failed to get team departments: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testGetUsersFromTeams() async {
    print('\n👤 PHASE 4: GET USERS FROM TEAMS TEST');
    print('═' * 40);

    // Test with empty team IDs first
    print('4.1 Testing empty team IDs:');
    var emptyResult =
        await departmentRepository.getUsersFromTeams([]); // Changed
    if (!emptyResult['success']) {
      print('   ✅ Empty team IDs rejected correctly');
      print('   Message: ${emptyResult['message']}');
    } else {
      print('   ❌ Empty team IDs should be rejected');
    }

    await _shortDelay();

    // Test with invalid team IDs
    print('4.2 Testing invalid team IDs:');
    var invalidResult =
        await departmentRepository.getUsersFromTeams([-1, 0]); // Changed
    if (!invalidResult['success']) {
      print('   ✅ Invalid team IDs rejected correctly');
      print('   Message: ${invalidResult['message']}');
    } else {
      print('   ❌ Invalid team IDs should be rejected');
    }

    await _shortDelay();

    // Test with valid team IDs
    print('4.3 Testing valid team IDs [1, 2]:');
    final result =
        await departmentRepository.getUsersFromTeams([1, 2]); // Changed
    if (result['success']) {
      print('✅ Team users loaded successfully');
      print('   Total users: ${result['total']}');
      print('   Team IDs: ${result['team_ids']}');
      print('   Message: ${result['message']}');

      final users = result['users'] as List;
      if (users.isNotEmpty) {
        print('   Users in teams:');
        for (int i = 0; i < users.length && i < 5; i++) {
          final user = users[i];
          print('     ${i + 1}. ${user['name']} (NIP: ${user['nip']})');
          print('        Email: ${user['email'] ?? 'N/A'}');
        }
      } else {
        print('   ⚠️  No users found in these teams');
      }
    } else {
      print('❌ Failed to get team users: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
    }

    await _shortDelay();

    // Test single team helper method
    print('4.4 Testing single team method:');
    final singleTeamResult =
        await departmentRepository.getUsersFromSingleTeam(1); // Changed
    if (singleTeamResult['success']) {
      print('   ✅ Single team users loaded successfully');
      print('   Total users: ${singleTeamResult['total']}');
    } else {
      print('   ❌ Single team method failed: ${singleTeamResult['message']}');
    }
  }

  Future<void> _testDepartmentWithTeams() async {
    print('\n🏢👥 PHASE 5: GET DEPARTMENT WITH TEAMS TEST');
    print('═' * 40);

    // Test with invalid department ID
    print('5.1 Testing invalid department ID (999):');
    var invalidResult =
        await departmentRepository.getDepartmentWithTeams(999); // Changed
    if (!invalidResult['success']) {
      print('   ✅ Non-existent department handled correctly');
      print('   Message: ${invalidResult['message']}');
      print('   Type: ${invalidResult['type']}');
    } else {
      print('   ❌ Non-existent department should not be found');
    }

    await _shortDelay();

    // Test with valid department ID
    print('5.2 Testing valid department ID (1):');
    final result =
        await departmentRepository.getDepartmentWithTeams(1); // Changed
    if (result['success']) {
      print('✅ Department with teams loaded successfully');
      print('   Message: ${result['message']}');

      final department = result['department'];
      print('   Department Info:');
      print(
          '     Name: ${department['nama_department'] ?? department['department']}');
      print('     ID: ${department['id']}');
      print(
          '     Manager: ${department['manager_department'] ?? 'No Manager'}');

      final teams = result['teams'] as List;
      print('   Teams (${teams.length} total):');
      for (int i = 0; i < teams.length && i < 3; i++) {
        final team = teams[i];
        print('     ${i + 1}. ${team['nama_team'] ?? team['name']}');
      }
    } else {
      print('❌ Failed to get department with teams: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
    }
  }

  Future<void> _testMeetingCreationData() async {
    print('\n📋 PHASE 6: GET MEETING CREATION DATA TEST');
    print('═' * 40);

    final result =
        await departmentRepository.getMeetingCreationData(); // Changed
    if (result['success']) {
      print('✅ Meeting creation data loaded successfully');
      print('   Message: ${result['message']}');

      final departments = result['departments'] as List;
      print('   Available departments for meetings: ${departments.length}');

      if (departments.isNotEmpty) {
        print('   Sample departments:');
        for (int i = 0; i < departments.length && i < 3; i++) {
          final dept = departments[i];
          print(
              '     ${i + 1}. ${dept['nama_department'] ?? dept['department']} (ID: ${dept['id']})');
        }
      }
    } else {
      print('❌ Failed to get meeting creation data: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testValidateMeetingParticipants() async {
    print('\n✅ PHASE 7: VALIDATE MEETING PARTICIPANTS TEST');
    print('═' * 40);

    // Test with invalid data first
    print('7.1 Testing invalid department ID:');
    var invalidDeptResult =
        await departmentRepository.validateMeetingParticipants(
      // Changed
      departmentId: -1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
    );
    if (!invalidDeptResult['success']) {
      print('   ✅ Invalid department ID rejected');
      print('   Message: ${invalidDeptResult['message']}');
    }

    await _shortDelay();

    print('7.2 Testing empty teams:');
    var emptyTeamsResult =
        await departmentRepository.validateMeetingParticipants(
      // Changed
      departmentId: 1,
      teamDepartmentIds: [],
      userNips: ['10001'],
    );
    if (!emptyTeamsResult['success']) {
      print('   ✅ Empty teams rejected');
      print('   Message: ${emptyTeamsResult['message']}');
    }

    await _shortDelay();

    print('7.3 Testing empty users:');
    var emptyUsersResult =
        await departmentRepository.validateMeetingParticipants(
      // Changed
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: [],
    );
    if (!emptyUsersResult['success']) {
      print('   ✅ Empty users rejected');
      print('   Message: ${emptyUsersResult['message']}');
    }

    await _shortDelay();

    // Test with valid data
    print('7.4 Testing valid participants:');
    final result = await departmentRepository.validateMeetingParticipants(
      // Changed
      departmentId: 1,
      teamDepartmentIds: [1, 2],
      userNips: ['10001', '10002'],
    );

    if (result['success']) {
      print('✅ Participants validated successfully');
      print('   Message: ${result['message']}');

      if (result['summary'] != null) {
        final summary = result['summary'];
        print('   Summary:');
        print('     Department: ${summary['department_name']}');
        print('     Teams: ${summary['teams_count']}');
        print('     Users: ${summary['users_count']}');
      }
    } else {
      print('❌ Validation failed: ${result['message']}');
      print('   Type: ${result['type'] ?? 'Unknown'}');
      if (result['invalidTeamIds'] != null) {
        print('   Invalid team IDs: ${result['invalidTeamIds']}');
      }
      if (result['invalidUserNips'] != null) {
        print('   Invalid user NIPs: ${result['invalidUserNips']}');
      }
    }
  }

  Future<void> _testCreateOnlineMeeting() async {
    print('\n💻 PHASE 8A: CREATE ONLINE MEETING TEST');
    print('═' * 40);

    // Test validation first
    print('8A.1 Testing missing online URL:');
    var noUrlResult = await departmentRepository.createOnlineMeeting(
      // Changed
      title: 'Test Meeting',
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
      onlineUrl: '', // Empty URL
    );
    if (!noUrlResult['success']) {
      print('   ✅ Missing online URL correctly rejected');
      print('   Message: ${noUrlResult['message']}');
    }

    await _shortDelay();

    // Test valid online meeting
    print('8A.2 Testing valid online meeting:');
    final result = await departmentRepository.createOnlineMeeting(
      // Changed
      title: 'Test Online Meeting - Repository',
      departmentId: 1,
      teamDepartmentIds: [1, 2],
      userNips: ['10001', '10002'],
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 2)),
      onlineUrl: 'https://zoom.us/j/123456789',
      description: 'This is a test online meeting from repository',
    );

    if (result['success']) {
      print('✅ Online meeting created successfully');
      print('   Meeting ID: ${result['meeting']['id']}');
      print('   Title: ${result['meeting']['title']}');
      print('   Type: ${result['meeting']['type']}');
      print('   Online URL: ${result['meeting']['online_url']}');
      print('   Head Department: ${result['head_department'] ?? 'N/A'}');
      print('   Created at: ${result['created_at']}');
    } else {
      print('❌ Failed to create online meeting: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
      print('   Requires login: ${result['requiresLogin'] ?? false}');
    }
  }

  Future<void> _testCreateOfflineMeeting() async {
    print('\n🏢 PHASE 8B: CREATE OFFLINE MEETING TEST');
    print('═' * 40);

    // Test validation first
    print('8B.1 Testing missing location:');
    var noLocationResult = await departmentRepository.createOfflineMeeting(
      // Changed
      title: 'Test Meeting',
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
      startTime: DateTime.now().add(Duration(days: 2)),
      endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
      location: '', // Empty location
    );
    if (!noLocationResult['success']) {
      print('   ✅ Missing location correctly rejected');
      print('   Message: ${noLocationResult['message']}');
    }

    await _shortDelay();

    // Test invalid time (past)
    print('8B.2 Testing past time:');
    var pastTimeResult = await departmentRepository.createOfflineMeeting(
      // Changed
      title: 'Test Meeting',
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
      startTime: DateTime.now().subtract(Duration(hours: 1)), // Past time
      endTime: DateTime.now().add(Duration(hours: 1)),
      location: 'Meeting Room A',
    );
    if (!pastTimeResult['success']) {
      print('   ✅ Past time correctly rejected');
      print('   Message: ${pastTimeResult['message']}');
    }

    await _shortDelay();

    // Test valid offline meeting
    print('8B.3 Testing valid offline meeting:');
    final result = await departmentRepository.createOfflineMeeting(
      // Changed
      title: 'Test Offline Meeting - Repository',
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
      startTime: DateTime.now().add(Duration(days: 2)),
      endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
      location: 'Meeting Room A - Floor 3',
      description: 'This is a test offline meeting from repository',
    );

    if (result['success']) {
      print('✅ Offline meeting created successfully');
      print('   Meeting ID: ${result['meeting']['id']}');
      print('   Title: ${result['meeting']['title']}');
      print('   Type: ${result['meeting']['type']}');
      print('   Location: ${result['meeting']['location']}');
      print('   Head Department: ${result['head_department'] ?? 'N/A'}');
    } else {
      print('❌ Failed to create offline meeting: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
    }
  }

  Future<void> _testDepartmentStatistics() async {
    print('\n📊 PHASE 9: DEPARTMENT STATISTICS TEST');
    print('═' * 40);

    final result =
        await departmentRepository.getDepartmentStatistics(); // Changed
    if (result['success']) {
      print('✅ Department statistics loaded successfully');
      print('   Message: ${result['message']}');

      final stats = result['statistics'];
      print('   Statistics Summary:');
      print('     Total departments: ${stats['total_departments']}');
      print('     With manager: ${stats['departments_with_manager']}');
      print('     Without manager: ${stats['departments_without_manager']}');

      final departmentNames = stats['department_names'] as List<String>;
      print(
          '     Department names: ${departmentNames.take(3).join(', ')}${departmentNames.length > 3 ? '...' : ''}');
    } else {
      print('❌ Failed to get department statistics: ${result['message']}');
      print('   Error type: ${result['type'] ?? 'Unknown'}');
    }
  }

  Future<void> _testHelperMethods() async {
    print('\n🛠️  PHASE 10: HELPER METHODS TEST');
    print('═' * 40);

    // Test validation helpers
    print('10.1 Testing validation helper methods:');

    // Test department ID validation
    bool validDept = departmentRepository.isValidDepartmentId(1); // Changed
    bool invalidDept = departmentRepository.isValidDepartmentId(-1); // Changed
    print('   Valid department ID (1): ${validDept ? "✅" : "❌"}');
    print('   Invalid department ID (-1): ${!invalidDept ? "✅" : "❌"}');

    // Test team IDs validation
    bool validTeams = departmentRepository.isValidTeamIds([1, 2, 3]); // Changed
    bool invalidTeams = departmentRepository.isValidTeamIds([]); // Changed
    print('   Valid team IDs [1,2,3]: ${validTeams ? "✅" : "❌"}');
    print('   Invalid team IDs []: ${!invalidTeams ? "✅" : "❌"}');

    // Test user NIPs validation
    bool validNips =
        departmentRepository.isValidUserNips(['10001', '10002']); // Changed
    bool invalidNips =
        departmentRepository.isValidUserNips(['', '  ']); // Changed
    print('   Valid user NIPs: ${validNips ? "✅" : "❌"}');
    print('   Invalid user NIPs: ${!invalidNips ? "✅" : "❌"}');

    await _shortDelay();

    print('10.2 Testing time validation:');
    final now = DateTime.now();
    final future = now.add(Duration(hours: 2));
    final past = now.subtract(Duration(hours: 1));

    bool validTime = departmentRepository.isValidMeetingTime(
        now.add(Duration(minutes: 10)), future); // Changed
    bool invalidTime =
        departmentRepository.isValidMeetingTime(past, future); // Changed
    print('   Valid meeting time: ${validTime ? "✅" : "❌"}');
    print('   Invalid meeting time (past): ${!invalidTime ? "✅" : "❌"}');

    await _shortDelay();

    print('10.3 Testing meeting type validation:');
    String validOnline = departmentRepository.validateMeetingType(
        'online', 'https://zoom.us/j/123', null); // Changed
    String validOffline = departmentRepository.validateMeetingType(
        'offline', null, 'Meeting Room A'); // Changed
    String invalidType = departmentRepository.validateMeetingType(
        'invalid', null, null); // Changed

    print(
        '   Valid online type: ${validOnline.isEmpty ? "✅" : "❌ ($validOnline)"}');
    print(
        '   Valid offline type: ${validOffline.isEmpty ? "✅" : "❌ ($validOffline)"}');
    print(
        '   Invalid type: ${invalidType.isNotEmpty ? "✅" : "❌"} ($invalidType)');

    await _shortDelay();

    print('10.4 Testing duration calculation:');
    final startTime = DateTime.now();
    final endTime = startTime.add(Duration(hours: 2, minutes: 30));
    final duration = departmentRepository.calculateMeetingDuration(
        startTime, endTime); // Changed

    print('   Duration calculation:');
    print('     Hours: ${duration['hours']}');
    print('     Minutes: ${duration['minutes']}');
    print('     Total minutes: ${duration['totalMinutes']}');
    print('     Formatted: ${duration['formatted']}');
    print(
        '   Duration correct: ${duration['hours'] == 2 && duration['minutes'] == 30 ? "✅" : "❌"}');
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _shortDelay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    testDepartmentMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Department Repository Test"), // Updated title
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.teal),
              SizedBox(height: 16),
              Text(
                "Testing DepartmentRepository Methods", // Updated text
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
              Text("🏢 Phase 2: Get Departments"),
              Text("👥 Phase 3: Team Departments"),
              Text("👤 Phase 4: Users from Teams"),
              Text("🏢👥 Phase 5: Department with Teams"),
              Text("📋 Phase 6: Meeting Creation Data"),
              Text("✅ Phase 7: Validate Participants"),
              Text("💻🏢 Phase 8: Create Meetings"),
              Text("📊 Phase 9: Statistics"),
              Text("🛠️  Phase 10: Helper Methods"),
            ],
          ),
        ),
      ),
    );
  }
}
