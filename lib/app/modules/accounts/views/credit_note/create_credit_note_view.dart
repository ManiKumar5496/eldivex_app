import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/parse_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';

class CreateCreditNoteView extends GetView<CreditNoteController> {
  const CreateCreditNoteView({super.key});

  /// edx_credit_notes.credit_type values (backend default: Hold).
  static const _creditTypes = ['Hold', 'Cancellation', 'Overpayment', 'Other'];

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreditNoteController>()) {
      Get.put(CreditNoteController());
    }
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColor.cPrimaryHeadingColor),
          onPressed: () => HelperUi.safeBack(Routes.MAIN),
        ),
        title: Text(
          'Create Credit Note',
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
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _buildForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Credit Note Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryHeadingColor,
              )),
          const SizedBox(height: 4),
          Text('Fill in the details to create a new credit note.',
              style: AppTextStyles.regular14Gre),
          const SizedBox(height: 24),
          Divider(color: AppColor.divColor),
          const SizedBox(height: 20),

          // ── Client selector (getActiveClients is per booking → dedupe) ──
          _buildLabel('Client', required: true),
          const SizedBox(height: 8),
          Obx(() {
            final clients = ClientOption.fromBookingRows(controller.activeClients);
            final selected = clients.any((c) => c.userId == controller.selectedClientId.value)
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
              onChanged: (val) {
                controller.selectedClientId.value = val;
                controller.selectedBookingId.value = null;
                controller.selectedInvoiceId.value = null;
                controller.targetInvoices.clear();
              },
            );
          }),
          const SizedBox(height: 18),

          // ── Booking selector ──────────────────────────────────────
          _buildLabel('Booking', required: true),
          const SizedBox(height: 8),
          Obx(() {
            final bookings = bookingRowsForUser(
                controller.activeClients, controller.selectedClientId.value);
            return _buildDropdownField<int>(
              hint: controller.selectedClientId.value == null
                  ? 'Select a client first'
                  : 'Select a booking',
              value: controller.selectedBookingId.value,
              items: bookings.map<DropdownMenuItem<int>>((b) {
                final id = toInt(field(b, 'booking_id'), toInt(field(b, 'id')));
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(bookingRowLabel(b), overflow: TextOverflow.ellipsis),
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
          const SizedBox(height: 18),

          // ── Invoice selector (optional) ───────────────────────────
          _buildLabel('Invoice (Optional)'),
          const SizedBox(height: 8),
          Obx(() {
            final invoices = controller.targetInvoices;
            final bookingSelected = controller.selectedBookingId.value != null;
            return _buildDropdownField<int>(
              hint: bookingSelected
                  ? (invoices.isEmpty ? 'No invoices found' : 'Select an invoice')
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
          const SizedBox(height: 18),

          // ── Credit Type ───────────────────────────────────────────
          _buildLabel('Credit Type', required: true),
          const SizedBox(height: 8),
          Obx(() => _buildDropdownField<String>(
                hint: 'Select type',
                value: _creditTypes.contains(controller.creditType.value)
                    ? controller.creditType.value
                    : null,
                items: _creditTypes
                    .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.creditType.value = val;
                },
              )),
          const SizedBox(height: 18),

          // ── Amount ───────────────────────────────────────────────
          _buildLabel('Amount (₹)', required: true),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.amountCtrl,
            hint: '0.00',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icon(Icons.currency_rupee,
                size: 18, color: AppColor.fontColorGrey),
          ),
          const SizedBox(height: 18),

          // ── Credit Date ───────────────────────────────────────────
          _buildLabel('Credit Date'),
          const SizedBox(height: 8),
          _buildDatePickerField(context),
          const SizedBox(height: 18),

          // ── Reason ───────────────────────────────────────────────
          _buildLabel('Reason', required: true),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.reasonCtrl,
            hint: 'Describe the reason for this credit note...',
            maxLines: 3,
          ),
          const SizedBox(height: 18),

          // ── Submit ───────────────────────────────────────────────
          Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final ok = await controller.createCreditNote();
                          if (ok) HelperUi.safeBack(Routes.MAIN);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    disabledBackgroundColor:
                        AppColor.cPrimaryButtonColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColor.buttonTextWhite),
                          ),
                        )
                      : Text(
                          'Create Credit Note',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColor.buttonTextWhite),
                        ),
                ),
              )),
        ],
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
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColor.cPrimaryButtonColor,
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            controller.creditDateCtrl.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColor.fieldColorGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.textFieldBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18,
                  color: hasDate
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.fontColorGrey),
              const SizedBox(width: 10),
              Text(
                hasDate ? _formatDate(dateText) : 'Today',
                style: TextStyle(
                  fontSize: 14,
                  color: hasDate
                      ? AppColor.cPrimaryHeadingColor
                      : AppColor.fontColorGrey,
                ),
              ),
              const Spacer(),
              if (hasDate)
                GestureDetector(
                  onTap: () => controller.creditDateCtrl.clear(),
                  child: Icon(Icons.close,
                      size: 16, color: AppColor.fontColorGrey),
                ),
            ],
          ),
        ),
      );
        });
  }

  // ─────────────────────────────────────────────
  // Reusable helpers
  // ─────────────────────────────────────────────
  Widget _buildLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColor.cPrimarySubHeadingColorGrey,
        ),
        children: required
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.textFieldBorderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(fontSize: 14, color: AppColor.fontColorGrey),
          prefixIcon: prefixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.textFieldBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style:
                  TextStyle(fontSize: 14, color: AppColor.fontColorGrey)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppColor.fontColorGrey, size: 20),
          style: TextStyle(fontSize: 14, color: AppColor.cPrimaryHeadingColor),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  String _formatDate(String iso) => formatAccDate(iso, empty: iso);
}
