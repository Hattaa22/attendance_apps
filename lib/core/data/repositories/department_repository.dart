import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/department_model.dart';
import '../models/meeting_model.dart';

abstract class DepartmentRepository {
  Future<List<DepartmentModel>> getDepartments();
  Future<List<TeamDepartmentModel>> getTeamDepartments(int departmentId);
  Future<List<TeamUserModel>> getUsersFromTeams(List<int> teamIds);

  // New meeting method
  Future<MeetingResponse> createMeeting(CreateMeetingRequest request);
}

class DepartmentRepositoryImpl implements DepartmentRepository {
  final Dio _dio;
  final AuthService _authService;

  DepartmentRepositoryImpl() : _dio = ApiService().dio, _authService = AuthService();

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.get('/departments');

      final List<dynamic> departmentsData = response.data;
      final departments = departmentsData
          .map((json) => DepartmentModel.fromJson(json))
          .toList();

      return departments;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to get departments');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to get departments: $e');
    }
  }

  @override
  Future<List<TeamDepartmentModel>> getTeamDepartments(int departmentId) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.get('/departments/$departmentId/teams');

      final List<dynamic> teamsData = response.data;
      final teams =
          teamsData.map((json) => TeamDepartmentModel.fromJson(json)).toList();

      return teams;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to get team departments');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to get team departments: $e');
    }
  }

  @override
  Future<List<TeamUserModel>> getUsersFromTeams(List<int> teamIds) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.post('/teams/users', data: {
        'team_ids': teamIds,
      });

      final List<dynamic> usersData = response.data;
      final users =
          usersData.map((json) => TeamUserModel.fromJson(json)).toList();

      return users;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to get users from teams');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to get users from teams: $e');
    }
  }

  @override
  Future<MeetingResponse> createMeeting(CreateMeetingRequest request) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.post('/meetings', data: request.toJson());

      final meetingResponse = MeetingResponse.fromJson(response.data);
      return meetingResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      if (e.response?.statusCode == 422 && e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final errorMessage = firstError is List ? firstError.first : firstError;
        throw Exception(errorMessage);
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to create meeting');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to create meeting: $e');
    }
  }
}
