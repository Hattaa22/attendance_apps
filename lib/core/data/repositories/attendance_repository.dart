import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
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

  Future<Map<String, dynamic>> getTodayAttendanceStatus();

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
      print(
          'DEBUG: Starting clockIn with lat: $latitude, lng: $longitude, time: $waktu');

      if (!await _authRepository.isAuthenticated()) {
        print('DEBUG: Authentication failed');
        return {
          'success': false,
          'message': 'Please login to clock in',
          'requiresLogin': true,
        };
      }
      print('DEBUG: Authentication passed');

      final validation = _validateLocationAndTime(latitude, longitude, waktu);
      if (!validation['valid']) {
        print('DEBUG: Validation failed: ${validation['message']}');
        return {
          'success': false,
          'message': validation['message'],
          'requiresLogin': false,
          'type': 'validation',
        };
      }
      print('DEBUG: Validation passed');

      print('DEBUG: Getting today\'s records...');
      final todayRecords = await _service.getTodayAttendanceRecords();
      print('DEBUG: Got ${todayRecords.length} today records');

      // Check if already clocked in today
      final hasClockIn =
          todayRecords.any((record) => record.type == 'clock-in');
      print('DEBUG: Has clock-in today: $hasClockIn');

      if (hasClockIn) {
        final clockInRecord =
            todayRecords.firstWhere((record) => record.type == 'clock-in');
        print('DEBUG: Already clocked in, returning business rule error');
        return {
          'success': false,
          'message': 'You have already clocked in today',
          'requiresLogin': false,
          'alreadyClockedIn': true,
          'clockInTime': clockInRecord.waktu.toIso8601String(),
          'type': 'business_rule',
        };
      }

      print('DEBUG: Calling service.clockIn...');
      final attendance = await _service.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );
      print('DEBUG: Service.clockIn successful');

      return {
        'success': true,
        'message': 'Clock-in successful',
        'attendance': attendance.toJson(),
        'clockInTime': waktu.toIso8601String(),
      };
    } on AttendanceException catch (e) {
      print('DEBUG: AttendanceException caught: ${e.message}');
      // Handle backend business rule errors
      if (e.message.contains('Already clocked in') ||
          e.message.contains('sudah melakukan clock-in')) {
        return {
          'success': false,
          'message': 'You have already clocked in today',
          'requiresLogin': false,
          'alreadyClockedIn': true,
          'type': 'business_rule',
        };
      }

      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
      };
    } on UnauthorizedException catch (e) {
      print('DEBUG: UnauthorizedException caught: ${e.message}');
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on ValidationException catch (e) {
      print('DEBUG: ValidationException caught: ${e.message}');
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      print('DEBUG: NetworkException caught: ${e.message}');
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'network',
        'retryable': true,
      };
    } catch (e, stackTrace) {
      print('DEBUG: Unexpected exception caught: $e');
      print('DEBUG: Stack trace: $stackTrace');
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
          'type': 'validation',
        };
      }

      final todayRecords = await _service.getTodayAttendanceRecords();

      // Check if already clocked out today
      final hasClockOut =
          todayRecords.any((record) => record.type == 'clock-out');

      if (hasClockOut) {
        final clockOutRecord =
            todayRecords.firstWhere((record) => record.type == 'clock-out');
        return {
          'success': false,
          'message': 'You have already clocked out today',
          'requiresLogin': false,
          'alreadyClockedOut': true,
          'clockOutTime': clockOutRecord.waktu.toIso8601String(),
          'type': 'business_rule',
        };
      }

      // Check if clocked in first
      final hasClockIn =
          todayRecords.any((record) => record.type == 'clock-in');

      if (!hasClockIn) {
        return {
          'success': false,
          'message': 'You must clock in first before clocking out',
          'requiresLogin': false,
          'needsClockIn': true,
          'type': 'business_rule',
        };
      }

      final attendance = await _service.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );

      // Calculate work duration
      final clockInRecord =
          todayRecords.firstWhere((record) => record.type == 'clock-in');
      final workDuration =
          _calculateWorkDuration(clockInRecord.waktu, waktu);

      return {
        'success': true,
        'message': 'Clock-out successful',
        'attendance': attendance.toJson(),
        'clockOutTime': waktu.toIso8601String(),
        'workDuration': workDuration,
      };
    } on AttendanceException catch (e) {
      // Handle specific business rule errors from backend
      if (e.message.contains('must clock in first') ||
          e.message.contains('belum melakukan clock-in')) {
        return {
          'success': false,
          'message': 'You must clock in first before clocking out',
          'requiresLogin': false,
          'needsClockIn': true,
          'type': 'business_rule',
        };
      } else if (e.message.contains('already clocked out') ||
          e.message.contains('sudah melakukan clock-out')) {
        return {
          'success': false,
          'message': 'You have already clocked out today',
          'requiresLogin': false,
          'alreadyClockedOut': true,
          'type': 'business_rule',
        };
      }

      return {
        'success': false,
        'message': e.message,
        'requiresLogin': false,
        'type': 'attendance',
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
        // ✅ Fix: Change 'attendance' to 'records' to match test expectations
        'records': attendanceList.map((a) => a.toJson()).toList(),
        'statistics': statistics,
        'count': attendanceList.length,
        // ✅ Add: Include both keys for compatibility
        'attendance': attendanceList.map((a) => a.toJson()).toList(),
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
  Future<Map<String, dynamic>> getTodayAttendanceStatus() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'hasClockedIn': false,
          'hasClockedOut': false,
          'clockInTime': null,
          'clockOutTime': null,
          'records': [],
        };
      }

      final todayRecords = await _service.getTodayAttendanceRecords();

      bool hasClockedIn = false;
      bool hasClockedOut = false;
      String? clockInTime;
      String? clockOutTime;

      for (final record in todayRecords) {
        if (record.type == 'clock-in') {
          hasClockedIn = true;
          clockInTime = record.waktu.toIso8601String();
        } else if (record.type == 'clock-out') {
          hasClockedOut = true;
          clockOutTime = record.waktu.toIso8601String();
        }
      }

      return {
        'hasClockedIn': hasClockedIn,
        'hasClockedOut': hasClockedOut,
        'clockInTime': clockInTime,
        'clockOutTime': clockOutTime,
        'records': todayRecords.map((record) => record.toJson()).toList(),
      };
    } catch (e) {
      print('Error getting today\'s attendance status: $e');
      return {
        'hasClockedIn': false,
        'hasClockedOut': false,
        'clockInTime': null,
        'clockOutTime': null,
        'records': [],
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

  Map<String, dynamic> _calculateWorkDuration(
      DateTime clockInTime, DateTime clockOutTime) {
    try {
      // final clockIn = DateTime.parse(clockInTime);
      final duration = clockOutTime.difference(clockInTime);

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