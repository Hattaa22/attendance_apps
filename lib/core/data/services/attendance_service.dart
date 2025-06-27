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
      print('DEBUG: Service - Starting clockIn API call...');
      final requestData = {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd H:mm:ss').format(waktu),
      };
      print('DEBUG: Service - Request data: $requestData');

      final response = await _dio
          .post('/attendance/clock-in', data: requestData)
          .timeout(Duration(seconds: 15));

      print('DEBUG: Service - Response status: ${response.statusCode}');
      print('DEBUG: Service - Response data: ${response.data}');

      if (response.data == null) {
        throw AttendanceException('Empty response from server');
      }

      if (response.data['attendance'] == null) {
        throw AttendanceException(
            'Invalid response format: missing attendance data');
      }

      final attendanceData = response.data['attendance'];
      print('DEBUG: Service - Parsing attendance data: $attendanceData');

      return AttendanceModel.fromJson(attendanceData);
    } on DioException catch (e) {
      print('DEBUG: Service - DioException in clockIn: ${e.message}');
      print('DEBUG: Service - Status code: ${e.response?.statusCode}');
      print('DEBUG: Service - Response data: ${e.response?.data}');

      String errorMessage = 'Clock-in failed';

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Laravel validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage =
              firstError is List ? firstError.first : firstError.toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation failed';
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 400) {
        // Handle backend business rule errors (400 status)
        final message = e.response?.data['message'] ?? 'Bad request';

        // Check for Indonesian message from your backend
        if (message.contains('sudah melakukan clock-in')) {
          throw AttendanceException('Already clocked in today');
        } else {
          throw AttendanceException(message);
        }
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
    } catch (e, stackTrace) {
      print('DEBUG: Service - Unexpected error in clockIn: $e');
      print('DEBUG: Service - Stack trace: $stackTrace');
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
      final response = await _dio.post('/attendance/clock-out', data: {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd H:mm:ss').format(waktu),
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
        // Laravel validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage =
              firstError is List ? firstError.first : firstError.toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'Validation failed';
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Bad request';

        if (message.contains('belum melakukan clock-in')) {
          throw AttendanceException(
              'You must clock in first before clocking out');
        } else if (message.contains('sudah melakukan clock-out')) {
          throw AttendanceException('You have already clocked out today');
        } else {
          throw AttendanceException(message);
        }
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
      final response = await _dio.get('/attendances/list');

      if (response.data == null) {
        throw AttendanceException('Empty response from server');
      }

      if (response.data['data'] == null) {
        throw AttendanceException('Invalid response format: missing data');
      }

      final List<dynamic> attendanceData = response.data['data'];
      print('DEBUG: Service - Got ${attendanceData.length} total records');

      List<AttendanceModel> allRecords = attendanceData.map((json) {
        try {
          return AttendanceModel.fromJson(json);
        } catch (e) {
          print('Error parsing attendance record: $e');
          print('Raw data: $json');
          rethrow;
        }
      }).toList();

      print(
          'DEBUG: Service - Parsed ${allRecords.length} records successfully');

      // ✅ Fix: Use direct date comparison (no timezone conversion)
      if (startDate != null) {
        final startDateString = DateFormat('yyyy-MM-dd').format(startDate);
        allRecords = allRecords.where((record) {
          final recordDateString =
              DateFormat('yyyy-MM-dd').format(record.waktu);
          return recordDateString.compareTo(startDateString) >= 0;
        }).toList();
        print(
            'DEBUG: Service - After start date filter: ${allRecords.length} records');
      }

      if (endDate != null) {
        final endDateString = DateFormat('yyyy-MM-dd').format(endDate);
        allRecords = allRecords.where((record) {
          final recordDateString =
              DateFormat('yyyy-MM-dd').format(record.waktu);
          return recordDateString.compareTo(endDateString) <= 0;
        }).toList();
        print(
            'DEBUG: Service - After end date filter: ${allRecords.length} records');
      }

      if (limit != null && limit > 0) {
        allRecords = allRecords.take(limit).toList();
        print('DEBUG: Service - After limit: ${allRecords.length} records');
      }

      print('DEBUG: Service - Returning ${allRecords.length} records');
      return allRecords;
    } on DioException catch (e) {
      print('DEBUG: Service - DioException: ${e.message}');
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
    } catch (e, stackTrace) {
      print('DEBUG: Service - Unexpected error: $e');
      print('DEBUG: Service - Stack trace: $stackTrace');
      if (e is AttendanceException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw AttendanceException('Failed to get attendance history: $e');
    }
  }

  Future<List<AttendanceModel>> getTodayAttendanceRecords() async {
    try {
      print('DEBUG: Service - Getting today\'s attendance records...');
      final response = await _dio.get('/attendances/list');
      print('DEBUG: Service - Response status: ${response.statusCode}');

      if (response.data == null || response.data['data'] == null) {
        print('DEBUG: Service - Empty response data');
        return [];
      }

      final List<dynamic> allRecords = response.data['data'];
      print('DEBUG: Service - Got ${allRecords.length} total records');

      // ✅ Fix: Use simple date string comparison (no timezone conversion)
      final now = DateTime.now();
      final todayDateString = DateFormat('yyyy-MM-dd').format(now);

      print('DEBUG: Service - Today date string: $todayDateString');
      print('DEBUG: Service - Current time: $now');

      final todayRecords = allRecords.where((recordData) {
        try {
          final record = AttendanceModel.fromJson(recordData);

          // ✅ Fix: Just compare date strings directly (no timezone conversion)
          final recordDateString =
              DateFormat('yyyy-MM-dd').format(record.waktu);

          bool isToday = recordDateString == todayDateString;

          print('DEBUG: Record ${record.id} (${record.type})');
          print('  Stored time: ${record.waktu}');
          print('  Record date: $recordDateString');
          print('  Today date: $todayDateString');
          print('  Is today: $isToday');

          return isToday;
        } catch (e) {
          print('DEBUG: Error parsing attendance record: $e');
          print('DEBUG: Raw record data: $recordData');
          return false;
        }
      }).toList();

      final result = todayRecords
          .map((record) => AttendanceModel.fromJson(record))
          .toList();
      print('DEBUG: Service - Returning ${result.length} today records');
      return result;
    } on DioException catch (e) {
      print('DEBUG: Service - DioException: ${e.message}');
      print('DEBUG: Service - Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw NetworkException('Failed to get today\'s records');
    } catch (e, stackTrace) {
      print('DEBUG: Service - Unexpected error: $e');
      print('DEBUG: Service - Stack trace: $stackTrace');
      throw AttendanceException('Failed to get today\'s records: $e');
    }
  }
}
