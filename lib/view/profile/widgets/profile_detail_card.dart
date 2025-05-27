import 'package:flutter/material.dart';

class ProfileDetailCard extends StatelessWidget {
  const ProfileDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _buildDetailRow('User ID', '12345'),
          _buildDivider(),
          _buildDetailRow('Email ID', 'sapsup87@gmail.com'),
          _buildDivider(),
          _buildDetailRow('Phone Number', '+62 877 1234 1234'),
        ],
      ),
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
              fontSize: 10,
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
                      fontSize: 10,
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
              : Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
        ],
      ),
    );
  }
}
