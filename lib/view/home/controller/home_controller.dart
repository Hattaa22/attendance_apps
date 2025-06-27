import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/models/home_model.dart';
import '../../../core/data/repositories/attendance_repository.dart';

class HomeController with ChangeNotifier {
  final AttendanceRepository _attendanceRepository = AttendanceRepositoryImpl();

  bool isLoading = false;
  String errorMessage = '';
  List<Map<String, dynamic>> attendanceList = [];
  HomeAttendanceStat? stat;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  HomeController() {
    fetchAttendanceStat();
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
