import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../widget_global/custom_button/custom_button.dart';
import '../../../../widget_global/form_field_one/form_field_one.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9.@]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
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
        _emailError = 'Invalid Email';
      });
      return false;
    }
    setState(() {
      _emailError = null;
    });
    return true;
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
                      FormFieldOne(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        errorText: _emailError ?? '',
                        onChanged: (_) => _updateFormState(),
                      ),
                      const SizedBox(height: 24),
                      // Send button
                      CustomButton(
                        text: 'Send',
                        isEnabled: _emailController.text.isNotEmpty,
                        onPressed: () {
                          if (_isValidEmail(_emailController.text)) {
                             context.push('/otp', extra: _emailController.text);
                          }
                        },
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
