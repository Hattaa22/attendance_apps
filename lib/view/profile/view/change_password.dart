import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:go_router/go_router.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController.addListener(_updateFormState);
    _newPasswordController.addListener(_updateFormState);
    _confirmPasswordController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      _isFormFilled = _oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Back Button + Title Below
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: 0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Enter your old password to change password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 0.002 * 14, // 0.2% of font size
                      color: const Color(0x1B1B1B).withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: greyMainColor,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        label: 'Old Password',
                        hint: 'Enter your old password',
                        controller: _oldPasswordController,
                        obscureText: _obscureOld,
                        toggleObscure: () {
                          setState(() {
                            _obscureOld = !_obscureOld;
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push('/resetPassword');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forget password?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                              letterSpacing: 0,
                              color: Color(0xFF2463EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'New Password',
                        hint: 'Enter your new password',
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        toggleObscure: () {
                          setState(() {
                            _obscureNew = !_obscureNew;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'Confirm Password',
                        hint: 'Confirm your new password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        toggleObscure: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isFormFilled
                            ? () {
                                if (_newPasswordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Passwords do not match.'),
                                    ),
                                  );
                                  return;
                                }

                                // Simpan password baru di sini
                                // PERBAIKAN: Gunakan pop dengan hasil true
                                context.pop(true); // Kirim hasil true ke halaman sebelumnya
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormFilled
                              ? blueMainColor
                              : const Color.fromRGBO(223, 223, 223, 1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.0,
              letterSpacing: 0,
              color: Color(0xFFA5A5A5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greyMainColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greyMainColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: toggleObscure,
            ),
          ),
        ),
      ],
    );
  }
}