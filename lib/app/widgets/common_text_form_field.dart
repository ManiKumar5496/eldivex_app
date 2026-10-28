import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:flutter/services.dart';

class FormTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool required;
  final IconData? prefixIcon;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;

  const FormTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.required = false,
    this.prefixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field; required marker in the danger token.
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColor.danger),
                ),
            ],
          ),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Fill, border, radius, focus ring and error colours come from the
        // app theme.
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            fillColor: readOnly ? AppColor.surfaceMuted : null,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColor.textTertiary)
                : null,
            prefixIconConstraints: prefixIcon != null
                ? const BoxConstraints(minWidth: 40, minHeight: 40)
                : null,
          ),
          validator: validator ??
              (required
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
                  : null),
        ),
      ],
    );
  }
}
