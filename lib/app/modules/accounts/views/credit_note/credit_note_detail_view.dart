import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/credit_note_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
      body: _resolving
          ? _page(
              context,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          : Obx(() {
              final note = _note;
              if (note == null) {
                return _page(
                  context,
                  child: recordNotFound(title: 'Credit note', onBack: _back),
                );
              }
              return _page(
                context,
                note: note,
                child: _responsiveColumns(
                  sideFirstOnMobile: true,
                  main: [
                    _detailsCard(note),
                    _applicationsCard(),
                  ],
                  side: [
                    _summaryCard(note),
                    _actions(note),
                  ],
                ),
              );
            }),
    );
  }

  // ── Page frame ─────────────────────────────────────────────────────────────

  Widget _page(BuildContext context, {CreditNoteModel? note, required Widget child}) {
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: _noteId > 0 ? 'Credit Note CN-$_noteId' : 'Credit Note',
                subtitle: note == null
                    ? null
                    : 'Booking #${note.bookingId}'
                        '${note.clientName != null ? ' · ${note.clientName}' : ''}',
                breadcrumbs: const ['Accounts', 'Credit Notes'],
                onBack: _back,
                titleTrailing: note == null
                    ? null
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppStatusBadge.status(note.status),
                          if (note.isApproved &&
                              (note.extendedStatus ?? '').isNotEmpty)
                            AppStatusBadge.status(note.extendedStatus!),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// Main + side columns on desktop, a single column below 900px.
  Widget _responsiveColumns({
    required List<Widget> main,
    required List<Widget> side,
    bool sideFirstOnMobile = false,
  }) {
    List<Widget> gap(List<Widget> items) => [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            items[i],
          ],
        ];
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: gap(sideFirstOnMobile ? [...side, ...main] : [...main, ...side]),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: gap(main),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: gap(side),
            ),
          ),
        ],
      );
    });
  }

  Widget _infoGrid(List<Widget> items) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 520 ? 2 : 1;
      final w = (c.maxWidth - 24 * (cols - 1)) / cols;
      return Wrap(
        spacing: 24,
        runSpacing: 18,
        children: [for (final i in items) SizedBox(width: w, child: i)],
      );
    });
  }

  // ── Cards ──────────────────────────────────────────────────────────────────

  Widget _summaryCard(CreditNoteModel note) {
    final used = (note.amount - note.available).clamp(0.0, note.amount);
    final progress = note.amount > 0 ? used / note.amount : 0.0;
    return AppCard(
      title: 'Credit amount',
      icon: LucideIcons.wallet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatInr(note.amount),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColor.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 6,
              backgroundColor: AppColor.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1 ? AppColor.info : AppColor.success),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppInfoRow(
                    label: 'Remaining', value: formatInr(note.available)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppInfoRow(label: 'Used', value: formatInr(used)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(CreditNoteModel note) {
    return AppCard(
      title: 'Details',
      icon: LucideIcons.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoGrid([
            AppInfoRow(label: 'Type', value: note.creditType),
            AppInfoRow(label: 'Booking', value: '#${note.bookingId}'),
            if (note.clientName != null)
              AppInfoRow(label: 'Client', value: note.clientName!),
            if (note.clientMobile != null)
              AppInfoRow(label: 'Mobile', value: note.clientMobile!),
            if (note.patientName != null)
              AppInfoRow(label: 'Patient', value: note.patientName!),
            if (note.invoiceId != null)
              AppInfoRow(label: 'Invoice', value: 'INV-${note.invoiceId}'),
            AppInfoRow(
                label: 'Credit Date',
                value: formatAccDate(note.creditDate ?? note.createdOn)),
          ]),
          const SizedBox(height: 18),
          AppInfoRow(label: 'Reason', value: note.reason ?? '—'),
        ],
      ),
    );
  }

  Widget _actions(CreditNoteModel note) {
    if (note.status == 'Pending') {
      return AppCard(
        title: 'Approval',
        subtitle: 'This credit note is awaiting a decision.',
        icon: LucideIcons.clipboardClock,
        iconTone: AppTone.warning,
        child: Obx(() {
          final busy = ctrl.isSubmitting.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: busy
                    ? null
                    : () => ctrl.confirmAndUpdateStatus(note, 'Approved'),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Approve'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => ctrl.confirmAndUpdateStatus(note, 'Rejected'),
                icon: const Icon(LucideIcons.x, size: 18),
                label: const Text('Reject'),
                style: AppButtonStyles.dangerOutlined,
              ),
            ],
          );
        }),
      );
    }
    if (note.canApply) {
      return AppCard(
        title: 'Apply credit',
        subtitle: 'Use the remaining balance against an open invoice.',
        icon: LucideIcons.listChecks,
        iconTone: AppTone.success,
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.APPLY_CREDIT_NOTE,
              arguments: note, parameters: {'id': '${note.id}'}),
          icon: const Icon(LucideIcons.listChecks, size: 18),
          label: const Text('Apply to Invoice'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _applicationsCard() {
    return AppCard(
      title: 'Applications',
      subtitle: 'Invoices this credit has been applied to',
      icon: LucideIcons.receiptText,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final apps = ctrl.creditNoteApplications
            .where((a) => a.creditNoteId == _noteId)
            .toList();
        if (apps.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.listChecks,
            title: 'Not applied yet',
            message: 'This credit note has not been applied yet.',
            compact: true,
          );
        }
        return horizontalTable(DataTable(
          columns: const [
            DataColumn(label: Text('Invoice')),
            DataColumn(label: Text('Booking')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Applied On')),
            DataColumn(label: Text('Notes')),
          ],
          rows: apps
              .map((a) => DataRow(cells: [
                    DataCell(Text(
                        a.targetInvoiceRef ?? 'INV-${a.targetInvoiceId}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.cAppPrimaryColor))),
                    DataCell(Text('#${a.targetBookingId}')),
                    DataCell(Text(formatInr(a.amountApplied),
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(AppStatusBadge.status(a.status)),
                    DataCell(Text(formatAccDate(a.appliedAt))),
                    DataCell(Text(a.notes ?? '—')),
                  ]))
              .toList(),
        ));
      }),
    );
  }
}
