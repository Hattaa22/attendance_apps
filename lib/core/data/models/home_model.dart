import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAttendanceStat {
  final int presents;
  final int absent;
  final int lateIn;

  HomeAttendanceStat({
    required this.presents,
    required this.absent,
    required this.lateIn,
  });
}

/// Fungsi utility untuk menghitung statistik home dari list absensi API
HomeAttendanceStat calculateHomeAttendanceStat(
  List<Map<String, dynamic>> attendanceList,
  int year,
  int month,
) {
  // Group clock-in dan clock-out per tanggal
  final Map<String, Map<String, dynamic>> grouped = {};
  for (var record in attendanceList) {
    final waktuStr = record['waktu'];
    if (waktuStr == null) continue;
    final date = DateTime.tryParse(waktuStr);
    if (date == null) continue;
    if (date.year != year || date.month != month) continue;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    grouped.putIfAbsent(
        dateKey,
        () => {
              'clock_in': null,
              'clock_out': null,
            });

    if (record['type'] == 'clock-in') {
      grouped[dateKey]!['clock_in'] = waktuStr;
    } else if (record['type'] == 'clock-out') {
      grouped[dateKey]!['clock_out'] = waktuStr;
    }
  }

  int presents = 0;
  int lateIn = 0;

  grouped.forEach((dateKey, value) {
    if (value['clock_in'] != null) {
      presents++;
      // Parse clockInTime dalam UTC
      final clockInTime = DateTime.parse(value['clock_in']).toUtc();
      // Batas jam 8 pagi UTC (harus sama dengan clockInTime)
      final batas = DateTime.utc(
          clockInTime.year, clockInTime.month, clockInTime.day, 8, 0, 0);
      if (clockInTime.isAfter(batas)) {
        lateIn++;
      }
    }
  });

  // Hitung jumlah hari dalam bulan (untuk absent)
  final daysInMonth = DateUtils.getDaysInMonth(year, month);
  final absent = daysInMonth - presents;

  return HomeAttendanceStat(
    presents: presents,
    absent: absent < 0 ? 0 : absent,
    lateIn: lateIn,
  );
}
