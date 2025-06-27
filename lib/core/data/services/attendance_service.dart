import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';

class AttendanceException implements Exception {
  final String message;
  AttendanceException(this.message);

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

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final Dio _dio = ApiService().dio;

  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      final response = await _dio.post('/attendances/clock-in', data: {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd HH:mm:ss').format(waktu),
      }).timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw AttendanceException('Empty response from server');
      }

      if (response.data['attendance'] == null) {
        throw AttendanceException(
            'Invalid response format: missing attendance data');
      }

      return AttendanceModel.fromJson(response.data['attendance']);
    } on DioException catch (e) {
      String errorMessage = 'Clock-in failed';

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Handle validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage =
              firstError is List ? firstError.first : firstError.toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation failed';
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 409) {
        // Conflict - already clocked in
        throw AttendanceException(
            e.response?.data['message'] ?? 'Already clocked in today');
      } else if (e.response?.statusCode == 400) {
        // Bad request - location issues, etc.
        throw AttendanceException(
            e.response?.data['message'] ?? 'Invalid request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Unable to connect to server - please check your internet connection');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw AttendanceException(errorMessage);
      }

      throw AttendanceException('Clock-in failed: Network error');
    } catch (e) {
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Clock-in failed: $e');
    }
  }

  Future<AttendanceModel> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      final response = await _dio.post('/attendances/clock-out', data: {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd HH:mm:ss').format(waktu),
      }).timeout(Duration(seconds: 15));

      if (response.data == null) {
        throw AttendanceException('Empty response from server');
      }

      if (response.data['attendance'] == null) {
        throw AttendanceException(
            'Invalid response format: missing attendance data');
      }

      return AttendanceModel.fromJson(response.data['attendance']);
    } on DioException catch (e) {
      String errorMessage = 'Clock-out failed';

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage =
              firstError is List ? firstError.first : firstError.toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation failed';
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 409) {
        throw AttendanceException(e.response?.data['message'] ??
            'Already clocked out or no clock-in found');
      } else if (e.response?.statusCode == 400) {
        throw AttendanceException(
            e.response?.data['message'] ?? 'Invalid request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Unable to connect to server - please check your internet connection');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
        throw AttendanceException(errorMessage);
      }

      throw AttendanceException('Clock-out failed: Network error');
    } catch (e) {
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Clock-out failed: $e');
    }
  }

  Future<List<AttendanceModel>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
      }
      if (endDate != null) {
        queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response =
          await _dio.get('/attendances/list', queryParameters: queryParams);

      if (response.data == null) {
        throw AttendanceException('Empty response from server');
      }

      final List<dynamic> attendanceData =
          response.data['data'] ?? response.data['attendance'] ?? [];

      return attendanceData
          .map((json) => AttendanceModel.fromJson(json))
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

      throw AttendanceException(
          e.response?.data['message'] ?? 'Failed to get attendance history');
    } catch (e) {
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Failed to get attendance history: $e');
    }
  }

  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      final response = await _dio.get('/attendances/today');

      if (response.data == null) {
        return null;
      }

      if (response.data['attendance'] == null) {
        return null;
      }

      return AttendanceModel.fromJson(response.data['attendance']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        return null;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw AttendanceException(
          e.response?.data['message'] ?? 'Failed to get today\'s attendance');
    } catch (e) {
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Failed to get today\'s attendance: $e');
    }
  }

  Future<Map<String, dynamic>> getAttendanceStatus() async {
    try {
      final response = await _dio.get('/attendances/status');

      return response.data ?? {};
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

      throw AttendanceException(
          e.response?.data['message'] ?? 'Failed to get attendance status');
    } catch (e) {
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Failed to get attendance status: $e');
    }
  }
}
