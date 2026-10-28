import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/service_distribution_widget.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/top_performing_cities_widget.dart';
import 'package:eldivex_app/app/modules/dashboard/views/dashboard_stats_widgets/weekly_bookings_widget.dart';
import 'package:eldivex_app/app/modules/role/controllers/role_controller.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../main.dart';
import 'dashboard_stats_widgets/booking_stats_chart.dart';
import 'dashboard_stats_widgets/dashboard_mini_stats.dart';
import 'dashboard_stats_widgets/dashboard_stats_section.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_stats_widgets/top_performing_cgs_widget.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    // Self-register like the other shell pages — the controller is disposed
    // on Get.offAllNamed (logout / session expiry) and nothing else
    // re-creates it reliably.
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFilterRow(context),
            _buildErrorBanner(),
            const SizedBox(height: 20),
            const DashboardMiniStats(),
            const DashboardStatsSection(),

            /// Analytics (charts + performance + cities), gated per role.
            _buildAnalytics(),
          ],
        ),
      ),
    );
  }

  /// Page title with a time-of-day greeting; refresh lives top-right.
  Widget _buildHeader() {
    final name = (box.read('user_name') ?? '').toString().trim();
    final first = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return AppPageHeader(
      title: 'Dashboard',
      subtitle: first.isEmpty
          ? '$greeting. Here’s how your operations are tracking.'
          : '$greeting, $first. Here’s how your operations are tracking.',
      actions: [
        // ── Last updated + manual refresh ────────────────────────────────
        Obx(() {
          final updated = controller.formattedLastUpdated;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (updated.isNotEmpty) ...[
                Text(
                  updated,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColor.textTertiary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              OutlinedButton.icon(
                onPressed: () => controller.refreshDashboard(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Charts, performance and cities, each gated by the role module it belongs
  /// to. Hidden sections leave no gap, and a lone surviving widget in a pair
  /// spans the full width instead of half.
  Widget _buildAnalytics() {
    final roles = Get.find<RoleController>();
    return Obx(() {
      roles.accessList.length; // rebuild once role access loads
      final canBookings = roles.hasAccess('Bookings');
      final canHp = roles.hasAccess('HP Modules');

      final blocks = <Widget>[];

      // Charts row — both are Bookings analytics.
      if (canBookings) {
        blocks.add(_pairLayout(const [
          WeeklyBookingsWidget(),
          ServiceDistributionWidget(),
        ]));
      }

      // Performance row — Top CGs (HP Modules) + Booking status (Bookings).
      final perf = <Widget>[
        if (canHp)
          TopPerformingCgsWidget(onViewAll: () => Get.toNamed(Routes.REGISTER_CG)),
        if (canBookings) const BookingStatusChartWidget(),
      ];
      if (perf.isNotEmpty) blocks.add(_pairLayout(perf));

      // Cities — Bookings analytics.
      if (canBookings) blocks.add(const TopPerformingCitiesWidget());

      if (blocks.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final block in blocks) ...[
            const SizedBox(height: _gap),
            block,
          ],
        ],
      );
    });
  }

  static const double _gap = 20;

  /// Lay out one or two analytics widgets responsively: a single widget spans
  /// full width; a pair stacks when the content area is narrow (phones,
  /// tablets with the sidebar open) and sits side-by-side otherwise.
  Widget _pairLayout(List<Widget> widgets) {
    if (widgets.isEmpty) return const SizedBox.shrink();
    if (widgets.length == 1) return widgets.first;
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 840) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgets[0],
            const SizedBox(height: _gap),
            widgets[1],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: widgets[0]),
          const SizedBox(width: _gap),
          Expanded(child: widgets[1]),
        ],
      );
    });
  }

  // ── Phase 4.1: Dashboard filter row ─────────────────────────────────────────
  // One toolbar above everything it scopes: branch, quick ranges, custom
  // From → To range, Apply / Clear. Wraps onto extra lines on narrow screens.

  Widget _buildFilterRow(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // ── Branch dropdown ──────────────────────────────────────────────
            _toolbarBox(
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.store,
                      size: 16, color: AppColor.textTertiary),
                  const SizedBox(width: 8),
                  // Fixed width so long branch names ellipsize instead of
                  // pushing the toolbar off-screen on phones.
                  SizedBox(
                    width: 180,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: controller.filterBranchId.value,
                        hint: Text(
                          'All Branches',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        isDense: true,
                        icon: Icon(LucideIcons.chevronDown,
                            size: 18, color: AppColor.textTertiary),
                        dropdownColor: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textPrimary,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'All Branches',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ...controller.getAllBranches
                              .map((b) => DropdownMenuItem<int?>(
                                    value: b.brId,
                                    child: Text(
                                      b.brName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  )),
                        ],
                        onChanged: (val) =>
                            controller.filterBranchId.value = val,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Quick range presets ──────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _toolbarBox(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _presetChip('Today', 'today'),
                    _presetChip('7d', '7d'),
                    _presetChip('30d', '30d'),
                    _presetChip('This month', 'month'),
                    _presetChip('All time', 'all'),
                  ],
                ),
              ),
            ),

            // ── From → To date range ─────────────────────────────────────────
            _toolbarBox(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),
                  Icon(LucideIcons.calendar,
                      size: 15, color: AppColor.textTertiary),
                  const SizedBox(width: 2),
                  // ── From date ──────────────────────────────────────────────
                  _buildDateButton(
                    context: context,
                    label: 'From',
                    value: controller.dashFrom.value,
                    onPicked: (d) {
                      controller.dashFrom.value = d;
                      controller.activePreset.value = '';
                    },
                    isLast: false,
                  ),
                  Icon(LucideIcons.arrowRight,
                      size: 14, color: AppColor.lightGrey),
                  // ── To date ────────────────────────────────────────────────
                  _buildDateButton(
                    context: context,
                    label: 'To',
                    value: controller.dashTo.value,
                    onPicked: (d) {
                      controller.dashTo.value = d;
                      controller.activePreset.value = '';
                    },
                    isLast: false,
                  ),
                ],
              ),
            ),

            // ── Apply button ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: controller.applyCustomRange,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Apply'),
            ),

            // ── Clear button (visible only when a filter is active) ──────────
            if (controller.dashFrom.value.isNotEmpty ||
                controller.dashTo.value.isNotEmpty ||
                controller.filterBranchId.value != null)
              TextButton.icon(
                onPressed: () {
                  controller.dashFrom.value = '';
                  controller.dashTo.value = '';
                  controller.filterBranchId.value = null;
                  controller.activePreset.value = '';
                  controller.fetchDashboardStats();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.textSecondary,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(LucideIcons.x, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ));
  }

  /// 36px bordered control shell shared by the toolbar's custom controls so
  /// they line up with the theme's buttons and inputs.
  Widget _toolbarBox({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      height: 36,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.borderStrong),
      ),
      child: child,
    );
  }

  /// Shown when the last stats fetch failed, so stale/zero numbers are not
  /// mistaken for real data.
  Widget _buildErrorBanner() {
    return Obx(() {
      final err = controller.dashboardError.value;
      if (err.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        decoration: BoxDecoration(
          color: AppColor.dangerSoft,
          border: Border.all(color: AppColor.danger.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.circleAlert,
                color: AppColor.danger, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                err,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.refreshDashboard(),
              style: TextButton.styleFrom(foregroundColor: AppColor.danger),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    });
  }

  // ── Quick-range preset chip (one segment of the segmented control) ─────────
  Widget _presetChip(String label, String preset) {
    final isActive = controller.activePreset.value == preset;
    return Material(
      color: isActive ? AppColor.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm - 1),
      child: InkWell(
        onTap: () => controller.applyDatePreset(preset),
        borderRadius: BorderRadius.circular(AppRadius.sm - 1),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive
                  ? AppColor.cAppPrimaryColor
                  : AppColor.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// One end of the From → To range. Tapping opens the date picker; the
  /// stored value stays 'yyyy-MM-dd', only the display is friendlier.
  Widget _buildDateButton({
    required BuildContext context,
    required String label,
    required String value,
    required ValueChanged<String> onPicked,
    bool isLast = false,
  }) {
    final parsed = value.isNotEmpty ? DateTime.tryParse(value) : null;
    final display = value.isEmpty
        ? (label == 'From' ? 'Start date' : 'End date')
        : (parsed != null ? DateFormat('d MMM yyyy').format(parsed) : value);

    return Tooltip(
      message: label == 'From' ? 'From date' : 'To date',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
                // Keep the ambient (light/dark) scheme; only brand the accent.
                colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColor.cPrimaryButtonColor,
                  onPrimary: AppColor.buttonTextWhite,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            display,
            style: TextStyle(
              fontSize: 13,
              color: value.isNotEmpty
                  ? AppColor.textPrimary
                  : AppColor.textTertiary,
              fontWeight:
                  value.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
