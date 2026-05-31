import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../controllers/accounts_controller.dart';

/// Revenue Recognition / Finance Dashboard
///
/// Shows MRR, ARR, deferred revenue, recognised revenue, collected
/// revenue and churn count — pulled from GET /api/getRevenueRecognition.
class RevenueRecognitionView extends GetView<AccountsController> {
  const RevenueRecognitionView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }

    // Trigger fetch the first time this view is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.mrr.value == 0 && !controller.isLoadingRevenue.value) {
        controller.fetchRevenueRecognition();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.isLoadingRevenue.value) {
                return _buildLoadingSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: MRR / ARR / Active Bookings ──
                  _buildSectionTitle('Recurring Revenue'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _bigKpiCard(
                          label: 'Monthly Recurring Revenue',
                          subtitle: 'From all active bookings × 30 days',
                          value: _fmt(controller.mrr.value.toDouble()),
                          color: AppColor.cPrimaryButtonColor,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _bigKpiCard(
                          label: 'Annual Recurring Revenue',
                          subtitle: 'MRR × 12',
                          value: _fmt(controller.arr.value.toDouble()),
                          color: Colors.indigo,
                          icon: Icons.bar_chart,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _bigKpiCard(
                          label: 'Active Bookings',
                          subtitle: 'Generating revenue this month',
                          value: '${controller.activeCount.value}',
                          color: Colors.green,
                          icon: Icons.people_alt_outlined,
                          isCurrency: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Row 2: Revenue breakdown ──
                  _buildSectionTitle('This Month\'s Revenue Breakdown'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _revenueBreakdownCard(
                          label: 'Deferred Revenue',
                          description:
                              'Invoiced but service not yet started',
                          value: controller.deferred.value.toDouble(),
                          color: Colors.orange,
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _revenueBreakdownCard(
                          label: 'Recognised Revenue',
                          description:
                              'Service in progress — invoiced this month',
                          value: controller.recognized.value.toDouble(),
                          color: Colors.teal,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _revenueBreakdownCard(
                          label: 'Collected Revenue',
                          description:
                              'Cash actually received this month',
                          value: controller.collected.value.toDouble(),
                          color: Colors.green.shade700,
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Row 3: Churn + Collection efficiency ──
                  _buildSectionTitle('Efficiency Metrics'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          label: 'Churn (Cancellations)',
                          value: '${controller.churnCount.value}',
                          description:
                              'Bookings cancelled this month',
                          color: Colors.red,
                          icon: Icons.cancel_outlined,
                          isCurrency: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _metricCard(
                          label: 'Collection Rate',
                          value: '${controller.collectionRate.value}%',
                          description: 'Collected ÷ Invoiced',
                          color: Colors.blue,
                          icon: Icons.percent,
                          isCurrency: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _metricCard(
                          label: 'Days Sales Outstanding',
                          value: '${controller.dso.value} days',
                          description:
                              'Avg time to collect after invoicing',
                          color: Colors.purple,
                          icon: Icons.schedule,
                          isCurrency: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _metricCard(
                          label: 'Overdue Amount',
                          value: _fmt(controller.overdueAmount.value),
                          description:
                              '${controller.overdueCount.value} invoices past due date',
                          color: Colors.red.shade700,
                          icon: Icons.warning_amber_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Revenue Waterfall ──
                  _buildSectionTitle('Revenue Waterfall'),
                  const SizedBox(height: 12),
                  _buildWaterfall(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Page header
  // ─────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finance Dashboard', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text(
              'Revenue recognition, MRR/ARR, and collection efficiency',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: controller.fetchRevenueRecognition,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.cPrimaryButtonColor,
            side: BorderSide(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Section label
  // ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColor.cPrimaryButtonColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Big KPI card (for MRR / ARR / Active)
  // ─────────────────────────────────────────────
  Widget _bigKpiCard({
    required String label,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
    bool isCurrency = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Revenue breakdown card
  // ─────────────────────────────────────────────
  Widget _revenueBreakdownCard({
    required String label,
    required String description,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fmt(value),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(description,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Small metric card
  // ─────────────────────────────────────────────
  Widget _metricCard({
    required String label,
    required String value,
    required String description,
    required Color color,
    required IconData icon,
    bool isCurrency = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(description,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Revenue waterfall bar chart (pure Flutter)
  // ─────────────────────────────────────────────
  Widget _buildWaterfall() {
    return Obx(() {
      final items = [
        _WaterfallItem(
          label: 'MRR',
          value: controller.mrr.value.toDouble(),
          color: AppColor.cPrimaryButtonColor,
        ),
        _WaterfallItem(
          label: 'Deferred',
          value: controller.deferred.value.toDouble(),
          color: Colors.orange,
        ),
        _WaterfallItem(
          label: 'Recognised',
          value: controller.recognized.value.toDouble(),
          color: Colors.teal,
        ),
        _WaterfallItem(
          label: 'Collected',
          value: controller.collected.value.toDouble(),
          color: Colors.green.shade600,
        ),
      ];

      final maxValue = items.map((i) => i.value).reduce(
            (a, b) => a > b ? a : b,
          );

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(3),
                          )),
                      const SizedBox(width: 4),
                      Text(item.label,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final ratio = maxValue > 0 ? item.value / maxValue : 0.0;
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _fmtShort(item.value),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: item.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: 140 * ratio,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: items.map((item) {
                return Expanded(
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Loading skeleton
  // ─────────────────────────────────────────────
  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Formatters
  // ─────────────────────────────────────────────
  String _fmt(double v) {
    final f = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return f.format(v);
  }

  String _fmtShort(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }
}

class _WaterfallItem {
  final String label;
  final double value;
  final Color color;
  const _WaterfallItem(
      {required this.label, required this.value, required this.color});
}
