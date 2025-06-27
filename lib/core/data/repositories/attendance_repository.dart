// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
import 'package:fortis_apps/core/data/repositories/auth_repository.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

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

abstract class AttendanceRepository {
  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });

  Future<Map<String, dynamic>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<Map<String, dynamic>> getTodayAttendance();

  Future<Map<String, dynamic>> getAttendanceStatus();

  Map<String, dynamic> validateClockInData({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });
  Map<String, dynamic> validateClockOutData({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  });
  String formatWorkDuration(int totalMinutes);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceService _service = AttendanceService();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  @override
  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to clock in',
          'requiresLogin': true,
        };
      }

      final validation = _validateLocationAndTime(latitude, longitude, waktu);
      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'requiresLogin': false,
        };
      }

      final todayAttendance = await _getTodayAttendanceSafely();
      if (todayAttendance != null && todayAttendance['clock_in'] != null) {
        return {
          'success': false,
          'message': 'You have already clocked in today',
          'requiresLogin': false,
          'alreadyClockedIn': true,
          'clockInTime': todayAttendance['clock_in'],
        };
      }

      final attendance = await _service.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      return {
        'success': true,
        'message': 'Clock-in successful',
        'attendance': attendance.toJson(),
        'clockInTime': waktu.toIso8601String(),
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
        'requiresLogin': false,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } on AttendanceException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during clock-in',
        'requiresLogin': false,
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to clock out',
          'requiresLogin': true,
        };
      }

      final validation = _validateLocationAndTime(latitude, longitude, waktu);
      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'requiresLogin': false,
        };
      }

      final todayAttendance = await _getTodayAttendanceSafely();
      if (todayAttendance != null && todayAttendance['clock_out'] != null) {
        return {
          'success': false,
          'message': 'You have already clocked out today',
          'requiresLogin': false,
          'alreadyClockedOut': true,
          'clockOutTime': todayAttendance['clock_out'],
        };
      }

      if (todayAttendance == null || todayAttendance['clock_in'] == null) {
        return {
          'success': false,
          'message': 'You must clock in first before clocking out',
          'requiresLogin': false,
          'needsClockIn': true,
        };
      }

      final attendance = await _service.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      final workDuration =
          _calculateWorkDuration(todayAttendance['clock_in'], waktu);

      return {
        'success': true,
        'message': 'Clock-out successful',
        'attendance': attendance.toJson(),
        'clockOutTime': waktu.toIso8601String(),
        'workDuration': workDuration,
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
        'requiresLogin': false,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } on AttendanceException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during clock-out',
        'requiresLogin': false,
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view attendance history',
          'requiresLogin': true,
        };
      }

      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        return {
          'success': false,
          'message': 'Start date cannot be after end date',
          'requiresLogin': false,
        };
      }

      final attendanceList = await _service.getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      final statistics = _calculateAttendanceStatistics(attendanceList);

      return {
        'success': true,
        'message': 'Attendance history retrieved successfully',
        'attendance': attendanceList.map((a) => a.toJson()).toList(),
        'statistics': statistics,
        'count': attendanceList.length,
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
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } on AttendanceException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get attendance history',
        'requiresLogin': false,
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view today\'s attendance',
          'requiresLogin': true,
        };
      }

      final attendance = await _service.getTodayAttendance();

      if (attendance == null) {
        return {
          'success': true,
          'message': 'No attendance record for today',
          'attendance': null,
          'hasClockedIn': false,
          'hasClockedOut': false,
        };
      }

      final attendanceData = attendance.toJson();
      final hasClockedIn = attendanceData['clock_in'] != null;
      final hasClockedOut = attendanceData['clock_out'] != null;

      String status = 'Not started';
      if (hasClockedIn && hasClockedOut) {
        status = 'Completed';
      } else if (hasClockedIn) {
        status = 'In progress';
      }

      return {
        'success': true,
        'message': 'Today\'s attendance retrieved successfully',
        'attendance': attendanceData,
        'hasClockedIn': hasClockedIn,
        'hasClockedOut': hasClockedOut,
        'status': status,
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
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } on AttendanceException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get today\'s attendance',
        'requiresLogin': false,
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getAttendanceStatus() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view attendance status',
          'requiresLogin': true,
        };
      }

      final status = await _service.getAttendanceStatus();

      return {
        'success': true,
        'message': 'Attendance status retrieved successfully',
        'status': status,
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
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } on AttendanceException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get attendance status',
        'requiresLogin': false,
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _validateLocationAndTime(
      double latitude, double longitude, DateTime waktu) {
    if (latitude < -90 || latitude > 90) {
      return {
        'valid': false,
        'message': 'Invalid latitude: must be between -90 and 90',
      };
    }

    if (longitude < -180 || longitude > 180) {
      return {
        'valid': false,
        'message': 'Invalid longitude: must be between -180 and 180',
      };
    }

    final now = DateTime.now();
    if (waktu.isAfter(now.add(Duration(minutes: 5)))) {
      return {
        'valid': false,
        'message': 'Time cannot be in the future',
      };
    }

    if (waktu.isBefore(now.subtract(Duration(hours: 24)))) {
      return {
        'valid': false,
        'message': 'Time cannot be more than 24 hours old',
      };
    }

    return {
      'valid': true,
      'message': 'Valid location and time',
    };
  }

  Future<Map<String, dynamic>?> _getTodayAttendanceSafely() async {
    try {
      final attendance = await _service.getTodayAttendance();
      return attendance?.toJson();
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _calculateWorkDuration(
      String clockInTime, DateTime clockOutTime) {
    try {
      final clockIn = DateTime.parse(clockInTime);
      final duration = clockOutTime.difference(clockIn);

      return {
        'hours': duration.inHours,
        'minutes': duration.inMinutes % 60,
        'totalMinutes': duration.inMinutes,
        'formatted': '${duration.inHours}h ${duration.inMinutes % 60}m',
      };
    } catch (e) {
      return {
        'hours': 0,
        'minutes': 0,
        'totalMinutes': 0,
        'formatted': 'Unknown',
        'error': 'Failed to calculate duration',
      };
    }
  }

  Map<String, dynamic> _calculateAttendanceStatistics(
      List<AttendanceModel> attendanceList) {
    if (attendanceList.isEmpty) {
      return {
        'totalDays': 0,
        'presentDays': 0,
        'averageWorkHours': 0.0,
        'onTimeDays': 0,
        'lateDays': 0,
      };
    }

    int presentDays = 0;
    int onTimeDays = 0;
    int lateDays = 0;
    double totalWorkHours = 0.0;

    for (final attendance in attendanceList) {
      final data = attendance.toJson();

      if (data['clock_in'] != null) {
        presentDays++;

        try {
          final clockIn = DateTime.parse(data['clock_in']);
          final standardStart =
              DateTime(clockIn.year, clockIn.month, clockIn.day, 9, 0);

          if (clockIn.isBefore(standardStart) ||
              clockIn.isAtSameMomentAs(standardStart)) {
            onTimeDays++;
          } else {
            lateDays++;
          }

          if (data['clock_out'] != null) {
            final clockOut = DateTime.parse(data['clock_out']);
            final workDuration = clockOut.difference(clockIn);
            totalWorkHours += workDuration.inMinutes / 60.0;
          }
        } catch (e) {
          // Skip this record if date parsing fails
        }
      }
    }

    return {
      'totalDays': attendanceList.length,
      'presentDays': presentDays,
      'averageWorkHours': presentDays > 0 ? totalWorkHours / presentDays : 0.0,
      'onTimeDays': onTimeDays,
      'lateDays': lateDays,
      'attendanceRate': attendanceList.length > 0
          ? (presentDays / attendanceList.length * 100)
          : 0.0,
    };
  }

  Map<String, dynamic> validateClockInData({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) {
    return _validateLocationAndTime(latitude, longitude, waktu);
  }

  Map<String, dynamic> validateClockOutData({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) {
    return _validateLocationAndTime(latitude, longitude, waktu);
  }

  bool isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  String formatWorkDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
