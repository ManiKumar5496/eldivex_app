import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/credit_note_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreditNoteListView extends GetView<CreditNoteController> {
  const CreditNoteListView({super.key});

  AppTone _typeTone(String type) {
    switch (type.toLowerCase()) {
      case 'service_adjustment':
        return AppTone.info;
      case 'billing_error':
        return AppTone.danger;
      case 'goodwill':
        return AppTone.violet;
      case 'advance_credit':
        return AppTone.info;
      case 'cancellation':
        return AppTone.warning;
      case 'hold':
        return AppTone.info;
      case 'overpayment':
        return AppTone.success;
      default:
        return AppTone.neutral;
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'SERVICE_ADJUSTMENT':
        return 'Svc Adj';
      case 'BILLING_ERROR':
        return 'Bill Error';
      case 'GOODWILL':
        return 'Goodwill';
      case 'ADVANCE_CREDIT':
        return 'Advance';
      case 'CANCELLATION':
        return 'Cancellation';
      default:
        return type;
    }
  }

  void _openDetail(CreditNoteModel note) => Get.toNamed(
        Routes.CREDIT_NOTE_DETAIL,
        arguments: note,
        parameters: {'id': '${note.id}'},
      );

  void _openApply(CreditNoteModel note) => Get.toNamed(
        Routes.APPLY_CREDIT_NOTE,
        arguments: note,
        parameters: {'id': '${note.id}'},
      );

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<CreditNoteController>()) {
      Get.put(CreditNoteController());
    }
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: 'Credit Notes',
              subtitle: 'Issue, approve and apply client credit notes',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.CREATE_CREDIT_NOTE),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Credit Note'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildKpis(),
            const SizedBox(height: 20),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildToolbar(),
                  Divider(height: 1, color: AppColor.borderSubtle),
                  _buildBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI row (derived from the loaded list) ─────────────────────────────────

  Widget _buildKpis() {
    return Obx(() {
      final notes = controller.creditNotes.whereType<CreditNoteModel>().toList();
      final pending = notes.where((n) => n.status == 'Pending').length;
      final total = notes.fold<double>(0, (s, n) => s + n.amount);
      final available = notes
          .where((n) => n.canApply)
          .fold<double>(0, (s, n) => s + n.available);
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Credit notes',
            value: '${notes.length}',
            icon: LucideIcons.notebookPen,
            caption: 'Matching the status filter',
          ),
          AppStatCard(
            label: 'Pending approval',
            value: '$pending',
            icon: LucideIcons.hourglass,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Total credited',
            value: _formatCurrency(total),
            icon: LucideIcons.wallet,
            tone: AppTone.info,
          ),
          AppStatCard(
            label: 'Available to apply',
            value: _formatCurrency(available),
            icon: LucideIcons.piggyBank,
            tone: AppTone.success,
          ),
        ],
      );
    });
  }

  // ── Toolbar: search + status filter + refresh ──────────────────────────────

  Widget _buildToolbar() {
    // getCreditNotes filters on edx_credit_notes.status.
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppSearchField(
              hint: 'Search by booking, client, type...',
              onChanged: controller.searchCreditNotes,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...filters.map((f) => _FilterChipItem(
                    label: f,
                    filterList: filters,
                    controller: controller,
                  )),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => controller.loadCreditNotes(),
                icon: const Icon(LucideIcons.refreshCw, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(height: 380, child: ShimmerLoader.table());
      }
      final notes = controller.filteredCreditNotes;
      if (notes.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.notebookPen,
          title: 'No credit notes found',
          message:
              'Create a credit note using the "New Credit Note" button above.',
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileCreditNoteList(notes),
        tablet: _buildScrollableTable(notes),
        desktop: _buildScrollableTable(notes),
      );
    });
  }

  // ── Mobile list ────────────────────────────────────────────────────────────

  Widget _buildMobileCreditNoteList(List notes) {
    final items = <Widget>[];
    for (final note in notes) {
      if (note is CreditNoteModel) {
        if (items.isNotEmpty) {
          items.add(Divider(height: 1, color: AppColor.borderSubtle));
        }
        items.add(_buildMobileCreditNoteCard(note));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteModel note) {
    final double amount = note.amount;
    final double remaining = note.available;
    final double progress = amount > 0
        ? ((amount - remaining) / amount).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: () => _openDetail(note),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Note ID + type + status
            Row(
              children: [
                Text('CN-${note.id}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColor.cAppPrimaryColor)),
                const SizedBox(width: 8),
                _typeBadge(note.creditType),
                const Spacer(),
                AppStatusBadge.status(note.displayStatus, dense: true),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Booking # + client + date
            Row(
              children: [
                Expanded(
                  child: Text(
                      '#${note.bookingId}${note.clientName != null ? ' · ${note.clientName}' : ''}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: AppColor.textSecondary)),
                ),
                const SizedBox(width: 8),
                Text(_formatDateStr(note.creditDate),
                    style: TextStyle(
                        fontSize: 12.5, color: AppColor.textTertiary)),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Amount
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColor.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 10),

            // Row 4: Remaining label + Progress bar
            Text(
              'Remaining: ${_formatCurrency(remaining)} / ${_formatCurrency(amount)}',
              style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 6),
            _progressBar(progress, height: 6),

            if (note.status == 'Pending') ...[
              const SizedBox(height: 16),
              _approvalButtons(note),
            ],

            // Bottom: Apply button if applicable
            if (note.canApply) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openApply(note),
                  icon: const Icon(LucideIcons.circleCheck,
                      size: 18),
                  label: const Text('Apply Credit Note'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Table (tablet / desktop) ───────────────────────────────────────────────

  Widget _buildScrollableTable(List notes) {
    return horizontalTable(DataTable(
      showCheckboxColumn: false,
      columns: const [
        DataColumn(label: Text('Credit Note #')),
        DataColumn(label: Text('Client / Booking')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Amount'), numeric: true),
        DataColumn(label: Text('Remaining'), numeric: true),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Actions')),
      ],
      rows: notes.map((note) {
        if (note is CreditNoteModel) {
          return _buildRow(note);
        }
        return const DataRow(cells: [
          DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-')),
          DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-')),
          DataCell(Text('-')), DataCell(Text('-')),
        ]);
      }).toList(),
    ));
  }

  DataRow _buildRow(CreditNoteModel note) {
    final double amount = note.amount;
    final double remaining = note.available;
    final double used = amount - remaining;
    final double progress = amount > 0 ? (used / amount).clamp(0.0, 1.0) : 0.0;

    return DataRow(
      onSelectChanged: (_) => _openDetail(note),
      cells: [
        DataCell(Text(
          'CN-${note.id}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.cAppPrimaryColor,
          ),
        )),
        DataCell(Text(note.clientName != null
            ? '${note.clientName} · #${note.bookingId}'
            : '#${note.bookingId}')),
        DataCell(_typeBadge(note.creditType)),
        DataCell(Text(_formatCurrency(amount),
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()]))),
        DataCell(SizedBox(
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatCurrency(remaining)} / ${_formatCurrency(amount)}',
                style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
              ),
              const SizedBox(height: 4),
              _progressBar(progress, height: 5),
            ],
          ),
        )),
        DataCell(AppStatusBadge.status(note.displayStatus)),
        DataCell(Text(_formatDateStr(note.creditDate ?? note.createdOn),
            style: TextStyle(color: AppColor.textSecondary))),
        DataCell(_buildActions(note)),
      ],
    );
  }

  Widget _buildActions(CreditNoteModel note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View Details',
          onPressed: () => _openDetail(note),
          icon: const Icon(LucideIcons.eye, size: 18),
        ),
        if (note.status == 'Pending') ...[
          const SizedBox(width: 4),
          _approvalButtons(note, compact: true),
        ],
        if (note.canApply) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: 'Apply',
            child: TextButton(
              onPressed: () => _openApply(note),
              style: AppButtonStyles.compact.merge(AppButtonStyles.soft),
              child: const Text('Apply'),
            ),
          ),
        ],
      ],
    );
  }

  /// Approve / Reject buttons for a Pending credit note
  /// (PATCH /updateCreditNoteStatus).
  Widget _approvalButtons(CreditNoteModel note, {bool compact = false}) {
    return Obx(() {
      final busy = controller.isSubmitting.value;
      if (compact) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Approve',
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => controller.confirmAndUpdateStatus(note, 'Approved'),
                style: AppButtonStyles.compact,
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Reject',
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => controller.confirmAndUpdateStatus(note, 'Rejected'),
                style: AppButtonStyles.compact
                    .merge(AppButtonStyles.dangerOutlined),
                child: const Text('Reject'),
              ),
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: busy
                  ? null
                  : () => controller.confirmAndUpdateStatus(note, 'Approved'),
              child: const Text('Approve'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: busy
                  ? null
                  : () => controller.confirmAndUpdateStatus(note, 'Rejected'),
              style: AppButtonStyles.dangerOutlined,
              child: const Text('Reject'),
            ),
          ),
        ],
      );
    });
  }

  // ── Small pieces ───────────────────────────────────────────────────────────

  Widget _typeBadge(String type) => AppStatusBadge(
        label: _typeLabel(type),
        tone: _typeTone(type),
        showDot: false,
        dense: true,
      );

  Widget _progressBar(double progress, {required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: AppColor.borderSubtle,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress >= 1.0 ? AppColor.info : AppColor.success,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) => formatInr(amount);

  String _formatDateStr(String? s) => formatAccDate(s, pattern: 'dd-MMM-yyyy');
}

class _FilterChipItem extends StatefulWidget {
  final String label;
  final List<String> filterList;
  final CreditNoteController controller;

  const _FilterChipItem({
    required this.label,
    required this.filterList,
    required this.controller,
  });

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem> {
  RxString get _selected => widget.controller.statusFilter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = _selected.value == widget.label;
      return FilterChip(
        label: Text(widget.label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) {
          _selected.value = widget.label;
          widget.controller.loadCreditNotes();
        },
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColor.cAppPrimaryColor : AppColor.textSecondary,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColor.cAppPrimaryColor.withValues(alpha: 0.45)
              : AppColor.divColor,
        ),
      );
    });
  }
}
