import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';
import 'dashboard_status_card.dart';

class DashboardStatsSection extends GetView<DashboardController> {
  const DashboardStatsSection({super.key});

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
            title: 'Total Users',
            value: controller.formattedTotalBookings,
            percentage: '+${controller.totalBookings.value > 0 ? '12.5' : '0'}%',
            icon: Icons.people_outline,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
          ),
          DashboardStatCard(
            title: 'Active Bookings',
            value: controller.formattedActiveBookings,
            percentage: '+${controller.activeBookings.value > 0 ? '8.2' : '0'}%',
            icon: Icons.calendar_month_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
          ),
          DashboardStatCard(
            title: 'Revenue',
            value: controller.formattedRevenue,
            percentage: '+${controller.totalRevenue.value > 0 ? '23.1' : '0'}%',
            icon: Icons.currency_rupee,
            iconBgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
          ),
          DashboardStatCard(
            title: 'Health Professionals',
            value: controller.formattedTotalHPs,
            percentage: '+${controller.totalHPs.value > 0 ? '5.7' : '0'}%',
            icon: Icons.person_outline,
            iconBgColor: const Color(0xFFFDF2F8),
            iconColor: const Color(0xFFDB2777),
          ),
          const DashboardStatCard(
            title: 'Avg Response Time',
            value: '2.4h',
            percentage: '-15.3%',
            icon: Icons.access_time,
            iconBgColor: Color(0xFFECFDF5),
            iconColor: Color(0xFF059669),
            isPositive: false,
          ),
          const DashboardStatCard(
            title: 'Completion Rate',
            value: '94.2%',
            percentage: '+3.1%',
            icon: Icons.show_chart,
            iconBgColor: Color(0xFFE0F2FE),
            iconColor: Color(0xFF0284C7),
          ),
        ],
      );
    });
  }
}
