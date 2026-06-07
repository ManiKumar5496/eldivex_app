import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.cPrimarySubHeadingColorGrey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled
              ? () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue.shade600,
                      onPrimary: AppColor.whiteColor,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && onDateSelected != null) {
              onDateSelected!(picked);
            }
          }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: enabled ? AppColor.whiteColor : AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled
                    ? AppColor.textFieldBorderColor
                    : AppColor.divColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : hint,
                  style: TextStyle(
                    color: enabled
                        ? (selectedDate != null
                        ? AppColor.cPrimaryHeadingColor
                        : AppColor.cPrimarySubHeadingColorGrey)
                        : AppColor.fontColorGrey,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: enabled
                      ? AppColor.prefixIconColor
                      : AppColor.lightGrey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}