import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import 'dashboard_shimmer.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class TopPerformingCitiesWidget extends GetView<DashboardController> {
  const TopPerformingCitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return DashboardShimmer.citiesTable();
      }

      final cities = controller.cityPerformanceData;

      return AppCard(
        title: 'Top Performing Cities',
        subtitle: 'Revenue and bookings by location',
        padding: EdgeInsets.zero,
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(Routes.branchManagement),
            style: AppButtonStyles.compact,
            child: const Text('View All'),
          ),
        ],
        child: cities.isEmpty
            ? const AppEmptyState(
                icon: LucideIcons.building,
                title: 'No city data available',
                compact: true,
              )
            : LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth >= 640;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    if (wide)
                      Container(
                        color: AppColor.surfaceMuted,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 36,
                                child: Text('Rank', style: _headerStyle)),
                            Expanded(
                                flex: 3,
                                child: Text('City', style: _headerStyle)),
                            Expanded(
                                flex: 2,
                                child: Text('Total Bookings',
                                    style: _headerStyle,
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 2,
                                child: Text('Revenue',
                                    style: _headerStyle,
                                    textAlign: TextAlign.right)),
                            const SizedBox(width: 32),
                            Expanded(
                                flex: 3,
                                child: Text('Progress', style: _headerStyle)),
                          ],
                        ),
                      ),

                    // Table Rows
                    for (var i = 0; i < cities.length; i++) ...[
                      if (i > 0 || wide)
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColor.borderSubtle),
                      wide
                          ? _wideRow(cities[i])
                          : _compactRow(cities[i]),
                    ],
                  ],
                );
              }),
      );
    });
  }

  /// Desktop: one aligned table row.
  Widget _wideRow(CityPerformance city) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 36, child: _RankChip(rank: city.rank)),
          // City Name
          Expanded(
            flex: 3,
            child: Text(
              city.city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _cityStyle,
            ),
          ),
          // Total Bookings
          Expanded(
            flex: 2,
            child: Text(
              '${city.bookings}',
              textAlign: TextAlign.right,
              style: _numberStyle,
            ),
          ),
          // Revenue
          Expanded(
            flex: 2,
            child: Text(
              _formatRevenue(city.revenue),
              textAlign: TextAlign.right,
              style: _numberStyle,
            ),
          ),
          const SizedBox(width: 32),
          // Progress Bar + Percentage
          Expanded(flex: 3, child: _Meter(progress: city.progress)),
        ],
      ),
    );
  }

  /// Phones / narrow cards: city + meter on the left, figures on the right.
  Widget _compactRow(CityPerformance city) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _RankChip(rank: city.rank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _cityStyle,
                ),
                const SizedBox(height: 6),
                _Meter(progress: city.progress),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatRevenue(city.revenue), style: _numberStyle),
              const SizedBox(height: 2),
              Text(
                '${city.bookings} bookings',
                style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatRevenue(double revenue) =>
      '₹${revenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  static TextStyle get _headerStyle => TextStyle(
        fontSize: 12.5,
        color: AppColor.textTertiary,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get _cityStyle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle get _numberStyle => TextStyle(
        fontSize: 14,
        color: AppColor.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

/// Rank number in a small rounded square; the podium (1–3) is tinted brand.
class _RankChip extends StatelessWidget {
  const _RankChip({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final podium = rank >= 1 && rank <= 3;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: podium ? AppColor.primarySoft : AppColor.neutralSoft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: podium ? AppColor.cAppPrimaryColor : AppColor.textSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Single-hue meter: brand fill on a lighter step of the same hue.
class _Meter extends StatelessWidget {
  const _Meter({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 6, color: AppColor.primarySoft),
                FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColor.cAppPrimaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Progress Percentage
        SizedBox(
          width: 38,
          child: Text(
            '${(progress * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColor.textTertiary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
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
