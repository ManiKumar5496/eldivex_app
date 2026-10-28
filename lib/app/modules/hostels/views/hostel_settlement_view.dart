import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../controllers/hostels_controller.dart';

class HostelSettlementView extends StatelessWidget {
  const HostelSettlementView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<HostelsController>()
        ? Get.find<HostelsController>()
        : Get.put(HostelsController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hostel Settlements',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColor.blackColor)),
            const SizedBox(height: 4),
            Text('Total payable to each hostel for the period, with a per-caregiver breakdown.',
                style: TextStyle(color: AppColor.fontColorGrey)),
            const SizedBox(height: 16),
            _filters(c),
            const SizedBox(height: 16),
            Obx(() {
              if (c.loadingSettlement.value) {
                return const Center(
                    child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
              }
              if (c.settlementError.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.settlementError.value,
                            style: TextStyle(color: AppColor.calenderRed)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: c.fetchSettlement,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final s = c.settlement.value;
              if (s == null) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('Pick a hostel and period, then tap Calculate.',
                        style: TextStyle(color: AppColor.fontColorGrey)),
                  ),
                );
              }
              return _result(c, s);
            }),
          ],
        ),
      ),
    );
  }

  Widget _filters(HostelsController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: Obx(() {
              // Only active hostels can be settled.
              final hostels = c.activeHostels;
              final sel = c.settlementHostelId.value;
              return DropdownButtonFormField<int>(
                  key: ValueKey('settle-hostel-${hostels.length}-$sel'),
                  initialValue: hostels.any((h) => h.id == sel) ? sel : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Hostel', border: OutlineInputBorder()),
                  items: hostels
                      .map((h) => DropdownMenuItem<int>(
                            value: h.id,
                            child: Text(
                                '${h.hostelName} (${HostelsController.normalizeGenderLabel(h.gender)})',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => c.settlementHostelId.value = v,
                );
            }),
          ),
          SizedBox(width: 170, child: _dateField(c.settlementFromCtrl, 'From')),
          SizedBox(width: 170, child: _dateField(c.settlementToCtrl, 'To')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cAppPrimaryColor,
              foregroundColor: AppColor.buttonTextWhite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            onPressed: c.fetchSettlement,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Widget _result(HostelsController c, dynamic s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${s.hostelName} — ${s.periodFrom} to ${s.periodTo}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.blackColor)),
              ),
              Obx(() {
                final savedId = c.lastSettlementId.value;
                if (savedId != null) {
                  // Saved in this session → offer mark-paid on it.
                  if (c.lastSettlementStatus.value == 'Paid') {
                    return Chip(
                      label: Text('Settlement #$savedId · Paid'),
                      backgroundColor: Colors.green.withValues(alpha: 0.12),
                    );
                  }
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: AppColor.buttonTextWhite,
                    ),
                    onPressed: c.isSubmitting.value
                        ? null
                        : () => _confirmMarkPaid(c, savedId),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text('Mark #$savedId as paid'),
                  );
                }
                return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cAppPrimaryColor,
                      foregroundColor: AppColor.buttonTextWhite,
                    ),
                    onPressed: (c.isSubmitting.value || s.lines.isEmpty)
                        ? null
                        : () => c.generateSettlement(),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Generate settlement'),
                  );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 24, runSpacing: 8, children: [
            _summary('Total payable', '₹${s.totalAmount.toStringAsFixed(0)}', emphasize: true),
            _summary('Caregivers', '${s.cgCount}'),
            _summary('Total nights', '${s.totalNights}'),
            _summary('Rate / day', '₹${s.ratePerDay.toStringAsFixed(0)}'),
          ]),
          const Divider(height: 28),
          if (s.lines.isEmpty)
            Text('No stays in this period.', style: TextStyle(color: AppColor.fontColorGrey))
          else ...[
            _headerRow(),
            ...s.lines.map<Widget>((l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(l.hpName.isEmpty ? 'CG #${l.hpId}' : l.hpName)),
                    Expanded(flex: 1, child: Text('${l.nights}')),
                    Expanded(flex: 2, child: Text('₹${l.ratePerDay.toStringAsFixed(0)}')),
                    Expanded(
                        flex: 2,
                        child: Text('₹${l.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600))),
                  ]),
                )),
          ],
        ],
      ),
    );
  }

  void _confirmMarkPaid(HostelsController c, int id) {
    final modeCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.whiteColor,
        title: Text('Mark settlement #$id as paid?'),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: modeCtrl,
            decoration: const InputDecoration(
              labelText: 'Payment mode (optional)',
              hintText: 'e.g. Bank transfer, UPI, Cash',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: c.isSubmitting.value ? null : Get.back,
                child: const Text('Cancel'),
              )),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cAppPrimaryColor,
                  foregroundColor: AppColor.buttonTextWhite,
                ),
                onPressed: c.isSubmitting.value
                    ? null
                    : () async {
                        final ok = await c.markSettlementPaid(id,
                            paymentMode: modeCtrl.text.trim());
                        if (ok && (Get.isDialogOpen ?? false)) Get.back();
                      },
                child: const Text('Mark paid'),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _headerRow() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(flex: 3, child: _h('Caregiver')),
          Expanded(flex: 1, child: _h('Nights')),
          Expanded(flex: 2, child: _h('Rate/day')),
          Expanded(flex: 2, child: _h('Amount')),
        ]),
      );

  Widget _h(String t) =>
      Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.fontColorGrey));

  Widget _dateField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      onTap: () async {
        final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
        final picked = await showDatePicker(
          context: Get.context!,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
    );
  }

  Widget _summary(String k, String v, {bool emphasize = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
          const SizedBox(height: 2),
          Text(v,
              style: TextStyle(
                  fontSize: emphasize ? 22 : 16,
                  fontWeight: FontWeight.w700,
                  color: emphasize ? AppColor.cAppPrimaryColor : AppColor.blackColor)),
        ],
      );
}
