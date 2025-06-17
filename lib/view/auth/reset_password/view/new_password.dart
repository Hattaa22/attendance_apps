import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/color/colors.dart';
import '../../../../widget_global/custom_button/custom_button.dart';
import '../../../../widget_global/password_field/password_field.dart';
import '../../../../widget_global/show_dialog_success/dialog_success.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isFormValid = false;
  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
      _isFormValid = _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordsMatch;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveNewPassword(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSuccessDialog(
        title: 'Password Changed Successfully',
        message: 'Your password has been updated successfully. You can now log in with your new password.',
        onOkayPressed: () => context.go('/login'),
      ),
    );
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
                      'Type your new password and confirm it below',
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
                      CustomPasswordField(
                        controller: _passwordController,
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        onChanged: (value) => _validateForm(),
                      ),
                      const SizedBox(height: 14),
                      CustomPasswordField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your new password',
                        onChanged: (value) => _validateForm(),
                      ),
                      if (!_passwordsMatch &&
                          _confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Password does not match',
                            style: TextStyle(
                              color: redMainColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Send button
                      CustomButton(
                        text: 'Save',
                        isEnabled: _isFormValid,
                        onPressed: () {
                          _saveNewPassword(context);
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
