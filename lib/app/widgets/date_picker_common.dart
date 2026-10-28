import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/app_tokens.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CommonDatePicker extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime? selectedDate;
  final Function(DateTime?)? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const CommonDatePicker({
    Key? key,
    required this.label,
    required this.hint,
    this.selectedDate,
    this.enabled = true,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColor.textSecondary : AppColor.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        // Styled like the theme's text inputs: field fill, strong outline,
        // 10px radius. The picker itself follows the app's DatePicker theme
        // (light and dark).
        Material(
          color: enabled ? Theme.of(context).inputDecorationTheme.fillColor ??
              AppColor.whiteColor : AppColor.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: enabled ? AppColor.borderStrong : AppColor.divColor,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: enabled
                ? () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (picked != null && onDateSelected != null) {
                onDateSelected!(picked);
              }
            }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              // No flex children: the picker may sit in unbounded-width rows.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasValue
                        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                        : hint,
                    style: TextStyle(
                      color: !enabled
                          ? AppColor.textTertiary
                          : (hasValue
                              ? AppColor.textPrimary
                              : AppColor.textTertiary),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.calendar,
                    color: enabled ? AppColor.textTertiary : AppColor.lightGrey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
