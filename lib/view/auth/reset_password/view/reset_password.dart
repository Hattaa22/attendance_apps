import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:fortis_apps/widget_global/show_dialog_success/dialog_success.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isFormFilled = false;
  String? _emailError;
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9.@]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      _isFormFilled = _emailController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    if (!_emailRegex.hasMatch(email) || !email.contains("@")){
      setState(() {
        _emailError = 'Email tidak valid';
      });
      return false;
    }
    setState(() {
      _emailError = null;
    });
    return true;
  }

  void _sendToEmail(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSuccessDialog(
        title: 'Email terkirim!',
        message: 'Kami telah mengirim link reset password ke email $email',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // White background section
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  // Welcome text
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Masukkan email anda untuk mendapatkan link reset password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(27, 27, 27, 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Grey background section
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
                      // Email field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hoverColor: Colors.white,
                              focusColor: Colors.white,
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                  color: Color.fromRGBO(165, 165, 165, 1)),
                                                            errorText: _emailError,
                              errorStyle: TextStyle(color: Colors.red),
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
                                borderSide:
                                    const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Send button
                      ElevatedButton(
                        onPressed: _isFormFilled
                            ? () {
                                if(_isValidEmail(_emailController.text)) {
                                  _sendToEmail(context, _emailController.text);
                                }
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
                        child: Text(
                          'Kirim',
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
}
