import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../widget_global/custom_button/custom_button.dart';
import '../../../../widget_global/form_field_one/form_field_one.dart';
import '../controller/reset_password_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResetPasswordController(),
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Consumer<ResetPasswordController>(
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

                            // Email/NIP field
                            FormFieldOne(
                              controller: controller.emailController,
                              labelText: 'Email or NIP',
                              hintText: 'Enter your email or NIP',
                              errorText: controller.emailError ?? '',
                              onChanged:
                                  (_) {}, // Controller handles this automatically
                            ),

                            // Show identifier type if detected
                            if (controller.emailController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Detected as: ${controller.getIdentifierTypeText()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Send button
                            CustomButton(
                              text:
                                  controller.isLoading ? 'Sending...' : 'Send',
                              isEnabled: controller.isFormValid &&
                                  !controller.isLoading,
                              onPressed: controller.isLoading
                                  ? null
                                  : () async {
                                      // Send reset request
                                      final result =
                                          await controller.sendResetRequest();

                                      if (result['success']) {
                                        // Navigate to OTP screen with email and reset token
                                        context.push('/otp', extra: {
                                          'email':
                                              controller.emailController.text,
                                          'resetTokenId':
                                              result['reset_token_id'],
                                        });
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
