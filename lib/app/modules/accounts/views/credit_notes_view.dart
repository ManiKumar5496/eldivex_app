import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/credit_note_model.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreditNotesView extends GetView<AccountsController> {
  const CreditNotesView({super.key});

  AppTone _typeTone(String type) {
    switch (type.toLowerCase()) {
      case 'hold':
        return AppTone.info;
      case 'cancellation':
        return AppTone.danger;
      case 'overpayment':
        return AppTone.violet;
      default:
        return AppTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    final embedded = accountsIsEmbeddedInTabs(context);
    final isMobile = SizeConfig.isMobile;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: accountsPagePadding(context, bottom: !isMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!embedded) ...[
              const AppPageHeader(
                title: 'Credit notes',
                subtitle:
                    'Review credits raised when bookings are put on hold, cancelled or overpaid',
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
            if (isMobile) ...[
              _buildToolbar(),
              _buildStatusFilters(),
              Expanded(child: _buildBody()),
            ] else
              Expanded(
                child: AppCard(
                  expandChild: true,
                  padding: EdgeInsets.zero,
                  title: 'All credit notes',
                  actions: [
                    _searchField(width: 300),
                    _refreshButton(),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusFilters(),
                      Divider(height: 1, color: AppColor.borderSubtle),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearch(String q) {
    final lq = q.toLowerCase();
    if (q.isEmpty) {
      controller.filteredCreditNotes.value =
          List.from(controller.creditNotes);
    } else {
      controller.filteredCreditNotes.value =
          controller.creditNotes.where((n) {
        return (n.clientName ?? '').toLowerCase().contains(lq) ||
            (n.clientMobile ?? '').contains(q) ||
            (n.patientName ?? '').toLowerCase().contains(lq) ||
            n.bookingId.toString().contains(q) ||
            n.creditType.toLowerCase().contains(lq);
      }).toList();
    }
  }

  Widget _searchField({double? width}) {
    return AppSearchField(
      onChanged: _onSearch,
      hint: 'Search credit notes by client, booking, type…',
      width: width,
    );
  }

  Widget _refreshButton() {
    return accountsToolbarIconButton(
      icon: LucideIcons.refreshCw,
      tooltip: 'Refresh',
      onPressed: () => controller.fetchCreditNotes(),
    );
  }

  /// Mobile toolbar: search + refresh.
  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(child: _searchField()),
        const SizedBox(width: 8),
        _refreshButton(),
      ],
    );
  }

  Widget _buildStatusFilters() {
    final statuses = ['All', 'Pending', 'Approved', 'Rejected'];
    final isMobile = SizeConfig.isMobile;
    return Obx(() {
      final activeFilter = controller.selectedCreditNoteFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: isMobile
            ? const EdgeInsets.symmetric(vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: statuses.map((s) {
            final isSelected = activeFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) {
                  controller.selectedCreditNoteFilter.value = s;
                  if (s == 'All') {
                    controller.filteredCreditNotes.value =
                        List.from(controller.creditNotes);
                  } else {
                    controller.filteredCreditNotes.value = controller.creditNotes
                        .where((n) => n.status == s)
                        .toList();
                  }
                },
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.4)
                      : AppColor.divColor,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingCreditNotes.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredCreditNotes.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.notebookPen,
          title: 'No credit notes found',
          message:
              'Credit notes are auto-created when a booking is put on hold or cancelled.',
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileCardList(),
        tablet: _buildScrollableTable(),
        desktop: _buildScrollableTable(),
      );
    });
  }

  Widget _buildMobileCardList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: controller.filteredCreditNotes.length,
      itemBuilder: (_, i) =>
          _buildMobileCreditNoteCard(controller.filteredCreditNotes[i]),
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteModel note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Note ID + Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CN-${note.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
                accountsStatusChip(note.status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 2: Booking badge + Type chip
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                AppStatusBadge(
                  label: '#${note.bookingId}',
                  tone: AppTone.primary,
                  showDot: false,
                  dense: true,
                ),
                AppStatusBadge(
                  label: note.creditType,
                  tone: _typeTone(note.creditType),
                  showDot: false,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Client / Patient
            Row(
              children: [
                Icon(LucideIcons.user,
                    size: 16, color: AppColor.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${note.clientName ?? '-'} / ${note.patientName ?? '-'}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 4: Amount + Date
            Row(
              children: [
                Text(
                  controller.formatCurrency(note.amount),
                  style: accountsAmountStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  _formatDateStr(note.creditDate ?? note.createdOn),
                  style:
                      TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            ),

            // Row 5: Reason
            if (note.reason != null && note.reason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.reason!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
              ),
            ],

            // Bottom: Action buttons for Pending notes
            if (note.status == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAction(
                        title: 'Reject Credit Note',
                        message:
                            'Reject CN-${note.id} of ${controller.formatCurrency(note.amount)}?',
                        confirmLabel: 'Reject',
                        tone: AppTone.danger,
                        onConfirm: () => controller.rejectCreditNote(note.id),
                      ),
                      style: AppButtonStyles.dangerOutlined,
                      icon: const Icon(LucideIcons.x, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAction(
                        title: 'Approve Credit Note',
                        message:
                            'Approve CN-${note.id} of ${controller.formatCurrency(note.amount)} for booking #${note.bookingId}?',
                        confirmLabel: 'Approve',
                        tone: AppTone.success,
                        onConfirm: () => controller.approveCreditNote(note.id),
                      ),
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      child: horizontalTable(
        DataTable(
          columns: const [
            DataColumn(label: Text('Note ID')),
            DataColumn(label: Text('Booking')),
            DataColumn(label: Text('Client / Patient')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Reason')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.filteredCreditNotes
              .map((note) => _buildRow(note))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(CreditNoteModel note) {
    return DataRow(cells: [
      DataCell(Text(
        'CN-${note.id}',
        style: TextStyle(
            fontWeight: FontWeight.w600, color: AppColor.cPrimaryButtonColor),
      )),
      DataCell(Text('#${note.bookingId}',
          style: TextStyle(color: AppColor.textSecondary))),
      DataCell(accountsCellStack(note.clientName ?? '-',
          subtitle: note.patientName ?? '-')),
      DataCell(AppStatusBadge(
        label: note.creditType,
        tone: _typeTone(note.creditType),
        showDot: false,
        dense: true,
      )),
      DataCell(Text(
        controller.formatCurrency(note.amount),
        style: accountsAmountStyle(),
      )),
      DataCell(SizedBox(
        width: 180,
        child: Tooltip(
          message: note.reason ?? '',
          child: Text(
            note.reason ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
        ),
      )),
      DataCell(Text(
        _formatDateStr(note.creditDate ?? note.createdOn),
        style: TextStyle(color: AppColor.textSecondary),
      )),
      DataCell(accountsStatusChip(note.status)),
      DataCell(_buildActions(note)),
    ]);
  }

  Widget _buildActions(CreditNoteModel note) {
    if (note.status != 'Pending') {
      return Icon(LucideIcons.circleCheck,
          size: 18, color: AppColor.lightGrey);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        accountsIconAction(
          icon: LucideIcons.check,
          tooltip: 'Approve',
          tone: AppTone.success,
          onPressed: () => _confirmAction(
            title: 'Approve Credit Note',
            message:
                'Approve CN-${note.id} of ${controller.formatCurrency(note.amount)} for booking #${note.bookingId}?',
            confirmLabel: 'Approve',
            tone: AppTone.success,
            onConfirm: () => controller.approveCreditNote(note.id),
          ),
        ),
        const SizedBox(width: 8),
        accountsIconAction(
          icon: LucideIcons.x,
          tooltip: 'Reject',
          tone: AppTone.danger,
          onPressed: () => _confirmAction(
            title: 'Reject Credit Note',
            message:
                'Reject CN-${note.id} of ${controller.formatCurrency(note.amount)}?',
            confirmLabel: 'Reject',
            tone: AppTone.danger,
            onConfirm: () => controller.rejectCreditNote(note.id),
          ),
        ),
      ],
    );
  }

  String _formatDateStr(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day.toString().padLeft(2, '0')}-${months[dt.month - 1]}-${dt.year}';
    } catch (_) {
      return s;
    }
  }

  /// Yes/no prompt; [onConfirm] runs only after the user confirms (the
  /// dialog is closed first, exactly as before).
  Future<void> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    required AppTone tone,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showAppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      tone: tone,
      icon: tone == AppTone.danger
          ? LucideIcons.circleX
          : LucideIcons.circleCheck,
    );
    if (confirmed) onConfirm();
  }
}
