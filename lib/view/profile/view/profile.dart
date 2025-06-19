import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../profile/widgets/profile_title.dart';
import '../../profile/widgets/profile_header.dart';
import '../../profile/widgets/profile_detail_card.dart';
import '../../profile/widgets/profile_action_button.dart';
import '../../profile/widgets/change_password_alert.dart';
import '../../profile/widgets/log_out.dart'; // ✅ Add this import

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
                label: 'Change password',
                iconPath: 'icon/Password.png',
                onTap: () async {
                  // Gunakan push dan tunggu hasil
                  final result = await context.push('/changePassword');

                  // Jika berhasil ganti password, tampilkan alert di profile
                  // Cek apakah context masih valid sebelum menampilkan dialog
                  if (result == true && context.mounted) {
                    ChangePasswordAlert.show(
                      context,
                      onOkayPressed: () {
                        Navigator.of(context).pop(); // Tutup dialog
                        // Tetap di profile page
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              
              ProfileActionButton(
                label: 'Logout',
                iconPath: 'icon/Sign_out_squre_fill.png',
                onTap: () {
                  LogOutPopup.show(
                    context
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
