import 'package:flutter/material.dart';
import '../../widgets/profile/profile_title.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_detail_card.dart';
import '../../widgets/profile/profile_action_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileTitle(),
              const SizedBox(height: 24),
              const Center(child: ProfileHeader()),
              const SizedBox(height: 32),
              const ProfileDetailCard(),
              const SizedBox(height: 16),
              ProfileActionButton(
                label: 'Settings',
                iconPath: 'icon/Setting_fill.png',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              ProfileActionButton(
                label: 'Logout',
                iconPath: 'icon/Sign_out_squre_fill.png',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
