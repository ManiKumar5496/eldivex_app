import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';

import '../../../role/controllers/role_controller.dart';
import '../../controllers/dashboard_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Compact operational mini-stats shown above the main stat cards:
/// "New bookings today" and "Cancellation rate". Both are Bookings metrics, so
/// they're hidden for roles without the Bookings module.
class DashboardMiniStats extends GetView<DashboardController> {
  const DashboardMiniStats({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = Get.find<RoleController>();
    return Obx(() {
      roles.accessList.length; // rebuild once role access loads
      if (!roles.hasAccess('Bookings')) return const SizedBox.shrink();
      if (controller.dashboardLoading.value) {
        return const SizedBox.shrink();
      }
      // Carries its own bottom gap so a hidden strip leaves no empty space.
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MiniStat(
              icon: LucideIcons.calendarCheck2,
              tone: AppTone.primary,
              label: 'New bookings today',
              value: '${controller.newBookingsToday.value}',
              onTap: () => Get.toNamed(Routes.BOOKINGS),
            ),
            _MiniStat(
              icon: LucideIcons.calendarX,
              tone: AppTone.danger,
              label: 'Cancellation rate',
              value:
                  '${controller.cancellationRate.value.toStringAsFixed(1)}% '
                  '(${controller.cancelledBookings.value})',
              onTap: () => Get.toNamed(Routes.BOOKINGS),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final AppTone tone;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _MiniStat({
    required this.icon,
    required this.tone,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: radius,
        border: Border.all(color: AppColor.divColor),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconTile(icon: icon, tone: tone, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColor.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 14),
                  Icon(LucideIcons.chevronRight,
                      size: 18, color: AppColor.lightGrey),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
