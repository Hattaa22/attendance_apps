import 'package:flutter/material.dart';

class ChangePasswordAlert extends StatelessWidget {
  final VoidCallback? onOkayPressed;

  const ChangePasswordAlert({
    super.key,
    this.onOkayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5), // Background transparan
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4), // Warna card
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon ceklis hijau
              Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Judul
              const Text(
                'Password successfully change!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi
              const Text(
                'Your new password has been successfully saved. Please use this password the next time you log in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: 0,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Okay
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onOkayPressed ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2463EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk memunculkan dialog
  static void show(BuildContext context, {VoidCallback? onOkayPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChangePasswordAlert(onOkayPressed: onOkayPressed);
      },
    );
  }
}
