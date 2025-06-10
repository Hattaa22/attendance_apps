import 'package:flutter/material.dart';
import '../../core/color/colors.dart';

class FormFieldOne extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int? maxLines;
  final String errorText;
  final Function(String)? onChanged;

  const FormFieldOne({ 
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines,
    this.errorText = '',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hoverColor: Colors.white,
            focusColor: Colors.white,
            hintText: hintText,
            errorText: errorText.isNotEmpty ? errorText : null,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            hintStyle: const TextStyle(
              color: Color.fromRGBO(165, 165, 165, 1),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}