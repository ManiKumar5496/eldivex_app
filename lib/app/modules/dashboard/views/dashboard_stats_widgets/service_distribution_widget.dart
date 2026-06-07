import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
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
          : 0.0;
      // Pad the value axis ~20% above the tallest bar; fall back to 5 when empty.
      final axisMax = maxVal <= 0 ? 5.0 : (maxVal * 1.2).ceilToDouble();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bookings by service type',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                // Category (service names) on the X axis; rendered vertically by BarSeries.
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: AppColor.fontColorGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Numeric value axis (booking counts).
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: axisMax,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColor.fieldColorGrey,
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: AppColor.lightGrey,
                    fontSize: 11,
                  ),
                ),
                series: <CartesianSeries>[
                  BarSeries<ServiceData, String>(
                    dataSource: data,
                    xValueMapper: (ServiceData data, _) => data.service,
                    yValueMapper: (ServiceData data, _) => data.bookings,
                    color: const Color(0xFF00BFA5),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    spacing: 0.3,
                    width: 0.7,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y bookings',
                  color: AppColor.fontColorBlack,
                  textStyle: TextStyle(
                    color: AppColor.buttonTextWhite,
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
