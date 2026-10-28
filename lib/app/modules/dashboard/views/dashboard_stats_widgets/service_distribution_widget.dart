import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_chart_style.dart';
import 'dashboard_shimmer.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ServiceDistributionWidget extends GetView<DashboardController> {
  const ServiceDistributionWidget({super.key});

  static const double _chartHeight = 260;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.horizontalBarChart(height: _chartHeight);
      }

      final data = controller.serviceDistributionData;
      final maxVal = data.isNotEmpty
          ? data.map((e) => e.bookings).reduce((a, b) => a > b ? a : b)
          : 0.0;
      // Pad the value axis ~20% above the tallest bar; fall back to 5 when empty.
      final axisMax = maxVal <= 0 ? 5.0 : (maxVal * 1.2).ceilToDouble();

      return AppCard(
        title: 'Service Distribution',
        subtitle: 'Bookings by service type',
        child: SizedBox(
          height: _chartHeight,
          child: data.isEmpty
              ? const AppEmptyState(
                  icon: LucideIcons.stethoscope,
                  title: 'No service bookings yet',
                  message: 'Bookings per service type will show here.',
                  compact: true,
                )
              : LayoutBuilder(builder: (context, constraints) {
                  final barWidth = DashChart.barFraction(
                    extent: constraints.maxHeight,
                    count: data.length,
                    maxPx: 20,
                  );
                  return SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    // Category (service names) on the X axis; rendered
                    // vertically by BarSeries. Inversed so the first (largest)
                    // service reads at the top, like a ranked list.
                    primaryXAxis: CategoryAxis(
                      isInversed: true,
                      majorGridLines: DashChart.noGrid,
                      majorTickLines: DashChart.noTicks,
                      axisLine: DashChart.baseline,
                      labelStyle: DashChart.categoryLabel,
                      maximumLabelWidth: 132,
                    ),
                    // Numeric value axis (booking counts). Every bar carries
                    // its value at the tip, so the axis itself stays hidden.
                    primaryYAxis: NumericAxis(
                      isVisible: false,
                      minimum: 0,
                      maximum: axisMax,
                      majorGridLines: DashChart.noGrid,
                    ),
                    series: <CartesianSeries>[
                      BarSeries<ServiceData, String>(
                        dataSource: data,
                        xValueMapper: (ServiceData data, _) => data.service,
                        yValueMapper: (ServiceData data, _) => data.bookings,
                        name: 'Bookings',
                        color: AppColor.cAppPrimaryColor,
                        // Rounded data-end, square at the baseline.
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(4)),
                        spacing: 0,
                        width: barWidth,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.outer,
                          builder: (dynamic d, ChartPoint<dynamic> point,
                              ChartSeries<dynamic, dynamic> series,
                              int pointIndex, int seriesIndex) {
                            return Text(
                              (d as ServiceData).bookings.toStringAsFixed(0),
                              style: DashChart.dataLabel,
                            );
                          },
                        ),
                      ),
                    ],
                    tooltipBehavior: DashChart.tooltip(
                      value: (d) =>
                          '${(d as ServiceData).bookings.toStringAsFixed(0)} bookings',
                      label: (d) => (d as ServiceData).service,
                    ),
                  );
                }),
        ),
      );
    });
  }
}

class ServiceData {
  final String service;
  final double bookings;

  ServiceData(this.service, this.bookings);
}
