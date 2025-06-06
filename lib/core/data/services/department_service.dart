import '../repositories/department_repository.dart';
import '../models/meeting_model.dart';
import 'auth_service.dart';

class DepartmentService {
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;

  late DepartmentRepository _repository;
  final AuthService _authService;

  DepartmentService._internal() : _authService = AuthService() {
    _repository = DepartmentRepositoryImpl();
  }

  // For testing
  DepartmentService.withRepository(this._repository) : _authService = AuthService();

  Future<Map<String, dynamic>> getDepartments() async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view departments',
          'requiresLogin': true,
        };
      }

      final departments = await _repository.getDepartments();

      return {
        'success': true,
        'departments': departments.map((dept) => dept.toJson()).toList(),
        'total': departments.length,
        'message': 'Departments loaded successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getTeamDepartments(int departmentId) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view team departments',
          'requiresLogin': true,
        };
      }

      if (departmentId <= 0) {
        return {
          'success': false,
          'message': 'Invalid department ID',
        };
      }

      final teams = await _repository.getTeamDepartments(departmentId);

      return {
        'success': true,
        'teams': teams.map((team) => team.toJson()).toList(),
        'total': teams.length,
        'department_id': departmentId,
        'message': 'Team departments loaded successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getUsersFromTeams(List<int> teamIds) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view team users',
          'requiresLogin': true,
        };
      }

      if (teamIds.isEmpty) {
        return {
          'success': false,
          'message': 'At least one team ID is required',
        };
      }

      if (teamIds.any((id) => id <= 0)) {
        return {
          'success': false,
          'message': 'Invalid team ID provided',
        };
      }

      final users = await _repository.getUsersFromTeams(teamIds);

      return {
        'success': true,
        'users': users.map((user) => user.toJson()).toList(),
        'total': users.length,
        'team_ids': teamIds,
        'message': 'Team users loaded successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getUsersFromSingleTeam(int teamId) async {
    return await getUsersFromTeams([teamId]);
  }

  Future<Map<String, dynamic>> getDepartmentWithTeams(int departmentId) async {
    try {
      final departmentsResult = await getDepartments();
      if (!departmentsResult['success']) {
        return departmentsResult;
      }

      final teamsResult = await getTeamDepartments(departmentId);
      if (!teamsResult['success']) {
        return teamsResult;
      }

      // Find the specific department - SAFE APPROACH
      final departments =
          departmentsResult['departments'] as List<Map<String, dynamic>>;

      final department =
          departments.where((dept) => dept['id'] == departmentId).firstOrNull;

      if (department == null) {
        return {
          'success': false,
          'message': 'Department with ID $departmentId not found',
        };
      }

      return {
        'success': true,
        'department': department,
        'teams': teamsResult['teams'],
        'message': 'Department with teams loaded successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load department with teams: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getDepartmentStatistics() async {
    try {
      final result = await getDepartments();
      if (!result['success']) return result;

      final departments = result['departments'] as List;

      int totalDepartments = departments.length;
      int departmentsWithManager = departments
          .where((dept) => dept['manager_department'] != null)
          .length;
      int departmentsWithoutManager = totalDepartments - departmentsWithManager;

      return {
        'success': true,
        'statistics': {
          'total_departments': totalDepartments,
          'departments_with_manager': departmentsWithManager,
          'departments_without_manager': departmentsWithoutManager,
        },
        'message': 'Department statistics loaded successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get department statistics: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createMeeting({
    required String title,
    required String type,
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
    required DateTime startTime,
    required DateTime endTime,
    String? onlineUrl,
    String? description,
    String? location,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to create meeting',
          'requiresLogin': true,
        };
      }

      // Create meeting request
      final request = CreateMeetingRequest(
        title: title,
        type: type,
        departmentId: departmentId,
        teamDepartmentIds: teamDepartmentIds,
        userNips: userNips,
        startTime: startTime,
        endTime: endTime,
        onlineUrl: onlineUrl,
        description: description,
        location: location,
      );

      // Validate request
      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid meeting data',
        };
      }

      final meetingResponse = await _repository.createMeeting(request);

      return {
        'success': true,
        'meeting': meetingResponse.meeting.toJson(),
        'head_department': meetingResponse.headDepartment,
        'message': meetingResponse.message,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> createOnlineMeeting({
    required String title,
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
    required DateTime startTime,
    required DateTime endTime,
    required String onlineUrl,
    String? description,
  }) async {
    return await createMeeting(
      title: title,
      type: 'online',
      departmentId: departmentId,
      teamDepartmentIds: teamDepartmentIds,
      userNips: userNips,
      startTime: startTime,
      endTime: endTime,
      onlineUrl: onlineUrl,
      description: description,
    );
  }

  Future<Map<String, dynamic>> createOfflineMeeting({
    required String title,
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? description,
  }) async {
    return await createMeeting(
      title: title,
      type: 'offline',
      departmentId: departmentId,
      teamDepartmentIds: teamDepartmentIds,
      userNips: userNips,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
    );
  }

  // Helper method to get all data needed for meeting creation
  Future<Map<String, dynamic>> getMeetingCreationData() async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to access meeting data',
          'requiresLogin': true,
        };
      }

      final departmentsResult = await getDepartments();
      if (!departmentsResult['success']) {
        return departmentsResult;
      }

      return {
        'success': true,
        'departments': departmentsResult['departments'],
        'message': 'Meeting creation data loaded successfully',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> validateMeetingParticipants({
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to validate participants',
          'requiresLogin': true,
        };
      }

      final departmentsResult = await getDepartments();
      if (!departmentsResult['success']) {
        return departmentsResult;
      }

      final departments = departmentsResult['departments'] as List;
      final departmentExists =
          departments.any((dept) => dept['id'] == departmentId);

      if (!departmentExists) {
        return {
          'success': false,
          'message': 'Department not found',
        };
      }

      final teamsResult = await getTeamDepartments(departmentId);
      if (!teamsResult['success']) {
        return teamsResult;
      }

      final teams = teamsResult['teams'] as List;
      final availableTeamIds = teams.map((team) => team['id']).toList();

      final invalidTeamIds = teamDepartmentIds
          .where((teamId) => !availableTeamIds.contains(teamId))
          .toList();

      if (invalidTeamIds.isNotEmpty) {
        return {
          'success': false,
          'message': 'Invalid team IDs: ${invalidTeamIds.join(', ')}',
        };
      }

      final usersResult = await getUsersFromTeams(teamDepartmentIds);
      if (!usersResult['success']) {
        return usersResult;
      }

      final users = usersResult['users'] as List;
      final availableUserNips = users.map((user) => user['nip']).toList();

      final invalidUserNips =
          userNips.where((nip) => !availableUserNips.contains(nip)).toList();

      if (invalidUserNips.isNotEmpty) {
        return {
          'success': false,
          'message': 'Invalid user NIPs: ${invalidUserNips.join(', ')}',
        };
      }

      return {
        'success': true,
        'message': 'All participants are valid',
        'participants': {
          'department':
              departments.firstWhere((dept) => dept['id'] == departmentId),
          'teams': teams
              .where((team) => teamDepartmentIds.contains(team['id']))
              .toList(),
          'users':
              users.where((user) => userNips.contains(user['nip'])).toList(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate participants: ${e.toString()}',
      };
    }
  }
}
