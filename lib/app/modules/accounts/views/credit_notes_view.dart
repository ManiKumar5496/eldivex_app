import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/credit_note_model.dart';

class CreditNotesView extends GetView<AccountsController> {
  const CreditNotesView({super.key});

  // ─────────────────────────────────────────────
  // Status chip colours
  // ─────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hold':
        return Colors.blue;
      case 'cancellation':
        return Colors.red.shade700;
      case 'overpayment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    return Column(
      children: [
        _buildToolbar(),
        _buildStatusFilters(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Toolbar: search + refresh
  // ─────────────────────────────────────────────
  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: TextField(
                onChanged: (q) {
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
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search credit notes by client, booking, type...',
                  hintStyle:
                      TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: AppColor.fontColorGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Refresh',
            child: InkWell(
              onTap: () => controller.fetchCreditNotes(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: Icon(Icons.refresh,
                    color: AppColor.cPrimaryButtonColor, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Status filter chips
  // ─────────────────────────────────────────────
  Widget _buildStatusFilters() {
    final statuses = ['All', 'Pending', 'Approved', 'Rejected'];
    return Obx(() {
      final activeFilter = controller.selectedCreditNoteFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: statuses.map((s) {
            final isSelected = activeFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s),
                selected: isSelected,
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
                backgroundColor: AppColor.whiteColor,
                selectedColor:
                    AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.fontColorGrey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColor.cPrimaryButtonColor
                        : AppColor.textFieldBorderColor,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Body: loading / empty / table
  // ─────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingCreditNotes.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredCreditNotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No credit notes found',
                  style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Credit notes are auto-created when a booking is put\non hold or cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: const TextStyle(fontSize: 13),
            columnSpacing: 16,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('Note ID')),
              DataColumn(label: Text('Booking')),
              DataColumn(label: Text('Client / Patient')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredCreditNotes.map((note) {
              return _buildRow(note);
            }).toList(),
          ),
        ),
      );
    });
  }

  DataRow _buildRow(CreditNoteModel note) {
    final statusColor = _statusColor(note.status);
    final typeColor = _typeColor(note.creditType);
    return DataRow(cells: [
      // Note ID
      DataCell(Text(
        'CN-${note.id}',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      )),

      // Booking ID
      DataCell(Text('#${note.bookingId}', style: AppTextStyles.regular14black)),

      // Client / Patient
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(note.clientName ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text(note.patientName ?? '-',
              style:
                  TextStyle(fontSize: 11, color: AppColor.fontColorGrey)),
        ],
      )),

      // Credit Type chip
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withValues(alpha: 0.25)),
        ),
        child: Text(
          note.creditType,
          style: TextStyle(
              color: typeColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      )),

      // Amount
      DataCell(Text(
        controller.formatCurrency(note.amount),
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.teal, fontSize: 13),
      )),

      // Reason
      DataCell(SizedBox(
        width: 160,
        child: Tooltip(
          message: note.reason ?? '',
          child: Text(
            note.reason ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      )),

      // Date
      DataCell(Text(
        _formatDateStr(note.creditDate ?? note.createdOn),
        style: const TextStyle(fontSize: 12),
      )),

      // Status chip
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          note.status,
          style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      )),

      // Actions
      DataCell(_buildActions(note)),
    ]);
  }

  Widget _buildActions(CreditNoteModel note) {
    if (note.status != 'Pending') {
      return Icon(Icons.check_circle_outline,
          size: 18, color: Colors.grey.shade400);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Approve',
          child: InkWell(
            onTap: () => _confirmAction(
              title: 'Approve Credit Note',
              message:
                  'Approve CN-${note.id} of ${controller.formatCurrency(note.amount)} for booking #${note.bookingId}?',
              confirmLabel: 'Approve',
              confirmColor: Colors.green,
              onConfirm: () => controller.approveCreditNote(note.id),
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.green),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Reject',
          child: InkWell(
            onTap: () => _confirmAction(
              title: 'Reject Credit Note',
              message:
                  'Reject CN-${note.id} of ${controller.formatCurrency(note.amount)}?',
              confirmLabel: 'Reject',
              confirmColor: Colors.red,
              onConfirm: () => controller.rejectCreditNote(note.id),
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
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

  void _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryHeadingColor)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                Text('Cancel', style: TextStyle(color: AppColor.fontColorGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
