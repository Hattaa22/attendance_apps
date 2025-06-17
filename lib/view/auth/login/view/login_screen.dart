import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:fortis_apps/widget_global/custom_button/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:fortis_apps/widget_global/password_field/password_field.dart';
import 'package:fortis_apps/widget_global/form_field_one/form_field_one.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9.@]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {});
  }

  bool _isValidEmail(String email) {
    if (!_emailRegex.hasMatch(email) || !email.contains("@")) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  // Checkmark icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromRGBO(225, 230, 236, 1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: SvgPicture.asset(
                        'assets/icon/Check_fill.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          blueMainColor,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Welcome text
                  const Text(
                    'Welcome to Attendance!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromRGBO(238, 238, 238, 1), width: 3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
                      const SizedBox(height: 14),
                      // Password field
                      CustomPasswordField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        onChanged: (_) => _updateFormState(),
                      ),
                      const SizedBox(height: 6),
                      // Forgot password
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
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      CustomButton(
                        text: 'Login',
                        isEnabled: _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty,
                        onPressed: () {
                          if (_isValidEmail(_emailController.text)) {
                            context.go('/home');
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
