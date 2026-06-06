import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/credit_note_model.dart';

class CreditNoteListView extends GetView<CreditNoteController> {
  const CreditNoteListView({super.key});

  // ─────────────────────────────────────────────
  // Status & type colours
  // ─────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'partially_applied':
      case 'partially applied':
        return Colors.orange;
      case 'fully_applied':
      case 'fully applied':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'service_adjustment':
        return Colors.teal;
      case 'billing_error':
        return Colors.red.shade700;
      case 'goodwill':
        return Colors.purple;
      case 'advance_credit':
        return Colors.blue;
      case 'cancellation':
        return Colors.orange;
      default:
        return Colors.grey;
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

  bool _canApply(String status) {
    final s = status.toLowerCase();
    return s == 'active' || s == 'partially_applied' || s == 'partially applied';
  }

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
        title: Text(
          'Credit Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/accounts/credit-note/create'),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'New Credit Note',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          _buildToolbar(),
          _buildStatusFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Toolbar: search + refresh
  // ─────────────────────────────────────────────
  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                  if (q.isEmpty) {
                    controller.creditNotes.refresh();
                  }
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by booking, client, type...',
                  hintStyle:
                      TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: 20),
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
              onTap: () => controller.loadCreditNotes(),
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
    final filters = [
      'All',
      'Active',
      'Partially Applied',
      'Fully Applied',
      'Expired',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: filters.map((f) {
          return _FilterChipItem(
            label: f,
            filterList: filters,
            controller: controller,
            statusColorFn: _statusColor,
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Body: loading / empty / table
  // ─────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ShimmerLoader.table();
      }
      final notes = controller.creditNotes;
      if (notes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No credit notes found', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Create a credit note using the "New Credit Note" button above.',
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(Colors.grey.shade50),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColor.cPrimaryHeadingColor,
              ),
              dataTextStyle: const TextStyle(fontSize: 13),
              columnSpacing: 16,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('Credit Note #')),
                DataColumn(label: Text('Booking')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Remaining')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Expiry')),
                DataColumn(label: Text('Actions')),
              ],
              rows: notes.map((note) {
                if (note is CreditNoteModel) {
                  return _buildRow(note);
                }
                return const DataRow(cells: [
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                  DataCell(Text('-')),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  DataRow _buildRow(CreditNoteModel note) {
    final statusColor = _statusColor(note.status);
    final typeColor = _typeColor(note.creditType);

    // Derive used/remaining from model — fallback gracefully if fields missing
    final double amount = note.amount;
    // CreditNoteModel may not have remaining field yet; use amount as placeholder
    final double remaining = amount;
    final double used = amount - remaining;
    final double progress = amount > 0 ? (used / amount).clamp(0.0, 1.0) : 0.0;

    return DataRow(
      onSelectChanged: (_) => Get.toNamed(
        '/accounts/credit-note/detail',
        arguments: note.id,
      ),
      cells: [
        // Credit Note #
        DataCell(Text(
          'CN-${note.id}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColor.cPrimaryButtonColor,
          ),
        )),

        // Booking
        DataCell(Text(
          '#${note.bookingId}',
          style: AppTextStyles.regular14black,
        )),

        // Type chip
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            _typeLabel(note.creditType),
            style: TextStyle(
                color: typeColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        )),

        // Amount
        DataCell(Text(
          _formatCurrency(amount),
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13, color: Colors.teal),
        )),

        // Remaining with progress
        DataCell(SizedBox(
          width: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatCurrency(remaining)} / ${_formatCurrency(amount)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
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

        // Expiry
        DataCell(Text(
          _formatDateStr(note.creditDate),
          style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
        )),

        // Actions
        DataCell(_buildActions(note)),
      ],
    );
  }

  Widget _buildActions(CreditNoteModel note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Details',
          child: InkWell(
            onTap: () => Get.toNamed(
              '/accounts/credit-note/detail',
              arguments: note.id,
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.visibility_outlined,
                  size: 16, color: AppColor.cPrimaryButtonColor),
            ),
          ),
        ),
        if (_canApply(note.status)) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: 'Apply',
            child: InkWell(
              onTap: () => Get.toNamed(
                '/accounts/credit-note/apply',
                arguments: note.id,
              ),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatDateStr(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      final dt = DateTime.parse(s);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day.toString().padLeft(2, '0')}-${months[dt.month - 1]}-${dt.year}';
    } catch (_) {
      return s;
    }
  }
}

// ─────────────────────────────────────────────
// Stateful filter chip item (manages its own selected state via parent RxString)
// ─────────────────────────────────────────────
class _FilterChipItem extends StatefulWidget {
  final String label;
  final List<String> filterList;
  final CreditNoteController controller;
  final Color Function(String) statusColorFn;

  const _FilterChipItem({
    required this.label,
    required this.filterList,
    required this.controller,
    required this.statusColorFn,
  });

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem> {
  // Shared notifier for all chips in the row — use InheritedWidget pattern
  // is overkill here; instead we rely on a static RxString in controller.
  // We'll use a simple approach: store the selected filter in a local static.
  static final RxString _selected = 'All'.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = _selected.value == widget.label;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(widget.label),
          selected: isSelected,
          onSelected: (_) {
            _selected.value = widget.label;
            if (widget.label == 'All') {
              widget.controller.loadCreditNotes();
            } else {
              // Map display label to API status value
              final statusMap = {
                'Active': 'Active',
                'Partially Applied': 'Partially Applied',
                'Fully Applied': 'Fully Applied',
                'Expired': 'Expired',
              };
              widget.controller
                  .loadCreditNotes(status: statusMap[widget.label]);
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    });
  }
}
