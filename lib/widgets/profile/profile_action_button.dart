import 'package:flutter/material.dart';
import '../../widgets/profile/log_out.dart';

class ProfileActionButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const ProfileActionButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(),
      child: InkWell(
        onTap: () {
          if (label == 'Logout') {
            LogOutPopup.show(context);
          } else {
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    label == 'Logout' ? Icons.logout : Icons.settings,
                    size: 30,
                    color: Colors.grey[600],
                  );
                },
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.2,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
