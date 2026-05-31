import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/service_distribution_widget.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/top_performing_cities_widget.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/weekly_bookings_widget.dart';
import 'package:eldivex_app/app/modules/login/controllers/login_controller.dart';
import '../../../../main.dart';
import 'dashboard_stats_widgets/booking_stats_chart.dart';
import 'dashboard_stats_widgets/dashboard_stats_section.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_stats_widgets/top_performing_cgs_widget.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    String userName = box.read("user_name") ?? "Admin User";
    String userImage = box.read("user_image") ?? "";
    final loginController = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(userName, userImage, loginController),
          _buildFilterRow(context),
          Expanded(
            child: SingleChildScrollView(
              padding: SizeConfig.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardStatsSection(),
                  SizedBox(height: SizeConfig.spacingLG),

                  /// Charts Section - Responsive Layout
                  SizeConfig.adaptiveLayout(
                    mobile: Column(
                      children: [
                        const WeeklyBookingsWidget(),
                        SizedBox(height: SizeConfig.spacingLG),
                        const ServiceDistributionWidget(),
                      ],
                    ),
                    tablet: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: WeeklyBookingsWidget()),
                        SizedBox(width: SizeConfig.spacingLG),
                        const Expanded(child: ServiceDistributionWidget()),
                      ],
                    ),
                  ),

                  SizedBox(height: SizeConfig.spacingLG),

                  /// Performance Section - Responsive Layout
                  SizeConfig.adaptiveLayout(
                    mobile: Column(
                      children: [
                        const TopPerformingCgsWidget(),
                        SizedBox(height: SizeConfig.spacingLG),
                        const BookingStatusChartWidget(),
                      ],
                    ),
                    tablet: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: TopPerformingCgsWidget()),
                        SizedBox(width: SizeConfig.spacingLG),
                        const Expanded(child: BookingStatusChartWidget()),
                      ],
                    ),
                  ),

                  SizedBox(height: SizeConfig.spacingLG),

                  /// Cities Section
                  const TopPerformingCitiesWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String userName, String userImage, LoginController loginController) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.spacingMD),
      decoration: SizeConfig.isMobile
          ? BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColor.divColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      )
          : null,
      child: Row(
        mainAxisAlignment: SizeConfig.isMobile
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          // Mobile Title
          if (SizeConfig.isMobile)
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: SizeConfig.fontH2,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryButtonColor,
              ),
            ),

          // Actions Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined),
                    iconSize: SizeConfig.iconMD,
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              // Settings Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.settings_outlined, size: SizeConfig.iconMD),
                offset: const Offset(0, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                ),
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.spacingLG),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.cPrimaryButtonColor,
                              AppColor.cPrimaryButtonColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(SizeConfig.radiusMD),
                            topRight: Radius.circular(SizeConfig.radiusMD),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(SizeConfig.spacingSM),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: SizeConfig.iconLG,
                              ),
                            ),
                            SizedBox(width: SizeConfig.spacingSM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontCaption,
                                      color: Colors.white70,
                                      fontFamily: "poppins_regular",
                                    ),
                                  ),
                                  Text(
                                    box.read('user_name') ?? 'User',
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontBody,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "poppins_regular",
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: "profile",
                      child: Text("Profile"),
                    ),
                    const PopupMenuItem<String>(
                      value: "logout",
                      child: Text("Logout"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == "logout") {
                    loginController.logout();
                  }
                },
              ),

              // User Profile (Hide on Mobile)
              if (!SizeConfig.isMobile) ...[
                SizedBox(width: SizeConfig.spacingSM),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColor.cAppBackgroundColor,
                      child: Image.network(
                        userImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: AppColor.cPrimaryButtonColor,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Phase 4.1: Dashboard filter row ─────────────────────────────────────────

  Widget _buildFilterRow(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColor.divColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ── Branch dropdown ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.divColor),
                borderRadius: BorderRadius.circular(6),
                color: AppColor.cAppBackgroundColor,
              ),
              child: DropdownButton<int?>(
                value: controller.filterBranchId.value,
                hint: Text(
                  'All Branches',
                  style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    color: AppColor.fontColorGrey,
                  ),
                ),
                underline: const SizedBox.shrink(),
                isDense: true,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'All Branches',
                      style: TextStyle(fontSize: SizeConfig.fontCaption),
                    ),
                  ),
                  ...controller.getAllBranches.map((b) => DropdownMenuItem<int?>(
                    value: b.brId,
                    child: Text(
                      b.brName,
                      style: TextStyle(fontSize: SizeConfig.fontCaption),
                    ),
                  )),
                ],
                onChanged: (val) => controller.filterBranchId.value = val,
              ),
            ),

            SizedBox(width: SizeConfig.spacingSM),

            // ── From date ────────────────────────────────────────────────────
            _buildDateButton(
              context: context,
              label: 'From',
              value: controller.dashFrom.value,
              onPicked: (d) => controller.dashFrom.value = d,
              isLast: false,
            ),

            SizedBox(width: SizeConfig.spacingSM),

            // ── To date ──────────────────────────────────────────────────────
            _buildDateButton(
              context: context,
              label: 'To',
              value: controller.dashTo.value,
              onPicked: (d) => controller.dashTo.value = d,
              isLast: false,
            ),

            SizedBox(width: SizeConfig.spacingSM),

            // ── Apply button ─────────────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: () => controller.fetchDashboardStats(
                  from: controller.dashFrom.value.isEmpty
                      ? null
                      : controller.dashFrom.value,
                  to: controller.dashTo.value.isEmpty
                      ? null
                      : controller.dashTo.value,
                  branchId: controller.filterBranchId.value,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 13)),
              ),
            ),

            // ── Clear button (visible only when a filter is active) ──────────
            if (controller.dashFrom.value.isNotEmpty ||
                controller.dashTo.value.isNotEmpty ||
                controller.filterBranchId.value != null) ...[
              SizedBox(width: SizeConfig.spacingXS),
              TextButton(
                onPressed: () {
                  controller.dashFrom.value = '';
                  controller.dashTo.value = '';
                  controller.filterBranchId.value = null;
                  controller.fetchDashboardStats();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.fontColorGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Clear', style: TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  Widget _buildDateButton({
    required BuildContext context,
    required String label,
    required String value,
    required ValueChanged<String> onPicked,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        DateTime initial = now;
        if (value.isNotEmpty) {
          try {
            initial = DateTime.parse(value);
          } catch (_) {}
        }
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: now,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColor.cPrimaryButtonColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPicked(
            '${picked.year}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.divColor),
          borderRadius: BorderRadius.circular(6),
          color: AppColor.cAppBackgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: SizeConfig.fontCaption,
                color: AppColor.fontColorGrey,
              ),
            ),
            Text(
              value.isNotEmpty ? value : 'All time',
              style: TextStyle(
                fontSize: SizeConfig.fontCaption,
                color: value.isNotEmpty
                    ? AppColor.fontColorBlack
                    : AppColor.lightGrey,
                fontWeight:
                    value.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: AppColor.fontColorGrey,
            ),
          ],
        ),
      ),
    );
  }
}