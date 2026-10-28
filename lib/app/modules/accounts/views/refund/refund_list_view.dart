import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/refund_controller.dart';
import '../../models/refund_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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

  // ── Local filter state ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Filter state lives on the controller so it survives rebuilds.
    final filterStatus = controller.listStatusFilter;
    final dateFromCtrl = controller.listFromDateCtrl;
    final dateToCtrl = controller.listToDateCtrl;

    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: 'Refunds',
              subtitle: 'Track, approve and settle client refunds',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.CREATE_REFUND),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Refund'),
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
                  // ── Filters bar ──────────────────────────────────────────
                  _buildFilterBar(context, filterStatus, dateFromCtrl, dateToCtrl),
                  Divider(height: 1, color: AppColor.borderSubtle),
                  // ── Table ────────────────────────────────────────────────
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SizedBox(
                          height: 380, child: ShimmerLoader.table());
                    }

                    // Status and dates are filtered server-side (getRefunds).
                    final filtered = controller.refunds.toList();

                    if (filtered.isEmpty) {
                      return const AppEmptyState(
                        icon: LucideIcons.receiptText,
                        title: 'No refunds found',
                        message:
                            'Try different filters, or create a new refund.',
                      );
                    }

                    return horizontalTable(DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Booking')),
                        DataColumn(label: Text('Amount'), numeric: true),
                        DataColumn(label: Text('Channel')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filtered.map((r) => _buildRow(r)).toList(),
                    ));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI row (derived from the loaded list) ──────────────────────────────────

  Widget _buildKpis() {
    return Obx(() {
      final list = controller.refunds;
      final pending = list.where((r) => r.status == 'PENDING_APPROVAL').length;
      final inFlight = list
          .where((r) => r.status == 'APPROVED' || r.status == 'PROCESSING')
          .length;
      final refunded = list
          .where((r) => r.status == 'COMPLETED')
          .fold<double>(0, (s, r) => s + r.refundAmount);
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Refunds',
            value: '${list.length}',
            icon: LucideIcons.receiptText,
            caption: 'Matching the current filters',
          ),
          AppStatCard(
            label: 'Pending approval',
            value: '$pending',
            icon: LucideIcons.hourglass,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Approved / processing',
            value: '$inFlight',
            icon: LucideIcons.refreshCw,
            tone: AppTone.info,
          ),
          AppStatCard(
            label: 'Refunded',
            value: formatInr(refunded),
            icon: LucideIcons.arrowLeftRight,
            tone: AppTone.success,
          ),
        ],
      );
    });
  }

  // ── Filter bar ──────────────────────────────────────────────────────────────

  InputDecoration _compactDecoration({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    RxString filterStatus,
    TextEditingController dateFromCtrl,
    TextEditingController dateToCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Status dropdown
          Obx(() => SizedBox(
                width: 200,
                child: InputDecorator(
                  decoration: _compactDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filterStatus.value,
                      isDense: true,
                      isExpanded: true,
                      icon: Icon(LucideIcons.chevronDown,
                          size: 18, color: AppColor.textTertiary),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s == 'ALL' ? 'All Statuses' : humanizeLabel(s),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.textPrimary),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) filterStatus.value = v;
                      },
                    ),
                  ),
                ),
              )),
          const SizedBox(width: 4),
          // Date From
          SizedBox(
            width: 160,
            child: TextField(
              controller: dateFromCtrl,
              readOnly: true,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
              decoration: _compactDecoration(
                hint: 'From date',
                prefixIcon: Icon(LucideIcons.calendar,
                    size: 16, color: AppColor.textTertiary),
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
          // Date To
          SizedBox(
            width: 160,
            child: TextField(
              controller: dateToCtrl,
              readOnly: true,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
              decoration: _compactDecoration(
                hint: 'To date',
                prefixIcon: Icon(LucideIcons.calendar,
                    size: 16, color: AppColor.textTertiary),
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
          const SizedBox(width: 4),
          // Apply / clear
          OutlinedButton.icon(
            onPressed: () => controller.loadRefunds(),
            icon: const Icon(LucideIcons.listFilter, size: 18),
            label: const Text('Apply'),
          ),
          TextButton(
            onPressed: () {
              filterStatus.value = 'ALL';
              dateFromCtrl.clear();
              dateToCtrl.clear();
              controller.loadRefunds();
            },
            child: const Text('Clear'),
          ),
          // Refresh
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => controller.loadRefunds(),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
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
            color: AppColor.cAppPrimaryColor, fontWeight: FontWeight.w600),
      )),
      DataCell(Text(r.clientName ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(r.bookingRef ?? 'BK-${r.bookingId}')),
      DataCell(Text(
        formatInr(r.refundAmount),
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()]),
      )),
      DataCell(_channelChip(r.refundChannel)),
      DataCell(AppStatusBadge.status(r.status)),
      DataCell(Text(
        formatAccDate(r.createdOn, pattern: 'dd-MMM-yyyy'),
        style: TextStyle(color: AppColor.textSecondary),
      )),
      DataCell(IconButton(
        tooltip: 'View',
        onPressed: () => Get.toNamed(Routes.REFUND_DETAIL,
            arguments: r.id, parameters: {'id': '${r.id}'}),
        icon: const Icon(LucideIcons.eye, size: 18),
      )),
    ]);
  }

  Widget _channelChip(String channel) {
    return AppStatusBadge(
      label: channel.toUpperCase() == 'UPI' ? 'UPI' : humanizeLabel(channel),
      showDot: false,
      dense: true,
    );
  }
}
