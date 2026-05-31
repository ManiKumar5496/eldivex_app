import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer {
  static Widget _shimmerBase({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Shimmer for DashboardStatsSection (6 stat cards)
  static Widget statsSection() {
    return _shimmerBase(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: List.generate(6, (_) => _statCard()),
      ),
    );
  }

  static Widget _statCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(width: 100, height: 14),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _box(width: 120, height: 28),
          const SizedBox(height: 8),
          _box(width: 80, height: 14),
        ],
      ),
    );
  }

  /// Shimmer for chart widgets (bar/column/area)
  static Widget chartWidget({double height = 220}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _shimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 160, height: 18),
            const SizedBox(height: 4),
            _box(width: 200, height: 13),
            const SizedBox(height: 32),
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final heights = [0.6, 0.8, 0.85, 0.7, 0.9, 0.6, 0.5];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FractionallySizedBox(
                        heightFactor: heights[i % heights.length],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for horizontal bar chart (service distribution)
  static Widget horizontalBarChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _shimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 160, height: 18),
            const SizedBox(height: 4),
            _box(width: 200, height: 13),
            const SizedBox(height: 32),
            ...List.generate(5, (i) {
              final widths = [0.3, 0.5, 0.65, 0.8, 1.0];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    _box(width: 100, height: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widths[i],
                        child: _box(height: 24, radius: 4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Shimmer for doughnut chart (booking status)
  static Widget doughnutChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _shimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 140, height: 18),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 30),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 40,
              runSpacing: 16,
              children: List.generate(4, (_) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _box(width: 90, height: 14),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for top performing CGs list
  static Widget cgList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _shimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _box(width: 180, height: 18),
                _box(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (_) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(width: 120, height: 15),
                          const SizedBox(height: 6),
                          _box(width: 80, height: 13),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _box(width: 50, height: 14),
                        const SizedBox(height: 6),
                        _box(width: 70, height: 12),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Shimmer for top performing cities table
  static Widget citiesTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _shimmerBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 180, height: 18),
                    const SizedBox(height: 4),
                    _box(width: 220, height: 13),
                  ],
                ),
                _box(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: 20),
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 50, child: _box(width: 30, height: 12)),
                  Expanded(flex: 3, child: _box(width: 40, height: 12)),
                  Expanded(flex: 2, child: _box(width: 80, height: 12)),
                  Expanded(flex: 2, child: _box(width: 60, height: 12)),
                  Expanded(flex: 3, child: _box(height: 12)),
                ],
              ),
            ),
            // Data rows
            ...List.generate(5, (_) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                    Expanded(flex: 3, child: _box(width: 80, height: 14)),
                    Expanded(flex: 2, child: _box(width: 40, height: 14)),
                    Expanded(flex: 2, child: _box(width: 50, height: 14)),
                    Expanded(flex: 3, child: _box(height: 8, radius: 4)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
