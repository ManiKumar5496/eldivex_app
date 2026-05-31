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
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.cPrimarySubHeadingColorGrey,
              ),
            ),
            if (isMandatory)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColor.whiteColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? AppColor.textFieldBorderColor
                  : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            onChanged: onChanged,
            style: TextStyle(
              color: enabled ? Colors.black87 : Colors.grey.shade600,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: enabled
                    ? AppColor.fontColorGrey
                    : Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                prefixIcon,
                color: enabled
                    ? AppColor.prefixIconColor
                    : Colors.grey.shade400,
                size: 20,
              )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 0 : 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}