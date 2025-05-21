import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Leave Page'),
      ),
      // bottomNavigationBar: Navigation(),
    );
  }
}