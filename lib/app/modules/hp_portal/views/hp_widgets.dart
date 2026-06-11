import 'package:flutter/material.dart';
import '../../../core/values/color_constants.dart';

/// Small shared building blocks for the caregiver portal so the tabs stay terse.
class HpUi {
  HpUi._();

  static String money(dynamic v) {
    final n = double.tryParse('$v') ?? 0;
    return '₹${n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2)}';
  }

  static Widget card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.divColor),
      ),
      child: child,
    );
  }

  static Widget sectionTitle(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.cPrimaryHeadingColor,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  static Color attendanceColor(String? status) {
    switch (status) {
      case 'present':
        return AppColor.lightGreen;
      case 'half_day':
        return Colors.orange;
      case 'leave':
        return AppColor.consultCColor;
      case 'absent':
        return AppColor.calenderRed;
      default:
        return AppColor.fontColorGrey;
    }
  }

  static Widget empty(String message, {IconData icon = Icons.inbox_outlined}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColor.fontColorGrey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center,
                style: TextStyle(color: AppColor.fontColorGrey)),
          ],
        ),
      ),
    );
  }

  static Widget kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(k, style: TextStyle(color: AppColor.fontColorGrey, fontSize: 13)),
          ),
          Expanded(
            child: Text(v.isEmpty || v == 'NA' ? '—' : v,
                style: TextStyle(color: AppColor.fontColorBlack, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
