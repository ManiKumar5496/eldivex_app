import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../controllers/cg_payment_controller.dart';
import '../controllers/hp_payouts_controller.dart';
import '../controllers/register_cg_controller.dart';
import '../models/cg_payment_summary.dart';

class CgPaymentView extends StatelessWidget {
  const CgPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are available (inline page in PageView)
    Get.lazyPut<CgPaymentController>(() => CgPaymentController(), fenix: true);
    Get.lazyPut<HpPayoutsController>(() => HpPayoutsController(), fenix: true);

    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 24),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    _buildTabBar(),
                    const SizedBox(height: 16),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColor.divColor.withValues(alpha: 0.8),
              blurRadius: 4,
            ),
          ],
        ),
        labelColor: AppColor.cPrimaryHeadingColor,
        unselectedLabelColor: AppColor.fontColorGrey,
        labelStyle:
            AppTextStyles.regular16.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.regular16Gre,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Calculate Payment'),
          Tab(text: 'Payout History'),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CG Payments', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          'Calculate attendance-based pay and generate caregiver payouts',
          style: AppTextStyles.regular14Gre,
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── CG selector + date range ────────────────────────────────────
          isMobile
              ? _buildFiltersMobile(registerCtrl)
              : _buildFiltersDesktop(registerCtrl),

          const SizedBox(height: 20),

          // ── Summary cards ────────────────────────────────────────────────
          Obx(() {
            final s = controller.paymentSummary.value;
            if (s == null) {
              return const SizedBox.shrink();
            }
            return isMobile
                ? _buildSummaryMobile(s)
                : _buildSummaryDesktop(s);
          }),

          const SizedBox(height: 20),

          // ── Pay breakdown table ──────────────────────────────────────────
          Obx(() {
            final s = controller.paymentSummary.value;
            if (s == null) {
              return _emptyPlaceholder();
            }
            return _buildBreakdownTable(s);
          }),

          const SizedBox(height: 24),

          // ── Generate payout row ──────────────────────────────────────────
          Obx(() {
            if (controller.paymentSummary.value == null) {
              return const SizedBox.shrink();
            }
            return isMobile
                ? _buildGenerateMobile(context)
                : _buildGenerateDesktop(context);
          }),

          const SizedBox(height: 24),
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
        const SizedBox(height: 12),
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
            style: AppTextStyles.regular14Gre
                .copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.divColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ctrl.text.isNotEmpty ? ctrl.text : 'YYYY-MM-DD',
                    style: ctrl.text.isNotEmpty
                        ? AppTextStyles.regular14black
                        : AppTextStyles.regular14Gre),
                Icon(Icons.calendar_today,
                    size: 16, color: AppColor.fontColorGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fetchButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : controller.fetchAndCalculate,
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.calculate, color: Colors.white, size: 18),
          label: Text(
            controller.isLoading.value ? 'Calculating...' : 'Fetch & Calculate',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ));
  }

  // ── Summary Cards ────────────────────────────────────────────────────────────

  Widget _buildSummaryDesktop(CgPaymentSummary s) {
    return Row(
      children: [
        _summaryCard('Total Days',  s.totalDays,   Icons.date_range,    AppColor.cPrimaryButtonColor),
        _summaryCard('Live-In',     s.liveInDays,  Icons.home,          Colors.teal),
        _summaryCard('Live-Out',    s.liveOutDays, Icons.directions_run, Colors.indigo),
        _summaryCard('Half Days',   s.halfDays,    Icons.access_time,   Colors.orange),
        _summaryCard('Absent',      s.absentDays,  Icons.cancel,        AppColor.calenderRed),
      ],
    );
  }

  Widget _buildSummaryMobile(CgPaymentSummary s) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _summaryCard('Total Days', s.totalDays, Icons.date_range, AppColor.cPrimaryButtonColor)),
            const SizedBox(width: 8),
            Expanded(child: _summaryCard('Live-In', s.liveInDays, Icons.home, Colors.teal)),
            const SizedBox(width: 8),
            Expanded(child: _summaryCard('Live-Out', s.liveOutDays, Icons.directions_run, Colors.indigo)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _summaryCard('Half Days', s.halfDays, Icons.access_time, Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _summaryCard('Absent', s.absentDays, Icons.cancel, AppColor.calenderRed)),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.regular12Gre,
                    overflow: TextOverflow.ellipsis),
                Text('$count', style: AppTextStyles.semiBold16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Breakdown Table ──────────────────────────────────────────────────────────

  Widget _buildBreakdownTable(CgPaymentSummary s) {
    final fmt = NumberFormat('#,##0.00');

    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _th('Shift Type', flex: 2),
                _th('Full Days',  flex: 2),
                _th('Half Days',  flex: 2),
                _th('Rate / Day', flex: 2),
                _th('Subtotal',   flex: 2),
              ],
            ),
          ),

          // Rows
          ...s.breakdowns.map((b) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColor.divColor)),
                ),
                child: Row(
                  children: [
                    _td(b.label, flex: 2, bold: true),
                    _td('${b.fullDays}', flex: 2),
                    _td('${b.halfDays}', flex: 2),
                    _td('₹${fmt.format(b.rate)}', flex: 2),
                    _td('₹${fmt.format(b.subtotal)}', flex: 2,
                        color: AppColor.cAppPrimaryColor, bold: true),
                  ],
                ),
              )),

          // Total row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Text('TOTAL PAY',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.semiBold16
                          .copyWith(color: AppColor.fontColorGrey)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${fmt.format(s.totalPay)}',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 20,
                      color: AppColor.cPrimaryButtonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {required int flex}) => Expanded(
        flex: flex,
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorGrey)),
      );

  Widget _td(String text,
      {required int flex, Color? color, bool bold = false}) =>
      Expanded(
        flex: flex,
        child: Text(text,
            style: AppTextStyles.regular14black.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis),
      );

  // ── Generate Payout ──────────────────────────────────────────────────────────

  Widget _buildGenerateDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _paymentModeDropdown()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _generateButton(context)),
        const Expanded(flex: 2, child: SizedBox()),
      ],
    );
  }

  Widget _buildGenerateMobile(BuildContext context) {
    return Column(
      children: [
        _paymentModeDropdown(),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: _generateButton(context)),
      ],
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
    return Obx(() => ElevatedButton.icon(
          onPressed: controller.isGeneratingPayout.value
              ? null
              : () => _confirmGenerate(context),
          icon: controller.isGeneratingPayout.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.payment, color: Colors.white, size: 18),
          label: Text(
            controller.isGeneratingPayout.value
                ? 'Generating...'
                : 'Generate Payout',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.lightGreen,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ));
  }

  void _confirmGenerate(BuildContext context) {
    final s = controller.paymentSummary.value;
    if (s == null) return;
    final fmt = NumberFormat('#,##0.00');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.lightGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.payment, size: 32, color: AppColor.lightGreen),
              ),
              const SizedBox(height: 16),
              Text('Confirm Payout', style: AppTextStyles.semiBold18),
              const SizedBox(height: 8),
              Text(
                'Generate ₹${fmt.format(s.totalPay)} payout for ${s.hpName}?\n'
                'Period: ${s.periodFrom} → ${s.periodTo}',
                style: AppTextStyles.regular14Gre,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.fontColorBlack,
                        side: BorderSide(color: AppColor.divColor),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final ok = await controller.generatePayout();
                        if (ok) {
                          // Refresh history tab
                          Get.find<HpPayoutsController>().fetchPendingPayouts();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lightGreen,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Generate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _emptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate_outlined,
              size: 56, color: AppColor.divColor),
          const SizedBox(height: 16),
          Text('Select a caregiver and date range, then tap Fetch & Calculate',
              style: AppTextStyles.regular14Gre,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends GetView<HpPayoutsController> {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterRow(ctrl: controller),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.isHistoryLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.payoutHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history,
                        size: 56, color: AppColor.divColor),
                    const SizedBox(height: 16),
                    Text('No payout history yet',
                        style: AppTextStyles.regular16Gre),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.fetchPayoutHistory,
              child: ListView.separated(
                itemCount: controller.payoutHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = controller.payoutHistory[index];
                  return _PayoutHistoryCard(payout: p);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Filter Row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.ctrl});
  final HpPayoutsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl.fromDateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'From',
              hintText: 'YYYY-MM-DD',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
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
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: ctrl.toDateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'To',
              hintText: 'YYYY-MM-DD',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
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
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: ctrl.applyHistoryFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Filter', style: AppTextStyles.regular14white),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: ctrl.clearHistoryFilter,
          style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            side: BorderSide(color: AppColor.divColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Clear', style: AppTextStyles.regular14Gre),
        ),
      ],
    );
  }
}

// ── Payout History Card ───────────────────────────────────────────────────────

class _PayoutHistoryCard extends StatelessWidget {
  const _PayoutHistoryCard({required this.payout});
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(hpName,
                        style: AppTextStyles.regular16
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColor.lightGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Paid',
                          style: TextStyle(
                              color: AppColor.lightGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 20, runSpacing: 4, children: [
                  _info('Period', '$periodFrom → $periodTo'),
                  _info('Mode', paymentMode),
                  if (paymentDate != null) _info('Paid on', paymentDate),
                ]),
              ],
            ),
          ),
          Text(
            '₹${fmtAmt != null ? fmt.format(fmtAmt) : amount}',
            style: AppTextStyles.heading.copyWith(
                fontSize: 20, color: AppColor.cAppPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
              text: value,
              style: TextStyle(
                  color: AppColor.fontColorBlack,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
