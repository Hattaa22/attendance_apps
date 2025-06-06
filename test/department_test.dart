import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/data/services/auth_service.dart';
import '../lib/core/data/services/department_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(DepartmentTestApp());
}

class DepartmentTestApp extends StatelessWidget {
  DepartmentTestApp({super.key});

  final AuthService authService = AuthService();
  final DepartmentService departmentService = DepartmentService();

  Future<void> testDepartmentMethods() async {
    print('=== Testing DepartmentService ===\n');
    // Test get departments
    await _testGetDepartments();
    await _delay();

    // Test get team departments
    await _testGetTeamDepartments();
    await _delay();

    // Test get users from teams
    await _testGetUsersFromTeams();
    await _delay();

    // Test combined methods
    await _testDepartmentWithTeams();
    await _delay();

    // Test meeting creation data
    await _testMeetingCreationData();
    await _delay();

    // Test validate meeting participants
    await _testValidateMeetingParticipants();
    await _delay();

    // Test create online meeting
    await _testCreateOnlineMeeting();
    await _delay();

    // Test create offline meeting
    await _testCreateOfflineMeeting();
    await _delay();

    // Test statistics
    await _testDepartmentStatistics();

    print('\n=== All department tests completed ===');
  }

  Future<void> _testGetDepartments() async {
    print('\n🏢 GET DEPARTMENTS TEST');
    print('─' * 30);

    final result = await departmentService.getDepartments();
    if (result['success']) {
      print('✅ Departments loaded successfully');
      print('   Total departments: ${result['total']}');

      final departments = result['departments'] as List;
      if (departments.isNotEmpty) {
        print('   First department: ${departments[0]['department']}');
        print(
            '   Manager: ${departments[0]['manager_department'] ?? 'No Manager'}');
      }
    } else {
      print('❌ Failed to get departments: ${result['message']}');
    }
  }

  Future<void> _testGetTeamDepartments() async {
    print('\n👥 GET TEAM DEPARTMENTS TEST');
    print('─' * 30);

    // Test with department ID 1 (adjust based on your data)
    final result = await departmentService.getTeamDepartments(1);
    if (result['success']) {
      print('✅ Team departments loaded successfully');
      print('   Total teams: ${result['total']}');
      print('   Department ID: ${result['department_id']}');

      final teams = result['teams'] as List;
      if (teams.isNotEmpty) {
        print('   First team: ${teams[0]['name']}');
      }
    } else {
      print('❌ Failed to get team departments: ${result['message']}');
    }
  }

  Future<void> _testGetUsersFromTeams() async {
    print('\n👤 GET USERS FROM TEAMS TEST');
    print('─' * 30);

    // Test with team IDs [1, 2] (adjust based on your data)
    final result = await departmentService.getUsersFromTeams([1, 2]);
    if (result['success']) {
      print('✅ Team users loaded successfully');
      print('   Total users: ${result['total']}');
      print('   Team IDs: ${result['team_ids']}');

      final users = result['users'] as List;
      if (users.isNotEmpty) {
        print('   First user: ${users[0]['name']} (${users[0]['nip']})');
        print('   Email: ${users[0]['email']}');
      }
    } else {
      print('❌ Failed to get team users: ${result['message']}');
    }
  }

  Future<void> _testDepartmentWithTeams() async {
    print('\n🏢👥 GET DEPARTMENT WITH TEAMS TEST');
    print('─' * 30);

    final result = await departmentService.getDepartmentWithTeams(1);
    if (result['success']) {
      print('✅ Department with teams loaded successfully');
      print('   Department: ${result['department']['department']}');
      print(
          '   Manager: ${result['department']['manager_department'] ?? 'No Manager'}');

      final teams = result['teams'] as List;
      print('   Total teams: ${teams.length}');
    } else {
      print('❌ Failed to get department with teams: ${result['message']}');
    }
  }

  Future<void> _testMeetingCreationData() async {
    print('\n📋 GET MEETING CREATION DATA TEST');
    print('─' * 30);

    final result = await departmentService.getMeetingCreationData();
    if (result['success']) {
      print('✅ Meeting creation data loaded successfully');
      final departments = result['departments'] as List;
      print('   Available departments: ${departments.length}');
    } else {
      print('❌ Failed to get meeting creation data: ${result['message']}');
    }
  }

  Future<void> _testValidateMeetingParticipants() async {
    print('\n✅ VALIDATE MEETING PARTICIPANTS TEST');
    print('─' * 30);

    final result = await departmentService.validateMeetingParticipants(
      departmentId: 1,
      teamDepartmentIds: [1, 2],
      userNips: ['10001', '10002'],
    );

    if (result['success']) {
      print('✅ Participants validated successfully');
      print('   Message: ${result['message']}');
    } else {
      print('❌ Validation failed: ${result['message']}');
    }
  }

  Future<void> _testCreateOnlineMeeting() async {
    print('\n💻 CREATE ONLINE MEETING TEST');
    print('─' * 30);

    final result = await departmentService.createOnlineMeeting(
      title: 'Test Online Meeting',
      departmentId: 1,
      teamDepartmentIds: [1, 2],
      userNips: ['10001', '10002'],
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 2)),
      onlineUrl: 'https://zoom.us/j/123456789',
      description: 'This is a test online meeting',
    );

    if (result['success']) {
      print('✅ Online meeting created successfully');
      print('   Meeting ID: ${result['meeting']['id']}');
      print('   Title: ${result['meeting']['title']}');
      print('   Head Department: ${result['head_department'] ?? 'N/A'}');
    } else {
      print('❌ Failed to create online meeting: ${result['message']}');
    }
  }

  Future<void> _testCreateOfflineMeeting() async {
    print('\n🏢 CREATE OFFLINE MEETING TEST');
    print('─' * 30);

    final result = await departmentService.createOfflineMeeting(
      title: 'Test Offline Meeting',
      departmentId: 1,
      teamDepartmentIds: [1],
      userNips: ['10001'],
      startTime: DateTime.now().add(Duration(days: 2)),
      endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
      location: 'Meeting Room A',
      description: 'This is a test offline meeting',
    );

    if (result['success']) {
      print('✅ Offline meeting created successfully');
      print('   Meeting ID: ${result['meeting']['id']}');
      print('   Title: ${result['meeting']['title']}');
      print('   Location: ${result['meeting']['location']}');
    } else {
      print('❌ Failed to create offline meeting: ${result['message']}');
    }
  }

  Future<void> _testDepartmentStatistics() async {
    print('\n📊 DEPARTMENT STATISTICS TEST');
    print('─' * 30);

    final result = await departmentService.getDepartmentStatistics();
    if (result['success']) {
      print('✅ Department statistics loaded successfully');
      final stats = result['statistics'];
      print('   Total departments: ${stats['total_departments']}');
      print('   With manager: ${stats['departments_with_manager']}');
      print('   Without manager: ${stats['departments_without_manager']}');
    } else {
      print('❌ Failed to get department statistics: ${result['message']}');
    }
  }

  Future<void> _testLogin() async {
    print('\n🔑 LOGIN TEST');
    print('─' * 30);

    final result = await authService.login('admin', 'password');
    if (result['success']) {
      print('✅ Login successful');
      print('   Token: ${result['token']}');
    } else {
      print('❌ Login failed: ${result['message']}');
    }
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    testDepartmentMethods();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Department Service Test"),
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
                "Testing DepartmentService Methods",
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
              Text("• Get all departments"),
              Text("• Get team departments"),
              Text("• Get users from teams"),
              Text("• Department with teams"),
              Text("• Department statistics"),
            ],
          ),
        ),
      ),
    );
  }
}
