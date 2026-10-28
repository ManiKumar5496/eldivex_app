import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final bool isMandatory;
  final ValueChanged<String>? onChanged;

  const CommonTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.enabled = true,
    this.isMandatory = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field; required marker in the danger token.
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (isMandatory)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColor.danger),
                ),
            ],
          ),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColor.textSecondary : AppColor.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        // Fill, border, radius and focus ring come from the app theme.
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(
            color: enabled ? AppColor.textPrimary : AppColor.textTertiary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            fillColor: enabled ? null : AppColor.surfaceMuted,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: enabled
                        ? AppColor.textTertiary
                        : AppColor.lightGrey,
                    size: 18,
                  )
                : null,
            prefixIconConstraints: prefixIcon != null
                ? const BoxConstraints(minWidth: 40, minHeight: 40)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
