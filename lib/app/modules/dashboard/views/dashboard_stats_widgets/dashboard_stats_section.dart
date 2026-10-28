import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../role/controllers/role_controller.dart';
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

  /// Declarative card registry: each card names the role module that gates it,
  /// so a role only sees the metrics for the modules it can access (e.g. a role
  /// without `Billing` never sees Revenue / Collection). One readable place to
  /// audit dashboard RBAC.
  List<_StatCardSpec> get _specs => [
        _StatCardSpec(
          module: 'Users',
          build: () => DashboardStatCard(
            title: 'Total Clients',
            value: controller.formattedTotalClients,
            percentage: _trendText('totalClients'),
            isPositive: _trendUp('totalClients'),
            icon: Icons.people_outline,
            iconBgColor: AppColor.cPrimaryButtonColor.withValues(alpha: 0.12),
            iconColor: AppColor.cPrimaryButtonColor,
            onTap: () => Get.toNamed(Routes.CLIENT_USERS),
          ),
        ),
        _StatCardSpec(
          module: 'Bookings',
          build: () => DashboardStatCard(
            title: 'Total Bookings',
            value: controller.formattedTotalBookings,
            percentage: _trendText('totalBookings'),
            isPositive: _trendUp('totalBookings'),
            icon: Icons.event_note_outlined,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
        ),
        _StatCardSpec(
          module: 'Bookings',
          build: () => DashboardStatCard(
            title: 'Active Bookings',
            value: controller.formattedActiveBookings,
            percentage: _trendText('activeBookings'),
            isPositive: _trendUp('activeBookings'),
            icon: Icons.calendar_month_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
        ),
        _StatCardSpec(
          module: 'Bookings',
          build: () => DashboardStatCard(
            title: 'Completed Bookings',
            value: controller.formattedCompletedBookings,
            percentage: _trendText('completedBookings'),
            isPositive: _trendUp('completedBookings'),
            icon: Icons.task_alt,
            iconBgColor: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            onTap: () => Get.toNamed(Routes.BOOKINGS),
          ),
        ),
        _StatCardSpec(
          module: 'Billing',
          build: () => DashboardStatCard(
            title: 'Revenue',
            value: controller.formattedRevenue,
            percentage: _trendText('totalRevenue'),
            isPositive: _trendUp('totalRevenue'),
            icon: Icons.currency_rupee,
            iconBgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            onTap: () => Get.toNamed(Routes.ACCOUNTS),
          ),
        ),
        _StatCardSpec(
          module: 'Billing',
          build: () => DashboardStatCard(
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
        ),
        _StatCardSpec(
          module: 'HP Modules',
          build: () => DashboardStatCard(
            title: 'Health Professionals',
            value: controller.formattedTotalHPs,
            icon: Icons.person_outline,
            iconBgColor: const Color(0xFFFDF2F8),
            iconColor: const Color(0xFFDB2777),
            onTap: () => Get.toNamed(Routes.REGISTER_CG),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final roles = Get.find<RoleController>();
    return Obx(() {
      roles.accessList.length; // rebuild once role access loads

      final cards = _specs
          .where((s) => roles.hasAccess(s.module))
          .map((s) => s.build())
          .toList();

      if (controller.dashboardLoading.value) {
        // Shimmer only the cards this role will actually see, so the layout
        // doesn't jump once data lands.
        return DashboardShimmer.statsSection(count: cards.length);
      }

      if (cards.isEmpty) return const SizedBox.shrink();

      return Wrap(spacing: 20, runSpacing: 20, children: cards);
    });
  }
}

/// One role-gated stat card: the module it requires + its builder.
class _StatCardSpec {
  final String module;
  final Widget Function() build;

  _StatCardSpec({required this.module, required this.build});
}
