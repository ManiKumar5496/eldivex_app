import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';

class ServiceDistributionWidget extends GetView<DashboardController> {
  const ServiceDistributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.horizontalBarChart();
      }

      final data = controller.serviceDistributionData;
      final maxVal = data.isNotEmpty
          ? data.map((e) => e.bookings).reduce((a, b) => a > b ? a : b)
          : 1400.0;
      final xMax = ((maxVal / 350).ceil() * 350).toDouble();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bookings by service type',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                primaryXAxis: NumericAxis(
                  minimum: 0,
                  maximum: xMax > 0 ? xMax : 1400,
                  interval: xMax > 0 ? xMax / 4 : 350,
                  majorGridLines: const MajorGridLines(
                    width: 1,
                    color: Color(0xFFF5F5F5),
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 11,
                  ),
                ),
                primaryYAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                series: <CartesianSeries>[
                  BarSeries<ServiceData, double>(
                    dataSource: data,
                    yValueMapper: (ServiceData data, _) => data.bookings,
                    xValueMapper: (ServiceData data, _) => data.bookings,
                    color: const Color(0xFF00BFA5),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    spacing: 0.3,
                    width: 0.7,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.y: point.x bookings',
                  color: const Color(0xFF1A1A1A),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
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
