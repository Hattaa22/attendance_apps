import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/color/colors.dart';
import '../../../../widget_global/custom_button/custom_button.dart';
import '../../../../widget_global/password_field/password_field.dart';
import '../../../../widget_global/show_dialog_success/dialog_success.dart';
import '../controller/new_password_controller.dart';

class NewPasswordPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const NewPasswordPage({super.key, this.data});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = NewPasswordController();
        // Initialize with session data
        if (widget.data != null) {
          controller.initialize(
            widget.data!['email'] ?? '',
            resetTokenId: widget.data!['resetTokenId'],
          );
        }
        return controller;
      },
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
                child: Consumer<NewPasswordController>(
                  builder: (context, controller, child) {
                    return Column(
                      children: [
                        const SizedBox(height: 0),
                        // Welcome text
                        const Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'Create a new password for ${controller.email}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(27, 27, 27, 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
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
                    child: Consumer<NewPasswordController>(
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

                            // New Password field
                            CustomPasswordField(
                              controller: controller.passwordController,
                              labelText: 'New Password',
                              hintText: 'Enter your new password',
                              errorText: controller.passwordError,
                              onChanged:
                                  (_) {}, // Controller handles this automatically
                            ),

                            // Password strength indicator
                            if (controller
                                .passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  final strength =
                                      controller.getPasswordStrength();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (strength['color'] as Color)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      strength['message'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: strength['color'] as Color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Password requirements
                              const SizedBox(height: 8),
                              ...controller.getPasswordRequirements().map(
                                    (req) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            req['valid']
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            size: 16,
                                            color: req['valid']
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            req['requirement'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: req['valid']
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],

                            const SizedBox(height: 14),

                            // Confirm Password field
                            CustomPasswordField(
                              controller: controller.confirmPasswordController,
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your new password',
                              errorText: controller.confirmPasswordError,
                              onChanged:
                                  (_) {}, // Controller handles this automatically
                            ),

                            // Password match indicator
                            if (controller
                                .confirmPasswordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    controller.passwordsMatch
                                        ? Icons.check_circle
                                        : Icons.error,
                                    size: 16,
                                    color: controller.passwordsMatch
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.passwordsMatch
                                        ? 'Passwords match'
                                        : 'Passwords do not match',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: controller.passwordsMatch
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Save button
                            CustomButton(
                              text: controller.isLoading ? 'Saving...' : 'Save',
                              isEnabled: controller.isFormValid &&
                                  !controller.isLoading,
                              onPressed: controller.isLoading
                                  ? null
                                  : () async {
                                      // Save new password
                                      final result =
                                          await controller.saveNewPassword();

                                      if (result['success']) {
                                        // Show success dialog
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) =>
                                              CustomSuccessDialog(
                                            title:
                                                'Password Changed Successfully',
                                            message:
                                                'Your password has been updated successfully. You can now log in with your new password.',
                                            onOkayPressed: () =>
                                                context.go('/login'),
                                          ),
                                        );
                                      }
                                    },
                            ),

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
