import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';
import '../../attendance/view/attendance.dart';
import '../../calendar/view/calendar.dart';
import '../../leave/view/leave.dart';
import '../../profile/profile.dart';
import 'home_body.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeBody(),
    const AttendancePage(),
    const CalendarPage(),
    const LeavePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Navigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}