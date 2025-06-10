import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:fortis_apps/core/navigation/navigation.dart';
import 'package:fortis_apps/core/color/colors.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int selectedYear = 2025;
  int selectedMonth = 4; // April

  final List<AttendanceRecord> allAttendanceRecords = [
    AttendanceRecord(
      date: 'Sat, Apr 10, 2025',
      checkIn: '',
      checkOut: '',
      workingHours: '',
      status: 'Leave',
      month: 4,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Fri, Apr 9, 2025',
      checkIn: '10:30 AM',
      checkOut: '04:00 PM',
      workingHours: '05:30:00',
      status: 'present',
      isToday: true,
      overtime: '00:00',
      late: '00:00',
      leavingEarly: '00:00',
      totalWork: '00:00',
      totalRest: '00:00',
      month: 4,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Thu, Apr 8, 2025',
      checkIn: '10:30 AM',
      checkOut: '04:00 PM',
      workingHours: '05:30:00',
      status: 'present',
      isToday: true,
      overtime: '00:00',
      late: '00:00',
      leavingEarly: '00:00',
      totalWork: '00:00',
      totalRest: '00:00',
      month: 4,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Wed, Apr 7, 2025',
      checkIn: '10:30 AM',
      checkOut: '04:00 PM',
      workingHours: '05:30:00',
      status: 'present',
      isToday: true,
      overtime: '00:00',
      late: '00:00',
      leavingEarly: '00:00',
      totalWork: '00:00',
      totalRest: '00:00',
      month: 4,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Fri, Mar 10, 2025',
      checkIn: '08:00 AM',
      checkOut: '04:00 PM',
      workingHours: '08:00:00',
      status: 'Leave',
      month: 3,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Thu, Mar 11, 2025',
      checkIn: '10:30 AM',
      checkOut: '04:00 PM',
      workingHours: '05:30:00',
      status: 'present',
      isToday: true,
      overtime: '00:00',
      late: '00:00',
      leavingEarly: '00:00',
      totalWork: '00:00',
      totalRest: '00:00',
      month: 3,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Wed, Mar 12, 2025',
      checkIn: '8:30 AM',
      checkOut: '02:00 PM',
      workingHours: '05:30:00',
      status: 'present',
      month: 3,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Tue, Mar 13, 2025',
      checkIn: '08:00 AM',
      checkOut: '02:00 PM',
      workingHours: '06:00:00',
      status: 'Half day',
      month: 3,
      year: 2025,
    ),
    AttendanceRecord(
      date: 'Mon, Mar 14, 2025',
      checkIn: '08:00 AM',
      checkOut: '02:00 PM',
      workingHours: '06:00:00',
      status: 'present',
      month: 3,
      year: 2025,
    ),
    // Add some February records for testing
    AttendanceRecord(
      date: 'Fri, Feb 28, 2025',
      checkIn: '09:00 AM',
      checkOut: '05:00 PM',
      workingHours: '08:00:00',
      status: 'present',
      month: 2,
      year: 2025,
    ),
  ];

  List<AttendanceRecord> get filteredAttendanceRecords {
    return allAttendanceRecords
        .where((record) => record.month == selectedMonth && record.year == selectedYear)
        .toList();
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

  void _showAttendanceDetails(AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAttendanceDetailsModal(record),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
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
            child: filteredAttendanceRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No attendance records found for this month',
                      style: TextStyle(
                        color: greyNavColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAttendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredAttendanceRecords[index];
                      return _buildAttendanceCard(record);
                    },
                  ),
          ),
        ],
      ),
      // bottomNavigationBar: Navigation(),
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Card(
      elevation: 1,
      color: record.status == 'Leave' ? Colors.red.shade50 : whiteMainColor, // Background merah muda untuk Leave
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAttendanceDetails(record),
        borderRadius: BorderRadius.circular(12),
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
                      color: record.status == 'Leave' 
                          ? Colors.red 
                          : (record.isToday ? blueMainColor : greyNavColor),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.date,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: record.status == 'Leave' 
                                ? Colors.red.shade700 
                                : deepNavyMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge positioned on the right
                  if (record.status == 'Leave') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Leave',
                        style: TextStyle(
                          color: whiteMainColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else if (record.status == 'Half day') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: greyNavColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Half day',
                        style: TextStyle(
                          color: whiteMainColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Show time info only for present status
              if (record.status == 'present') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeInfo('Check In', record.checkIn, greenMainColor),
                    ),
                    Expanded(
                      child: _buildTimeInfo('Check Out', record.checkOut, Colors.red),
                    ),
                    Expanded(
                      child: _buildTimeInfo('Working HRs', record.workingHours, Colors.orange),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
                // Refresh the list after closing the modal
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

  Widget _buildAttendanceDetailsModal(AttendanceRecord record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: whiteMainColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Attendance details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: deepNavyMainColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Present date', record.date),
          _buildDetailRow('Status', record.status),
          _buildDetailRow('Overtime', record.overtime),
          _buildDetailRow('Clock in', record.checkIn.isNotEmpty ? record.checkIn : '-'),
          _buildDetailRow('Clock Out', record.checkOut.isNotEmpty ? record.checkOut : '-'),
          _buildDetailRow('Late', record.late),
          _buildDetailRow('Leaving early', record.leavingEarly),
          _buildDetailRow('Total work', record.totalWork),
          _buildDetailRow('Total rest', record.totalRest),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueMainColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Okay',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(
              fontSize: 14,
              color: greyNavColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: deepNavyMainColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Data Model
class AttendanceRecord {
  final String date;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String status;
  final bool isToday;
  final String overtime;
  final String late;
  final String leavingEarly;
  final String totalWork;
  final String totalRest;
  final int month;
  final int year;

  AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.status,
    required this.month,
    required this.year,
    this.isToday = false,
    this.overtime = '00:00',
    this.late = '00:00',
    this.leavingEarly = '00:00',
    this.totalWork = '00:00',
    this.totalRest = '00:00',
  });
}