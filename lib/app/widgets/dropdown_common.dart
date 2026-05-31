import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';


/// A professional, themed dropdown widget that supports generic types.
///
/// Use this for all dropdowns across the app to ensure consistent styling
/// with the app's color scheme and typography.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final bool isMandatory;
  final bool enabled;
  final bool clearable;
  final VoidCallback? onClear;
  final bool isDense;
  final bool isExpanded;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppDropdown({
    super.key,
    this.label,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isMandatory = false,
    this.enabled = true,
    this.clearable = false,
    this.onClear,
    this.isDense = false,
    this.isExpanded = true,
    this.height,
    this.padding,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    final bool isDisabled = !enabled || onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColor.lightGrey
                      : AppColor.unSelectedMenu,
                  fontFamily: 'poppins_regular',
                ),
              ),
              if (isMandatory)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColor.calenderRed,
                    fontSize: 14,
                    fontFamily: 'poppins_regular',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColor.fieldColorGrey
                : AppColor.whiteColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDisabled
                  ? AppColor.divColor
                  : hasValue
                      ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.4)
                      : AppColor.textFieldBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (isExpanded)
                Expanded(
                  child: _buildDropdownButton(isDisabled),
                )
              else
                _buildDropdownButton(isDisabled),
              if (clearable && hasValue && !isDisabled)
                GestureDetector(
                  onTap: onClear ?? () => onChanged?.call(null),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColor.lightGrey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownButton(bool isDisabled) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.lightGrey,
            fontFamily: 'poppins_regular',
          ),
        ),
        isExpanded: isExpanded,
        isDense: isDense,
        icon: isDisabled
            ? const SizedBox.shrink()
            : Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColor.prefixIconColor,
                size: 22,
              ),
        dropdownColor: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(borderRadius),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.cPrimaryHeadingColor,
          fontFamily: 'poppins_regular',
        ),
        items: items,
        onChanged: isDisabled ? null : onChanged,
      ),
    );
  }
}

/// A themed DropdownButtonFormField wrapper for use inside forms.
///
/// Provides consistent styling with validation support.
class AppDropdownFormField<T> extends StatelessWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final bool isMandatory;
  final bool enabled;
  final double borderRadius;
  final String? Function(T?)? validator;

  const AppDropdownFormField({
    super.key,
    this.label,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isMandatory = false,
    this.enabled = true,
    this.borderRadius = 10,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColor.lightGrey
                      : AppColor.unSelectedMenu,
                  fontFamily: 'poppins_regular',
                ),
              ),
              if (isMandatory)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColor.calenderRed,
                    fontSize: 14,
                    fontFamily: 'poppins_regular',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.cPrimaryHeadingColor,
            fontFamily: 'poppins_regular',
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColor.prefixIconColor,
            size: 22,
          ),
          dropdownColor: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(borderRadius),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColor.lightGrey,
              fontFamily: 'poppins_regular',
            ),
            filled: true,
            fillColor: isDisabled
                ? AppColor.fieldColorGrey
                : AppColor.whiteColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColor.cPrimaryButtonColor,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColor.divColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColor.calenderRed),
            ),
          ),
          items: items,
          onChanged: isDisabled ? null : onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

/// Backward-compatible convenience wrapper for simple string dropdowns.
class CommonDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?)? onChanged;
  final bool isMandatory;

  const CommonDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      label: label,
      hint: hint,
      value: value,
      isMandatory: isMandatory,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
