import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';
import '../../../core/color/colors.dart';

class CustomMultiSelect extends StatelessWidget {
  final List<String> options;
  final List<String> selectedValues;
  final Function(List<String>) onChanged;
  final String whenEmpty;
  final int maxSelection;
  final String maxSelectionMessage;

  const CustomMultiSelect({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.whenEmpty = 'Select items',
    this.maxSelection = 3,
    this.maxSelectionMessage = 'You can only select up to 3 items',
  });

  @override
  Widget build(BuildContext context) {
    return DropDownMultiSelect(
      onChanged: (List<String> values) {
        if (values.length <= maxSelection) {
          onChanged(values);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(maxSelectionMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      options: options,
      selectedValues: selectedValues,
      whenEmpty: whenEmpty,
      childBuilder: (selectedValues) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            selectedValues.isEmpty ? whenEmpty : selectedValues.join(', '),
            style: TextStyle(
              color: selectedValues.isEmpty ? Colors.grey[400] : Colors.black,
            ),
          ),
        );
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }
}