import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:fortis_apps/view/menus_timesheet_page.dart';

class Navigation extends StatelessWidget {
  // final int currentIndex;
  // final Function(int) onTap;

  const Navigation({
    super.key,
    // required this.currentIndex,
    // required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/icon/home-icon.png')), label: 'HOME'),
        BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/leave-icon.png')), label: 'LEAVE'),
        BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/icon/calendar-icon.png')), label: 'CALENDER'),
        BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/timesheet-icon.png')), label: 'TIMESHEET'),
      ],
      backgroundColor: blueMainColor,
      // selectedItemColor:
      //     currentIndex == -1 ? Colors.white : Colors.black,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 3) { // Index 3 adalah TIMESHEET
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MenusTimesheetPage(),
            ),
          );
        }
      },
    );
  }
}
