import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/credit_note_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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

  double get _pad => MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      bottomNavigationBar: _resolving
          ? null
          : Obx(() {
              final note = _note;
              if (note == null || !note.canApply) {
                return const SizedBox.shrink();
              }
              return _actionBar();
            }),
      body: _resolving
          ? _page(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          : Obx(() {
              final note = _note;
              if (note == null) {
                return _page(
                    child: recordNotFound(title: 'Credit note', onBack: _back));
              }
              if (!note.canApply) {
                return _page(
                  child: AppCard(
                    child: AppEmptyState(
                      icon: LucideIcons.info,
                      tone: AppTone.warning,
                      title: 'This credit note cannot be applied',
                      message: note.isApproved
                          ? 'CN-${note.id} has no remaining balance to apply.'
                          : 'CN-${note.id} is ${note.status}. Only Approved credit notes can be applied.',
                    ),
                  ),
                );
              }
              return _page(
                child: LayoutBuilder(builder: (context, c) {
                  if (c.maxWidth < 900) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _summaryCard(note),
                        const SizedBox(height: 20),
                        _form(note),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _form(note)),
                      const SizedBox(width: 20),
                      SizedBox(width: 340, child: _summaryCard(note)),
                    ],
                  );
                }),
              );
            }),
    );
  }

  Widget _page({required Widget child}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_pad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Apply Credit Note',
                subtitle: 'Settle an open invoice using an approved credit note',
                breadcrumbs: const ['Accounts', 'Credit Notes'],
                onBack: _back,
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      padding: EdgeInsets.symmetric(horizontal: _pad, vertical: 12),
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
                  onPressed: _back,
                  child: const Text('Cancel'),
                ),
                Obx(() => ElevatedButton(
                      onPressed: ctrl.isSubmitting.value
                          ? null
                          : () async {
                              final ok = await ctrl.applyCreditNote();
                              if (ok) _back();
                            },
                      child: ctrl.isSubmitting.value
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.cAppPrimaryColor),
                            )
                          : const Text('Apply Credit'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(CreditNoteModel note) {
    return AppCard(
      title: 'CN-${note.id}',
      icon: LucideIcons.notebookPen,
      actions: [AppStatusBadge.status(note.displayStatus)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInfoRow(
            label: 'Available to apply',
            valueWidget: Text(
              formatInr(note.available),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColor.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'of ${formatInr(note.amount)} issued'
            '${note.clientName != null ? ' · ${note.clientName}' : ''}',
            style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary)),
      );

  Widget _dropdown<T>({
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
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: AppColor.textTertiary)),
          icon: Icon(LucideIcons.chevronDown,
              color: AppColor.textTertiary, size: 18),
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
      decoration: InputDecoration(hintText: hint),
    );
  }

  /// Two columns when the card is wide enough, one on phones.
  Widget _formGrid(List<Widget> fields) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 560 ? 2 : 1;
      final w = (c.maxWidth - 20 * (cols - 1)) / cols;
      return Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [for (final f in fields) SizedBox(width: w, child: f)],
      );
    });
  }

  Widget _form(CreditNoteModel note) {
    final bookings = _candidateBookings(note);
    final bookingIds = bookings
        .map((b) => toInt(field(b, 'booking_id'), toInt(field(b, 'id'))))
        .toSet();
    if (!bookingIds.contains(note.bookingId)) bookingIds.add(note.bookingId);

    return AppCard(
      title: 'Apply to invoice',
      subtitle: 'Pick the booking and open invoice to settle',
      icon: LucideIcons.listChecks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _formGrid([
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _label('Target Booking *'),
                Obx(() => _dropdown<int>(
                      hint: 'Select booking',
                      value: bookingIds.contains(ctrl.selectedTargetBookingId.value)
                          ? ctrl.selectedTargetBookingId.value
                          : null,
                      items: bookingIds.map((id) {
                        final row = bookings.firstWhereOrNull((b) =>
                            toInt(field(b, 'booking_id'), toInt(field(b, 'id'))) ==
                            id);
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                              row != null ? bookingRowLabel(row) : 'Booking #$id',
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: _selectBooking,
                    )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _label('Target Invoice *'),
                Obx(() {
                  // getInvoices: invoice_db_id = PK, invoice_id = 'INV-<id>'.
                  final open = ctrl.targetInvoices
                      .where((inv) => toDouble(field(inv, 'balance_due')) > 0)
                      .toList();
                  final ids =
                      open.map((inv) => toInt(field(inv, 'invoice_db_id'))).toSet();
                  return _dropdown<int>(
                    hint: ctrl.isLoading.value
                        ? 'Loading invoices…'
                        : (open.isEmpty
                            ? 'No open invoices for this booking'
                            : 'Select invoice'),
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
                              final suggested = math.min(note.available,
                                  toDouble(field(inv, 'balance_due')));
                              ctrl.applyAmountCtrl.text =
                                  suggested.toStringAsFixed(2);
                            }
                          },
                  );
                }),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _label('Amount to Apply (₹) *'),
                _textField(ctrl.applyAmountCtrl, '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          _label('Notes'),
          _textField(ctrl.applyNotesCtrl, 'Optional notes', maxLines: 2),
        ],
      ),
    );
  }
}
