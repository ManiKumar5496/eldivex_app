import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/refund_controller.dart';
import '../../models/refund_model.dart';
import '../accounts_format.dart';

class RefundListView extends GetView<RefundController> {
  const RefundListView({super.key});

  // ── Status helpers ──────────────────────────────────────────────────────────

  static const List<String> _statusOptions = [
    'ALL',
    'PENDING_APPROVAL',
    'APPROVED',
    'PROCESSING',
    'COMPLETED',
    'REJECTED',
  ];

  Widget _statusBadge(String status) {
    final color = accountsStatusColor(status);
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


  // ── Local filter state ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Filter state lives on the controller so it survives rebuilds.
    final filterStatus = controller.listStatusFilter;
    final dateFromCtrl = controller.listFromDateCtrl;
    final dateToCtrl = controller.listToDateCtrl;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CREATE_REFUND),
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

              // Status and dates are filtered server-side (getRefunds).
              final filtered = controller.refunds.toList();

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
                  child: horizontalTable(DataTable(
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
                  )),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
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
            onPressed: () => controller.loadRefunds(),
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
          // Refresh
          Obx(() => controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => controller.loadRefunds(),
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
        formatInr(r.refundAmount),
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      )),
      DataCell(_channelChip(r.refundChannel)),
      DataCell(_statusBadge(r.status)),
      DataCell(Text(
        formatAccDate(r.createdOn, pattern: 'dd-MMM-yyyy'),
        style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
      )),
      DataCell(InkWell(
        onTap: () => Get.toNamed(Routes.REFUND_DETAIL,
            arguments: r.id, parameters: {'id': '${r.id}'}),
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
}
