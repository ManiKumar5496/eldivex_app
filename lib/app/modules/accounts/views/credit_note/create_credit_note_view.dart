import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/parse_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateCreditNoteView extends GetView<CreditNoteController> {
  const CreateCreditNoteView({super.key});

  /// edx_credit_notes.credit_type values (backend default: Hold).
  static const _creditTypes = ['Hold', 'Cancellation', 'Overpayment', 'Other'];

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreditNoteController>()) {
      Get.put(CreditNoteController());
    }
    applyClientArgument(context, _selectClient);
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
                  title: 'Create Credit Note',
                  subtitle: 'Fill in the details to create a new credit note.',
                  breadcrumbs: const ['Accounts', 'Credit Notes'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                ),
                const SizedBox(height: 24),
                _buildForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Client dropdown change — also used to preselect the client passed by
  /// the outstanding page's Quick Actions.
  void _selectClient(int? val) {
    controller.selectedClientId.value = val;
    controller.selectedBookingId.value = null;
    controller.selectedInvoiceId.value = null;
    controller.targetInvoices.clear();
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          title: 'Client & booking',
          subtitle: 'Who the credit is issued to',
          icon: LucideIcons.user,
          child: _formGrid([
            // ── Client selector (getActiveClients is per booking → dedupe) ──
            _field(
              _buildLabel('Client', required: true),
              Obx(() {
                final clients =
                    ClientOption.fromBookingRows(controller.activeClients);
                final selected = clients
                        .any((c) => c.userId == controller.selectedClientId.value)
                    ? controller.selectedClientId.value
                    : null;
                return _buildDropdownField<int>(
                  hint: 'Select a client',
                  value: selected,
                  items: clients
                      .map((c) => DropdownMenuItem<int>(
                            value: c.userId,
                            child: Text(c.label, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: _selectClient,
                );
              }),
            ),

            // ── Booking selector ──────────────────────────────────────
            _field(
              _buildLabel('Booking', required: true),
              Obx(() {
                final bookings = bookingRowsForUser(
                    controller.activeClients, controller.selectedClientId.value);
                return _buildDropdownField<int>(
                  hint: controller.selectedClientId.value == null
                      ? 'Select a client first'
                      : 'Select a booking',
                  value: controller.selectedBookingId.value,
                  items: bookings.map<DropdownMenuItem<int>>((b) {
                    final id =
                        toInt(field(b, 'booking_id'), toInt(field(b, 'id')));
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(bookingRowLabel(b),
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: bookings.isEmpty
                      ? null
                      : (val) {
                          controller.selectedBookingId.value = val;
                          controller.selectedInvoiceId.value = null;
                          if (val != null) controller.loadTargetInvoices(val);
                        },
                );
              }),
            ),

            // ── Invoice selector (optional) ───────────────────────────
            _field(
              _buildLabel('Invoice (Optional)'),
              Obx(() {
                final invoices = controller.targetInvoices;
                final bookingSelected =
                    controller.selectedBookingId.value != null;
                return _buildDropdownField<int>(
                  hint: bookingSelected
                      ? (invoices.isEmpty
                          ? 'No invoices found'
                          : 'Select an invoice')
                      : 'Select a booking first',
                  value: controller.selectedInvoiceId.value,
                  items: invoices.map<DropdownMenuItem<int>>((inv) {
                    // getInvoices: invoice_db_id = PK, invoice_id = 'INV-<id>'.
                    final id = toInt(field(inv, 'invoice_db_id'));
                    final ref = toStr(field(inv, 'invoice_id'), '#$id');
                    final amt = toDouble(field(inv, 'balance_due'));
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                        '$ref — Balance: ${formatInr(amt)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: bookingSelected && invoices.isNotEmpty
                      ? (val) => controller.selectedInvoiceId.value = val
                      : null,
                );
              }),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        AppCard(
          title: 'Credit details',
          subtitle: 'Type, amount and the reason for the credit',
          icon: LucideIcons.notebookPen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _formGrid([
                // ── Credit Type ─────────────────────────────────────────
                _field(
                  _buildLabel('Credit Type', required: true),
                  Obx(() => _buildDropdownField<String>(
                        hint: 'Select type',
                        value: _creditTypes.contains(controller.creditType.value)
                            ? controller.creditType.value
                            : null,
                        items: _creditTypes
                            .map((t) => DropdownMenuItem<String>(
                                value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) controller.creditType.value = val;
                        },
                      )),
                ),

                // ── Amount ─────────────────────────────────────────────
                _field(
                  _buildLabel('Amount (₹)', required: true),
                  _buildTextField(
                    controller: controller.amountCtrl,
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 18),
                  ),
                ),

                // ── Credit Date ─────────────────────────────────────────
                _field(
                  _buildLabel('Credit Date'),
                  _buildDatePickerField(context),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Reason ───────────────────────────────────────────────
              _field(
                _buildLabel('Reason', required: true),
                _buildTextField(
                  controller: controller.reasonCtrl,
                  hint: 'Describe the reason for this credit note...',
                  maxLines: 3,
                ),
              ),
            ],
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => HelperUi.safeBack(Routes.MAIN),
                  child: const Text('Cancel'),
                ),
                // ── Submit ─────────────────────────────────────────────
                Obx(() => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              final ok = await controller.createCreditNote();
                              if (ok) HelperUi.safeBack(Routes.MAIN);
                            },
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.cAppPrimaryColor,
                              ),
                            )
                          : const Text('Create Credit Note'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Date picker button
  // ─────────────────────────────────────────────
  Widget _buildDatePickerField(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.creditDateCtrl,
        builder: (context, value, _) {
      final dateText = value.text.trim();
      final hasDate = dateText.isNotEmpty;
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(DateTime.now().year - 2),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.creditDateCtrl.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.calendar,
                size: 18,
                color: hasDate
                    ? AppColor.cAppPrimaryColor
                    : AppColor.textTertiary),
            suffixIcon: hasDate
                ? IconButton(
                    tooltip: 'Clear',
                    onPressed: () => controller.creditDateCtrl.clear(),
                    icon: Icon(LucideIcons.x,
                        size: 16, color: AppColor.textTertiary),
                  )
                : null,
          ),
          child: Text(
            hasDate ? _formatDate(dateText) : 'Today',
            style: TextStyle(
              fontSize: 14,
              color: hasDate ? AppColor.textPrimary : AppColor.textTertiary,
            ),
          ),
        ),
      );
        });
  }

  // ─────────────────────────────────────────────
  // Reusable helpers
  // ─────────────────────────────────────────────

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

  Widget _buildLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColor.danger),
                )
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: onChanged != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: AppColor.textTertiary)),
          isExpanded: true,
          icon: Icon(LucideIcons.chevronDown,
              color: AppColor.textTertiary, size: 18),
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          borderRadius: BorderRadius.circular(AppRadius.md),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  String _formatDate(String iso) => formatAccDate(iso, empty: iso);
}
