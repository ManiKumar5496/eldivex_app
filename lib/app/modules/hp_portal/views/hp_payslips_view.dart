import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';

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
        if (c.payouts.isEmpty) return HpUi.empty('No payouts yet.', icon: Icons.receipt_long);
        return RefreshIndicator(
          onRefresh: c.fetchPayouts,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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
    return InkWell(
      onTap: () => _showPayslip(p['id']),
      borderRadius: BorderRadius.circular(14),
      child: HpUi.card(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(HpUi.money(p['pay_amount']),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColor.fontColorBlack)),
                  const SizedBox(height: 4),
                  Text('${p['period_from'] ?? '—'} → ${p['period_to'] ?? '—'}',
                      style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
                ],
              ),
            ),
            HpUi.statusChip(paid ? 'PAID' : 'PENDING',
                paid ? AppColor.lightGreen : Colors.orange),
          ],
        ),
      ),
    );
  }

  Future<void> _showPayslip(dynamic id) async {
    final data = await c.fetchPayslip(id is int ? id : int.tryParse('$id') ?? 0);
    if (data == null) return;
    final breakdown = (data['breakdown'] as List?) ?? [];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.cAppBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Payslip',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              ),
              const SizedBox(height: 12),
              HpUi.kv('Amount', HpUi.money(data['pay_amount'])),
              HpUi.kv('Period', '${data['period_from'] ?? '—'} → ${data['period_to'] ?? '—'}'),
              HpUi.kv('Status', '${data['status'] ?? '—'}'),
              HpUi.kv('Mode', '${data['payment_mode'] ?? '—'}'),
              HpUi.kv('Paid on', '${data['payment_date'] ?? '—'}'),
              const Divider(height: 24),
              HpUi.sectionTitle('Attendance in period'),
              if (breakdown.isEmpty)
                Text('No attendance records in this period.',
                    style: TextStyle(color: AppColor.fontColorGrey))
              else
                ...breakdown.map((d) {
                  final m = Map<String, dynamic>.from(d);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text('${m['date'] ?? ''}')),
                        Text('${m['status'] ?? ''}',
                            style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(HpUi.money(m['amount']),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
