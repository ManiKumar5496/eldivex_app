import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/hostels_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HostelSettlementView extends StatelessWidget {
  const HostelSettlementView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final c = Get.isRegistered<HostelsController>()
        ? Get.find<HostelsController>()
        : Get.put(HostelsController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppPageHeader(
              title: 'Hostel Settlements',
              subtitle:
                  'Total payable to each hostel for the period, with a per-caregiver breakdown.',
            ),
            SizedBox(height: SizeConfig.isMobile ? 16 : 24),
            _filters(c),
            const SizedBox(height: 20),
            Obx(() {
              if (c.loadingSettlement.value) {
                return const AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (c.settlementError.value.isNotEmpty) {
                return AppCard(
                  child: AppEmptyState(
                    icon: LucideIcons.circleAlert,
                    tone: AppTone.danger,
                    title: 'Could not calculate settlement',
                    message: c.settlementError.value,
                    actionLabel: 'Retry',
                    actionIcon: LucideIcons.refreshCw,
                    onAction: c.fetchSettlement,
                  ),
                );
              }
              final s = c.settlement.value;
              if (s == null) {
                return const AppCard(
                  child: AppEmptyState(
                    icon: LucideIcons.calculator,
                    title: 'No settlement calculated',
                    message: 'Pick a hostel and period, then tap Calculate.',
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
    final narrow = SizeConfig.isMobile;
    return AppCard(
      title: 'Settlement period',
      subtitle: 'Only active hostels can be settled',
      icon: LucideIcons.slidersHorizontal,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: narrow ? double.infinity : 280,
            child: Obx(() {
              // Only active hostels can be settled.
              final hostels = c.activeHostels;
              final sel = c.settlementHostelId.value;
              return DropdownButtonFormField<int>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                  key: ValueKey('settle-hostel-${hostels.length}-$sel'),
                  initialValue: hostels.any((h) => h.id == sel) ? sel : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Hostel'),
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
          SizedBox(width: narrow ? 150 : 170, child: _dateField(c.settlementFromCtrl, 'From')),
          SizedBox(width: narrow ? 150 : 170, child: _dateField(c.settlementToCtrl, 'To')),
          ElevatedButton.icon(
            onPressed: c.fetchSettlement,
            icon: const Icon(LucideIcons.calculator, size: 18),
            label: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Widget _result(HostelsController c, dynamic s) {
    final List lines = s.lines as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppResponsiveGrid(
          minItemWidth: SizeConfig.isMobile ? 140 : 200,
          maxColumns: 4,
          spacing: SizeConfig.isMobile ? 12 : 16,
          children: [
            _summary('Total payable', '₹${s.totalAmount.toStringAsFixed(0)}',
                LucideIcons.wallet, AppTone.primary),
            _summary('Caregivers', '${s.cgCount}', LucideIcons.users,
                AppTone.info),
            _summary('Total nights', '${s.totalNights}', LucideIcons.moon,
                AppTone.violet),
            _summary('Rate / day', '₹${s.ratePerDay.toStringAsFixed(0)}',
                LucideIcons.banknote, AppTone.neutral),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          title: '${s.hostelName}',
          subtitle: '${s.periodFrom} to ${s.periodTo}',
          icon: LucideIcons.receiptText,
          padding: EdgeInsets.zero,
          actions: [
            Obx(() {
              final savedId = c.lastSettlementId.value;
              if (savedId != null) {
                // Saved in this session → offer mark-paid on it.
                if (c.lastSettlementStatus.value == 'Paid') {
                  return AppStatusBadge(
                    label: 'Settlement #$savedId · Paid',
                    tone: AppTone.success,
                  );
                }
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.success,
                    foregroundColor: AppColor.pureWhite,
                  ),
                  onPressed: c.isSubmitting.value
                      ? null
                      : () => _confirmMarkPaid(c, savedId),
                  icon: const Icon(LucideIcons.circleCheck, size: 18),
                  label: Text('Mark #$savedId as paid'),
                );
              }
              return ElevatedButton.icon(
                  onPressed: (c.isSubmitting.value || s.lines.isEmpty)
                      ? null
                      : () => c.generateSettlement(),
                  icon: const Icon(LucideIcons.receiptText, size: 18),
                  label: const Text('Generate settlement'),
                );
            }),
          ],
          child: lines.isEmpty
              ? const AppEmptyState(
                  compact: true,
                  icon: LucideIcons.calendarX,
                  title: 'No stays in this period.',
                )
              : _linesTable(lines),
        ),
      ],
    );
  }

  /// Per-caregiver breakdown; money and counts right-aligned.
  Widget _linesTable(List lines) {
    final money = TextStyle(
      fontSize: 14,
      color: AppColor.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return LayoutBuilder(builder: (context, constraints) {
      final table = DataTable(
        horizontalMargin: 20,
        columnSpacing: 24,
        headingRowHeight: 44,
        columns: const [
          DataColumn(label: Text('Caregiver')),
          DataColumn(label: Text('Nights'), numeric: true),
          DataColumn(label: Text('Rate/day'), numeric: true),
          DataColumn(label: Text('Amount'), numeric: true),
        ],
        rows: [
          for (final l in lines)
            DataRow(cells: [
              DataCell(Text(
                l.hpName.isEmpty ? 'CG #${l.hpId}' : l.hpName,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary),
              )),
              DataCell(Text('${l.nights}', style: money)),
              DataCell(Text('₹${l.ratePerDay.toStringAsFixed(0)}', style: money)),
              DataCell(Text('₹${l.amount.toStringAsFixed(0)}',
                  style: money.copyWith(
                      fontWeight: FontWeight.w600, color: AppColor.textPrimary))),
            ]),
        ],
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: table,
        ),
      );
    });
  }

  void _confirmMarkPaid(HostelsController c, int id) {
    final modeCtrl = TextEditingController();
    Get.dialog(
      AppDialog(
        title: 'Mark settlement #$id as paid?',
        icon: LucideIcons.circleCheck,
        tone: AppTone.success,
        maxWidth: 440,
        // Same guard as Cancel: no closing while the request runs.
        onClose: () {
          if (!c.isSubmitting.value) Get.back();
        },
        actions: [
          Obx(() => OutlinedButton(
                onPressed: c.isSubmitting.value ? null : Get.back,
                child: const Text('Cancel'),
              )),
          Obx(() => ElevatedButton(
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
        child: TextField(
          controller: modeCtrl,
          decoration: const InputDecoration(
            labelText: 'Payment mode (optional)',
            hintText: 'e.g. Bank transfer, UPI, Cash',
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _dateField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(LucideIcons.calendar, size: 18),
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

  Widget _summary(String k, String v, IconData icon, AppTone tone) =>
      AppStatCard(label: k, value: v, icon: icon, tone: tone);
}
