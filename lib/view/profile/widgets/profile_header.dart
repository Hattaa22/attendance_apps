import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/profile_controller.dart';
import '../controller/photo_controller.dart';
import 'change_photo_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileController, PhotoController>(
      builder: (context, profileController, photoController, child) {
        final isLoading =
            profileController.isLoading || photoController.isUpdating;

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child: profileController.buildProfileImage(),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => _showPhotoChangeDialog(
                            context, profileController, photoController),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            )
                          : Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),


            Text(
              profileController.isLoading
                  ? 'Loading...'
                  : profileController.name,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 0.2 / 100 * 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),


            if (profileController.isLoading) ...[
              _buildLoadingTag(),
            ] else if (profileController.error != null) ...[
              _textTag('Error loading profile'),
            ] 
            // else ...[
            //   _textTag(profileController.department),
            // ],
          ],
        );
      },
    );
  }


  void _showPhotoChangeDialog(
    BuildContext context,
    ProfileController profileController,
    PhotoController photoController,
  ) {
    ChangePhotoProfile.show(
      context,
      onTakePhoto: () async {
        final result = await photoController.takePhoto(context);
        if (result['success'] && result['profile'] != null) {

          profileController.updateProfileData(result['profile']);
        }
      },
      onChoosePhoto: () async {
        final result = await photoController.choosePhoto(context);
        if (result['success'] && result['profile'] != null) {

          profileController.updateProfileData(result['profile']);
        }
      },
    );
  }

  Widget _buildLoadingTag() {
    return Container(
      width: 80,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _textTag(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 0.2 / 100 * 10,
        color: const Color(0xFF8B8B8B),
      ),
    );
  }
}
