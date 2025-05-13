import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';
import 'package:fortis_apps/core/appbar/app_bar_custom.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MenusTimesheetPage extends StatefulWidget {
  const MenusTimesheetPage({super.key});

  @override
  _MenusTimesheetPageState createState() => _MenusTimesheetPageState();
}

class _MenusTimesheetPageState extends State<MenusTimesheetPage> {
  final List<Map<String, dynamic>> attendanceData = [
    {
      'date': '26 Oktober 2021',
      'status': 'Absen',
      'lembur': '00.00',
      'clockIn': '08.30 AM',
      'clockOut': '17.30 AM',
      'terlambat': '00.00',
      'meninggalkanDini': '00.00',
      'totalPekerjaan': '00.00',
      'totalIstirahat': '00.00',
    },
    {
      'date': '27 Oktober 2021',
      'status': 'Absen',
      'lembur': '00.00',
      'clockIn': '08.30 AM',
      'clockOut': '17.30 AM',
      'terlambat': '00.00',
      'meninggalkanDini': '00.00',
      'totalPekerjaan': '00.00',
      'totalIstirahat': '00.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarCustom(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ...attendanceData.map((data) => _buildAttendanceCard(data)).toList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> data) {
    final cardColor = const Color(0xFFE9EBEA);
    final labelTextColor = const Color(0xFF170F4F);
    final valueTextColor = const Color(0xFF0E0F0F);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: Container(
            width: 283,
            padding: const EdgeInsets.only(top: 34, left: 28, right: 28, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal Absen',
                    style: GoogleFonts.roboto(
                      color: labelTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 14 / 13,
                      letterSpacing: 0.02,
                    )),
                const SizedBox(height: 6),
                Text(data['date'],
                    style: GoogleFonts.roboto(
                      color: valueTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 14 / 13,
                      letterSpacing: 0.02,
                    )),
                const SizedBox(height: 6),
                _buildRow(labelTextColor, valueTextColor, 'Status', data['status'], 'Lembur', data['lembur']),
                const SizedBox(height: 6),
                _buildRow(labelTextColor, valueTextColor, 'Clock In', data['clockIn'], 'Clock Out', data['clockOut']),
                const SizedBox(height: 6),
                _buildRow(labelTextColor, valueTextColor, 'Terlambat', data['terlambat'], 'Meninggalkan Dini', data['meninggalkanDini']),
                const SizedBox(height: 6),
                _buildRow(labelTextColor, valueTextColor, 'Total Pekerjaan', data['totalPekerjaan'], 'Total Istirahat', data['totalIstirahat']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(Color labelTextColor, Color valueTextColor, String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1,
                  style: GoogleFonts.roboto(
                    color: labelTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 14 / 13,
                    letterSpacing: 0.02,
                  )),
              const SizedBox(height: 4),
              Text(value1,
                  style: GoogleFonts.roboto(
                    color: valueTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2,
                  style: GoogleFonts.roboto(
                    color: labelTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 4),
              Text(value2,
                  style: GoogleFonts.roboto(
                    color: valueTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
