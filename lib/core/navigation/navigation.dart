import 'package:flutter/material.dart';

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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
        BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded), label: 'LEAVE'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'CALENDER'),
        BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded), label: 'TIMESHEET'),
      ],
      backgroundColor: Colors.lightBlue.shade900,
      // selectedItemColor:
      //     currentIndex == -1 ? Colors.white : Colors.black,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      // onTap: onTap,
    );
  }
}
