import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';

class TopPerformingCitiesWidget extends GetView<DashboardController> {
  const TopPerformingCitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.citiesTable();
      }

      final cities = controller.cityPerformanceData;

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
                        'Top Performing Cities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Revenue and bookings by location',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (cities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      'No city data available',
                      style:
                          TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                    ),
                  ),
                )
              else ...[
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                          width: 50,
                          child: Text('Rank', style: _headerStyle)),
                      Expanded(
                          flex: 3,
                          child: Text('City', style: _headerStyle)),
                      Expanded(
                          flex: 2,
                          child: Text('Total Bookings',
                              style: _headerStyle,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text('Revenue',
                              style: _headerStyle,
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 3,
                          child: Text('Progress',
                              style: _headerStyle,
                              textAlign: TextAlign.end)),
                    ],
                  ),
                ),

                // Table Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cities.length,
                  separatorBuilder: (context, index) => const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 0),
                      child: Row(
                        children: [
                          // Rank Circle
                          SizedBox(
                            width: 50,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: _getRankColor(city.rank),
                              child: Text(
                                '${city.rank}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          // City Name
                          Expanded(
                            flex: 3,
                            child: Text(
                              city.city,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          // Total Bookings
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${city.bookings}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF424242),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Revenue
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${city.revenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF424242),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Progress Bar
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E0E0),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: city.progress,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2196F3),
                                            Color(0xFF4CAF50)
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Progress Percentage
                          Text(
                            '${(city.progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF424242),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF757575),
    fontWeight: FontWeight.w500,
  );

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFFE0E0E0);
    }
  }
}

class CityPerformance {
  final int rank;
  final String city;
  final int bookings;
  final double revenue;
  final double progress;

  CityPerformance({
    required this.rank,
    required this.city,
    required this.bookings,
    required this.revenue,
    required this.progress,
  });
}
