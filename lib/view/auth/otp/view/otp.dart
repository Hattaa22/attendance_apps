import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../../../widget_global/custom_button/custom_button.dart';
import '../controller/otp_controller.dart';

class OtpPage extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const OtpPage({
    super.key,
    required this.data,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = OtpController();
        // Initialize with email and reset token
        controller.initialize(
          widget.data['email'] ?? '',
          resetTokenId: widget.data['resetTokenId'],
        );
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
                child: Consumer<OtpController>(
                  builder: (context, controller, child) {
                    return Column(
                      children: [
                        const SizedBox(height: 0),
                        // Welcome text
                        const Text(
                          'OTP Verification',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'Enter the OTP code sent to email ${controller.email}',
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
                    padding: const EdgeInsets.all(30),
                    child: Consumer<OtpController>(
                      builder: (context, controller, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show general error if any
                            if (controller.generalError != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
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
                            ],

                            // OTP Input Field
                            OTPTextField(
                              length: 6,
                              width: MediaQuery.of(context).size.width,
                              fieldWidth: 45,
                              style: const TextStyle(fontSize: 15),
                              fieldStyle: FieldStyle.box,
                              otpFieldStyle: OtpFieldStyle(
                                backgroundColor: Colors.white,
                                borderColor: Colors.white,
                              ),
                              onChanged: (pin) {
                                controller.updateOtp(pin);
                              },
                              onCompleted: (pin) {
                                controller.updateOtp(pin);
                                debugPrint("OTP is => $pin");
                              },
                            ),
                            const SizedBox(height: 24),

                            // Resend OTP section
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Didn\'t receive the OTP? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: greyInputText,
                                    ),
                                  ),
                                  controller.canResend
                                      ? InkWell(
                                          onTap: controller.isLoading
                                              ? null
                                              : () async {
                                                  final result =
                                                      await controller
                                                          .resendOtp();

                                                  if (result['success']) {
                                                    // Show success message
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'OTP has been resent to ${controller.email}'),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  }
                                                  // Error handling is done in the controller
                                                },
                                          child: Text(
                                            controller.isLoading
                                                ? 'Resending...'
                                                : 'Resend',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: controller.isLoading
                                                  ? Colors.grey
                                                  : blueMainColor,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          controller.formattedTimer,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blueMainColor,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Verify button
                            Center(
                              child: CustomButton(
                                text: controller.isLoading
                                    ? 'Verifying...'
                                    : 'Verify',
                                isEnabled: controller.isOtpComplete &&
                                    !controller.isLoading,
                                onPressed: controller.isLoading
                                    ? null
                                    : () async {
                                        // Verify OTP
                                        final result =
                                            await controller.verifyOtp();

                                        if (result['success']) {
                                          // Navigate to new password screen
                                          context.go('/newPassword', extra: {
                                            'email': controller.email,
                                            'resetTokenId':
                                                widget.data['resetTokenId'],
                                          });
                                        }
                                      },
                              ),
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
