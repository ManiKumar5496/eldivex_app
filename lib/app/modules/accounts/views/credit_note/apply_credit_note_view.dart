import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/credit_note_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';

/// Applies an Approved credit note to an open invoice
/// (POST /applyCreditNote { credit_note_id, target_booking_id,
/// target_invoice_id, amount_to_apply, notes }).
class ApplyCreditNoteView extends StatefulWidget {
  const ApplyCreditNoteView({super.key});

  @override
  State<ApplyCreditNoteView> createState() => _ApplyCreditNoteViewState();
}

class _ApplyCreditNoteViewState extends State<ApplyCreditNoteView> {
  late final CreditNoteController ctrl;
  int _noteId = 0;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<CreditNoteController>()
        ? Get.find<CreditNoteController>()
        : Get.put(CreditNoteController());
    _resolve();
  }

  Future<void> _resolve() async {
    ctrl.clearApplyForm();
    // Arguments carry the list row; a browser refresh only keeps ?id=.
    final args = Get.arguments;
    if (args is CreditNoteModel) {
      _noteId = args.id;
      ctrl.selectedCreditNote.value = args;
    } else {
      _noteId = toIntOrNull(args) ?? toInt(Get.parameters['id']);
      if (_noteId > 0) await ctrl.loadCreditNoteById(_noteId);
    }
    final note = _note;
    if (note != null) {
      ctrl.selectedCreditNoteId.value = note.id;
      if (ctrl.activeClients.isEmpty) await ctrl.loadActiveClients();
      _selectBooking(note.bookingId);
    }
    if (mounted) setState(() => _resolving = false);
  }

  CreditNoteModel? get _note {
    final n = ctrl.selectedCreditNote.value;
    return n is CreditNoteModel && n.id == _noteId ? n : null;
  }

  void _back() => HelperUi.safeBack(Routes.MAIN);

  void _selectBooking(int? bookingId) {
    ctrl.selectedTargetBookingId.value = bookingId;
    ctrl.selectedTargetInvoiceId.value = null;
    ctrl.applyAmountCtrl.clear();
    ctrl.targetInvoices.clear();
    if (bookingId != null) ctrl.loadTargetInvoices(bookingId);
  }

  /// Bookings of the credit note's client (any booking in the org is accepted
  /// by the backend, but credit normally stays with the same client).
  List<dynamic> _candidateBookings(CreditNoteModel note) {
    final rows = ctrl.activeClients;
    final own = rows.firstWhereOrNull((r) =>
        toInt(field(r, 'booking_id'), toInt(field(r, 'id'))) == note.bookingId);
    if (own == null) return const [];
    return bookingRowsForUser(rows, toIntOrNull(field(own, 'user_id')));
  }

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
          onPressed: _back,
        ),
        title: Text(
          'Apply Credit Note',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ),
      body: _resolving
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final note = _note;
              if (note == null) {
                return recordNotFound(title: 'Credit note', onBack: _back);
              }
              if (!note.canApply) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      note.isApproved
                          ? 'CN-${note.id} has no remaining balance to apply.'
                          : 'CN-${note.id} is ${note.status}. Only Approved credit notes can be applied.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColor.fontColorGrey),
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _form(note),
                  ),
                ),
              );
            }),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColor.cPrimarySubHeadingColorGrey)),
      );

  Widget _dropdown<T>({
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
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: AppColor.fontColorGrey)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.textFieldBorderColor),
      ),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: AppColor.fontColorGrey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _form(CreditNoteModel note) {
    final bookings = _candidateBookings(note);
    final bookingIds = bookings
        .map((b) => toInt(field(b, 'booking_id'), toInt(field(b, 'id'))))
        .toSet();
    if (!bookingIds.contains(note.bookingId)) bookingIds.add(note.bookingId);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('CN-${note.id}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cPrimaryButtonColor)),
              accountsStatusChip(note.displayStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Available: ${formatInr(note.available)} of ${formatInr(note.amount)}'
            '${note.clientName != null ? ' · ${note.clientName}' : ''}',
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
          ),
          const Divider(height: 32),

          _label('Target Booking *'),
          Obx(() => _dropdown<int>(
                hint: 'Select booking',
                value: bookingIds.contains(ctrl.selectedTargetBookingId.value)
                    ? ctrl.selectedTargetBookingId.value
                    : null,
                items: bookingIds.map((id) {
                  final row = bookings.firstWhereOrNull((b) =>
                      toInt(field(b, 'booking_id'), toInt(field(b, 'id'))) == id);
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(row != null ? bookingRowLabel(row) : 'Booking #$id',
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _selectBooking,
              )),
          const SizedBox(height: 18),

          _label('Target Invoice *'),
          Obx(() {
            // getInvoices: invoice_db_id = PK, invoice_id = 'INV-<id>'.
            final open = ctrl.targetInvoices
                .where((inv) => toDouble(field(inv, 'balance_due')) > 0)
                .toList();
            final ids = open.map((inv) => toInt(field(inv, 'invoice_db_id'))).toSet();
            return _dropdown<int>(
              hint: ctrl.isLoading.value
                  ? 'Loading invoices…'
                  : (open.isEmpty ? 'No open invoices for this booking' : 'Select invoice'),
              value: ids.contains(ctrl.selectedTargetInvoiceId.value)
                  ? ctrl.selectedTargetInvoiceId.value
                  : null,
              items: open.map((inv) {
                final id = toInt(field(inv, 'invoice_db_id'));
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    '${toStr(field(inv, 'invoice_id'), 'INV-$id')} — Balance ${formatInr(field(inv, 'balance_due'))}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: open.isEmpty
                  ? null
                  : (id) {
                      ctrl.selectedTargetInvoiceId.value = id;
                      final inv = open.firstWhereOrNull(
                          (i) => toInt(field(i, 'invoice_db_id')) == id);
                      if (inv != null) {
                        final suggested = math.min(
                            note.available, toDouble(field(inv, 'balance_due')));
                        ctrl.applyAmountCtrl.text = suggested.toStringAsFixed(2);
                      }
                    },
            );
          }),
          const SizedBox(height: 18),

          _label('Amount to Apply (₹) *'),
          _textField(ctrl.applyAmountCtrl, '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 18),

          _label('Notes'),
          _textField(ctrl.applyNotesCtrl, 'Optional notes', maxLines: 2),
          const SizedBox(height: 28),

          Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : () async {
                          final ok = await ctrl.applyCreditNote();
                          if (ok) _back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: ctrl.isSubmitting.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColor.buttonTextWhite),
                        )
                      : Text('Apply Credit',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColor.buttonTextWhite)),
                ),
              )),
        ],
      ),
    );
  }
}
