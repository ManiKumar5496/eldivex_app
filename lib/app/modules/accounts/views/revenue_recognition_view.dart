import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../controllers/accounts_controller.dart';

class RevenueRecognitionView extends GetView<AccountsController> {
  const RevenueRecognitionView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.mrr.value == 0 && !controller.isLoadingRevenue.value) {
        controller.fetchRevenueRecognition();
      }
    });

    return Scaffold(
      backgroundColor: AppColor.fieldColorGrey,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            SizedBox(height: SizeConfig.spacingLG),
            Obx(() {
              if (controller.isLoadingRevenue.value) {
                return _buildLoadingSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Recurring Revenue'),
                  SizedBox(height: SizeConfig.spacingSM),
                  _buildResponsiveGrid([
                    _bigKpiCard(
                      label: 'Monthly Recurring Revenue',
                      subtitle: 'From all active bookings × 30 days',
                      value: _fmt(controller.mrr.value.toDouble()),
                      color: AppColor.cPrimaryButtonColor,
                      icon: Icons.trending_up,
                    ),
                    _bigKpiCard(
                      label: 'Annual Recurring Revenue',
                      subtitle: 'MRR × 12',
                      value: _fmt(controller.arr.value.toDouble()),
                      color: Colors.indigo,
                      icon: Icons.bar_chart,
                    ),
                    _bigKpiCard(
                      label: 'Active Bookings',
                      subtitle: 'Generating revenue this month',
                      value: '${controller.activeCount.value}',
                      color: Colors.green,
                      icon: Icons.people_alt_outlined,
                      isCurrency: false,
                    ),
                  ]),
                  SizedBox(height: SizeConfig.spacingLG),

                  _buildSectionTitle('This Month\'s Revenue Breakdown'),
                  SizedBox(height: SizeConfig.spacingSM),
                  _buildResponsiveGrid([
                    _revenueBreakdownCard(
                      label: 'Deferred Revenue',
                      description: 'Invoiced but service not yet started',
                      value: controller.deferred.value.toDouble(),
                      color: Colors.orange,
                      icon: Icons.hourglass_empty,
                    ),
                    _revenueBreakdownCard(
                      label: 'Recognised Revenue',
                      description: 'Service in progress — invoiced this month',
                      value: controller.recognized.value.toDouble(),
                      color: Colors.teal,
                      icon: Icons.check_circle_outline,
                    ),
                    _revenueBreakdownCard(
                      label: 'Collected Revenue',
                      description: 'Cash actually received this month',
                      value: controller.collected.value.toDouble(),
                      color: Colors.green.shade700,
                      icon: Icons.payments_outlined,
                    ),
                  ]),
                  SizedBox(height: SizeConfig.spacingLG),

                  _buildSectionTitle('Efficiency Metrics'),
                  SizedBox(height: SizeConfig.spacingSM),
                  _buildResponsiveGrid([
                    _metricCard(
                      label: 'Churn (Cancellations)',
                      value: '${controller.churnCount.value}',
                      description: 'Bookings cancelled this month',
                      color: Colors.red,
                      icon: Icons.cancel_outlined,
                      isCurrency: false,
                    ),
                    _metricCard(
                      label: 'Collection Rate',
                      value: '${controller.collectionRate.value}%',
                      description: 'Collected ÷ Invoiced',
                      color: Colors.blue,
                      icon: Icons.percent,
                      isCurrency: false,
                    ),
                    _metricCard(
                      label: 'Days Sales Outstanding',
                      value: '${controller.dso.value} days',
                      description: 'Avg time to collect after invoicing',
                      color: Colors.purple,
                      icon: Icons.schedule,
                      isCurrency: false,
                    ),
                    _metricCard(
                      label: 'Overdue Amount',
                      value: _fmt(controller.overdueAmount.value),
                      description:
                          '${controller.overdueCount.value} invoices past due date',
                      color: Colors.red.shade700,
                      icon: Icons.warning_amber_outlined,
                    ),
                  ]),
                  SizedBox(height: SizeConfig.spacingLG),

                  _buildSectionTitle('Revenue Waterfall'),
                  SizedBox(height: SizeConfig.spacingSM),
                  _buildWaterfall(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    if (SizeConfig.isMobile) {
      return Column(
        children: children
            .map((c) => Padding(
                  padding: EdgeInsets.only(bottom: SizeConfig.spacingMD),
                  child: c,
                ))
            .toList(),
      );
    }
    if (SizeConfig.isTablet) {
      return Wrap(
        spacing: SizeConfig.gridSpacing,
        runSpacing: SizeConfig.gridSpacing,
        children: children
            .map((c) => SizedBox(
                  width: (SizeConfig.screenWidth -
                          2 * SizeConfig.pagePadding.left -
                          SizeConfig.gridSpacing) /
                      2,
                  child: c,
                ))
            .toList(),
      );
    }
    // Desktop: Row with Expanded
    final expanded = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      expanded.add(Expanded(child: children[i]));
      if (i < children.length - 1) {
        expanded.add(SizedBox(width: SizeConfig.spacingMD));
      }
    }
    return Row(children: expanded);
  }

  Widget _buildPageHeader() {
    return SizeConfig.adaptiveLayout(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Finance Dashboard',
                  style: TextStyle(
                      fontSize: SizeConfig.fontH2,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cPrimaryHeadingColor)),
              IconButton(
                onPressed: controller.fetchRevenueRecognition,
                icon: Icon(Icons.refresh,
                    color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
                tooltip: 'Refresh',
              ),
            ],
          ),
          Text(
            'Revenue recognition, MRR/ARR, and collection efficiency',
            style: TextStyle(
                fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey),
          ),
        ],
      ),
      tablet: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Finance Dashboard', style: AppTextStyles.heading),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Revenue recognition, MRR/ARR, and collection efficiency',
                style: TextStyle(
                    fontSize: SizeConfig.fontBodySmall,
                    color: AppColor.fontColorGrey),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: controller.fetchRevenueRecognition,
            icon: Icon(Icons.refresh, size: SizeConfig.iconSM),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.cPrimaryButtonColor,
              side: BorderSide(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.radiusSM)),
            ),
          ),
        ],
      ),
    );
  }

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
        SizedBox(width: SizeConfig.spacingXS),
        Text(
          title,
          style: TextStyle(
            fontSize: SizeConfig.fontBody,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ],
    );
  }

  Widget _bigKpiCard({
    required String label,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
    bool isCurrency = true,
  }) {
    return Container(
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
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
                padding: EdgeInsets.all(SizeConfig.spacingSM),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                ),
                child: Icon(icon, color: color, size: SizeConfig.iconMD),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: SizeConfig.spacingMD),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeConfig.responsive(mobile: 22.0, tablet: 24.0, desktop: 26.0),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: SizeConfig.spacingXS),
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.fontBody,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor)),
          SizedBox(height: SizeConfig.spacingXS),
          Text(subtitle,
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.fontColorGrey)),
        ],
      ),
    );
  }

  Widget _revenueBreakdownCard({
    required String label,
    required String description,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.spacingSM),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: SizeConfig.iconMD),
          ),
          SizedBox(width: SizeConfig.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fmt(value),
                    style: TextStyle(
                      fontSize: SizeConfig.fontH2,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
                SizedBox(height: SizeConfig.spacingXS / 2),
                Text(label,
                    style: TextStyle(
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w600)),
                Text(description,
                    style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        color: AppColor.fontColorGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required String description,
    required Color color,
    required IconData icon,
    bool isCurrency = true,
  }) {
    return Container(
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: SizeConfig.iconSM),
          SizedBox(height: SizeConfig.spacingSM),
          Text(value,
              style: TextStyle(
                  fontSize: SizeConfig.fontH2,
                  fontWeight: FontWeight.w700,
                  color: color)),
          SizedBox(height: SizeConfig.spacingXS / 2),
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.fontBody, fontWeight: FontWeight.w500)),
          SizedBox(height: SizeConfig.spacingXS / 2),
          Text(description,
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.fontColorGrey)),
        ],
      ),
    );
  }

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

      final maxValue = items.map((i) => i.value).reduce((a, b) => a > b ? a : b);
      final chartHeight = SizeConfig.responsive(
          mobile: 140.0, tablet: 160.0, desktop: 180.0);
      final barMaxHeight = SizeConfig.responsive(
          mobile: 100.0, tablet: 120.0, desktop: 140.0);

      return Container(
        padding: SizeConfig.cardPadding,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: SizeConfig.spacingMD,
              runSpacing: SizeConfig.spacingXS,
              children: items.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        )),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text(item.label,
                        style: TextStyle(fontSize: SizeConfig.fontBodySmall)),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: SizeConfig.spacingLG),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final ratio = maxValue > 0 ? item.value / maxValue : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spacingXS),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _fmtShort(item.value),
                            style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
                              fontWeight: FontWeight.w600,
                              color: item.color,
                            ),
                          ),
                          SizedBox(height: SizeConfig.spacingXS),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: barMaxHeight * ratio,
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
            SizedBox(height: SizeConfig.spacingXS),
            Row(
              children: items.map((item) {
                return Expanded(
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.fontColorGrey),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponsiveGrid(List.generate(
          3,
          (_) => Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
            ),
          ),
        )),
        SizedBox(height: SizeConfig.spacingLG),
        _buildResponsiveGrid(List.generate(
          3,
          (_) => Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
            ),
          ),
        )),
      ],
    );
  }

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
