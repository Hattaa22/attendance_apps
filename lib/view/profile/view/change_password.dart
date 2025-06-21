import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fortis_apps/core/color/colors.dart';
import '../controller/change_password_controller.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = ChangePasswordController();
        controller.initialize();
        return controller;
      },
      child: Consumer<ChangePasswordController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Header section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Back Button + Title
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: controller.isLoading
                                  ? null
                                  : () => context.pop(),
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
                            letterSpacing: 0.002 * 14,
                            color: const Color(0x1B1B1B).withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Form section
                Expanded(
                  child: Container(
                    color: greyMainColor,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Old Password Field
                            _buildPasswordField(
                              context: context,
                              controller: controller,
                              label: 'Old Password',
                              hint: 'Enter your old password',
                              textController: controller.oldPasswordController,
                              obscureText: controller.obscureOld,
                              toggleObscure:
                                  controller.toggleOldPasswordVisibility,
                            ),

                            const SizedBox(height: 6),

                            // Forget Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => context.push('/resetPassword'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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

                            // New Password Field
                            _buildPasswordField(
                              context: context,
                              controller: controller,
                              label: 'New Password',
                              hint: 'Enter your new password',
                              textController: controller.newPasswordController,
                              obscureText: controller.obscureNew,
                              toggleObscure:
                                  controller.toggleNewPasswordVisibility,
                              showStrength: true,
                            ),

                            const SizedBox(height: 16),

                            // Confirm Password Field
                            _buildPasswordField(
                              context: context,
                              controller: controller,
                              label: 'Confirm Password',
                              hint: 'Confirm your new password',
                              textController:
                                  controller.confirmPasswordController,
                              obscureText: controller.obscureConfirm,
                              toggleObscure:
                                  controller.toggleConfirmPasswordVisibility,
                            ),

                            const SizedBox(height: 24),

                            // ✅ Change Password Button with Controller
                            ElevatedButton(
                              onPressed: (controller.isFormFilled &&
                                      !controller.isLoading)
                                  ? () =>
                                      _handleChangePassword(context, controller)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (controller.isFormFilled &&
                                        !controller.isLoading)
                                    ? blueMainColor
                                    : const Color.fromRGBO(223, 223, 223, 1),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
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
        },
      ),
    );
  }

  Future<void> _handleChangePassword(
      BuildContext context, ChangePasswordController controller) async {
    final result = await controller.changePassword(context);

    if (result['success']) {
      // Success - pop with true result
      context.pop(true);
    }
    // Error handling is done in controller via SnackBars
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required ChangePasswordController controller,
    required String label,
    required String hint,
    required TextEditingController textController,
    required bool obscureText,
    required VoidCallback toggleObscure,
    bool showStrength = false,
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
          controller: textController,
          obscureText: obscureText,
          enabled: !controller.isLoading,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color:
                    controller.isLoading ? Colors.grey.shade400 : Colors.grey,
              ),
              onPressed: controller.isLoading ? null : toggleObscure,
            ),
          ),
        ),

        if (showStrength && textController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Password strength: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                controller.getPasswordStrength(textController.text),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      controller.getPasswordStrengthColor(textController.text),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
