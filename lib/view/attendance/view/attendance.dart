import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:get/get.dart';
import 'package:fortis_apps/view/attendance/controllers/attendance_controller.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceController attendanceController = Get.put(AttendanceController());

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    attendanceController.fetchAttendanceHistory(
      startDate: DateTime(selectedYear, selectedMonth, 1),
      endDate: DateTime(selectedYear, selectedMonth + 1, 0),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: whiteMainColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _buildMonthYearPicker(),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  /// Group records by date, and assign clock-in/clock-out per day
  List<Map<String, dynamic>> groupAttendanceByDate(List records) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var record in records) {
      final waktuStr = record['waktu'];
      if (waktuStr == null) continue;
      final date = DateTime.tryParse(waktuStr);
      if (date == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      grouped.putIfAbsent(dateKey, () => {
        'date': date,
        'clock_in': null,
        'clock_out': null,
        'late_duration': null,
        'overtime_duration': null,
        'raw_clock_in': null,
        'raw_clock_out': null,
      });

      if (record['type'] == 'clock-in') {
        grouped[dateKey]!['clock_in'] = DateFormat('HH:mm').format(date);
        grouped[dateKey]!['raw_clock_in'] = waktuStr;
        grouped[dateKey]!['late_duration'] = record['late_duration'];
        grouped[dateKey]!['overtime_duration'] = record['overtime_duration'];
      } else if (record['type'] == 'clock-out') {
        grouped[dateKey]!['clock_out'] = DateFormat('HH:mm').format(date);
        grouped[dateKey]!['raw_clock_out'] = waktuStr;
      }
    }
    // Sort descending by date
    final list = grouped.values.toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyMainColor,
      appBar: AppBar(
        backgroundColor: whiteMainColor,
        elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: deepNavyMainColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and month picker
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Monthly',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: deepNavyMainColor,
                  ),
                ),
                TextButton(
                  onPressed: _showMonthPicker,
                  style: TextButton.styleFrom(
                    backgroundColor: blueMainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMonthName(selectedMonth).toUpperCase(),
                        style: const TextStyle(
                          color: whiteMainColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: whiteMainColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (attendanceController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              // Filter data sesuai bulan & tahun
              final records = attendanceController.attendanceHistory.where((record) {
                final dateStr = record['waktu'];
                if (dateStr == null || dateStr is! String || dateStr.isEmpty) return false;
                final date = DateTime.tryParse(dateStr);
                if (date == null) return false;
                return date.month == selectedMonth && date.year == selectedYear;
              }).toList();

              final grouped = groupAttendanceByDate(records);

              if (grouped.isEmpty) {
                return const Center(
                  child: Text(
                    'No attendance records found for this month',
                    style: TextStyle(
                      color: greyNavColor,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final record = grouped[index];
                  return _buildAttendanceCard(record);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final date = record['date'] as DateTime?;
    final formattedDate = date != null
        ? DateFormat('EEE, MMM d, yyyy').format(date)
        : '-';

    final clockIn = record['clock_in'] ?? '-';
    final clockOut = record['clock_out'] ?? '-';

    String workingHours = '-';
    if (record['raw_clock_in'] != null && record['raw_clock_out'] != null) {
      try {
        final inTime = DateTime.parse(record['raw_clock_in']);
        final outTime = DateTime.parse(record['raw_clock_out']);
        final diff = outTime.difference(inTime);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        workingHours = '$hours:$minutes:$seconds';
      } catch (_) {
        workingHours = '-';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        color: whiteMainColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: blueMainColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: deepNavyMainColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInfo('Clock In', clockIn, greenMainColor),
                  ),
                  Expanded(
                    child: _buildTimeInfo('Clock Out', clockOut, Colors.red),
                  ),
                  Expanded(
                    child: _buildTimeInfo('Working HR\'s', workingHours, Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, Color color) {
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: greyNavColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    int newYear = selectedYear;
                    int newMonth = selectedMonth - 1;
                    if (newMonth < 1) {
                      newMonth = 12;
                      newYear--;
                    }
                    selectedYear = newYear;
                    selectedMonth = newMonth;
                  });
                  attendanceController.fetchAttendanceHistory(
                    startDate: DateTime(selectedYear, selectedMonth, 1),
                    endDate: DateTime(selectedYear, selectedMonth + 1, 0),
                  );
                },
                icon: const Icon(Icons.chevron_left, color: deepNavyMainColor),
              ),
              Text(
                '$selectedYear',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: deepNavyMainColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    int newYear = selectedYear;
                    int newMonth = selectedMonth + 1;
                    if (newMonth > 12) {
                      newMonth = 1;
                      newYear++;
                    }
                    selectedYear = newYear;
                    selectedMonth = newMonth;
                  });
                  attendanceController.fetchAttendanceHistory(
                    startDate: DateTime(selectedYear, selectedMonth, 1),
                    endDate: DateTime(selectedYear, selectedMonth + 1, 0),
                  );
                },
                icon: const Icon(Icons.chevron_right, color: deepNavyMainColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ].asMap().entries.map((entry) {
              int index = entry.key + 1;
              String month = entry.value;
              bool isSelected = index == selectedMonth;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMonth = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? blueMainColor : greyMainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      month,
                      style: TextStyle(
                        color: isSelected ? whiteMainColor : deepNavyMainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                attendanceController.fetchAttendanceHistory(
                  startDate: DateTime(selectedYear, selectedMonth, 1),
                  endDate: DateTime(selectedYear, selectedMonth + 1, 0),
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blueMainColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: whiteMainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
