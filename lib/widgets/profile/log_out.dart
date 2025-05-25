import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LogOutPopup extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onLogout;
  final VoidCallback? onAddAccount;
  final VoidCallback? onClose;

  const LogOutPopup({
    super.key,
    this.onCancel,
    this.onLogout,
    this.onAddAccount,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Are you logging out?',
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
                        const TextSpan(
                          text:
                              'You can always log back in at any time. If you just want to switch accounts, you can ',
                        ),
                        TextSpan(
                          text: 'add another account',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = onAddAccount ?? () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 110,
                        child: OutlinedButton(
                          onPressed:
                              onCancel ?? () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.2,
                              letterSpacing: 0.002 * 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          onPressed:
                              onLogout ?? () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
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
              ),

              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context,
      {VoidCallback? onCancel,
      VoidCallback? onLogout,
      VoidCallback? onAddAccount}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => LogOutPopup(
        onCancel: onCancel,
        onLogout: onLogout,
        onAddAccount: onAddAccount,
      ),
    );
  }
}
