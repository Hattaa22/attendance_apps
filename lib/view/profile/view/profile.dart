import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/profile_controller.dart';
import '../controller/photo_controller.dart';
import '../widgets/profile_title.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_detail_card.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/change_password_alert.dart';
import '../widgets/log_out.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final controller = ProfileController();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.initialize();
            });
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => PhotoController(),
        ),
      ],
      child: Scaffold(
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
                    final result = await context.push('/changePassword');

                    if (result == true && context.mounted) {
                      ChangePasswordAlert.show(
                        context,
                        onOkayPressed: () {
                          Navigator.of(context).pop();
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
                    LogOutPopup.show(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
