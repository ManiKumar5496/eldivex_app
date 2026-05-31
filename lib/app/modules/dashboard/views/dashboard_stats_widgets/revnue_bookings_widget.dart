import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controllers/dashboard_controller.dart';


class RevenueBookingsTrendWidget extends GetView<DashboardController> {
  const RevenueBookingsTrendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TrendData> data = [
      TrendData('Jan', 48000, 50000),
      TrendData('Feb', 52000, 52000),
      TrendData('Mar', 55000, 55000),
      TrendData('Apr', 62000, 60000),
      TrendData('May', 68000, 65000),
      TrendData('Jun', 75000, 72000),
      TrendData('Jul', 82000, 78000),
      TrendData('Aug', 88000, 82000),
    ];

    return Material(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue & Bookings Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monthly performance overview',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton('8M', true),
                      _buildToggleButton('6M', false),
                      _buildToggleButton('3M', false),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320, // Increased slightly to accommodate legend below
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.only(left: 10, right: 20, bottom: 40),
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(
                    width: 1,
                    color: Color(0xFFF0F0F0),
                    dashArray: [5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                  ),
                  majorTickLines: const MajorTickLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100000,
                  interval: 25000,
                  numberFormat:
                  NumberFormat.compactCurrency(symbol: '', decimalDigits: 0),
                  majorGridLines: const MajorGridLines(
                    width: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 11,
                  ),
                  majorTickLines: const MajorTickLines(width: 0),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  orientation: LegendItemOrientation.horizontal,
                  overflowMode: LegendItemOverflowMode.wrap,
                  itemPadding: 24,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
                series: <CartesianSeries>[
                  AreaSeries<TrendData, String>(
                    dataSource: data,
                    xValueMapper: (TrendData d, _) => d.month,
                    yValueMapper: (TrendData d, _) => d.revenue,
                    name: 'Revenue (\$) ',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90CAF9), Color(0xFFE3F2FD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderColor: const Color(0xFF2196F3),
                    borderWidth: 3,
                  ),
                  LineSeries<TrendData, String>(
                    dataSource: data,
                    xValueMapper: (TrendData d, _) => d.month,
                    yValueMapper: (TrendData d, _) => d.target,
                    name: 'Target (\$) ',
                    color: const Color(0xFF4CAF50),
                    width: 3,
                    dashArray: const [10, 6],
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : \$point.y',
                  color: const Color(0xFF1A1A1A),
                  textStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF424242),
        ),
      ),
    );
  }
}

class TrendData {
  final String month;
  final double revenue;
  final double target;

  TrendData(this.month, this.revenue, this.target);
}