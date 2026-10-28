import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/internal_transfer_controller.dart';
import '../../models/parse_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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

  /// {user_id, booking_id, amount} passed in: move a booking's excess (credit
  /// balance) to another booking of the same client. The client is selected
  /// once their bookings have loaded, so both dropdowns hold valid values.
  Future<void> _prefill(Map args) async {
    final clientId = toIntOrNull(args['user_id']);
    final bookingId = toIntOrNull(args['booking_id']);
    if (clientId == null || bookingId == null) return;
    await ctrl.loadClientBookings(clientId);
    ctrl.selectedClientId.value = clientId;
    ctrl.onSourceBookingChanged(bookingId);
    ctrl.transferType.value = 'CREDIT_BALANCE_TRANSFER';
    final amount = toDoubleOrNull(args['amount']);
    if (amount != null && amount > 0) {
      ctrl.transferAmountCtrl.text = amount.toStringAsFixed(2);
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  String _formatCurrency(double v) => formatInr(v);

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: label,
          children: [
            if (required)
              TextSpan(text: ' *', style: TextStyle(color: AppColor.danger)),
          ],
        ),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
    );
  }

  /// Theme-styled field frame for a [DropdownButton].
  Widget _dropdownFrame({required Widget child, bool enabled = true}) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Icon get _dropdownIcon => Icon(LucideIcons.chevronDown,
      size: 18, color: AppColor.textTertiary);

  Text _hint(String text) =>
      Text(text, style: TextStyle(color: AppColor.textTertiary, fontSize: 14));

  /// Small tinted status line under a field.
  Widget _notice(AppTone tone, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tone.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tone.color,
              ),
            ),
          ),
        ],
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
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [for (final f in fields) SizedBox(width: w, child: f)],
      );
    });
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    prepareCreateForm(context, reset: ctrl.clearForm, prefill: _prefill);
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      bottomNavigationBar: _buildActionBar(pad),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Create Internal Transfer',
                    subtitle:
                        'Move a credit balance from one booking to another',
                    breadcrumbs: const ['Accounts', 'Internal Transfers'],
                    onBack: () => HelperUi.safeBack(Routes.MAIN),
                  ),
                  const SizedBox(height: 24),

                  // Warning banner
                  _buildWarningBanner(),
                  const SizedBox(height: 20),

                  // Bookings
                  AppCard(
                    title: 'Transfer Details',
                    subtitle: 'Client and the two bookings involved',
                    icon: LucideIcons.arrowLeftRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Client selector
                        _formGrid([_buildClientSelector()]),
                        const SizedBox(height: 16),
                        _formGrid([
                          // Source booking
                          _buildSourceBookingSelector(),
                          // Target booking
                          _buildTargetBookingSelector(),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount + type
                  AppCard(
                    title: 'Amount',
                    subtitle: 'How much to move and why',
                    icon: LucideIcons.indianRupee,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _formGrid([
                          // Transfer Amount
                          _buildAmountField(),
                          // Transfer Type
                          _buildTransferTypeDropdown(),
                        ]),
                        const SizedBox(height: 8),

                        // Live preview
                        _buildLivePreview(),
                        const SizedBox(height: 8),

                        _formGrid([
                          // Reason
                          _buildReasonField(),
                          // Notes
                          _buildNotesField(),
                        ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColor.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: AppColor.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This transfer requires Finance Head approval before it takes effect.',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Client', required: true),
        Obx(() {
          final clients = ctrl.activeClients;
          // Deduplicate by user_id so we show one entry per client
          final seen = <int>{};
          final unique = clients.where((c) {
            final id = toInt(field(c, 'user_id'));
            return seen.add(id);
          }).toList();

          return _dropdownFrame(
            child: DropdownButton<int>(
              isExpanded: true,
              value: ctrl.selectedClientId.value,
              icon: _dropdownIcon,
              borderRadius: BorderRadius.circular(AppRadius.md),
              hint: _hint('Select client'),
              items: unique.map((c) {
                final id = toInt(field(c, 'user_id'));
                final name = c['client_name']?.toString() ??
                    c['name']?.toString() ??
                    'Client $id';
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name,
                      style: TextStyle(
                          fontSize: 14, color: AppColor.textPrimary)),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                ctrl.selectedClientId.value = id;
                ctrl.loadClientBookings(id);
              },
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Source Booking (Credit)', required: true),
        Obx(() {
          final bookings = ctrl.clientBookings;
          final targetId = ctrl.selectedTargetBookingId.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dropdownFrame(
                enabled: bookings.isNotEmpty,
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: ctrl.selectedSourceBookingId.value,
                  icon: _dropdownIcon,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  hint: _hint(
                    bookings.isEmpty
                        ? 'Select a client first'
                        : 'Select source booking',
                  ),
                  items: bookings
                      .where((b) {
                        final id = toInt(field(b, 'booking_id'));
                        return id != targetId;
                      })
                      .map((b) {
                        final id = toInt(field(b, 'booking_id'));
                        final ref = b['booking_ref']?.toString() ?? '#$id';
                        final balance = toDouble(field(b, 'outstanding_amount'));
                        final credit = balance < 0;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Row(
                            children: [
                              Text(ref,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.textPrimary)),
                              const SizedBox(width: 8),
                              if (credit)
                                Text(
                                  'Credit: ${_formatCurrency(balance.abs())}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColor.success,
                                      fontWeight: FontWeight.w600),
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

              // Live source balance card
              Obx(() {
                final ob = ctrl.sourceBookingOutstanding.value;
                if (ob == null) return const SizedBox.shrink();
                final credit = ob.outstandingAmount < 0;
                return _notice(
                  credit ? AppTone.success : AppTone.warning,
                  credit
                      ? LucideIcons.circleCheck
                      : LucideIcons.triangleAlert,
                  credit
                      ? 'Available credit: ${_formatCurrency(ob.outstandingAmount.abs())}'
                      : 'No credit available — Outstanding: ${_formatCurrency(ob.outstandingAmount)}',
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Target Booking (Outstanding)', required: true),
        Obx(() {
          final bookings = ctrl.clientBookings;
          final sourceId = ctrl.selectedSourceBookingId.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dropdownFrame(
                enabled: bookings.isNotEmpty,
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: ctrl.selectedTargetBookingId.value,
                  icon: _dropdownIcon,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  hint: _hint(
                    bookings.isEmpty
                        ? 'Select a client first'
                        : 'Select target booking',
                  ),
                  items: bookings
                      .where((b) {
                        final id = toInt(field(b, 'booking_id'));
                        return id != sourceId;
                      })
                      .map((b) {
                        final id = toInt(field(b, 'booking_id'));
                        final ref = b['booking_ref']?.toString() ?? '#$id';
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(ref,
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.textPrimary)),
                        );
                      })
                      .toList(),
                  onChanged: bookings.isEmpty
                      ? null
                      : (id) => ctrl.onTargetBookingChanged(id),
                ),
              ),

              // Live target balance card
              Obx(() {
                final ob = ctrl.targetBookingOutstanding.value;
                if (ob == null) return const SizedBox.shrink();
                final hasOutstanding = ob.outstandingAmount > 0;
                return _notice(
                  hasOutstanding ? AppTone.danger : AppTone.success,
                  hasOutstanding
                      ? LucideIcons.receiptText
                      : LucideIcons.circleCheck,
                  hasOutstanding
                      ? 'Outstanding: ${_formatCurrency(ob.outstandingAmount)}'
                      : 'No outstanding amount',
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. 5000.00',
            prefixText: '₹  ',
            prefixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary),
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
      final src = ctrl.sourceBookingOutstanding.value;
      final tgt = ctrl.targetBookingOutstanding.value;
      // The amount is a TextEditingController (not observable) — listen to it
      // so the preview follows typing.
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl.transferAmountCtrl,
        builder: (context, value, _) {
      final amount = double.tryParse(value.text.trim()) ?? 0;

      if (amount <= 0 || (src == null && tgt == null)) {
        return const SizedBox.shrink();
      }

      final srcAfter = src != null ? src.outstandingAmount + amount : null;
      final tgtAfter = tgt != null ? tgt.outstandingAmount - amount : null;

      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.eye, size: 16, color: AppColor.info),
                const SizedBox(width: 6),
                Text(
                  'Transfer Preview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
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
                  const SizedBox(width: 12),
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
        },
      );
    });
  }

  Widget _previewColumn({
    required String label,
    required double before,
    required double after,
  }) {
    final improved = after < before;
    final tone = improved ? AppColor.success : AppColor.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColor.textTertiary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                _formatCurrency(before),
                style: TextStyle(
                    fontSize: 13,
                    color: AppColor.textTertiary,
                    decoration: TextDecoration.lineThrough),
              ),
              Icon(
                improved ? LucideIcons.arrowDown : LucideIcons.arrowUp,
                size: 14,
                color: tone,
              ),
              Text(
                _formatCurrency(after),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tone,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Transfer Type', required: true),
        Obx(() => _dropdownFrame(
              child: DropdownButton<String>(
                isExpanded: true,
                value: ctrl.transferType.value,
                icon: _dropdownIcon,
                borderRadius: BorderRadius.circular(AppRadius.md),
                items: _transferTypes
                    .map((t) => DropdownMenuItem<String>(
                          value: t['value'],
                          child: Text(t['label']!,
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.textPrimary)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) ctrl.transferType.value = v;
                },
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Reason', required: true),
        TextFormField(
          controller: ctrl.reasonCtrl,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Explain why this transfer is required...',
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Notes (optional)'),
        TextFormField(
          controller: ctrl.notesCtrl,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Additional notes...',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Bottom action bar (Cancel + Submit)
  // ─────────────────────────────────────────────

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
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: ctrl.isSubmitting.value
              ? null
              : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final ok = await ctrl.createTransfer();
                    if (ok) HelperUi.safeBack(Routes.MAIN);
                  }
                },
          icon: ctrl.isSubmitting.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppColor.cAppPrimaryColor, strokeWidth: 2),
                )
              : const Icon(LucideIcons.send, size: 18),
          label: Text(
            ctrl.isSubmitting.value
                ? 'Submitting...'
                : 'Submit Transfer for Approval',
          ),
        ));
  }
}
