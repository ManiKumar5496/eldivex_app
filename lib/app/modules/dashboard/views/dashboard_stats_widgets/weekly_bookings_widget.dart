import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_chart_style.dart';
import 'dashboard_shimmer.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class WeeklyBookingsWidget extends GetView<DashboardController> {
  const WeeklyBookingsWidget({super.key});

  static const double _chartHeight = 260;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.chartWidget(height: _chartHeight);
      }

      final data = controller.weeklyBookingsData;
      final maxVal = data.isNotEmpty
          ? data.map((e) => e.bookings).reduce((a, b) => a > b ? a : b)
          : 0.0;
      final axis = DashChart.niceAxis(maxVal);
      // Label only the peak; the axis and tooltip carry the rest.
      final peakIndex =
          maxVal > 0 ? data.indexWhere((e) => e.bookings == maxVal) : -1;

      return AppCard(
        title: 'Weekly Bookings',
        subtitle: 'Last 7 days performance',
        child: SizedBox(
          height: _chartHeight,
          child: data.isEmpty
              ? const AppEmptyState(
                  icon: LucideIcons.chartColumn,
                  title: 'No bookings yet',
                  message: 'Daily bookings for the last 7 days will show here.',
                  compact: true,
                )
              : LayoutBuilder(builder: (context, constraints) {
                  // ~40px of the width goes to the value-axis labels.
                  final barWidth = DashChart.barFraction(
                    extent: constraints.maxWidth - 40,
                    count: data.length,
                  );
                  return SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: DashChart.noGrid,
                      majorTickLines: DashChart.noTicks,
                      axisLine: DashChart.baseline,
                      labelStyle: DashChart.categoryLabel,
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: axis.max,
                      interval: axis.interval,
                      majorGridLines: DashChart.grid,
                      majorTickLines: DashChart.noTicks,
                      axisLine: DashChart.noAxisLine,
                      labelStyle: DashChart.valueLabel,
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<BookingData, String>(
                        dataSource: data,
                        xValueMapper: (BookingData data, _) => data.day,
                        yValueMapper: (BookingData data, _) => data.bookings,
                        name: 'Bookings',
                        color: AppColor.cAppPrimaryColor,
                        // Rounded data-end, square at the baseline.
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        width: barWidth,
                        spacing: 0,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: peakIndex >= 0,
                          labelAlignment: ChartDataLabelAlignment.outer,
                          builder: (dynamic d, ChartPoint<dynamic> point,
                              ChartSeries<dynamic, dynamic> series,
                              int pointIndex, int seriesIndex) {
                            if (pointIndex != peakIndex) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              (d as BookingData).bookings.toStringAsFixed(0),
                              style: DashChart.dataLabel,
                            );
                          },
                        ),
                      ),
                    ],
                    tooltipBehavior: DashChart.tooltip(
                      value: (d) =>
                          '${(d as BookingData).bookings.toStringAsFixed(0)} bookings',
                      label: (d) => (d as BookingData).day,
                    ),
                  );
                }),
        ),
      );
    });
  }
}

class BookingData {
  final String day;
  final double bookings;

  BookingData(this.day, this.bookings);
}
