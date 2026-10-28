import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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

      return AppCard(
        title: title,
        subtitle: 'Ranked by bookings',
        padding: EdgeInsets.zero,
        actions: [
          TextButton(
            onPressed: onViewAll,
            style: AppButtonStyles.compact,
            child: const Text('View all'),
          ),
        ],

        /// List
        child: items.isEmpty
            ? const AppEmptyState(
                icon: LucideIcons.userSearch,
                title: 'No health professionals found',
                compact: true,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppColor.borderSubtle,
                        ),
                      _TopCgTile(item: items[i], rank: i + 1),
                    ],
                  ],
                ),
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
  final int rank;

  const _TopCgTile({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    final numberStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColor.textTertiary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          /// Rank
          SizedBox(
            width: 22,
            child: Text('$rank', style: numberStyle),
          ),
          const SizedBox(width: 6),

          /// Avatar
          AppAvatar(name: item.name, size: 34),

          const SizedBox(width: 12),

          /// Name & Service
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColor.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// Rating & Bookings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.bookings}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' bookings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.rating > 0) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.star,
                        color: AppColor.warning, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
