import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/app_tokens.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';


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
          _FieldLabel(
            label: label!,
            isMandatory: isMandatory,
            isDisabled: isDisabled,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          padding: padding ??
              const EdgeInsets.only(left: 14, right: 10),
          // Matches the theme's text inputs: field fill, strong outline.
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColor.surfaceMuted
                : (Theme.of(context).inputDecorationTheme.fillColor ??
                    AppColor.whiteColor),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDisabled ? AppColor.divColor : AppColor.borderStrong,
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
                Tooltip(
                  message: 'Clear',
                  child: InkWell(
                    onTap: onClear ?? () => onChanged?.call(null),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: AppColor.textTertiary,
                      ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textTertiary,
          ),
        ),
        isExpanded: isExpanded,
        isDense: isDense,
        icon: isDisabled
            ? const SizedBox.shrink()
            : Icon(
                LucideIcons.chevronDown,
                color: AppColor.textTertiary,
                size: 18,
              ),
        dropdownColor: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 4,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.textPrimary,
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

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _FieldLabel(
            label: label!,
            isMandatory: isMandatory,
            isDisabled: isDisabled,
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.textPrimary,
          ),
          icon: Icon(
            LucideIcons.chevronDown,
            color: AppColor.textTertiary,
            size: 18,
          ),
          dropdownColor: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          elevation: 4,
          // Border, focus ring and error colours come from the app theme;
          // only the corner radius honours the caller's value.
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColor.textTertiary,
            ),
            fillColor: isDisabled ? AppColor.surfaceMuted : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: _border(AppColor.borderStrong),
            enabledBorder: _border(AppColor.borderStrong),
            focusedBorder: _border(AppColor.cPrimaryButtonColor, 1.5),
            disabledBorder: _border(AppColor.divColor),
            errorBorder: _border(AppColor.danger),
            focusedErrorBorder: _border(AppColor.danger, 1.5),
          ),
          items: items,
          onChanged: isDisabled ? null : onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

/// Field label above a dropdown: 13.5 / w600 secondary text, required
/// marker in the danger token.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.isMandatory,
    required this.isDisabled,
  });

  final String label;
  final bool isMandatory;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
        color: isDisabled ? AppColor.textTertiary : AppColor.textSecondary,
      ),
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
