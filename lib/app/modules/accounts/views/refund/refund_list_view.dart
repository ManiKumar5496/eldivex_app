import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/refund_controller.dart';
import '../../models/refund_model.dart';

class RefundListView extends GetView<RefundController> {
  const RefundListView({super.key});

  // ── Status helpers ──────────────────────────────────────────────────────────

  static const List<String> _statusOptions = [
    'ALL',
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'PROCESSING',
    'COMPLETED',
    'REJECTED',
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return AppColor.fontColorGrey;
      case 'PENDING_APPROVAL':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return AppColor.fontColorGrey;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ── Local filter state ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Local reactive state for filters
    final RxString filterStatus = 'ALL'.obs;
    final TextEditingController dateFromCtrl = TextEditingController();
    final TextEditingController dateToCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/create-refund'),
        backgroundColor: AppColor.cPrimaryButtonColor,
        icon: Icon(Icons.add, color: AppColor.buttonTextWhite),
        label: Text(
          'New Refund',
          style: TextStyle(
            color: AppColor.buttonTextWhite,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Filters bar ──────────────────────────────────────────────────
          _buildFilterBar(context, filterStatus, dateFromCtrl, dateToCtrl),
          // ── Table ────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerLoader.table();
              }

              final filtered = _applyFilters(
                controller.refunds,
                filterStatus.value,
                dateFromCtrl.text,
                dateToCtrl.text,
              );

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: AppColor.divColor),
                      const SizedBox(height: 12),
                      Text('No refunds found', style: AppTextStyles.regular16Gre),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.divColor),
                  ),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppColor.fieldColorGrey),
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColor.cPrimaryHeadingColor,
                    ),
                    dataTextStyle: const TextStyle(fontSize: 13),
                    columnSpacing: 16,
                    horizontalMargin: 12,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Booking')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Channel')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filtered.map((r) => _buildRow(r)).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ──────────────────────────────────────────────────────────────

  Widget _buildFilterBar(
    BuildContext context,
    RxString filterStatus,
    TextEditingController dateFromCtrl,
    TextEditingController dateToCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // Status dropdown
          Obx(() => Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: filterStatus.value,
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s == 'ALL' ? 'All Statuses' : s.replaceAll('_', ' '),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) filterStatus.value = v;
                    },
                  ),
                ),
              )),
          const SizedBox(width: 12),
          // Date From
          SizedBox(
            width: 160,
            height: 44,
            child: TextField(
              controller: dateFromCtrl,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'From date',
                hintStyle:
                    TextStyle(color: AppColor.fontColorGrey, fontSize: 13),
                prefixIcon: Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColor.fontColorGrey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                filled: true,
                fillColor: AppColor.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  dateFromCtrl.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Date To
          SizedBox(
            width: 160,
            height: 44,
            child: TextField(
              controller: dateToCtrl,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'To date',
                hintStyle:
                    TextStyle(color: AppColor.fontColorGrey, fontSize: 13),
                prefixIcon: Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColor.fontColorGrey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                filled: true,
                fillColor: AppColor.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  dateToCtrl.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Apply / clear
          OutlinedButton.icon(
            onPressed: () {
              controller.loadRefunds(
                status: filterStatus.value == 'ALL' ? null : filterStatus.value,
              );
            },
            icon: const Icon(Icons.search, size: 16),
            label: const Text('Apply'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.cPrimaryButtonColor,
              side: BorderSide(color: AppColor.cPrimaryButtonColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              filterStatus.value = 'ALL';
              dateFromCtrl.clear();
              dateToCtrl.clear();
              controller.loadRefunds();
            },
            child: Text('Clear',
                style: TextStyle(color: AppColor.fontColorGrey, fontSize: 13)),
          ),
          const Spacer(),
          // Refresh
          Obx(() => controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  tooltip: 'Refresh',
                  onPressed: controller.loadRefunds,
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColor.fontColorGrey,
                )),
        ],
      ),
    );
  }

  // ── Table row ───────────────────────────────────────────────────────────────

  DataRow _buildRow(RefundModel r) {
    return DataRow(cells: [
      DataCell(Text(
        'REF-${r.id}',
        style: TextStyle(
            color: AppColor.cPrimaryButtonColor, fontWeight: FontWeight.w600),
      )),
      DataCell(Text(r.clientName ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(r.bookingRef ?? 'BK-${r.bookingId}')),
      DataCell(Text(
        _formatCurrency(r.refundAmount),
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      )),
      DataCell(_channelChip(r.refundChannel)),
      DataCell(_statusBadge(r.status)),
      DataCell(Text(
        r.createdOn != null ? _formatDate(r.createdOn!) : '—',
        style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
      )),
      DataCell(InkWell(
        onTap: () => Get.toNamed('/refund-detail', arguments: r.id),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            'View',
            style: TextStyle(
                fontSize: 12,
                color: AppColor.cPrimaryButtonColor,
                fontWeight: FontWeight.w500),
          ),
        ),
      )),
    ]);
  }

  Widget _channelChip(String channel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        channel.replaceAll('_', ' '),
        style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey.shade700,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<RefundModel> _applyFilters(
    List<RefundModel> list,
    String status,
    String dateFrom,
    String dateTo,
  ) {
    return list.where((r) {
      final matchStatus = status == 'ALL' || r.status == status;
      bool matchFrom = true;
      bool matchTo = true;
      if (dateFrom.isNotEmpty && r.createdOn != null) {
        matchFrom = r.createdOn!.compareTo(dateFrom) >= 0;
      }
      if (dateTo.isNotEmpty && r.createdOn != null) {
        matchTo = r.createdOn!.compareTo(dateTo) <= 0;
      }
      return matchStatus && matchFrom && matchTo;
    }).toList();
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}-${_monthName(dt.month)}-${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
