import 'package:flutter/material.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Profile',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 32 / 16,
        color: Colors.black,
      ),
    );
  }
}
