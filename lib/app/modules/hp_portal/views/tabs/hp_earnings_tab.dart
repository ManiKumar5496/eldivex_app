import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpEarningsTab extends StatefulWidget {
  const HpEarningsTab({super.key});

  @override
  State<HpEarningsTab> createState() => _HpEarningsTabState();
}

class _HpEarningsTabState extends State<HpEarningsTab> {
  final c = Get.find<HpController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.earningsSummary.value == null) c.fetchMonthSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: c.fetchMonthSummary,
      child: ListView(
        padding: HpUi.pagePadding(context, top: 20),
        children: [
          HpUi.tabHeader('Earnings', subtitle: 'This month'),
          Obx(() {
            if (c.loadingEarnings.value && c.earningsSummary.value == null) {
              return HpUi.loader();
            }
            final s = c.earningsSummary.value;
            if (s == null) {
              return HpUi.card(
                child: const AppEmptyState(
                  compact: true,
                  icon: LucideIcons.banknote,
                  title: 'No earnings data',
                  message: 'Earnings for this month will appear here.',
                ),
              );
            }
            final counts = (s['counts'] as Map?) ?? {};
            final days = (s['days'] as List?) ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppStatCard(
                  label: 'Total earned',
                  value: HpUi.money(s['total_amount']),
                  icon: LucideIcons.wallet,
                  caption: 'This month',
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  AppStatusBadge(
                      label: 'Present ${counts['present'] ?? 0}',
                      tone: AppTone.success),
                  AppStatusBadge(
                      label: 'Half ${counts['half_day'] ?? 0}',
                      tone: AppTone.warning),
                  AppStatusBadge(
                      label: 'Leave ${counts['leave'] ?? 0}',
                      tone: AppTone.violet),
                  AppStatusBadge(
                      label: 'Absent ${counts['absent'] ?? 0}',
                      tone: AppTone.danger),
                ]),
                const SizedBox(height: 24),
                HpUi.sectionTitle(
                  'Daily breakdown',
                  trailing: TextButton.icon(
                    onPressed: () => Get.toNamed(Routes.HP_PAYSLIPS),
                    icon: const Icon(LucideIcons.receiptText, size: 18),
                    label: const Text('Payslips'),
                  ),
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: days.isEmpty
                      ? const AppEmptyState(
                          compact: true,
                          icon: LucideIcons.calendarDays,
                          title: 'No days recorded yet',
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < days.length; i++) ...[
                              if (i > 0)
                                Divider(
                                    height: 1, color: AppColor.borderSubtle),
                              _dayRow(Map<String, dynamic>.from(days[i])),
                            ],
                          ],
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _dayRow(Map<String, dynamic> d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Text('${d['date'] ?? ''}',
                  style:
                      TextStyle(fontSize: 14, color: AppColor.textPrimary))),
          HpUi.attendanceBadge(d['status']?.toString(), dense: true),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64),
            child: Text(HpUi.money(d['amount']),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        ],
      ),
    );
  }
}
