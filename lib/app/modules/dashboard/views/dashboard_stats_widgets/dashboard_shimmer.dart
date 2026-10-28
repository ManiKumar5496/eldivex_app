import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import 'package:shimmer/shimmer.dart';

/// Loading skeletons for the dashboard. Each one mirrors the shape of the
/// card it stands in for (AppCard frame, header, hairline, body) so nothing
/// jumps when the data lands. Only the bones shimmer; the card frame stays
/// still.
class DashboardShimmer {
  static Widget _shimmerBase({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: AppColor.divColor,
      highlightColor: AppColor.fieldColorGrey,
      child: child,
    );
  }

  static Widget _box({
    double width = double.infinity,
    double height = 16,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Static card frame matching [AppCard].
  static BoxDecoration get _frame => BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColor.divColor),
        boxShadow: AppShadows.card,
      );

  /// AppCard-shaped skeleton: header bones, hairline, then [body].
  static Widget _card({
    required Widget body,
    bool subtitle = true,
    bool action = false,
    EdgeInsetsGeometry bodyPadding = const EdgeInsets.all(20),
  }) {
    return Container(
      decoration: _frame,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: _shimmerBase(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _box(width: 150, height: 14),
                        if (subtitle) ...[
                          const SizedBox(height: 7),
                          _box(width: 210, height: 11),
                        ],
                      ],
                    ),
                  ),
                  if (action) _box(width: 56, height: 14),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColor.borderSubtle),
          Padding(padding: bodyPadding, child: _shimmerBase(child: body)),
        ],
      ),
    );
  }

  /// Shimmer for DashboardStatsSection. [count] matches the number of cards the
  /// current role will actually render so the placeholder doesn't jump.
  static Widget statsSection({int count = 7}) {
    if (count <= 0) return const SizedBox.shrink();
    return AppResponsiveGrid(
      minItemWidth: 220,
      maxColumns: 4,
      children: List.generate(count, (_) => _statCard()),
    );
  }

  static Widget _statCard() {
    return DecoratedBox(
      decoration: _frame,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _shimmerBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _box(width: 110, height: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _box(width: 34, height: 34, radius: 9),
                ],
              ),
              const SizedBox(height: 10),
              _box(width: 120, height: 26),
              const SizedBox(height: 10),
              _box(width: 140, height: 14),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer for chart widgets (bar/column/area)
  static Widget chartWidget({double height = 220}) {
    const heights = [0.55, 0.75, 0.8, 0.65, 0.9, 0.6, 0.45];
    return _card(
      body: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            return Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heights[i % heights.length],
                  child: _box(width: 20, height: double.infinity, radius: 4),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Shimmer for horizontal bar chart (service distribution)
  static Widget horizontalBarChart({double height = 260}) {
    const widths = [1.0, 0.8, 0.62, 0.45, 0.3];
    return _card(
      body: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widths.length, (i) {
            return Row(
              children: [
                _box(width: 90, height: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widths[i] * 0.85,
                    child: _box(height: 20, radius: 4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Shimmer for doughnut chart (booking status)
  static Widget doughnutChart() {
    Widget ring() => Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.whiteColor, width: 22),
          ),
        );

    Widget legend() => Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _box(width: 8, height: 8, radius: 4),
                  const SizedBox(width: 10),
                  _box(width: 110, height: 12),
                  const Spacer(),
                  _box(width: 36, height: 12),
                ],
              ),
            );
          }),
        );

    return _card(
      body: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth >= 460) {
          return Row(
            children: [
              ring(),
              const SizedBox(width: 28),
              Expanded(child: legend()),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [ring(), const SizedBox(height: 20), legend()],
        );
      }),
    );
  }

  /// Shimmer for top performing CGs list
  static Widget cgList() {
    return _card(
      action: true,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _box(width: 14, height: 12),
                const SizedBox(width: 14),
                _box(width: 34, height: 34, radius: 17),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _box(width: 140, height: 13),
                      const SizedBox(height: 6),
                      _box(width: 90, height: 11),
                    ],
                  ),
                ),
                _box(width: 64, height: 13),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Shimmer for top performing cities table
  static Widget citiesTable() {
    return _card(
      action: true,
      bodyPadding: EdgeInsets.zero,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _box(width: 16, height: 10),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _box(width: 40, height: 10)),
                Expanded(flex: 2, child: _box(width: 60, height: 10)),
                Expanded(flex: 2, child: _box(width: 50, height: 10)),
                Expanded(flex: 3, child: _box(height: 10)),
              ],
            ),
          ),
          ...List.generate(5, (_) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  _box(width: 24, height: 24, radius: 6),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _box(width: 90, height: 13)),
                  Expanded(flex: 2, child: _box(width: 40, height: 13)),
                  Expanded(flex: 2, child: _box(width: 60, height: 13)),
                  Expanded(flex: 3, child: _box(height: 6, radius: 3)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
