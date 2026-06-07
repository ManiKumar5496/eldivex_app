import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/hp_payouts_controller.dart';

class HpPayoutsView extends GetView<HpPayoutsController> {
  const HpPayoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
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
                            _PendingTab(),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColor.divColor),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HP Payouts', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Track pending dues and record caregiver payments.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showCreatePayoutDialog(context, controller),
          icon: Icon(Icons.add, size: 18, color: AppColor.buttonTextWhite),
          label: Text('Create Payout', style: AppTextStyles.regular14white),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
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
        labelStyle: AppTextStyles.regular16.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.regular16Gre,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'History'),
        ],
      ),
    );
  }
}

// ── Pending Tab ───────────────────────────────────────────────────────────────

class _PendingTab extends GetView<HpPayoutsController> {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPendingLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.pendingPayouts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 56, color: AppColor.cAppPrimaryColor),
              const SizedBox(height: 16),
              Text('No pending payouts', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text('All caregivers are up to date!',
                  style: AppTextStyles.regular14Gre),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchPendingPayouts,
        child: ListView.separated(
          itemCount: controller.pendingPayouts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final payout = controller.pendingPayouts[index];
            return _PayoutCard(
              payout: payout,
              isPending: true,
              onMarkPaid: () => _confirmMarkPaid(context, controller, payout),
            );
          },
        ),
      );
    });
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends GetView<HpPayoutsController> {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date filter row
        _FilterRow(controller: controller),
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
                    Icon(Icons.history, size: 56, color: AppColor.lightGrey),
                    const SizedBox(height: 16),
                    Text('No payout history', style: AppTextStyles.regular16Gre),
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
                  final payout = controller.payoutHistory[index];
                  return _PayoutCard(payout: payout, isPending: false);
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
  const _FilterRow({required this.controller});
  final HpPayoutsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.fromDateCtrl,
            readOnly: true,
            decoration: _inputDecoration('From date (YYYY-MM-DD)'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 30)),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.fromDateCtrl.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller.toDateCtrl,
            readOnly: true,
            decoration: _inputDecoration('To date (YYYY-MM-DD)'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.toDateCtrl.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: controller.applyHistoryFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Filter', style: AppTextStyles.regular14white),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: controller.clearHistoryFilter,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            side: BorderSide(color: AppColor.textFieldBorderColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Clear', style: AppTextStyles.regular14Gre),
        ),
      ],
    );
  }
}

// ── Payout Card ───────────────────────────────────────────────────────────────

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({
    required this.payout,
    required this.isPending,
    this.onMarkPaid,
  });

  final Map<String, dynamic> payout;
  final bool isPending;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final id          = payout['id']?.toString() ?? '—';
    final hpName      = payout['hp_reg_name']?.toString() ??
                        payout['hp_name']?.toString() ?? 'HP #${payout['hp_unique_id']}';
    final bookingId   = payout['booking_id']?.toString() ?? '—';
    final periodFrom  = payout['period_from']?.toString() ?? '—';
    final periodTo    = payout['period_to']?.toString() ?? '—';
    final amount      = payout['pay_amount']?.toString() ?? '—';
    final paymentMode = payout['payment_mode']?.toString() ?? 'Cash';
    final paymentDate = payout['payment_date']?.toString();
    final daysOwed    = payout['days_owed']?.toString();

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
          // Left: info
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
                    _StatusChip(isPending: isPending),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  children: [
                    _InfoItem(label: 'ID', value: '#$id'),
                    _InfoItem(label: 'Booking', value: '#$bookingId'),
                    _InfoItem(label: 'Period',
                        value: '$periodFrom → $periodTo'),
                    if (daysOwed != null)
                      _InfoItem(label: 'Days', value: daysOwed),
                    _InfoItem(label: 'Mode', value: paymentMode),
                    if (paymentDate != null)
                      _InfoItem(label: 'Paid on', value: paymentDate),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: amount + action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_formatAmount(amount)}',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 22,
                  color: isPending
                      ? AppColor.babyCColor
                      : AppColor.cAppPrimaryColor,
                ),
              ),
              if (isPending && onMarkPaid != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onMarkPaid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cAppPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('Mark Paid',
                      style: AppTextStyles.regular14white),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(String raw) {
    final d = double.tryParse(raw);
    if (d == null) return raw;
    return d.toStringAsFixed(2);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPending});
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final color = isPending ? AppColor.babyCColor : AppColor.cAppPrimaryColor;
    final label = isPending ? 'Pending' : 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.regular12Gre.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: AppTextStyles.regular12Gre,
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.regular14black
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

void _confirmMarkPaid(
  BuildContext context,
  HpPayoutsController controller,
  Map<String, dynamic> payout,
) {
  final hpName = payout['hp_reg_name']?.toString() ??
      'HP #${payout['hp_unique_id']}';
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Confirm Payment', style: AppTextStyles.heading.copyWith(fontSize: 20)),
      content: Text(
        'Mark the payout for $hpName as Paid?\n'
        'Amount: ₹${payout['pay_amount']}',
        style: AppTextStyles.regular16,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Cancel', style: AppTextStyles.regular16Gre),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            controller.markPayoutPaid(payout['id'] as int);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cAppPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Mark Paid', style: AppTextStyles.regular16white),
        ),
      ],
    ),
  );
}

void _showCreatePayoutDialog(
  BuildContext context,
  HpPayoutsController controller,
) {
  final hpIdCtrl      = TextEditingController();
  final bookingIdCtrl = TextEditingController();
  final periodFromCtrl = TextEditingController();
  final periodToCtrl  = TextEditingController();
  final amountCtrl    = TextEditingController();
  String selectedMode = 'Cash';

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Create Payout',
            style: AppTextStyles.heading.copyWith(fontSize: 20)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'HP ID *',
                      child: TextField(
                        controller: hpIdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Caregiver ID'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Booking ID',
                      child: TextField(
                        controller: bookingIdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Optional'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Period From *',
                      child: TextField(
                        controller: periodFromCtrl,
                        readOnly: true,
                        decoration:
                            _inputDecoration('Pick date', icon: Icons.calendar_today_outlined),
                        onTap: () async {
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (p != null) {
                            periodFromCtrl.text =
                                p.toIso8601String().substring(0, 10);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Period To *',
                      child: TextField(
                        controller: periodToCtrl,
                        readOnly: true,
                        decoration:
                            _inputDecoration('Pick date', icon: Icons.calendar_today_outlined),
                        onTap: () async {
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (p != null) {
                            periodToCtrl.text =
                                p.toIso8601String().substring(0, 10);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Amount (₹) *',
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _inputDecoration('0.00'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Payment Mode',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.fieldColorGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColor.textFieldBorderColor),
                        ),
                        child: DropdownButton<String>(
                          value: selectedMode,
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: AppTextStyles.regular16,
                          items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque']
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedMode = v ?? 'Cash'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTextStyles.regular16Gre),
          ),
          Obx(() {
            final loading = controller.isSubmitting.value;
            return ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (hpIdCtrl.text.trim().isEmpty ||
                          periodFromCtrl.text.isEmpty ||
                          periodToCtrl.text.isEmpty ||
                          amountCtrl.text.trim().isEmpty) {
                        HelperUi.showToast(
                            message: 'Fill all required fields.');
                        return;
                      }
                      final ok = await controller.createPayout(
                        hpUniqueId: hpIdCtrl.text.trim(),
                        periodFrom: periodFromCtrl.text,
                        periodTo: periodToCtrl.text,
                        payAmount: amountCtrl.text.trim(),
                        paymentMode: selectedMode,
                        bookingId: bookingIdCtrl.text.trim(),
                      );
                      if (ok && ctx.mounted) Navigator.of(ctx).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.buttonTextWhite),
                    )
                  : Text('Create', style: AppTextStyles.regular16white),
            );
          }),
        ],
      ),
    ),
  );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldsHeading16),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

InputDecoration _inputDecoration(String hint, {IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.regular14Gre,
    suffixIcon: icon != null
        ? Icon(icon, size: 18, color: AppColor.prefixIconColor)
        : null,
    filled: true,
    fillColor: AppColor.fieldColorGrey,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
    ),
  );
}
