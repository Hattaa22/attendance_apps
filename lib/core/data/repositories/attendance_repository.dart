import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });

  Future<AttendanceModel> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio _dio;
  final AuthService _authService;

  AttendanceRepositoryImpl() : _dio = ApiService().dio, _authService = AuthService();

  @override
  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.post('/attendance/clock-in', data: {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd HH:mm:ss').format(waktu),
      });

      final attendance = AttendanceModel.fromJson(response.data['attendance']);
      return attendance;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(e.response?.data['message'] ?? 'Clock-in failed');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Clock-in failed: $e');
    }
  }

  @override
  Future<AttendanceModel> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.post('/attendance/clock-out', data: {
        'latitude': latitude,
        'longitude': longitude,
        'waktu': DateFormat('yyyy-MM-dd HH:mm:ss').format(waktu),
      });

      final attendance = AttendanceModel.fromJson(response.data['attendance']);
      return attendance;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(e.response?.data['message'] ?? 'Clock-out failed');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Clock-out failed: $e');
    }
  }
}
