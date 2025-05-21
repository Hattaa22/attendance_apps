import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Attendance Page'),
      ),
      // bottomNavigationBar: Navigation(),
    );
  }
}