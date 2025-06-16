import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/department_model.dart';
import '../models/meeting_model.dart';

class DepartmentException implements Exception {
  final String message;
  DepartmentException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class DepartmentService {
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;
  DepartmentService._internal();

  final Dio _dio = ApiService().dio;

  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response =
          await _dio.get('/departments').timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw DepartmentException('Empty response from server');
      }

      final List<dynamic> departmentsData = response.data;
      return departmentsData
          .map((json) => DepartmentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw DepartmentException(
          e.response?.data['message'] ?? 'Failed to get departments');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw DepartmentException('Failed to get departments: $e');
    }
  }

  Future<List<TeamDepartmentModel>> getTeamDepartments(int departmentId) async {
    try {
      final response = await _dio
          .get('/departments/$departmentId/teams')
          .timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw DepartmentException('Empty response from server');
      }

      final List<dynamic> teamsData = response.data;
      return teamsData
          .map((json) => TeamDepartmentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw DepartmentException('Department not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw DepartmentException(
          e.response?.data['message'] ?? 'Failed to get team departments');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw DepartmentException('Failed to get team departments: $e');
    }
  }

  Future<List<TeamUserModel>> getUsersFromTeams(List<int> teamIds) async {
    try {
      final response = await _dio.post('/teams/users', data: {
        'team_ids': teamIds,
      }).timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw DepartmentException('Empty response from server');
      }

      final List<dynamic> usersData = response.data;
      return usersData.map((json) => TeamUserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          final errorMessage =
              firstError is List ? firstError.first : firstError.toString();
          throw ValidationException(errorMessage);
        } else {
          throw ValidationException(
              e.response?.data['message'] ?? 'Validation failed');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw DepartmentException(
          e.response?.data['message'] ?? 'Failed to get users from teams');
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw DepartmentException('Failed to get users from teams: $e');
    }
  }

  Future<MeetingResponse> createMeeting(CreateMeetingRequest request) async {
    try {
      final response = await _dio
          .post('/meetings', data: request.toJson())
          .timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw DepartmentException('Empty response from server');
      }

      return MeetingResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          final errorMessage =
              firstError is List ? firstError.first : firstError.toString();
          throw ValidationException(errorMessage);
        } else {
          throw ValidationException(
              e.response?.data['message'] ?? 'Validation failed');
        }
      } else if (e.response?.statusCode == 400) {
        throw DepartmentException(e.response?.data['message'] ?? 'Bad request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw DepartmentException(
          e.response?.data['message'] ?? 'Failed to create meeting');
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw DepartmentException('Failed to create meeting: $e');
    }
  }
}
