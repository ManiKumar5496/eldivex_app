import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/credit_note_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';

/// Credit note detail: summary, approval actions (Pending), apply shortcut
/// (Approved with balance) and the application history
/// (GET /getCreditNoteApplications?credit_note_id=).
class CreditNoteDetailView extends StatefulWidget {
  const CreditNoteDetailView({super.key});

  @override
  State<CreditNoteDetailView> createState() => _CreditNoteDetailViewState();
}

class _CreditNoteDetailViewState extends State<CreditNoteDetailView> {
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
    // Arguments carry the list row; a browser refresh only keeps ?id=.
    final args = Get.arguments;
    if (args is CreditNoteModel) {
      _noteId = args.id;
      ctrl.selectedCreditNote.value = args;
    } else {
      _noteId = toIntOrNull(args) ?? toInt(Get.parameters['id']);
      if (_noteId > 0) await ctrl.loadCreditNoteById(_noteId);
    }
    if (_noteId > 0) ctrl.loadApplications(_noteId);
    if (mounted) setState(() => _resolving = false);
  }

  CreditNoteModel? get _note {
    final n = ctrl.selectedCreditNote.value;
    return n is CreditNoteModel && n.id == _noteId ? n : null;
  }

  void _back() => HelperUi.safeBack(Routes.MAIN);

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
          _noteId > 0 ? 'Credit Note CN-$_noteId' : 'Credit Note',
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryCard(note),
                        const SizedBox(height: 16),
                        _detailsCard(note),
                        const SizedBox(height: 16),
                        _actions(note),
                        const SizedBox(height: 16),
                        _applicationsCard(),
                      ],
                    ),
                  ),
                ),
              );
            }),
    );
  }

  Widget _card({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor)),
            const Divider(height: 20),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _summaryCard(CreditNoteModel note) {
    final used = (note.amount - note.available).clamp(0.0, note.amount);
    final progress = note.amount > 0 ? used / note.amount : 0.0;
    return _card(children: [
      Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('CN-${note.id}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.cPrimaryButtonColor)),
          accountsStatusChip(note.status),
          if (note.isApproved && (note.extendedStatus ?? '').isNotEmpty)
            accountsStatusChip(note.extendedStatus!),
        ],
      ),
      const SizedBox(height: 14),
      Text(formatInr(note.amount),
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700, color: Colors.teal)),
      const SizedBox(height: 10),
      Text('Remaining ${formatInr(note.available)} · Used ${formatInr(used)}',
          style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress.toDouble(),
          minHeight: 6,
          backgroundColor: AppColor.divColor,
          valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1 ? Colors.blue : Colors.green),
        ),
      ),
    ]);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColor.cPrimaryHeadingColor)),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(CreditNoteModel note) {
    return _card(title: 'Details', children: [
      _row('Type', note.creditType),
      _row('Booking', '#${note.bookingId}'),
      if (note.clientName != null) _row('Client', note.clientName!),
      if (note.clientMobile != null) _row('Mobile', note.clientMobile!),
      if (note.patientName != null) _row('Patient', note.patientName!),
      if (note.invoiceId != null) _row('Invoice', 'INV-${note.invoiceId}'),
      _row('Credit Date', formatAccDate(note.creditDate ?? note.createdOn)),
      _row('Reason', note.reason ?? '—'),
    ]);
  }

  Widget _actions(CreditNoteModel note) {
    if (note.status == 'Pending') {
      return Obx(() {
        final busy = ctrl.isSubmitting.value;
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: busy
                  ? null
                  : () => ctrl.confirmAndUpdateStatus(note, 'Approved'),
              icon: Icon(Icons.check, size: 18, color: AppColor.buttonTextWhite),
              label: Text('Approve',
                  style: TextStyle(color: AppColor.buttonTextWhite)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
            ),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => ctrl.confirmAndUpdateStatus(note, 'Rejected'),
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              label: const Text('Reject', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red)),
            ),
          ],
        );
      });
    }
    if (note.canApply) {
      return ElevatedButton.icon(
        onPressed: () => Get.toNamed(Routes.APPLY_CREDIT_NOTE,
            arguments: note, parameters: {'id': '${note.id}'}),
        icon: Icon(Icons.playlist_add_check,
            size: 18, color: AppColor.buttonTextWhite),
        label: Text('Apply to Invoice',
            style: TextStyle(color: AppColor.buttonTextWhite)),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _applicationsCard() {
    return _card(title: 'Applications', children: [
      Obx(() {
        final apps = ctrl.creditNoteApplications
            .where((a) => a.creditNoteId == _noteId)
            .toList();
        if (apps.isEmpty) {
          return Text('This credit note has not been applied yet.',
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey));
        }
        return horizontalTable(DataTable(
          headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Invoice')),
            DataColumn(label: Text('Booking')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Applied On')),
            DataColumn(label: Text('Notes')),
          ],
          rows: apps
              .map((a) => DataRow(cells: [
                    DataCell(Text(a.targetInvoiceRef ?? 'INV-${a.targetInvoiceId}')),
                    DataCell(Text('#${a.targetBookingId}')),
                    DataCell(Text(formatInr(a.amountApplied))),
                    DataCell(accountsStatusChip(a.status)),
                    DataCell(Text(formatAccDate(a.appliedAt))),
                    DataCell(Text(a.notes ?? '—')),
                  ]))
              .toList(),
        ));
      }),
    ]);
  }
}
