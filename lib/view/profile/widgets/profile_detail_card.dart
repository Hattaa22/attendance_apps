import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/profile_controller.dart';

class ProfileDetailCard extends StatelessWidget {
  const ProfileDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        return Container(
          decoration: _boxDecoration(),
          child: Column(
            children: [
              if (controller.isLoading) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B8B8B),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading profile...',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                ),
              ]

              else if (controller.error != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.error!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.red.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.refreshProfile(),
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size(0, 0),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]

              else ...[
                _buildDetailRow('User ID', controller.userId),
                _buildDivider(),
                _buildDetailRow('Email ID', controller.email),
                _buildDivider(),
                _buildDetailRow('Department', controller.department),
              ],
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFF8B8B8B).withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    bool isEmail = label == 'Email ID';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: 0.2,
              color: Color(0xFF8B8B8B),
            ),
          ),

          isEmail
              ? Builder(
                  builder: (context) {
                    final textStyle = const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Colors.black,
                    );

                    final textPainter = TextPainter(
                      text: TextSpan(text: value, style: textStyle),
                      textDirection: TextDirection.ltr,
                    )..layout();

                    final textWidth = textPainter.width;

                    const narrowChars = [
                      'i',
                      'l',
                      'I',
                      '1',
                      '|',
                      '!',
                      '.',
                      ':'
                    ];

                    final narrowCount = value
                        .split('')
                        .where((c) => narrowChars.contains(c))
                        .length;

                    final extraWidth = narrowCount * 1.8;

                    return Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(value, style: textStyle),
                        ),
                        Container(
                          width: textWidth + extraWidth,
                          height: 1,
                          color: Colors.black,
                        ),
                      ],
                    );
                  },
                )

              : Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ],
      ),
    );
  }
}
