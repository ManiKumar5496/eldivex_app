import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../controllers/accounts_controller.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class RevenueRecognitionView extends GetView<AccountsController> {
  const RevenueRecognitionView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }

    // Auto-fetch once; later loads come from the Refresh buttons. (Checking
    // mrr == 0 here refetched on every rebuild for orgs with no revenue.)
    if (!controller.revenueRequested) {
      controller.revenueRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchRevenueRecognition();
      });
    }

    final embedded = accountsIsEmbeddedInTabs(context);
    final isMobile = SizeConfig.isMobile;
    final sectionGap = isMobile ? 24.0 : 32.0;
    final gridGap = isMobile ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: accountsPagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPageHeader(embedded),
            SizedBox(height: embedded ? 16 : (isMobile ? 20 : 24)),
            Obx(() {
              if (controller.isLoadingRevenue.value) {
                return _buildLoadingSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Recurring revenue',
                      subtitle: 'Run-rate from all active bookings'),
                  const SizedBox(height: 12),
                  AppResponsiveGrid(
                    minItemWidth: 220,
                    maxColumns: 3,
                    spacing: gridGap,
                    children: [
                      AppStatCard(
                        label: 'Monthly Recurring Revenue',
                        caption: 'From all active bookings × 30 days',
                        value: _fmt(controller.mrr.value.toDouble()),
                        tone: AppTone.primary,
                        icon: LucideIcons.trendingUp,
                      ),
                      AppStatCard(
                        label: 'Annual Recurring Revenue',
                        caption: 'MRR × 12',
                        value: _fmt(controller.arr.value.toDouble()),
                        tone: AppTone.violet,
                        icon: LucideIcons.chartColumn,
                      ),
                      AppStatCard(
                        label: 'Active Bookings',
                        caption: 'Generating revenue this month',
                        value: '${controller.activeCount.value}',
                        tone: AppTone.success,
                        icon: LucideIcons.users,
                      ),
                    ],
                  ),
                  SizedBox(height: sectionGap),

                  // This month: breakdown list next to the waterfall chart.
                  AppResponsiveGrid(
                    minItemWidth: 420,
                    maxColumns: 2,
                    spacing: gridGap,
                    children: [
                      _buildBreakdownCard(),
                      _buildWaterfall(),
                    ],
                  ),
                  SizedBox(height: sectionGap),

                  _buildSectionTitle('Efficiency metrics',
                      subtitle: 'How quickly invoiced revenue turns into cash'),
                  const SizedBox(height: 12),
                  AppResponsiveGrid(
                    minItemWidth: 200,
                    maxColumns: 4,
                    spacing: gridGap,
                    children: [
                      AppStatCard(
                        label: 'Churn (Cancellations)',
                        value: '${controller.churnCount.value}',
                        caption: 'Bookings cancelled this month',
                        tone: AppTone.danger,
                        icon: LucideIcons.circleX,
                      ),
                      AppStatCard(
                        label: 'Collection Rate',
                        value: '${controller.collectionRate.value}%',
                        caption: 'Collected ÷ Invoiced',
                        tone: AppTone.info,
                        icon: LucideIcons.percent,
                      ),
                      AppStatCard(
                        label: 'Days Sales Outstanding',
                        value: '${controller.dso.value} days',
                        caption: 'Avg time to collect after invoicing',
                        tone: AppTone.violet,
                        icon: LucideIcons.clock,
                      ),
                      AppStatCard(
                        label: 'Overdue Amount',
                        value: _fmt(controller.overdueAmount.value),
                        caption:
                            '${controller.overdueCount.value} invoices past due date',
                        tone: AppTone.warning,
                        icon: LucideIcons.triangleAlert,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool embedded) {
    final refresh = OutlinedButton.icon(
      onPressed: controller.fetchRevenueRecognition,
      icon: const Icon(LucideIcons.refreshCw, size: 18),
      label: const Text('Refresh'),
    );
    if (embedded) {
      return Align(alignment: Alignment.centerRight, child: refresh);
    }
    return AppPageHeader(
      title: 'Finance dashboard',
      subtitle: 'Revenue recognition, MRR/ARR, and collection efficiency',
      actions: [refresh],
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return AppSectionTitle(title: title, subtitle: subtitle);
  }

  /// "This month's revenue breakdown" — one row per revenue state, amounts
  /// right-aligned like a ledger.
  Widget _buildBreakdownCard() {
    final rows = [
      _revenueBreakdownCard(
        label: 'Deferred Revenue',
        description: 'Invoiced but service not yet started',
        value: controller.deferred.value.toDouble(),
        tone: AppTone.warning,
        icon: LucideIcons.hourglass,
      ),
      _revenueBreakdownCard(
        label: 'Recognised Revenue',
        description: 'Service in progress — invoiced this month',
        value: controller.recognized.value.toDouble(),
        tone: AppTone.info,
        icon: LucideIcons.circleCheck,
      ),
      _revenueBreakdownCard(
        label: 'Collected Revenue',
        description: 'Cash actually received this month',
        value: controller.collected.value.toDouble(),
        tone: AppTone.success,
        icon: LucideIcons.banknote,
      ),
    ];
    return AppCard(
      title: 'This month\'s revenue breakdown',
      subtitle: 'Where invoiced revenue sits right now',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, color: AppColor.borderSubtle),
          ],
        ],
      ),
    );
  }

  Widget _revenueBreakdownCard({
    required String label,
    required String description,
    required double value,
    required AppTone tone,
    required IconData icon,
  }) {
    final narrow = SizeConfig.isMobile;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 16 : 20, vertical: 16),
      child: Row(
        children: [
          AppIconTile(icon: icon, tone: tone, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                        fontSize: 12.5, color: AppColor.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(_fmt(value),
              style: accountsAmountStyle(
                  fontSize: narrow ? 15 : 17, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildWaterfall() {
    final legend = [
      _WaterfallItem(label: 'MRR', value: 0, color: AppColor.cAppPrimaryColor),
      _WaterfallItem(label: 'Deferred', value: 0, color: AppColor.warning),
      _WaterfallItem(label: 'Recognised', value: 0, color: AppColor.info),
      _WaterfallItem(label: 'Collected', value: 0, color: AppColor.success),
    ];
    return AppCard(
      title: 'Revenue Waterfall',
      subtitle: 'MRR → deferred → recognised → collected',
      child: Obx(() {
        final items = [
          _WaterfallItem(
            label: 'MRR',
            value: controller.mrr.value.toDouble(),
            color: AppColor.cAppPrimaryColor,
          ),
          _WaterfallItem(
            label: 'Deferred',
            value: controller.deferred.value.toDouble(),
            color: AppColor.warning,
          ),
          _WaterfallItem(
            label: 'Recognised',
            value: controller.recognized.value.toDouble(),
            color: AppColor.info,
          ),
          _WaterfallItem(
            label: 'Collected',
            value: controller.collected.value.toDouble(),
            color: AppColor.success,
          ),
        ];

        final maxValue =
            items.map((i) => i.value).reduce((a, b) => a > b ? a : b);
        final chartHeight = SizeConfig.responsive(
            mobile: 140.0, tablet: 160.0, desktop: 180.0);
        final barMaxHeight = SizeConfig.responsive(
            mobile: 100.0, tablet: 120.0, desktop: 140.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: legend.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(2),
                        )),
                    const SizedBox(width: 6),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 12.5, color: AppColor.textSecondary)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final ratio = maxValue > 0 ? item.value / maxValue : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _fmtShort(item.value),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textSecondary,
                              fontFeatures: accountsTabularFigures,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: barMaxHeight * ratio,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.xs),
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
            Divider(height: 1, color: AppColor.borderSubtle),
            const SizedBox(height: 8),
            Row(
              children: items.map((item) {
                return Expanded(
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppColor.textTertiary),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton() {
    Widget box(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColor.borderSubtle),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppResponsiveGrid(
          minItemWidth: 220,
          maxColumns: 3,
          children: List.generate(3, (_) => box(118)),
        ),
        const SizedBox(height: 32),
        AppResponsiveGrid(
          minItemWidth: 420,
          maxColumns: 2,
          children: List.generate(2, (_) => box(260)),
        ),
        const SizedBox(height: 32),
        AppResponsiveGrid(
          minItemWidth: 200,
          maxColumns: 4,
          children: List.generate(4, (_) => box(118)),
        ),
      ],
    );
  }

  String _fmt(double v) => formatInr(v);

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
