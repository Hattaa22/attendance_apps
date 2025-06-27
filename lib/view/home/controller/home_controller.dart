import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fortis_apps/core/data/repositories/attendance_repository.dart';
import '../../../core/data/repositories/profile_repository.dart';

import '../../../core/data/models/auth_model.dart';

class HomeController extends GetxController {
  final AttendanceRepository _attendanceRepository = AttendanceRepositoryImpl();
  // final AuthRepository _authRepository = AuthRepositoryImpl();
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  var currentUser = Rxn<UserModel>();

  Future<Map<String, dynamic>> loadProfile() async {
    try {
      final result = await _profileRepository.getProfile();
      debugPrint('Profile Result: $result');
      return result;
    } catch (e) {
      debugPrint('Load Profile Error: $e');
      return {
        'success': false,
        'message': 'Failed to load profile',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      // Panggil repository attendance
      final result = await _attendanceRepository.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );
      debugPrint('Clock In Result: $result');
      return result;
    } catch (e) {
      debugPrint('Clock In Error: $e');
      return {
        'success': false,
        'message': 'Failed to clock in',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      // Panggil repository attendance
      final result = await _attendanceRepository.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );
      debugPrint('Clock Out Result: $result');
      return result;
    } catch (e) {
      debugPrint('Clock Out Error: $e');
      return {
        'success': false,
        'message': 'Failed to clock out',
        'details': e.toString(),
      };
    }
  }

Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final result = await _attendanceRepository.getAttendanceHistory();
      debugPrint('Today Attendance: $result');
      return result;
    } catch (e) {
      debugPrint('Get Today Attendance Error: $e');
      return {
        'success': false,
        'message': 'Failed to get attendance status',
        'hasClockedIn': false,
        'hasClockedOut': true
      };
    }
  }
}
