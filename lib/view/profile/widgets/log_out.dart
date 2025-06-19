import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controller/logout_controller.dart';

class LogOutPopup extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onClose;
  final bool showLoading;

  const LogOutPopup({
    super.key,
    this.onCancel,
    this.onClose,
    this.showLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LogoutController(),
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Consumer<LogoutController>(
                  builder: (context, controller, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            controller.isLoading
                                ? 'Logging out...'
                                : 'Are you sure want to Log out?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              height: 1.2,
                              letterSpacing: 0.002 * 16,
                              color: const Color(0xFF2463EB),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (controller.error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.error!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          // Description (only show if no error)
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                height: 1.2,
                                letterSpacing: 0.002 * 11,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.isLoading
                                      ? 'Please wait while we sign you out...'
                                      : 'You can always log back in at any time.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Loading indicator
                        if (controller.isLoading && showLoading) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 8),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cancel button
                            SizedBox(
                              width: 110,
                              child: OutlinedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : (onCancel ??
                                        () => Navigator.of(context).pop()),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: controller.isLoading
                                        ? Colors.grey
                                        : Colors.black,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.2,
                                    letterSpacing: 0.002 * 14,
                                    color: controller.isLoading
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Logout button
                            SizedBox(
                              width: 110,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () async {
                                        final result =
                                            await controller.logout();
                                        if (result['success']) {
                                          print('Logout successful, closing popup');

                                          // Close popup first
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                            print('Popup closed');
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Logged out successfully'),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                          if (context.mounted) {
                                            try {
                                              context.go('/login');
                                            } catch (e) {
                                              print('Navigation error: $e');
                                            }
                                          } 
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.isLoading
                                      ? Colors.grey
                                      : Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  controller.isLoading
                                      ? 'Logging out...'
                                      : 'Log out',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.2,
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                // Close button (X)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Consumer<LogoutController>(
                    builder: (context, controller, child) {
                      return GestureDetector(
                        onTap: controller.isLoading
                            ? null
                            : (onClose ?? () => Navigator.of(context).pop()),
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color:
                              controller.isLoading ? Colors.grey : Colors.black,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    VoidCallback? onCancel,
    VoidCallback? onLogoutSuccess,
    VoidCallback? onClose,
    bool showLoading = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => LogOutPopup(
        onCancel: onCancel,
        onClose: onClose,
        showLoading: showLoading,
      ),
    );
  }
}
