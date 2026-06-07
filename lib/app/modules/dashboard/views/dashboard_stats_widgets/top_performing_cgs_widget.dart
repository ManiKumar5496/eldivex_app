import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';

/// =======================
/// Model
/// =======================
class TopCgItem {
  final String name;
  final String service;
  final double rating;
  final int bookings;

  TopCgItem({
    required this.name,
    required this.service,
    required this.rating,
    required this.bookings,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}

/// =======================
/// Widget
/// =======================
class TopPerformingCgsWidget extends GetView<DashboardController> {
  final String title;
  final VoidCallback? onViewAll;

  const TopPerformingCgsWidget({
    super.key,
    this.title = 'Top Health Professionals',
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.cgList();
      }

      final items = controller.topCgItems;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: onViewAll,
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// List
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No health professionals found',
                    style: TextStyle(color: AppColor.lightGrey, fontSize: 14),
                  ),
                ),
              )
            else
              Column(
                children: items.map((item) {
                  return _TopCgTile(item: item);
                }).toList(),
              ),
          ],
        ),
      );
    });
  }
}

/// =======================
/// Tile
/// =======================
class _TopCgTile extends StatelessWidget {
  final TopCgItem item;

  const _TopCgTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.divColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade400,
            child: Text(
              item.initials,
              style: TextStyle(
                color: AppColor.buttonTextWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// Name & Service
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.service,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.fontColorGrey,
                  ),
                ),
              ],
            ),
          ),

          /// Rating & Bookings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.rating > 0)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Text(
                '${item.bookings} bookings',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.fontColorGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
