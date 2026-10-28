import 'package:flutter/material.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';

import '../../../role/controllers/role_controller.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';
import 'dashboard_status_card.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
            icon: LucideIcons.users,
            tone: AppTone.primary,
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
            icon: LucideIcons.calendarDays,
            tone: AppTone.info,
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
            icon: LucideIcons.calendarDays,
            tone: AppTone.primary,
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
            icon: LucideIcons.circleCheckBig,
            tone: AppTone.success,
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
            icon: LucideIcons.indianRupee,
            tone: AppTone.violet,
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
            icon: LucideIcons.wallet,
            tone: AppTone.warning,
            onTap: () => Get.toNamed(Routes.OUTSTANDING_DASHBOARD),
          ),
        ),
        _StatCardSpec(
          module: 'HP Modules',
          build: () => DashboardStatCard(
            title: 'Health Professionals',
            value: controller.formattedTotalHPs,
            // Approved profiles (not date-filtered); keeps the card the same
            // height as its trend-bearing neighbours.
            subtitle: 'Approved profiles',
            icon: LucideIcons.stethoscope,
            tone: AppTone.info,
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

      return AppResponsiveGrid(
        minItemWidth: 220,
        maxColumns: 4,
        children: cards,
      );
    });
  }
}

/// One role-gated stat card: the module it requires + its builder.
class _StatCardSpec {
  final String module;
  final Widget Function() build;

  _StatCardSpec({required this.module, required this.build});
}
