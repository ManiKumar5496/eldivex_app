import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/hp_payouts_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpPayoutsView extends GetView<HpPayoutsController> {
  const HpPayoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Padding(
          // Bottom padding is applied inside each tab.
          padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildKpis(),
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
    return AppPageHeader(
      title: 'HP Payouts',
      subtitle: 'Track pending dues and record caregiver payments.',
      breadcrumbs: const ['Settings', 'HP Payouts'],
      onBack: () => Get.back(),
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showCreatePayoutDialog(context, controller),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Create Payout'),
        ),
      ],
    );
  }

  /// Totals derived from the payouts already loaded for the two tabs.
  Widget _buildKpis() {
    return Obx(() {
      final pending = controller.pendingPayouts;
      final history = controller.payoutHistory;
      final fmt = NumberFormat('#,##0.00');
      return AppResponsiveGrid(
        minItemWidth: 150,
        maxColumns: 4,
        spacing: 12,
        children: [
          AppStatCard(
            label: 'Pending payouts',
            value: '${pending.length}',
            icon: LucideIcons.clipboardClock,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Pending amount',
            value: '₹${fmt.format(_sumAmounts(pending))}',
            icon: LucideIcons.wallet,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Paid payouts',
            value: '${history.length}',
            icon: LucideIcons.circleCheckBig,
            tone: AppTone.success,
            caption: 'Matches history filter',
          ),
          AppStatCard(
            label: 'Paid amount',
            value: '₹${fmt.format(_sumAmounts(history))}',
            icon: LucideIcons.banknote,
            tone: AppTone.success,
            caption: 'Matches history filter',
          ),
        ],
      );
    });
  }

  Widget _buildTabBar() {
    return const TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        Tab(text: 'Pending'),
        Tab(text: 'History'),
      ],
    );
  }
}

double _sumAmounts(List<Map<String, dynamic>> payouts) => payouts.fold(
    0.0,
    (sum, p) =>
        sum + (double.tryParse(p['pay_amount']?.toString() ?? '') ?? 0));

// ── Pending Tab ───────────────────────────────────────────────────────────────

class _PendingTab extends GetView<HpPayoutsController> {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        expandChild: true,
        child: Obx(() {
          if (controller.isPendingLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.pendingPayouts.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.circleCheck,
              tone: AppTone.success,
              title: 'No pending payouts',
              message: 'All caregivers are up to date!',
            );
          }

          final count = controller.pendingPayouts.length;
          return _PayoutTable(
            isPending: true,
            itemCount: count,
            onRefresh: controller.fetchPendingPayouts,
            itemBuilder: (context, index) {
              final payout = controller.pendingPayouts[index];
              return _PayoutCard(
                payout: payout,
                isPending: true,
                onMarkPaid: () => _confirmMarkPaid(context, controller, payout),
              );
            },
          );
        }),
      ),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends GetView<HpPayoutsController> {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        expandChild: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date filter row
            Padding(
              padding: const EdgeInsets.all(16),
              child: _FilterRow(controller: controller),
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
                    title: 'No payout history',
                  );
                }
                final count = controller.payoutHistory.length;
                return _PayoutTable(
                  isPending: false,
                  itemCount: count,
                  onRefresh: controller.fetchPayoutHistory,
                  itemBuilder: (context, index) {
                    final payout = controller.payoutHistory[index];
                    return _PayoutCard(payout: payout, isPending: false);
                  },
                );
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
  const _FilterRow({required this.controller});
  final HpPayoutsController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 230,
          child: TextField(
            controller: controller.fromDateCtrl,
            readOnly: true,
            decoration: _inputDecoration('From date (YYYY-MM-DD)',
                icon: LucideIcons.calendar),
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
        SizedBox(
          width: 230,
          child: TextField(
            controller: controller.toDateCtrl,
            readOnly: true,
            decoration: _inputDecoration('To date (YYYY-MM-DD)',
                icon: LucideIcons.calendar),
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
        OutlinedButton.icon(
          onPressed: controller.applyHistoryFilter,
          icon: const Icon(LucideIcons.listFilter, size: 18),
          label: const Text('Filter'),
        ),
        TextButton(
          onPressed: controller.clearHistoryFilter,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

// ── Payout Table ──────────────────────────────────────────────────────────────

/// Column definitions shared by the header and each [_PayoutCard] row.
/// The trailing "Action" column only exists on the Pending tab.
class _PayoutColumns {
  static const labels = [
    'Caregiver', 'ID', 'Booking', 'Period', 'Days', 'Mode', 'Paid on',
    'Status', 'Amount',
  ];
  static const flex = [3, 1, 1, 3, 1, 2, 2, 2, 2];
  static const amountIndex = 8;
  static const actionFlex = 2;
}

class _PayoutTable extends StatelessWidget {
  const _PayoutTable({
    required this.isPending,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
  });

  final bool isPending;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final minWidth = isPending ? 1100.0 : 980.0;
    return LayoutBuilder(builder: (context, constraints) {
      final width =
          constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: Column(
            children: [
              _headerRow(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: itemBuilder,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _headerRow() {
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: AppColor.textSecondary,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _PayoutColumns.labels.length; i++)
            Expanded(
              flex: _PayoutColumns.flex[i],
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  _PayoutColumns.labels[i],
                  overflow: TextOverflow.ellipsis,
                  textAlign: i == _PayoutColumns.amountIndex
                      ? TextAlign.right
                      : TextAlign.left,
                  style: style,
                ),
              ),
            ),
          if (isPending)
            Expanded(
              flex: _PayoutColumns.actionFlex,
              child: Text('Action', textAlign: TextAlign.right, style: style),
            ),
        ],
      ),
    );
  }
}

// ── Payout Row ────────────────────────────────────────────────────────────────

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

    final textStyle = TextStyle(fontSize: 13.5, color: AppColor.textPrimary);
    final mutedStyle = textStyle.copyWith(color: AppColor.textSecondary);

    Widget cell(int i, Widget child) => Expanded(
          flex: _PayoutColumns.flex[i],
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: child,
          ),
        );

    Widget text(int i, String value, {TextStyle? style}) => cell(
          i,
          Text(value,
              overflow: TextOverflow.ellipsis, style: style ?? textStyle),
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
          text(1, '#$id', style: mutedStyle),
          text(2, '#$bookingId', style: mutedStyle),
          text(3, '$periodFrom → $periodTo'),
          text(4, daysOwed ?? '—'),
          text(5, paymentMode),
          text(6, paymentDate ?? '—', style: mutedStyle),
          cell(
            7,
            Align(
              alignment: Alignment.centerLeft,
              child: _StatusChip(isPending: isPending),
            ),
          ),
          cell(
            _PayoutColumns.amountIndex,
            Text(
              '₹${_formatAmount(amount)}',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: textStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (isPending)
            Expanded(
              flex: _PayoutColumns.actionFlex,
              child: Align(
                alignment: Alignment.centerRight,
                child: (isPending && onMarkPaid != null)
                    ? TextButton.icon(
                        onPressed: onMarkPaid,
                        style: AppButtonStyles.compact
                            .merge(AppButtonStyles.soft),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Mark Paid'),
                      )
                    : const SizedBox.shrink(),
              ),
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
    final label = isPending ? 'Pending' : 'Paid';
    return AppStatusBadge.status(label, dense: true);
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
    builder: (ctx) => AppDialog(
      title: 'Confirm Payment',
      icon: LucideIcons.banknote,
      tone: AppTone.success,
      maxWidth: 440,
      onClose: () => Navigator.of(ctx).pop(),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            controller.markPayoutPaid(payout['id'] as int);
          },
          child: const Text('Mark Paid'),
        ),
      ],
      child: Text(
        'Mark the payout for $hpName as Paid?\n'
        'Amount: ₹${payout['pay_amount']}',
        style: TextStyle(
            fontSize: 14, height: 1.6, color: AppColor.textSecondary),
      ),
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
      builder: (ctx, setState) => AppDialog(
        title: 'Create Payout',
        subtitle: 'Record a manual payout for a caregiver',
        icon: LucideIcons.filePlus,
        maxWidth: 560,
        onClose: () => Navigator.of(ctx).pop(),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                    )
                  : const Text('Create'),
            );
          }),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldPair(
              left: _LabeledField(
                label: 'HP ID *',
                child: TextField(
                  controller: hpIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Caregiver ID'),
                ),
              ),
              right: _LabeledField(
                label: 'Booking ID',
                child: TextField(
                  controller: bookingIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Optional'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FieldPair(
              left: _LabeledField(
                label: 'Period From *',
                child: TextField(
                  controller: periodFromCtrl,
                  readOnly: true,
                  decoration:
                      _inputDecoration('Pick date', icon: LucideIcons.calendar),
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
              right: _LabeledField(
                label: 'Period To *',
                child: TextField(
                  controller: periodToCtrl,
                  readOnly: true,
                  decoration:
                      _inputDecoration('Pick date', icon: LucideIcons.calendar),
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
            const SizedBox(height: 16),
            _FieldPair(
              left: _LabeledField(
                label: 'Amount (₹) *',
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: _inputDecoration('0.00'),
                ),
              ),
              right: _LabeledField(
                label: 'Payment Mode',
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColor.borderStrong),
                  ),
                  child: DropdownButton<String>(
                    value: selectedMode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    dropdownColor: AppColor.whiteColor,
                    icon: Icon(LucideIcons.chevronDown,
                        size: 18, color: AppColor.textTertiary),
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
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
      ),
    ),
  );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

/// Two fields side by side, stacked when the dialog is phone-narrow.
class _FieldPair extends StatelessWidget {
  const _FieldPair({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 420) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 16), right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      );
    });
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Theme supplies fill, border, radius and padding; only the hint and the
/// optional trailing icon are set here.
InputDecoration _inputDecoration(String hint, {IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    suffixIcon: icon != null ? Icon(icon, size: 18) : null,
  );
}
