import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../../../core/data/models/home_model.dart';
import '../../../core/data/repositories/attendance_repository.dart';
import '../../../core/data/repositories/profile_repository.dart';

class HomeController with ChangeNotifier {
  final AttendanceRepository _attendanceRepository = AttendanceRepositoryImpl();
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();

  bool isLoading = false;
  String errorMessage = '';
  List<Map<String, dynamic>> attendanceList = [];
  HomeAttendanceStat? stat;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  HomeController() {
    fetchAttendanceStat();
  }

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

  Future<void> fetchAttendanceStat({int? year, int? month}) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final y = year ?? selectedYear;
    final m = month ?? selectedMonth;

    try {
      final result = await _attendanceRepository.getAttendanceHistory(
        startDate: DateTime(y, m, 1),
        endDate: DateTime(y, m + 1, 0),
      );

      if (result['success'] == true && result['attendance'] != null) {
        attendanceList = List<Map<String, dynamic>>.from(result['attendance']);
        stat = calculateHomeAttendanceStat(attendanceList, y, m);
      } else {
        errorMessage = result['message'] ?? 'Failed to fetch data';
        stat = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      stat = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeMonth(int year, int month) {
    selectedYear = year;
    selectedMonth = month;
    fetchAttendanceStat(year: year, month: month);
  }
}
