import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:shimmer/shimmer.dart';

/// Common shimmer loading widget used across the app.
/// Replaces CircularProgressIndicator and HelperUi().loader() for professional loading states.
class ShimmerLoader extends StatelessWidget {
  final ShimmerType type;
  final int itemCount;
  final double? height;

  const ShimmerLoader({
    super.key,
    this.type = ShimmerType.table,
    this.itemCount = 6,
    this.height,
  });

  /// Quick constructors
  const ShimmerLoader.table({super.key, this.itemCount = 6})
      : type = ShimmerType.table,
        height = null;

  const ShimmerLoader.form({super.key})
      : type = ShimmerType.form,
        itemCount = 6,
        height = null;

  const ShimmerLoader.cardList({super.key, this.itemCount = 4})
      : type = ShimmerType.cardList,
        height = null;

  const ShimmerLoader.grid({super.key, this.itemCount = 6})
      : type = ShimmerType.grid,
        height = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.divColor,
      highlightColor: AppColor.fieldColorGrey,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case ShimmerType.table:
        return _buildTableShimmer();
      case ShimmerType.form:
        return _buildFormShimmer();
      case ShimmerType.cardList:
        return _buildCardListShimmer();
      case ShimmerType.grid:
        return _buildGridShimmer();
    }
  }

  // ─── Table Shimmer ──────────────────────────────────────────

  Widget _buildTableShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 16),
        // Data rows
        ...List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _box(width: 40, height: 40, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(height: 14, width: 120),
                      const SizedBox(height: 6),
                      _box(height: 12, width: 80),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _box(height: 14)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _box(height: 14)),
                const SizedBox(width: 12),
                _box(width: 70, height: 28, radius: 14),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Form Shimmer ───────────────────────────────────────────

  Widget _buildFormShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(width: 200, height: 22),
        const SizedBox(height: 24),
        ...List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 100, height: 14),
                const SizedBox(height: 8),
                _box(height: 44, radius: 8),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        _box(width: 140, height: 44, radius: 8),
      ],
    );
  }

  // ─── Card List Shimmer ──────────────────────────────────────

  Widget _buildCardListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(itemCount, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.fieldColorGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _box(width: 48, height: 48, radius: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 160, height: 16),
                    const SizedBox(height: 8),
                    _box(width: 100, height: 13),
                  ],
                ),
              ),
              _box(width: 60, height: 28, radius: 14),
            ],
          ),
        );
      }),
    );
  }

  // ─── Grid Shimmer ───────────────────────────────────────────

  Widget _buildGridShimmer() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(itemCount, (_) {
        return Container(
          width: 280,
          height: 180,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  // ─── Helper ─────────────────────────────────────────────────

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
}

enum ShimmerType { table, form, cardList, grid }
