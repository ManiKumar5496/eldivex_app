import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpPayslipsView extends StatefulWidget {
  const HpPayslipsView({super.key});

  @override
  State<HpPayslipsView> createState() => _HpPayslipsViewState();
}

class _HpPayslipsViewState extends State<HpPayslipsView> {
  final c = Get.find<HpController>();

  @override
  void initState() {
    super.initState();
    c.fetchPayouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Payslips & Payouts')),
      body: Obx(() {
        if (c.loadingPayouts.value) return const Center(child: CircularProgressIndicator());
        if (c.payouts.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.receiptText,
            title: 'No payouts yet.',
            message: 'Your payslips will appear here once a payout is made.',
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchPayouts,
          child: ListView.separated(
            padding: HpUi.pagePadding(context, top: 20),
            itemCount: c.payouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tile(c.payouts[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(Map<String, dynamic> p) {
    final paid = (p['status'] ?? '').toString() == 'Paid';
    return HpUi.card(
      onTap: () => _showPayslip(p['id']),
      child: Row(
        children: [
          AppIconTile(
            icon: LucideIcons.receiptText,
            tone: paid ? AppTone.success : AppTone.warning,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(HpUi.money(p['pay_amount']),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColor.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 2),
                Text('${p['period_from'] ?? '—'} → ${p['period_to'] ?? '—'}',
                    style: TextStyle(color: AppColor.textTertiary, fontSize: 12.5)),
              ],
            ),
          ),
          AppStatusBadge(
            label: paid ? 'Paid' : 'Pending',
            tone: paid ? AppTone.success : AppTone.warning,
          ),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronRight,
              size: 20, color: AppColor.textTertiary),
        ],
      ),
    );
  }

  Future<void> _showPayslip(dynamic id) async {
    final data = await c.fetchPayslip(id is int ? id : int.tryParse('$id') ?? 0);
    if (data == null) return;
    final breakdown = (data['breakdown'] as List?) ?? [];
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HpUi.maxContentWidth),
            child: HpUi.sheet(
              title: 'Payslip',
              subtitle: '${data['period_from'] ?? '—'} → ${data['period_to'] ?? '—'}',
              icon: LucideIcons.receiptText,
              bottomInset: 0,
              children: [
                HpUi.kv('Amount', HpUi.money(data['pay_amount'])),
                HpUi.kv('Period', '${data['period_from'] ?? '—'} → ${data['period_to'] ?? '—'}'),
                HpUi.kv('Status', '${data['status'] ?? '—'}'),
                HpUi.kv('Mode', '${data['payment_mode'] ?? '—'}'),
                HpUi.kv('Paid on', '${data['payment_date'] ?? '—'}'),
                Divider(height: 32, color: AppColor.borderSubtle),
                HpUi.sectionTitle('Attendance in period'),
                if (breakdown.isEmpty)
                  Text('No attendance records in this period.',
                      style: TextStyle(fontSize: 13.5, color: AppColor.textTertiary))
                else
                  ...breakdown.map((d) {
                    final m = Map<String, dynamic>.from(d);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('${m['date'] ?? ''}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.textPrimary))),
                          HpUi.attendanceBadge(m['status']?.toString(),
                              dense: true),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 64),
                            child: Text(HpUi.money(m['amount']),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ])),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
