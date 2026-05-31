import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_charts_extension.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
    controller.initBookingStatusData();

    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.doughnutChart();
      }

      final chartData = controller.filteredBookingStatusData;

      if (chartData.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No booking data available',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            const Text(
              'Booking Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            /// Doughnut Chart
            Center(
              child: SizedBox(
                height: 220,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries>[
                    DoughnutSeries<BookingStatusData, String>(
                      dataSource: chartData,
                      xValueMapper: (data, _) => data.label,
                      yValueMapper: (data, _) => data.value,
                      pointColorMapper: (data, _) => data.color,
                      innerRadius: '70%',
                      radius: '85%',
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Clickable Legends
            Wrap(
              spacing: 40,
              runSpacing: 16,
              children: controller.bookingStatusData.map((data) {
                final isSelected =
                    controller.selectedStatus.value == data.label;

                return GestureDetector(
                  onTap: () => controller.toggleBookingStatus(data.label),
                  child: _LegendItem(
                    color: data.color,
                    label: data.label,
                    value: data.value,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
  final bool isSelected;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSelected || !isSelected ? 1 : 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label - ',
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.black : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
