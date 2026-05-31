import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';

class WeeklyBookingsWidget extends GetView<DashboardController> {
  const WeeklyBookingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.chartWidget();
      }

      final data = controller.weeklyBookingsData;
      final maxVal = data.isNotEmpty
          ? data.map((e) => e.bookings).reduce((a, b) => a > b ? a : b)
          : 180.0;
      final yMax = ((maxVal / 45).ceil() * 45).toDouble();

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
              'Weekly Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 7 days performance',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: yMax > 0 ? yMax : 180,
                  interval: yMax > 0 ? yMax / 4 : 45,
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
                series: <CartesianSeries>[
                  ColumnSeries<BookingData, String>(
                    dataSource: data,
                    xValueMapper: (BookingData data, _) => data.day,
                    yValueMapper: (BookingData data, _) => data.bookings,
                    color: const Color(0xFF2196F3),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    width: 0.6,
                    spacing: 0.2,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y bookings',
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

class BookingData {
  final String day;
  final double bookings;

  BookingData(this.day, this.bookings);
}
