import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Calendar Page'),
      ),
      // bottomNavigationBar: Navigation(),
    );
  }
}