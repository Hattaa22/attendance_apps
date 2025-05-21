import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
// import 'package:lucide_icons_flutter/test_icons.dart';
import 'package:fortis_apps/view/attendance/view/attendance.dart';
import 'package:fortis_apps/view/calendar/view/calendar.dart';
import 'package:fortis_apps/view/home/view/home.dart';
import 'package:fortis_apps/view/leave/view/leave.dart';
import 'package:fortis_apps/view/profile/view/profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const AttendancePage(),
    const CalendarPage(),
    const LeavePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardList), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calendarDays), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.logOut), label: 'Leave'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.circleUserRound), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: blueMainColor,
        unselectedItemColor: greyMainColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: IndexedStack(
  //       index: page,
  //       children: const [
  //         HomePage(),
  //         AttendancePage(),
  //         CalendarPage(),
  //         LeavePage(),
  //         ProfilePage(),
  //       ],
  //     ),
  //     bottomNavigationBar: NavigationBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       height: 64,
  //       // indicatorColor: primaryColor.withAlpha(24),
  //       selectedIndex: page,
  //       onDestinationSelected: _onItemTapped,
  //       destinations: [
  //         NavigationDestination(
  //           selectedIcon: Icon(LucideIcons.house, size: 24, color: blueMainColor,),
  //           icon: const Icon(LucideIcons.house, size: 24),
  //           label: 'Home',
  //         ),
  //         NavigationDestination(
  //           selectedIcon: Icon(LucideIcons.clipboard_list, size: 24, color: blueMainColor,),
  //           icon: const Icon(LucideIcons.clipboard_list, size: 24),
  //           label: 'Attendance',
  //         ),
  //         NavigationDestination(
  //           selectedIcon: Icon(LucideIcons.calendar_days, size: 24, color: blueMainColor,),
  //           icon: const Icon(LucideIcons.calendar_days, size: 24),
  //           label: 'Calendar',
  //         ),
  //         NavigationDestination(
  //           selectedIcon: Icon(LucideIcons.log_out, size: 24, color: blueMainColor,),
  //           icon: const Icon(LucideIcons.log_out, size: 24),
  //           label: 'Leave',
  //         ),
  //         NavigationDestination(
  //           selectedIcon: Icon(LucideIcons.circle_user_round, size: 24, color: blueMainColor,),
  //           icon: const Icon(LucideIcons.circle_user_round, size: 24),
  //           label: 'Profile',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _pages[_selectedIndex],
  //     bottomNavigationBar: BottomNavigationBar(
  //       items: const [
  //         BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Home'),
  //         BottomNavigationBarItem(
  //             icon: Icon(LucideIcons.clipboard_list), label: 'Attendance'),
  //         BottomNavigationBarItem(
  //             icon: Icon(LucideIcons.calendar_days), label: 'Calendar'),
  //         BottomNavigationBarItem(
  //             icon: Icon(LucideIcons.log_out), label: 'Leave'),
  //         BottomNavigationBarItem(
  //             icon: Icon(LucideIcons.circle_user_round), label: 'Profile'),
  //       ],
  //       backgroundColor: Colors.white,
  //       selectedItemColor: blueMainColor,
  //       unselectedItemColor: greyMainColor,
  //       type: BottomNavigationBarType.fixed,
  //       currentIndex: _selectedIndex,
  //       onTap: (index) {
  //         setState(() {
  //           _selectedIndex = index;
  //         });
  //       },
  //     ),
  //   );
  // }
