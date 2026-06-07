import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../../controllers/internal_transfer_controller.dart';

class CreateTransferView extends StatefulWidget {
  const CreateTransferView({super.key});

  @override
  State<CreateTransferView> createState() => _CreateTransferViewState();
}

class _CreateTransferViewState extends State<CreateTransferView> {
  late final InternalTransferController ctrl;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _transferTypes = [
    {'value': 'OVERPAYMENT_TRANSFER', 'label': 'Overpayment Transfer'},
    {'value': 'RECEIPT_REALLOCATION', 'label': 'Receipt Reallocation'},
    {'value': 'CREDIT_BALANCE_TRANSFER', 'label': 'Credit Balance Transfer'},
    {'value': 'SERVICE_SWITCH', 'label': 'Service Switch'},
  ];

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InternalTransferController>()) {
      ctrl = Get.find<InternalTransferController>();
    } else {
      ctrl = Get.put(InternalTransferController());
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  String _formatCurrency(double v) =>
      '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.cPrimarySubHeadingColorGrey,
            ),
          ),
          if (required)
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
        ],
      ),
    );
  }

  BoxDecoration _dropdownDecoration() => BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.textFieldBorderColor),
      );

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColor.cPrimaryHeadingColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Internal Transfer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning banner
                  _buildWarningBanner(),
                  const SizedBox(height: 24),

                  // Form card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.divColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Icon(Icons.swap_horiz,
                                color: AppColor.cPrimaryButtonColor, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Transfer Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.cPrimaryHeadingColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),

                        // Client selector
                        _buildClientSelector(),
                        const SizedBox(height: 20),

                        // Source booking
                        _buildSourceBookingSelector(),
                        const SizedBox(height: 20),

                        // Target booking
                        _buildTargetBookingSelector(),
                        const SizedBox(height: 20),

                        // Transfer Amount
                        _buildAmountField(),
                        const SizedBox(height: 8),

                        // Live preview
                        _buildLivePreview(),
                        const SizedBox(height: 20),

                        // Transfer Type
                        _buildTransferTypeDropdown(),
                        const SizedBox(height: 20),

                        // Reason
                        _buildReasonField(),
                        const SizedBox(height: 20),

                        // Notes
                        _buildNotesField(),
                        const SizedBox(height: 28),

                        // Submit
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Warning banner
  // ─────────────────────────────────────────────

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: Colors.amber.shade800, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This transfer requires Finance Head approval before it takes effect.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Client selector
  // ─────────────────────────────────────────────

  Widget _buildClientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Client', required: true),
        Obx(() {
          final clients = ctrl.activeClients;
          // Deduplicate by user_id so we show one entry per client
          final seen = <int>{};
          final unique = clients.where((c) {
            final id = (c['user_id'] as num?)?.toInt() ?? 0;
            return seen.add(id);
          }).toList();

          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: _dropdownDecoration(),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: ctrl.selectedClientId.value,
                hint: Text('Select client',
                    style: TextStyle(
                        color: AppColor.fontColorGrey, fontSize: 14)),
                items: unique.map((c) {
                  final id = (c['user_id'] as num?)?.toInt() ?? 0;
                  final name = c['client_name']?.toString() ??
                      c['name']?.toString() ??
                      'Client $id';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(name, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  ctrl.selectedClientId.value = id;
                  ctrl.loadClientBookings(id);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Source booking
  // ─────────────────────────────────────────────

  Widget _buildSourceBookingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Source Booking (Credit)', required: true),
        Obx(() {
          final bookings = ctrl.clientBookings;
          final targetId = ctrl.selectedTargetBookingId.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _dropdownDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: ctrl.selectedSourceBookingId.value,
                    hint: Text(
                      bookings.isEmpty
                          ? 'Select a client first'
                          : 'Select source booking',
                      style: TextStyle(
                          color: AppColor.fontColorGrey, fontSize: 14),
                    ),
                    items: bookings
                        .where((b) {
                          final id = (b['booking_id'] as num?)?.toInt() ?? 0;
                          return id != targetId;
                        })
                        .map((b) {
                          final id = (b['booking_id'] as num?)?.toInt() ?? 0;
                          final ref = b['booking_ref']?.toString() ?? '#$id';
                          final balance = (b['outstanding_amount'] as num?)?.toDouble() ?? 0.0;
                          final credit = balance < 0;
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Row(
                              children: [
                                Text(ref,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                if (credit)
                                  Text(
                                    'Credit: ${_formatCurrency(balance.abs())}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                    onChanged: bookings.isEmpty
                        ? null
                        : (id) => ctrl.onSourceBookingChanged(id),
                  ),
                ),
              ),

              // Live source balance card
              Obx(() {
                final ob = ctrl.sourceBookingOutstanding.value;
                if (ob == null) return const SizedBox.shrink();
                final credit = ob.outstandingAmount < 0;
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: credit
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: credit
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        credit
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        size: 18,
                        color: credit ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        credit
                            ? 'Available credit: ${_formatCurrency(ob.outstandingAmount.abs())}'
                            : 'No credit available — Outstanding: ${_formatCurrency(ob.outstandingAmount)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: credit
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Target booking
  // ─────────────────────────────────────────────

  Widget _buildTargetBookingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Target Booking (Outstanding)', required: true),
        Obx(() {
          final bookings = ctrl.clientBookings;
          final sourceId = ctrl.selectedSourceBookingId.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _dropdownDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: ctrl.selectedTargetBookingId.value,
                    hint: Text(
                      bookings.isEmpty
                          ? 'Select a client first'
                          : 'Select target booking',
                      style: TextStyle(
                          color: AppColor.fontColorGrey, fontSize: 14),
                    ),
                    items: bookings
                        .where((b) {
                          final id = (b['booking_id'] as num?)?.toInt() ?? 0;
                          return id != sourceId;
                        })
                        .map((b) {
                          final id = (b['booking_id'] as num?)?.toInt() ?? 0;
                          final ref = b['booking_ref']?.toString() ?? '#$id';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(ref,
                                style: const TextStyle(fontSize: 14)),
                          );
                        })
                        .toList(),
                    onChanged: bookings.isEmpty
                        ? null
                        : (id) => ctrl.onTargetBookingChanged(id),
                  ),
                ),
              ),

              // Live target balance card
              Obx(() {
                final ob = ctrl.targetBookingOutstanding.value;
                if (ob == null) return const SizedBox.shrink();
                final hasOutstanding = ob.outstandingAmount > 0;
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasOutstanding
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasOutstanding
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasOutstanding
                            ? Icons.receipt_long_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                        color: hasOutstanding ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasOutstanding
                            ? 'Outstanding: ${_formatCurrency(ob.outstandingAmount)}'
                            : 'No outstanding amount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: hasOutstanding
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Transfer amount field
  // ─────────────────────────────────────────────

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final src = ctrl.sourceBookingOutstanding.value;
          final maxCredit =
              src != null && src.outstandingAmount < 0
                  ? src.outstandingAmount.abs()
                  : null;
          return _fieldLabel(
            maxCredit != null
                ? 'Transfer Amount (max ${_formatCurrency(maxCredit)})'
                : 'Transfer Amount',
            required: true,
          );
        }),
        TextFormField(
          controller: ctrl.transferAmountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. 5000.00',
            hintStyle:
                TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
            prefixText: '₹  ',
            prefixStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: AppColor.whiteColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final n = double.tryParse(v.trim());
            if (n == null || n <= 0) return 'Enter a valid positive amount';
            return null;
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Live preview
  // ─────────────────────────────────────────────

  Widget _buildLivePreview() {
    return Obx(() {
      final amountText = ctrl.transferAmountCtrl.text.trim();
      final amount = double.tryParse(amountText) ?? 0;
      final src = ctrl.sourceBookingOutstanding.value;
      final tgt = ctrl.targetBookingOutstanding.value;

      if (amount <= 0 || (src == null && tgt == null)) {
        return const SizedBox.shrink();
      }

      final srcAfter = src != null ? src.outstandingAmount + amount : null;
      final tgtAfter = tgt != null ? tgt.outstandingAmount - amount : null;

      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview_outlined,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Text(
                  'Transfer Preview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (src != null && srcAfter != null)
                  Expanded(
                    child: _previewColumn(
                      label: 'Source booking after',
                      before: src.outstandingAmount,
                      after: srcAfter,
                    ),
                  ),
                if (src != null && tgt != null && tgtAfter != null)
                  const SizedBox(width: 16),
                if (tgt != null && tgtAfter != null)
                  Expanded(
                    child: _previewColumn(
                      label: 'Target booking after',
                      before: tgt.outstandingAmount,
                      after: tgtAfter,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _previewColumn({
    required String label,
    required double before,
    required double after,
  }) {
    final improved = after < before;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColor.fontColorGrey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _formatCurrency(before),
                style: TextStyle(
                    fontSize: 13,
                    color: AppColor.fontColorGrey,
                    decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 8),
              Icon(
                improved ? Icons.arrow_downward : Icons.arrow_upward,
                size: 14,
                color: improved ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCurrency(after),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: improved ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Transfer type dropdown
  // ─────────────────────────────────────────────

  Widget _buildTransferTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Transfer Type', required: true),
        Obx(() => Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: _dropdownDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: ctrl.transferType.value,
                  items: _transferTypes
                      .map((t) => DropdownMenuItem<String>(
                            value: t['value'],
                            child: Text(t['label']!,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.transferType.value = v;
                  },
                ),
              ),
            )),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Reason field
  // ─────────────────────────────────────────────

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Reason', required: true),
        TextFormField(
          controller: ctrl.reasonCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Explain why this transfer is required...',
            hintStyle:
                TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
            filled: true,
            fillColor: AppColor.whiteColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Reason is required';
            return null;
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Notes field
  // ─────────────────────────────────────────────

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Notes (optional)'),
        TextFormField(
          controller: ctrl.notesCtrl,
          maxLines: 2,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Additional notes...',
            hintStyle:
                TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
            filled: true,
            fillColor: AppColor.whiteColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Submit button
  // ─────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: ctrl.isSubmitting.value
                ? null
                : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ctrl.createTransfer();
                    }
                  },
            icon: ctrl.isSubmitting.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: AppColor.buttonTextWhite, strokeWidth: 2),
                  )
                : Icon(Icons.send_rounded,
                    color: AppColor.buttonTextWhite, size: 18),
            label: Text(
              ctrl.isSubmitting.value
                  ? 'Submitting...'
                  : 'Submit Transfer for Approval',
              style: TextStyle(
                color: AppColor.buttonTextWhite,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              disabledBackgroundColor:
                  AppColor.cPrimaryButtonColor.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ));
  }
}
