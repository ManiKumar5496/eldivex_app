import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/common_textfield.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/refund_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';

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
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => HelperUi.safeBack(Routes.MAIN),
          color: AppColor.cPrimaryHeadingColor,
        ),
        title: Text(
          'Create Refund',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColor.divColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Select Booking ────────────────────────────────────
            _sectionCard(
              title: 'Select Booking',
              icon: Icons.bookmark_outline,
              children: [
                // Client dropdown
                _dropdownLabel('Client', isMandatory: true),
                const SizedBox(height: 8),
                Obx(() {
                  // getActiveClients is one row per booking; dedupe to clients.
                  final clients = ClientOption.fromBookingRows(controller.activeClients);
                  final selected = clients.any((c) => c.userId == controller.selectedClientId.value)
                      ? controller.selectedClientId.value
                      : null;
                  return _dropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selected,
                          hint: Text(
                            'Choose a client',
                            style: TextStyle(
                                color: AppColor.fontColorGrey, fontSize: 14),
                          ),
                          items: clients.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.userId,
                              child: Text(c.label,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (id) {
                            controller.selectedClientId.value = id;
                            controller.selectedBookingId.value = null;
                            controller.selectedReceiptIds.clear();
                            controller.clientReceipts.clear();
                          },
                        ),
                      ),
                    );
                }),
                const SizedBox(height: 16),

                // Booking dropdown — derived from selected client's bookings
                _dropdownLabel('Booking', isMandatory: true),
                const SizedBox(height: 8),
                Obx(() {
                  final bookings = bookingRowsForUser(
                      controller.activeClients, controller.selectedClientId.value);

                  return _dropdownContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: controller.selectedBookingId.value,
                        hint: Text(
                          controller.selectedClientId.value == null
                              ? 'Select a client first'
                              : 'Choose a booking',
                          style: TextStyle(
                              color: AppColor.fontColorGrey, fontSize: 14),
                        ),
                        items: bookings.map((b) {
                          final bid = toInt(field(b, 'booking_id'), toInt(field(b, 'id')));
                          final paid = toDouble(field(b, 'total_paid'));
                          return DropdownMenuItem<int>(
                            value: bid,
                            child: Text('${bookingRowLabel(b)} · Paid ${formatInr(paid)}',
                                style: const TextStyle(fontSize: 14),
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
              ],
            ),
            const SizedBox(height: 16),

            // ── Section: Select Receipts ───────────────────────────────────
            _sectionCard(
              title: 'Select Receipts',
              icon: Icons.receipt_outlined,
              children: [
                Obx(() {
                  final receipts = controller.clientReceipts;
                  if (controller.selectedBookingId.value == null) {
                    return _emptyHint(
                        Icons.touch_app_outlined, 'Select a booking to see receipts');
                  }
                  if (receipts.isEmpty) {
                    return _emptyHint(
                        Icons.inbox_outlined, 'No receipts found for this booking');
                  }
                  return Column(
                    children: receipts.map((r) {
                      final receiptId = toInt(field(r, 'id'));
                      final receiptNo = toStr(field(r, 'receipt_number'), '#$receiptId');
                      final date = formatAccDate(field(r, 'receipt_date') ?? field(r, 'created_on'));
                      final amount = toDouble(field(r, 'total_amount'));
                      final mode = toStr(field(r, 'payment_mode'), '—');
                      final isSelected =
                          controller.selectedReceiptIds.contains(receiptId);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.04)
                              : AppColor.fieldColorGrey,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.4)
                                : AppColor.divColor,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColor.cPrimaryButtonColor,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          onChanged: (checked) {
                            if (checked == true) {
                              controller.selectedReceiptIds.add(receiptId);
                            } else {
                              controller.selectedReceiptIds.remove(receiptId);
                            }
                          },
                          title: Row(
                            children: [
                              Text(
                                receiptNo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.cPrimaryButtonColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(mode,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blueGrey.shade700)),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${formatInr(amount)}  •  $date',
                            style: TextStyle(
                                fontSize: 12, color: AppColor.fontColorGrey),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // ── Section: Refund Details ────────────────────────────────────
            _sectionCard(
              title: 'Refund Details',
              icon: Icons.currency_rupee_rounded,
              children: [
                // Amount
                Obx(() {
                  // Compute max refundable = sum of selected receipts
                  double maxAmount = 0;
                  for (final r in controller.clientReceipts) {
                    if (controller.selectedReceiptIds.contains(toInt(field(r, 'id')))) {
                      maxAmount += toDouble(field(r, 'total_amount'));
                    }
                  }
                  final hint = maxAmount > 0
                      ? 'Selected receipts total: ${formatInr(maxAmount)}'
                      : 'Enter refund amount';
                  return CommonTextField(
                    label: 'Refund Amount',
                    hint: hint,
                    controller: controller.refundAmountCtrl,
                    keyboardType: TextInputType.number,
                    isMandatory: true,
                  );
                }),
                const SizedBox(height: 16),

                // Channel
                _dropdownLabel('Refund Channel', isMandatory: true),
                const SizedBox(height: 8),
                Obx(() => _dropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.refundChannel.value,
                          items: _channels
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.replaceAll('_', ' '),
                                        style:
                                            const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) controller.refundChannel.value = v;
                          },
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Dynamic channel detail fields
                Obx(() => _buildChannelFields(controller.refundChannel.value)),
                const SizedBox(height: 16),

                // Reason
                _dropdownLabel('Reason for Refund', isMandatory: true),
                const SizedBox(height: 8),
                Obx(() => _dropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.refundReason.value,
                          items: _reasons
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r.replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) controller.refundReason.value = v;
                          },
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Approval level indicator
                Obx(() {
                  final amount =
                      double.tryParse(controller.refundAmountCtrl.text) ?? 0;
                  String level;
                  Color levelColor;
                  if (amount <= 0) {
                    return const SizedBox.shrink();
                  } else if (amount <= 1000) {
                    level = 'L1 — Supervisor Approval';
                    levelColor = Colors.green;
                  } else if (amount <= 10000) {
                    level = 'L2 — Manager Approval';
                    levelColor = Colors.orange;
                  } else {
                    level = 'L3 — Finance Director Approval';
                    levelColor = Colors.red;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: levelColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: levelColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Approval Level: $level',
                          style: TextStyle(
                            fontSize: 13,
                            color: levelColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // ── Section: Notes ─────────────────────────────────────────────
            _sectionCard(
              title: 'Notes',
              icon: Icons.notes_rounded,
              children: [
                CommonTextField(
                  label: 'Internal Notes',
                  hint: 'Add any additional notes or remarks (optional)',
                  controller: controller.notesCtrl,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Submit button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final ok = await controller.createRefund();
                            if (ok) HelperUi.safeBack(Routes.MAIN);
                          },
                    icon: controller.isSubmitting.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColor.buttonTextWhite),
                          )
                        : Icon(Icons.send_rounded, size: 18,
                            color: AppColor.buttonTextWhite),
                    label: Text(
                      controller.isSubmitting.value
                          ? 'Submitting…'
                          : 'Submit Refund Request',
                      style: TextStyle(
                          color: AppColor.buttonTextWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cPrimaryButtonColor,
                      disabledBackgroundColor:
                          AppColor.cPrimaryButtonColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ── Channel-specific fields ─────────────────────────────────────────────────

  Widget _buildChannelFields(String channel) {
    switch (channel) {
      case 'BANK_TRANSFER':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldsSectionHeader('Bank Transfer Details'),
            const SizedBox(height: 10),
            CommonTextField(
              label: 'Bank Name',
              hint: 'e.g. HDFC Bank',
              controller: controller.bankNameCtrl,
              isMandatory: true,
            ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'Account Number',
              hint: 'Enter account number',
              controller: controller.accountNumberCtrl,
              keyboardType: TextInputType.number,
              isMandatory: true,
            ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'IFSC Code',
              hint: 'e.g. HDFC0001234',
              controller: controller.ifscCodeCtrl,
              isMandatory: true,
            ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'Account Holder Name',
              hint: 'Name as on bank account',
              controller: controller.accountHolderCtrl,
              isMandatory: true,
            ),
          ],
        );

      case 'UPI':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldsSectionHeader('UPI Details'),
            const SizedBox(height: 10),
            CommonTextField(
              label: 'UPI ID',
              hint: 'e.g. name@upi',
              controller: controller.upiIdCtrl,
              isMandatory: true,
            ),
          ],
        );

      case 'CHEQUE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldsSectionHeader('Cheque Details'),
            const SizedBox(height: 10),
            CommonTextField(
              label: 'Cheque Number',
              hint: 'Enter cheque number',
              controller: controller.chequeNumberCtrl,
              isMandatory: true,
            ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'Cheque Date',
              hint: 'DD-MMM-YYYY',
              controller: controller.chequeDateCtrl,
              isMandatory: true,
            ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'Bank Name',
              hint: 'Issuing bank name',
              controller: controller.bankNameCtrl,
            ),
          ],
        );

      case 'CASH':
      case 'GATEWAY_REVERSAL':
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Reusable UI helpers ─────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    size: 16, color: AppColor.cPrimaryButtonColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _dropdownLabel(String label, {bool isMandatory = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.cPrimarySubHeadingColorGrey,
          ),
        ),
        if (isMandatory)
          const Text(' *',
              style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _dropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.textFieldBorderColor),
      ),
      child: child,
    );
  }

  Widget _fieldsSectionHeader(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColor.cPrimarySubHeadingColorGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _emptyHint(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColor.divColor),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.regular14Gre),
          ],
        ),
      ),
    );
  }
}
