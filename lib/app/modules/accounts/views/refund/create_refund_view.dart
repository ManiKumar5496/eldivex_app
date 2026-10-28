import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/refund_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateRefundView extends GetView<RefundController> {
  const CreateRefundView({super.key});

  static const List<String> _channels = [
    'CASH',
    'BANK_TRANSFER',
    'UPI',
    'CHEQUE',
    'GATEWAY_REVERSAL',
  ];

  static const List<String> _reasons = [
    'SERVICE_NOT_DELIVERED',
    'PARTIAL_DELIVERY',
    'OVERPAYMENT',
    'QUALITY_ISSUE',
    'GOODWILL',
    'CREDIT_NOTE_CASHOUT',
  ];

  @override
  Widget build(BuildContext context) {
    prepareCreateForm(context,
        reset: controller.clearForm, selectClient: _selectClient, prefill: _prefill);
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      bottomNavigationBar: _buildActionBar(pad),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Create Refund',
                  subtitle: 'Raise a refund request against client receipts',
                  breadcrumbs: const ['Accounts', 'Refunds'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                ),
                const SizedBox(height: 24),

                // ── Section: Select Booking ──────────────────────────────────
                _sectionCard(
                  title: 'Select Booking',
                  icon: LucideIcons.bookmark,
                  children: [
                    _formGrid([
                      // Client dropdown
                      _field(
                        _dropdownLabel('Client', isMandatory: true),
                        Obx(() {
                          // getActiveClients is one row per booking; dedupe to clients.
                          final clients =
                              ClientOption.fromBookingRows(controller.activeClients);
                          final selected = clients.any(
                                  (c) => c.userId == controller.selectedClientId.value)
                              ? controller.selectedClientId.value
                              : null;
                          return _dropdownContainer(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selected,
                                icon: const Icon(LucideIcons.chevronDown,
                                    size: 18),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                hint: _hint('Choose a client'),
                                items: clients.map((c) {
                                  return DropdownMenuItem<int>(
                                    value: c.userId,
                                    child: Text(c.label,
                                        style: _itemStyle,
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: _selectClient,
                              ),
                            ),
                          );
                        }),
                      ),

                      // Booking dropdown — derived from selected client's bookings
                      _field(
                        _dropdownLabel('Booking', isMandatory: true),
                        Obx(() {
                          final bookings = bookingRowsForUser(
                              controller.activeClients,
                              controller.selectedClientId.value);

                          return _dropdownContainer(
                            enabled: controller.selectedClientId.value != null,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: controller.selectedBookingId.value,
                                icon: const Icon(LucideIcons.chevronDown,
                                    size: 18),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                hint: _hint(
                                  controller.selectedClientId.value == null
                                      ? 'Select a client first'
                                      : 'Choose a booking',
                                ),
                                items: bookings.map((b) {
                                  final bid = toInt(
                                      field(b, 'booking_id'), toInt(field(b, 'id')));
                                  final paid = toDouble(field(b, 'total_paid'));
                                  return DropdownMenuItem<int>(
                                    value: bid,
                                    child: Text(
                                        '${bookingRowLabel(b)} · Paid ${formatInr(paid)}',
                                        style: _itemStyle,
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: controller.selectedClientId.value == null
                                    ? null
                                    : (id) {
                                        controller.selectedBookingId.value = id;
                                        controller.selectedReceiptIds.clear();
                                        if (id != null) {
                                          controller.loadClientReceipts(id);
                                        } else {
                                          controller.clientReceipts.clear();
                                        }
                                      },
                              ),
                            ),
                          );
                        }),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section: Select Receipts ─────────────────────────────────
                _sectionCard(
                  title: 'Select Receipts',
                  subtitle: 'Receipts this refund is paid back against',
                  icon: LucideIcons.receipt,
                  children: [
                    Obx(() {
                      final receipts = controller.clientReceipts;
                      if (controller.selectedBookingId.value == null) {
                        return _emptyHint(LucideIcons.pointer,
                            'Select a booking to see receipts');
                      }
                      if (receipts.isEmpty) {
                        return _emptyHint(LucideIcons.inbox,
                            'No receipts found for this booking');
                      }
                      return Column(
                        children: receipts.map((r) {
                          final receiptId = toInt(field(r, 'id'));
                          final receiptNo =
                              toStr(field(r, 'receipt_number'), '#$receiptId');
                          final date = formatAccDate(
                              field(r, 'receipt_date') ?? field(r, 'created_on'));
                          final amount = toDouble(field(r, 'total_amount'));
                          final mode = toStr(field(r, 'payment_mode'), '—');
                          final isSelected =
                              controller.selectedReceiptIds.contains(receiptId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primarySoft
                                  : AppColor.whiteColor,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.cAppPrimaryColor
                                        .withValues(alpha: 0.4)
                                    : AppColor.divColor,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              onChanged: (checked) {
                                if (checked == true) {
                                  controller.selectedReceiptIds.add(receiptId);
                                } else {
                                  controller.selectedReceiptIds.remove(receiptId);
                                }
                              },
                              title: Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    receiptNo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                  AppStatusBadge(
                                      label: mode, showDot: false, dense: true),
                                ],
                              ),
                              subtitle: Text(
                                '${formatInr(amount)}  •  $date',
                                style: TextStyle(
                                    fontSize: 13, color: AppColor.textTertiary),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section: Refund Details ──────────────────────────────────
                _sectionCard(
                  title: 'Refund Details',
                  icon: LucideIcons.indianRupee,
                  children: [
                    _formGrid([
                      // Amount
                      Obx(() {
                        // Compute max refundable = sum of selected receipts
                        double maxAmount = 0;
                        for (final r in controller.clientReceipts) {
                          if (controller.selectedReceiptIds
                              .contains(toInt(field(r, 'id')))) {
                            maxAmount += toDouble(field(r, 'total_amount'));
                          }
                        }
                        final hint = maxAmount > 0
                            ? 'Selected receipts total: ${formatInr(maxAmount)}'
                            : 'Enter refund amount';
                        return _labeledField(
                          label: 'Refund Amount',
                          hint: hint,
                          controller: controller.refundAmountCtrl,
                          keyboardType: TextInputType.number,
                          isMandatory: true,
                        );
                      }),

                      // Channel
                      _field(
                        _dropdownLabel('Refund Channel', isMandatory: true),
                        Obx(() => _dropdownContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: controller.refundChannel.value,
                                  icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 18),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  items: _channels
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(c.replaceAll('_', ' '),
                                                style: _itemStyle),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      controller.refundChannel.value = v;
                                    }
                                  },
                                ),
                              ),
                            )),
                      ),

                      // Reason
                      _field(
                        _dropdownLabel('Reason for Refund', isMandatory: true),
                        Obx(() => _dropdownContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: controller.refundReason.value,
                                  icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 18),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  items: _reasons
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(
                                              r.replaceAll('_', ' '),
                                              style: _itemStyle,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      controller.refundReason.value = v;
                                    }
                                  },
                                ),
                              ),
                            )),
                      ),
                    ]),

                    // Dynamic channel detail fields
                    Obx(() => _buildChannelFields(controller.refundChannel.value)),

                    // Approval level indicator (recomputed as the amount is typed)
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.refundAmountCtrl,
                      builder: (context, value, _) {
                        final amount = double.tryParse(value.text) ?? 0;
                        String level;
                        AppTone tone;
                        if (amount <= 0) {
                          return const SizedBox.shrink();
                        // Same thresholds as the server (≤ ₹500 L1, ≤ ₹5,000 L2).
                        } else if (amount <= 500) {
                          level = 'L1 — Supervisor Approval';
                          tone = AppTone.success;
                        } else if (amount <= 5000) {
                          level = 'L2 — Manager Approval';
                          tone = AppTone.warning;
                        } else {
                          level = 'L3 — Finance Director Approval';
                          tone = AppTone.danger;
                        }
                        return Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: tone.soft,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.shield,
                                  color: tone.color, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Approval Level: $level',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tone.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section: Notes ───────────────────────────────────────────
                _sectionCard(
                  title: 'Notes',
                  icon: LucideIcons.notepadText,
                  children: [
                    _labeledField(
                      label: 'Internal Notes',
                      hint: 'Add any additional notes or remarks (optional)',
                      controller: controller.notesCtrl,
                      maxLines: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Client dropdown change — also used to preselect the client passed by
  /// the outstanding page's Quick Actions.
  void _selectClient(int? id) {
    controller.selectedClientId.value = id;
    controller.selectedBookingId.value = null;
    controller.selectedReceiptIds.clear();
    controller.clientReceipts.clear();
  }

  /// {user_id, booking_id, amount} passed in, e.g. a booking's excess after a
  /// cancellation or hold. Selected once the bookings list has loaded.
  Future<void> _prefill(Map args) async {
    final clientId = toIntOrNull(args['user_id']);
    final bookingId = toIntOrNull(args['booking_id']);
    if (clientId == null || bookingId == null) return;
    if (controller.activeClients.isEmpty) await controller.loadActiveClients();
    _selectClient(clientId);
    controller.selectedBookingId.value = bookingId;
    controller.loadClientReceipts(bookingId);
    final amount = toDoubleOrNull(args['amount']);
    if (amount != null && amount > 0) {
      controller.refundAmountCtrl.text = amount.toStringAsFixed(2);
    }
  }

  // ── Bottom action bar (Cancel + Submit) ─────────────────────────────────────

  Widget _buildActionBar(double pad) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
      child: SafeArea(
        top: false,
        // heightFactor 1: inside bottomNavigationBar a plain Center grows to
        // the full screen height and squeezes the page body to nothing.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            // Full form width (≤ 1100) so the buttons line up with the form's
            // right edge instead of centring.
            constraints: const BoxConstraints(minWidth: 1100, maxWidth: 1100),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => HelperUi.safeBack(Routes.MAIN),
                  child: const Text('Cancel'),
                ),
                // ── Submit button ──────────────────────────────────────────
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              final ok = await controller.createRefund();
                              if (ok) HelperUi.safeBack(Routes.MAIN);
                            },
                      icon: controller.isSubmitting.value
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.cAppPrimaryColor),
                            )
                          : const Icon(LucideIcons.send, size: 18),
                      label: Text(
                        controller.isSubmitting.value
                            ? 'Submitting…'
                            : 'Submit Refund Request',
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Channel-specific fields ─────────────────────────────────────────────────

  Widget _buildChannelFields(String channel) {
    switch (channel) {
      case 'BANK_TRANSFER':
        return _channelGroup('Bank Transfer Details', [
          _labeledField(
            label: 'Bank Name',
            hint: 'e.g. HDFC Bank',
            controller: controller.bankNameCtrl,
            isMandatory: true,
          ),
          _labeledField(
            label: 'Account Number',
            hint: 'Enter account number',
            controller: controller.accountNumberCtrl,
            keyboardType: TextInputType.number,
            isMandatory: true,
          ),
          _labeledField(
            label: 'IFSC Code',
            hint: 'e.g. HDFC0001234',
            controller: controller.ifscCodeCtrl,
            isMandatory: true,
          ),
          _labeledField(
            label: 'Account Holder Name',
            hint: 'Name as on bank account',
            controller: controller.accountHolderCtrl,
            isMandatory: true,
          ),
        ]);

      case 'UPI':
        return _channelGroup('UPI Details', [
          _labeledField(
            label: 'UPI ID',
            hint: 'e.g. name@upi',
            controller: controller.upiIdCtrl,
            isMandatory: true,
          ),
        ]);

      case 'CHEQUE':
        return _channelGroup('Cheque Details', [
          _labeledField(
            label: 'Cheque Number',
            hint: 'Enter cheque number',
            controller: controller.chequeNumberCtrl,
            isMandatory: true,
          ),
          _labeledField(
            label: 'Cheque Date',
            hint: 'DD-MMM-YYYY',
            controller: controller.chequeDateCtrl,
            isMandatory: true,
          ),
          _labeledField(
            label: 'Bank Name',
            hint: 'Issuing bank name',
            controller: controller.bankNameCtrl,
          ),
        ]);

      case 'CASH':
      case 'GATEWAY_REVERSAL':
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _channelGroup(String title, List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 16),
          AppSectionTitle(title: title),
          const SizedBox(height: 12),
          _formGrid(fields),
        ],
      ),
    );
  }

  // ── Reusable UI helpers ─────────────────────────────────────────────────────

  TextStyle get _itemStyle =>
      TextStyle(fontSize: 14, color: AppColor.textPrimary);

  Text _hint(String text) =>
      Text(text, style: TextStyle(color: AppColor.textTertiary, fontSize: 14));

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// Two columns when the card is wide enough, one on phones.
  Widget _formGrid(List<Widget> fields) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 600 ? 2 : 1;
      final w = (c.maxWidth - 20 * (cols - 1)) / cols;
      return Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [for (final f in fields) SizedBox(width: w, child: f)],
      );
    });
  }

  Widget _field(Widget label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [label, const SizedBox(height: 8), input],
    );
  }

  Widget _dropdownLabel(String label, {bool isMandatory = false}) {
    return Text.rich(
      TextSpan(text: label, children: [
        if (isMandatory)
          TextSpan(text: ' *', style: TextStyle(color: AppColor.danger)),
      ]),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
      ),
    );
  }

  /// Theme-styled field frame for a [DropdownButton].
  Widget _dropdownContainer({required Widget child, bool enabled = true}) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: child,
    );
  }

  /// Label above a theme-styled text field.
  Widget _labeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isMandatory = false,
  }) {
    return _field(
      _dropdownLabel(label, isMandatory: isMandatory),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget _emptyHint(IconData icon, String message) {
    return AppEmptyState(icon: icon, title: message, compact: true);
  }
}
