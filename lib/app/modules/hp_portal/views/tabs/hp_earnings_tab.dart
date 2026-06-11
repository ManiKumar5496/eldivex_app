import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          Text('This month',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
          const SizedBox(height: 12),
          Obx(() {
            if (c.loadingEarnings.value && c.earningsSummary.value == null) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            }
            final s = c.earningsSummary.value;
            if (s == null) return HpUi.empty('No earnings data.', icon: Icons.payments_outlined);
            final counts = (s['counts'] as Map?) ?? {};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HpUi.card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total earned', style: TextStyle(color: AppColor.fontColorGrey)),
                      const SizedBox(height: 6),
                      Text(HpUi.money(s['total_amount']),
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w800, color: AppColor.cAppPrimaryColor)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        HpUi.statusChip('Present ${counts['present'] ?? 0}', AppColor.lightGreen),
                        HpUi.statusChip('Half ${counts['half_day'] ?? 0}', Colors.orange),
                        HpUi.statusChip('Leave ${counts['leave'] ?? 0}', AppColor.consultCColor),
                        HpUi.statusChip('Absent ${counts['absent'] ?? 0}', AppColor.calenderRed),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    HpUi.sectionTitle('Daily breakdown'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Get.toNamed(Routes.HP_PAYSLIPS),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Payslips'),
                    ),
                  ],
                ),
                ...((s['days'] as List?) ?? []).map((d) => _dayRow(Map<String, dynamic>.from(d))),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _dayRow(Map<String, dynamic> d) {
    final color = HpUi.attendanceColor(d['status']?.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 10),
          Expanded(child: Text('${d['date'] ?? ''}', style: TextStyle(color: AppColor.fontColorBlack))),
          Text((d['status'] ?? '').toString(),
              style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
          const SizedBox(width: 12),
          Text(HpUi.money(d['amount']),
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.fontColorBlack)),
        ],
      ),
    );
  }
}
