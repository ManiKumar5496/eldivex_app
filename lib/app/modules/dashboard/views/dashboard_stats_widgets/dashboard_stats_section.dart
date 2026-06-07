import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';
import 'dashboard_status_card.dart';

class DashboardStatsSection extends GetView<DashboardController> {
  const DashboardStatsSection({super.key});

  /// Build a "+12.5%" / "-3.1%" chip string from a signed trend value.
  /// Returns null when the trend is unknown (chip hidden).
  String? _trendText(String key) {
    final t = controller.trends[key];
    if (t == null) return null;
    final sign = t >= 0 ? '+' : '';
    return '$sign${t.toStringAsFixed(1)}%';
  }

  bool _trendUp(String key) => (controller.trends[key] ?? 0) >= 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.statsSection();
      }

      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          DashboardStatCard(
            title: 'Total Clients',
            value: controller.formattedTotalClients,
            percentage: _trendText('totalClients'),
            isPositive: _trendUp('totalClients'),
            icon: Icons.people_outline,
            iconBgColor: AppColor.cPrimaryButtonColor.withValues(alpha: 0.12),
            iconColor: AppColor.cPrimaryButtonColor,
            onTap: () => Get.toNamed(Routes.CLIENT_USERS),
          ),
          DashboardStatCard(
            title: 'Total Bookings',
            value: controller.formattedTotalBookings,
            percentage: _trendText('totalBookings'),
            isPositive: _trendUp('totalBookings'),
            icon: Icons.event_note_outlined,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
          DashboardStatCard(
            title: 'Active Bookings',
            value: controller.formattedActiveBookings,
            percentage: _trendText('activeBookings'),
            isPositive: _trendUp('activeBookings'),
            icon: Icons.calendar_month_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
          DashboardStatCard(
            title: 'Completed Bookings',
            value: controller.formattedCompletedBookings,
            percentage: _trendText('completedBookings'),
            isPositive: _trendUp('completedBookings'),
            icon: Icons.task_alt,
            iconBgColor: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
          DashboardStatCard(
            title: 'Revenue',
            value: controller.formattedRevenue,
            percentage: _trendText('totalRevenue'),
            isPositive: _trendUp('totalRevenue'),
            icon: Icons.currency_rupee,
            iconBgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            onTap: () => Get.toNamed(Routes.ACCOUNTS),
          ),
          DashboardStatCard(
            title: 'Collection Rate',
            value: controller.formattedCollectionRate,
            subtitle: 'Outstanding ${controller.formattedOutstanding}',
            percentage: _trendText('totalCollected'),
            isPositive: _trendUp('totalCollected'),
            icon: Icons.account_balance_wallet_outlined,
            iconBgColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            onTap: () => Get.toNamed(Routes.OUTSTANDING_DASHBOARD),
          ),
          DashboardStatCard(
            title: 'Health Professionals',
            value: controller.formattedTotalHPs,
            icon: Icons.person_outline,
            iconBgColor: const Color(0xFFFDF2F8),
            iconColor: const Color(0xFFDB2777),
            onTap: () => Get.toNamed(Routes.REGISTER_CG),
          ),
        ],
      );
    });
  }
}
