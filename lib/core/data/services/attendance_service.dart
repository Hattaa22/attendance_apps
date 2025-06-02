import '../repositories/attendance_repository.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;

  late AttendanceRepository _repository;

  AttendanceService._internal() {
    _repository = AttendanceRepositoryImpl();
  }

  // For testing
  AttendanceService.withRepository(this._repository);

  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      final attendance = await _repository.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      return {
        'success': true,
        'message': 'Clock-in berhasil',
        'attendance': attendance.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      final attendance = await _repository.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      return {
        'success': true,
        'message': 'Clock-out berhasil',
        'attendance': attendance.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
}
