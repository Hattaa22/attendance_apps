import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'dart:async';

import '../../../../widget_global/custom_button/custom_button.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _currentOtp = '';
  bool _isOtpComplete = false;

  Timer? _timer;
  int remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      remainingSeconds = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                      'Enter the OTP code sent to email ${widget.email}',
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
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          setState(() {
                            _currentOtp = pin;
                            _isOtpComplete = pin.length == 6;
                          });
                        },
                        onCompleted: (pin) {
                          setState(() {
                            _currentOtp = pin;
                            _isOtpComplete = true;
                          });
                          debugPrint("OTP is => $pin");
                        },
                      ),
                      const SizedBox(height: 24),
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
                            _canResend
                                ? InkWell(
                                    onTap: () {
                                      // Add your resend OTP logic here
                                      debugPrint(
                                          'Resending OTP to ${widget.email}');
                                      _startTimer();
                                    },
                                    child: Text(
                                      'Resend',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: blueMainColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
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
                      Center(
                        child: CustomButton(
                          text: 'Verify',
                          isEnabled: _isOtpComplete,
                          onPressed: () {
                            if (_isOtpComplete) {
                              debugPrint('OTP is => $_currentOtp');
                              context.go('/newPassword');
                            }
                          },
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
