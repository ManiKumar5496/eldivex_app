import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';

/// Compact operational mini-stats shown above the main stat cards:
/// "New bookings today" and "Cancellation rate".
class DashboardMiniStats extends GetView<DashboardController> {
  const DashboardMiniStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return const SizedBox.shrink();
      }
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _MiniStat(
            icon: Icons.today_outlined,
            iconColor: const Color(0xFF2563EB),
            label: 'New bookings today',
            value: '${controller.newBookingsToday.value}',
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
          _MiniStat(
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFE4574D),
            label: 'Cancellation rate',
            value: '${controller.cancellationRate.value.toStringAsFixed(1)}% '
                '(${controller.cancelledBookings.value})',
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
        ],
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.fontColorGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
}
