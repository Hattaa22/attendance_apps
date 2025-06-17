import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:fortis_apps/widget_global/custom_button/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:fortis_apps/widget_global/password_field/password_field.dart';
import 'package:fortis_apps/widget_global/form_field_one/form_field_one.dart';
import 'package:provider/provider.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
<<<<<<< API-logic_Daffa
    return ChangeNotifierProvider(
      create: (context) => LoginController(),
      child: Scaffold(
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
                    const SizedBox(height: 50),
                    // Logo
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
                      child: const Image(
                        image:
                            AssetImage('assets/images/logo-attendances-2.png'),
                        width: 24,
                        height: 24,
                      ),
=======
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
>>>>>>> login-reset-password_Wildan
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to Attendance!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
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
<<<<<<< API-logic_Daffa
                    const SizedBox(height: 30),
                  ],
                ),
=======
                  ),
                  const SizedBox(height: 20),
                ],
>>>>>>> login-reset-password_Wildan
              ),
            ),
            // Grey background section
            Expanded(
              child: Container(
                color: greyMainColor,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Consumer<LoginController>(
                      builder: (context, controller, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show general error if any
                            if (controller.generalError != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.generalError!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email/NIP field (static label)
                            FormFieldOne(
                              controller: controller.emailController,
                              labelText: 'Email or NIP',
                              hintText: 'Enter your email or NIP',
                              errorText: controller.emailError ?? '',
                              onChanged:
                                  (_) {}, // Controller handles this automatically
                            ),

                            const SizedBox(height: 14),
                            // Password field
                            CustomPasswordField(
                              controller: controller.passwordController,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              onChanged:
                                  (_) {}, // Controller handles this automatically
                              errorText: controller.passwordError,
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                              text: controller.isLoading
                                  ? 'Logging in...'
                                  : 'Login',
                              isEnabled: controller.isFormValid &&
                                  !controller.isLoading,
                              onPressed: controller.isLoading
                                  ? null
                                  : () async {
                                      // Validation and detection happens here on submit
                                      final result = await controller.login();

                                      if (result['success']) {
                                        // Login successful - navigate to home
                                        context.go('/home');
                                      }
                                      // Error handling is done in the controller
                                      // UI will update automatically via Consumer
                                    },
                            ),

                            // Show loading indicator
                            if (controller.isLoading) ...[
                              const SizedBox(height: 16),
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
