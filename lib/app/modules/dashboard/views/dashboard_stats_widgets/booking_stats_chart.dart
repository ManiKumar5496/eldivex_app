import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_charts_extension.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_chart_style.dart';
import 'dashboard_shimmer.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class BookingStatusData {
  final String label;
  final int value;
  final Color color;

  BookingStatusData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class BookingStatusChartWidget extends GetView<DashboardController> {
  const BookingStatusChartWidget({super.key});

  static final NumberFormat _count = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    controller.initBookingStatusData();

    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.doughnutChart();
      }

      final chartData = controller.filteredBookingStatusData;

      if (chartData.isEmpty) {
        return const AppCard(
          title: 'Booking Status',
          subtitle: 'Bookings by current status',
          child: AppEmptyState(
            icon: LucideIcons.chartPie,
            title: 'No booking data available',
            compact: true,
          ),
        );
      }

      final selected = controller.selectedStatus.value;
      final all = controller.bookingStatusData;
      // Colour follows the status (not its rank), and slices sit in
      // lifecycle order so neighbouring colours are always distinguishable.
      final colors = DashChart.statusColors(all.map((e) => e.label));
      final legendRows = DashChart.orderByStatus(all, (e) => e.label);
      final slices = DashChart.orderByStatus(chartData, (e) => e.label);
      final grandTotal = all.fold<int>(0, (s, e) => s + e.value);
      final shownTotal = slices.fold<int>(0, (s, e) => s + e.value);

      final donut = SizedBox(
        width: 184,
        height: 184,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          annotations: [
            CircularChartAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _count.format(shownTotal),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      selected ?? 'Bookings',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          tooltipBehavior: DashChart.tooltip(
            value: (d) {
              final v = (d as BookingStatusData).value;
              final pct = grandTotal > 0 ? (v / grandTotal * 100) : 0;
              return '${_count.format(v)} · ${pct.toStringAsFixed(1)}%';
            },
            label: (d) => (d as BookingStatusData).label,
          ),
          series: <CircularSeries>[
            DoughnutSeries<BookingStatusData, String>(
              dataSource: slices,
              xValueMapper: (data, _) => data.label,
              yValueMapper: (data, _) => data.value,
              pointColorMapper: (data, _) =>
                  colors[data.label] ?? AppColor.lightGrey,
              innerRadius: '76%',
              radius: '100%',
              // 2px surface gap between slices instead of an outline.
              strokeColor: AppColor.whiteColor,
              strokeWidth: 2,
              animationDuration: 600,
            ),
          ],
        ),
      );

      /// Clickable legend: also the chart's table view (label, count, share).
      final legend = Column(
        mainAxisSize: MainAxisSize.min,
        children: legendRows.map((data) {
          final isSelected = selected == data.label;
          return _LegendItem(
            color: colors[data.label] ?? AppColor.lightGrey,
            label: data.label,
            value: data.value,
            share: grandTotal > 0 ? data.value / grandTotal : 0,
            isSelected: isSelected,
            isDimmed: selected != null && !isSelected,
            onTap: () => controller.toggleBookingStatus(data.label),
          );
        }).toList(),
      );

      return AppCard(
        title: 'Booking Status',
        subtitle: selected == null
            ? 'Bookings by current status'
            : 'Showing $selected · tap it again to show all',
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth >= 460) {
            return Row(
              children: [
                donut,
                const SizedBox(width: 28),
                Expanded(child: legend),
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: donut),
              const SizedBox(height: 20),
              legend,
            ],
          );
        }),
      );
    });
  }
}

/// =======================
/// Legend Item
/// =======================
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double share;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.share,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isDimmed ? 0.45 : 1,
      child: Material(
        color: isSelected ? AppColor.surfaceMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? AppColor.textPrimary
                          : AppColor.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  NumberFormat('#,###').format(value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${(share * 100).toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColor.textTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
