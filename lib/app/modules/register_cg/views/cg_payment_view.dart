import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../controllers/cg_payment_controller.dart';
import '../controllers/hp_payouts_controller.dart';
import '../controllers/register_cg_controller.dart';
import '../models/cg_payment_summary.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CgPaymentView extends StatelessWidget {
  const CgPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are available (inline page in PageView)
    Get.lazyPut<CgPaymentController>(() => CgPaymentController(), fenix: true);
    Get.lazyPut<HpPayoutsController>(() => HpPayoutsController(), fenix: true);

    SizeConfig.init(context);
    final pad = SizeConfig.pagePadding;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        // Bottom padding is applied inside each tab so content can scroll
        // to the edge.
        padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTabBar(),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          _CalculateTab(),
                          _HistoryTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return const TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        Tab(text: 'Calculate Payment'),
        Tab(text: 'Payout History'),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const AppPageHeader(
      title: 'CG Payments',
      subtitle: 'Calculate attendance-based pay and generate caregiver payouts',
    );
  }
}

// ── Calculate Tab ─────────────────────────────────────────────────────────────

class _CalculateTab extends GetView<CgPaymentController> {
  const _CalculateTab();

  @override
  Widget build(BuildContext context) {
    final isMobile = SizeConfig.isMobile;
    final registerCtrl = Get.find<RegisterCgController>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20, bottom: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── CG selector + date range ────────────────────────────────────
          AppCard(
            title: 'Pay period',
            subtitle: 'Pick a caregiver and date range to calculate attendance-based pay',
            icon: LucideIcons.calculator,
            child: isMobile
                ? _buildFiltersMobile(registerCtrl)
                : _buildFiltersDesktop(registerCtrl),
          ),

          const SizedBox(height: 20),

          // ── Summary cards ────────────────────────────────────────────────
          Obx(() {
            final s = controller.paymentSummary.value;
            if (s == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildSummary(s),
            );
          }),

          // ── Pay breakdown table ──────────────────────────────────────────
          Obx(() {
            final s = controller.paymentSummary.value;
            if (s == null) {
              return _emptyPlaceholder();
            }
            return _buildBreakdownTable(s);
          }),

          const SizedBox(height: 20),

          // ── Generate payout row ──────────────────────────────────────────
          Obx(() {
            if (controller.paymentSummary.value == null) {
              return const SizedBox.shrink();
            }
            return isMobile
                ? _buildGenerateMobile(context)
                : _buildGenerateDesktop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildFiltersDesktop(RegisterCgController registerCtrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 3, child: _cgDropdown(registerCtrl)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _datePicker('From', controller.periodFromCtrl)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _datePicker('To', controller.periodToCtrl)),
        const SizedBox(width: 16),
        _fetchButton(),
      ],
    );
  }

  Widget _buildFiltersMobile(RegisterCgController registerCtrl) {
    return Column(
      children: [
        _cgDropdown(registerCtrl),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _datePicker('From', controller.periodFromCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _datePicker('To', controller.periodToCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: _fetchButton()),
      ],
    );
  }

  Widget _cgDropdown(RegisterCgController registerCtrl) {
    return Obx(() {
      final cgList = registerCtrl.activeCgList;
      return AppDropdownFormField(
        label: 'Select Caregiver',
        hint: 'Choose a caregiver',
        value: controller.selectedCg.value,
        items: cgList.map((cg) {
          return DropdownMenuItem(
            value: cg,
            child: Text(
              '${cg.hpRegFirstName} ${cg.hpRegLastName} (HP-${cg.hpRegId})',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (cg) {
          if (cg != null) controller.selectCg(cg);
        },
      );
    });
  }

  Widget _datePicker(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: AppColor.textSecondary)),
        const SizedBox(height: 8),
        Material(
          color: AppColor.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColor.textFieldBorderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () async {
              final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme:
                        ColorScheme.light(primary: AppColor.cPrimaryButtonColor),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              // Rebuilds when the picked date is written to [ctrl].
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: ctrl,
                builder: (context, value, _) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.text.isNotEmpty ? value.text : 'YYYY-MM-DD',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: value.text.isNotEmpty
                              ? AppColor.textPrimary
                              : AppColor.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.calendar,
                        size: 16, color: AppColor.textTertiary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fetchButton() {
    return Obx(() => SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: controller.isLoading.value
                ? null
                : controller.fetchAndCalculate,
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                  )
                : const Icon(LucideIcons.calculator, size: 18),
            label: Text(
              controller.isLoading.value ? 'Calculating...' : 'Fetch & Calculate',
            ),
          ),
        ));
  }

  // ── Summary Cards ────────────────────────────────────────────────────────────

  Widget _buildSummary(CgPaymentSummary s) {
    return AppResponsiveGrid(
      minItemWidth: 160,
      maxColumns: 5,
      spacing: SizeConfig.isMobile ? 12 : 16,
      children: [
        AppStatCard(
          label: 'Total Days',
          value: '${s.totalDays}',
          icon: LucideIcons.calendarRange,
          tone: AppTone.primary,
        ),
        AppStatCard(
          label: 'Live-In',
          value: '${s.liveInDays}',
          icon: LucideIcons.house,
          tone: AppTone.info,
        ),
        AppStatCard(
          label: 'Live-Out',
          value: '${s.liveOutDays}',
          icon: LucideIcons.personStanding,
          tone: AppTone.violet,
        ),
        AppStatCard(
          label: 'Half Days',
          value: '${s.halfDays}',
          icon: LucideIcons.clock,
          tone: AppTone.warning,
        ),
        AppStatCard(
          label: 'Absent',
          value: '${s.absentDays}',
          icon: LucideIcons.circleX,
          tone: AppTone.danger,
        ),
      ],
    );
  }

  // ── Breakdown Table ──────────────────────────────────────────────────────────

  static const double _breakdownMinWidth = 600;

  Widget _buildBreakdownTable(CgPaymentSummary s) {
    final fmt = NumberFormat('#,##0.00');

    return AppCard(
      title: 'Pay breakdown',
      icon: LucideIcons.receiptText,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth < _breakdownMinWidth
            ? _breakdownMinWidth
            : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceMuted,
                    border: Border(
                        bottom: BorderSide(color: AppColor.borderSubtle)),
                  ),
                  child: Row(
                    children: [
                      _th('Shift Type', flex: 2),
                      _th('Full Days',  flex: 2, numeric: true),
                      _th('Half Days',  flex: 2, numeric: true),
                      _th('Rate / Day', flex: 2, numeric: true),
                      _th('Subtotal',   flex: 2, numeric: true),
                    ],
                  ),
                ),

                // Rows
                ...s.breakdowns.map((b) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColor.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          _td(b.label, flex: 2, bold: true),
                          _td('${b.fullDays}', flex: 2, numeric: true),
                          _td('${b.halfDays}', flex: 2, numeric: true),
                          _td('₹${fmt.format(b.rate)}', flex: 2, numeric: true),
                          _td('₹${fmt.format(b.subtotal)}', flex: 2,
                              bold: true, numeric: true),
                        ],
                      ),
                    )),

                // Gross pay row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: s.hostelDeduction > 0
                      ? AppColor.surfaceMuted
                      : AppColor.primarySoft,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                            s.hostelDeduction > 0 ? 'GROSS PAY' : 'TOTAL PAY',
                            textAlign: TextAlign.right,
                            style: _totalLabelStyle),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${fmt.format(s.totalPay)}',
                          textAlign: TextAlign.right,
                          style: _moneyStyle(
                            size: 18,
                            color: s.hostelDeduction > 0
                                ? AppColor.textPrimary
                                : AppColor.cPrimaryButtonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hostel deductions (only when the CG stayed in a hostel) ──
                if (s.hostelDeduction > 0) ...[
                  ...s.hostelLines.map((h) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: AppColor.borderSubtle)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Text(
                                'Hostel: ${h.hostelName}  (${h.nights} nights × ₹${fmt.format(h.ratePerDay)})',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColor.textSecondary),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('− ₹${fmt.format(h.amount)}',
                                  textAlign: TextAlign.right,
                                  style: _moneyStyle(
                                      size: 13.5,
                                      color: AppColor.danger,
                                      weight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      )),

                  // Net pay row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColor.primarySoft,
                      border: Border(
                          top: BorderSide(color: AppColor.borderSubtle)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text('NET PAY',
                              textAlign: TextAlign.right,
                              style: _totalLabelStyle.copyWith(
                                  color: AppColor.textPrimary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${fmt.format(s.netPay)}',
                            textAlign: TextAlign.right,
                            style: _moneyStyle(
                              size: 20,
                              color: AppColor.cPrimaryButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  TextStyle get _totalLabelStyle => TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColor.textSecondary,
      );

  TextStyle _moneyStyle({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  Widget _th(String text, {required int flex, bool numeric = false}) =>
      Expanded(
        flex: flex,
        child: Padding(
          padding: EdgeInsets.only(left: numeric ? 12 : 0),
          child: Text(text,
              textAlign: numeric ? TextAlign.right : TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: AppColor.textSecondary)),
        ),
      );

  Widget _td(String text,
      {required int flex,
      Color? color,
      bool bold = false,
      bool numeric = false}) =>
      Expanded(
        flex: flex,
        child: Padding(
          padding: EdgeInsets.only(left: numeric ? 12 : 0),
          child: Text(text,
              textAlign: numeric ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 13.5,
                color: color ?? AppColor.textPrimary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                fontFeatures:
                    numeric ? const [FontFeature.tabularFigures()] : null,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      );

  // ── Generate Payout ──────────────────────────────────────────────────────────

  Widget _buildGenerateDesktop(BuildContext context) {
    return AppCard(
      title: 'Generate payout',
      subtitle: 'Record the calculated amount as a caregiver payout',
      icon: LucideIcons.banknote,
      iconTone: AppTone.success,
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(width: 280, child: _paymentModeDropdown()),
          _generateButton(context),
        ],
      ),
    );
  }

  Widget _buildGenerateMobile(BuildContext context) {
    return AppCard(
      title: 'Generate payout',
      icon: LucideIcons.banknote,
      iconTone: AppTone.success,
      child: Column(
        children: [
          _paymentModeDropdown(),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: _generateButton(context)),
        ],
      ),
    );
  }

  Widget _paymentModeDropdown() {
    return Obx(() => AppDropdownFormField<String>(
          label: 'Payment Mode',
          hint: 'Select mode',
          value: controller.paymentMode.value,
          items: CgPaymentController.paymentModes
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.paymentMode.value = v;
          },
        ));
  }

  Widget _generateButton(BuildContext context) {
    return Obx(() => SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: controller.isGeneratingPayout.value
                ? null
                : () => _confirmGenerate(context),
            icon: controller.isGeneratingPayout.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                  )
                : const Icon(LucideIcons.banknote, size: 18),
            label: Text(
              controller.isGeneratingPayout.value
                  ? 'Generating...'
                  : 'Generate Payout',
            ),
          ),
        ));
  }

  void _confirmGenerate(BuildContext context) {
    final s = controller.paymentSummary.value;
    if (s == null) return;
    final fmt = NumberFormat('#,##0.00');

    Get.dialog(
      AppDialog(
        title: 'Confirm Payout',
        icon: LucideIcons.banknote,
        tone: AppTone.success,
        maxWidth: 440,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final ok = await controller.generatePayout();
              if (ok) {
                // Refresh history tab
                Get.find<HpPayoutsController>().fetchPendingPayouts();
              }
            },
            child: const Text('Generate'),
          ),
        ],
        child: Text(
          'Generate ₹${fmt.format(s.netPay)} payout for ${s.hpName}?\n'
          '${s.hostelDeduction > 0 ? 'Gross ₹${fmt.format(s.totalPay)} − hostel ₹${fmt.format(s.hostelDeduction)}\n' : ''}'
          'Period: ${s.periodFrom} → ${s.periodTo}',
          style: TextStyle(
              fontSize: 14, height: 1.6, color: AppColor.textSecondary),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _emptyPlaceholder() {
    return const AppCard(
      child: AppEmptyState(
        icon: LucideIcons.calculator,
        title: 'No calculation yet',
        message: 'Select a caregiver and date range, then tap Fetch & Calculate',
      ),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends GetView<HpPayoutsController> {
  const _HistoryTab();

  static const double _tableMinWidth = 760;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: SizeConfig.isMobile ? 12 : 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        expandChild: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _FilterRow(ctrl: controller),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Expanded(
              child: Obx(() {
                if (controller.isHistoryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.payoutHistory.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.history,
                    title: 'No payout history yet',
                  );
                }
                final count = controller.payoutHistory.length;
                return LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth < _tableMinWidth
                      ? _tableMinWidth
                      : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          const _HistoryHeaderRow(),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: controller.fetchPayoutHistory,
                              child: ListView.builder(
                                itemCount: count,
                                itemBuilder: (context, index) {
                                  final p = controller.payoutHistory[index];
                                  return _PayoutHistoryRow(payout: p);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.ctrl});
  final HpPayoutsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 190,
          child: TextField(
            controller: ctrl.fromDateCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'From',
              hintText: 'YYYY-MM-DD',
              isDense: true,
              suffixIcon: Icon(LucideIcons.calendar, size: 16),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 30)),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ctrl.fromDateCtrl.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
        SizedBox(
          width: 190,
          child: TextField(
            controller: ctrl.toDateCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'To',
              hintText: 'YYYY-MM-DD',
              isDense: true,
              suffixIcon: Icon(LucideIcons.calendar, size: 16),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ctrl.toDateCtrl.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: ctrl.applyHistoryFilter,
          icon: const Icon(LucideIcons.listFilter, size: 18),
          label: const Text('Filter'),
        ),
        TextButton(
          onPressed: ctrl.clearHistoryFilter,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

// ── Payout History Table ──────────────────────────────────────────────────────

/// Column flexes shared by [_HistoryHeaderRow] and [_PayoutHistoryRow].
const _kHistoryFlex = [3, 3, 2, 2, 2, 2];

class _HistoryHeaderRow extends StatelessWidget {
  const _HistoryHeaderRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['Caregiver', 'Period', 'Mode', 'Paid on', 'Status', 'Amount'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              flex: _kHistoryFlex[i],
              child: Padding(
                padding: EdgeInsets.only(
                    right: i == labels.length - 1 ? 0 : 12),
                child: Text(
                  labels[i],
                  textAlign:
                      i == labels.length - 1 ? TextAlign.right : TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PayoutHistoryRow extends StatelessWidget {
  const _PayoutHistoryRow({required this.payout});
  final Map<String, dynamic> payout;

  @override
  Widget build(BuildContext context) {
    final hpName = payout['hp_reg_name']?.toString() ??
        payout['hp_name']?.toString() ??
        'HP #${payout['hp_unique_id']}';
    final periodFrom  = payout['period_from']?.toString() ?? '—';
    final periodTo    = payout['period_to']?.toString()   ?? '—';
    final amount      = payout['pay_amount']?.toString()  ?? '—';
    final paymentMode = payout['payment_mode']?.toString() ?? 'Cash';
    final paymentDate = payout['payment_date']?.toString();
    final fmt = NumberFormat('#,##0.00');
    final fmtAmt = double.tryParse(amount);

    final textStyle = TextStyle(fontSize: 13.5, color: AppColor.textPrimary);

    Widget cell(int i, Widget child) => Expanded(
          flex: _kHistoryFlex[i],
          child: Padding(
            padding: EdgeInsets.only(right: i == _kHistoryFlex.length - 1 ? 0 : 12),
            child: child,
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          cell(
            0,
            Row(
              children: [
                AppAvatar(name: hpName, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hpName,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          cell(1, Text('$periodFrom → $periodTo',
              overflow: TextOverflow.ellipsis, style: textStyle)),
          cell(2, Text(paymentMode,
              overflow: TextOverflow.ellipsis, style: textStyle)),
          cell(3, Text(paymentDate ?? '—',
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(color: AppColor.textSecondary))),
          cell(
            4,
            Align(
              alignment: Alignment.centerLeft,
              child: AppStatusBadge.status('Paid', dense: true),
            ),
          ),
          cell(
            5,
            Text(
              '₹${fmtAmt != null ? fmt.format(fmtAmt) : amount}',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
