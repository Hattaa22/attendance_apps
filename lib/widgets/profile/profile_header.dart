import 'package:flutter/material.dart';
import '../../widgets/profile/change_photo_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  'images/profile.jpg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Show change photo modal
                  ChangePhotoProfile.show(
                    context,
                    onTakePhoto: () {
                      // Handle take photo action
                      _handleTakePhoto();
                    },
                    onChoosePhoto: () {
                      // Handle choose photo action
                      _handleChoosePhoto();
                    },
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    'icon/edit.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey[700],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Sawadikap',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _textTag('Fulltime'),
            _dot(),
            _textTag('Frontend WebDev'),
            _dot(),
            _textTag('Joined 25 Feb 2025'),
          ],
        )
      ],
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

  Widget _dot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFF8B8B8B),
        shape: BoxShape.circle,
      ),
    );
  }

  void _handleTakePhoto() {
    // TODO: Implementasi untuk mengambil foto dari kamera
    print('Take photo selected');
  }

  // Method untuk handle choose photo
  void _handleChoosePhoto() {
    // TODO: Implementasi untuk memilih foto dari galeri
    print('Choose photo from gallery selected');
  }
}