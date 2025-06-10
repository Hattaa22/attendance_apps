import '../repositories/attendance_repository.dart';
import 'auth_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;

  late AttendanceRepository _repository;
  final AuthService _authService;

  AttendanceService._internal() : _authService = AuthService() {
    _repository = AttendanceRepositoryImpl();
  }

  // For testing
  AttendanceService.withRepository(this._repository) : _authService = AuthService();

  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to clock in',
          'requiresLogin': true,
        };
      }

      final attendance = await _repository.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      return {
        'success': true,
        'message': 'Clock-in successful',
        'attendance': attendance.toJson(),
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

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to clock out',
          'requiresLogin': true,
        };
      }

      final attendance = await _repository.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      return {
        'success': true,
        'message': 'Clock-out successful',
        'attendance': attendance.toJson(),
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
}
