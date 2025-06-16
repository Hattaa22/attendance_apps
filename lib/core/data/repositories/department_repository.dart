import '../models/meeting_model.dart';
import '../services/department_service.dart';
import '../repositories/auth_repository.dart';

abstract class DepartmentRepository {
  Future<Map<String, dynamic>> getDepartments();
  Future<Map<String, dynamic>> getTeamDepartments(int departmentId);
  Future<Map<String, dynamic>> getUsersFromTeams(List<int> teamIds);
  Future<Map<String, dynamic>> getUsersFromSingleTeam(int teamId);
  Future<Map<String, dynamic>> getDepartmentWithTeams(int departmentId);
  Future<Map<String, dynamic>> getDepartmentStatistics();
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
  });
  Future<Map<String, dynamic>> createOnlineMeeting({
    required String title,
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
    required DateTime startTime,
    required DateTime endTime,
    required String onlineUrl,
    String? description,
  });
  Future<Map<String, dynamic>> createOfflineMeeting({
    required String title,
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? description,
  });
  Future<Map<String, dynamic>> getMeetingCreationData();
  Future<Map<String, dynamic>> validateMeetingParticipants({
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
  });
  String validateMeetingType(String type, String? onlineUrl, String? location);
  bool isValidDepartmentId(int departmentId);
  bool isValidTeamIds(List<int> teamIds);
  bool isValidUserNips(List<String> userNips);
  bool isValidMeetingTime(DateTime startTime, DateTime endTime);
  Map<String, dynamic> calculateMeetingDuration(
      DateTime startTime, DateTime endTime);
}

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentService _service = DepartmentService();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  @override
  Future<Map<String, dynamic>> getDepartments() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view departments',
          'requiresLogin': true,
        };
      }

      final departments = await _service.getDepartments();

      return {
        'success': true,
        'departments': departments.map((dept) => dept.toJson()).toList(),
        'total': departments.length,
        'message': 'Departments loaded successfully',
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on DepartmentException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'department',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load departments',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getTeamDepartments(int departmentId) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
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
          'type': 'validation',
        };
      }

      final teams = await _service.getTeamDepartments(departmentId);

      return {
        'success': true,
        'teams': teams.map((team) => team.toJson()).toList(),
        'total': teams.length,
        'department_id': departmentId,
        'message': 'Team departments loaded successfully',
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on DepartmentException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'department',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load team departments',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getUsersFromTeams(List<int> teamIds) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
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
          'type': 'validation',
        };
      }

      if (teamIds.any((id) => id <= 0)) {
        return {
          'success': false,
          'message': 'Invalid team ID provided',
          'type': 'validation',
        };
      }

      final users = await _service.getUsersFromTeams(teamIds);

      return {
        'success': true,
        'users': users.map((user) => user.toJson()).toList(),
        'total': users.length,
        'team_ids': teamIds,
        'message': 'Team users loaded successfully',
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on DepartmentException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'department',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load team users',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getUsersFromSingleTeam(int teamId) async {
    return await getUsersFromTeams([teamId]);
  }

  @override
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

      final departments =
          departmentsResult['departments'] as List<Map<String, dynamic>>;

      final department =
          departments.where((dept) => dept['id'] == departmentId).firstOrNull;

      if (department == null) {
        return {
          'success': false,
          'message': 'Department with ID $departmentId not found',
          'type': 'not_found',
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
        'message': 'Failed to load department with teams',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
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

      List<String> departmentNames = departments
          .map((dept) => dept['nama_department'] as String? ?? 'Unknown')
          .toList();

      return {
        'success': true,
        'statistics': {
          'total_departments': totalDepartments,
          'departments_with_manager': departmentsWithManager,
          'departments_without_manager': departmentsWithoutManager,
          'department_names': departmentNames,
        },
        'message': 'Department statistics loaded successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get department statistics',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
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
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to create meeting',
          'requiresLogin': true,
        };
      }

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

      if (!request.isValid) {
        return {
          'success': false,
          'message': request.validationError ?? 'Invalid meeting data',
          'type': 'validation',
        };
      }

      if (startTime.isAfter(endTime)) {
        return {
          'success': false,
          'message': 'Start time cannot be after end time',
          'type': 'validation',
        };
      }

      if (startTime.isBefore(DateTime.now().subtract(Duration(minutes: 5)))) {
        return {
          'success': false,
          'message': 'Meeting cannot be scheduled in the past',
          'type': 'validation',
        };
      }

      if (type == 'online' && (onlineUrl == null || onlineUrl.trim().isEmpty)) {
        return {
          'success': false,
          'message': 'Online URL is required for online meetings',
          'type': 'validation',
        };
      }

      if (type == 'offline' && (location == null || location.trim().isEmpty)) {
        return {
          'success': false,
          'message': 'Location is required for offline meetings',
          'type': 'validation',
        };
      }

      final meetingResponse = await _service.createMeeting(request);

      return {
        'success': true,
        'meeting': meetingResponse.meeting.toJson(),
        'head_department': meetingResponse.headDepartment,
        'message': meetingResponse.message,
        'created_at': DateTime.now().toIso8601String(),
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on DepartmentException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'department',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create meeting',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
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

  @override
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

  @override
  Future<Map<String, dynamic>> getMeetingCreationData() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
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
      return {
        'success': false,
        'message': 'Failed to load meeting creation data',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> validateMeetingParticipants({
    required int departmentId,
    required List<int> teamDepartmentIds,
    required List<String> userNips,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to validate participants',
          'requiresLogin': true,
        };
      }

      if (departmentId <= 0) {
        return {
          'success': false,
          'message': 'Invalid department ID',
          'type': 'validation',
        };
      }

      if (teamDepartmentIds.isEmpty) {
        return {
          'success': false,
          'message': 'At least one team must be selected',
          'type': 'validation',
        };
      }

      if (userNips.isEmpty) {
        return {
          'success': false,
          'message': 'At least one user must be selected',
          'type': 'validation',
        };
      }

      final departmentsResult = await getDepartments();
      if (!departmentsResult['success']) {
        return departmentsResult;
      }

      final departments = departmentsResult['departments'] as List;
      final department =
          departments.where((dept) => dept['id'] == departmentId).firstOrNull;

      if (department == null) {
        return {
          'success': false,
          'message': 'Department not found',
          'type': 'not_found',
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
          'type': 'validation',
          'invalidTeamIds': invalidTeamIds,
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
          'type': 'validation',
          'invalidUserNips': invalidUserNips,
        };
      }

      final validatedParticipants = {
        'department': department,
        'teams': teams
            .where((team) => teamDepartmentIds.contains(team['id']))
            .toList(),
        'users': users.where((user) => userNips.contains(user['nip'])).toList(),
      };

      return {
        'success': true,
        'message': 'All participants are valid',
        'participants': validatedParticipants,
        'summary': {
          'department_name': department['nama_department'],
          'teams_count': validatedParticipants['teams']?.length ?? 0,
          'users_count': validatedParticipants['users']?.length ?? 0,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate participants',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  bool isValidDepartmentId(int departmentId) {
    return departmentId > 0;
  }

  bool isValidTeamIds(List<int> teamIds) {
    return teamIds.isNotEmpty && teamIds.every((id) => id > 0);
  }

  bool isValidUserNips(List<String> userNips) {
    return userNips.isNotEmpty &&
        userNips.every((nip) => nip.trim().isNotEmpty);
  }

  bool isValidMeetingTime(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    return startTime.isAfter(now.subtract(Duration(minutes: 5))) &&
        startTime.isBefore(endTime);
  }

  String validateMeetingType(String type, String? onlineUrl, String? location) {
    if (type != 'online' && type != 'offline') {
      return 'Meeting type must be either "online" or "offline"';
    }

    if (type == 'online' && (onlineUrl == null || onlineUrl.trim().isEmpty)) {
      return 'Online URL is required for online meetings';
    }

    if (type == 'offline' && (location == null || location.trim().isEmpty)) {
      return 'Location is required for offline meetings';
    }

    return ''; // Valid
  }

  Map<String, dynamic> calculateMeetingDuration(
      DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);

    return {
      'hours': duration.inHours,
      'minutes': duration.inMinutes % 60,
      'totalMinutes': duration.inMinutes,
      'formatted': '${duration.inHours}h ${duration.inMinutes % 60}m',
    };
  }
}
