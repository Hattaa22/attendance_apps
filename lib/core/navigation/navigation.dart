import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Navigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navigation(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icon/Home.png'),
            size: 30,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icon/Desk_alt.png'),
            size: 30,
          ),
          label: 'Attedance',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icon/Date_range.png'),
            size: 30,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icon/Sign_out_squre.png'),
            size: 30,
          ),
          label: 'Leave',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icon/User_cicrle_light.png'),
            size: 30,
          ),
          label: 'Leave',
        ),
      ],
      backgroundColor: Colors.white,
      selectedItemColor: blueMainColor,
      unselectedItemColor: greyNavColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
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
