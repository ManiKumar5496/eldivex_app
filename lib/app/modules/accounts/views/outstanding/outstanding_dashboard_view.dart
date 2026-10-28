import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/outstanding_controller.dart';
import '../../../../routes/app_pages.dart';
import '../../models/active_booking_client_model.dart';
import '../accounts_format.dart';

class OutstandingDashboardView extends GetView<OutstandingController> {
  const OutstandingDashboardView({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) => formatInrCompact(v);

  String _fmtFull(double v) => formatInr(v);

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available; loadActiveClients is called in onInit.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.activeClients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 20),
                  _buildKpiRow(),
                  const SizedBox(height: 24),
                  _buildAgingSection(),
                  const SizedBox(height: 24),
                  _buildClientList(),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── page header ───────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Accounts Receivable', style: AppTextStyles.heading)),
          TextButton.icon(
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // ─── filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColor.divColor),
      ),
      color: AppColor.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Client filter — getActiveClients is per booking, so dedupe by user_id.
            (() {
              final clients = ClientOption.fromBookingRows(controller.activeClients);
              final selected = clients.any((c) => c.userId == controller.selectedClientId.value)
                  ? controller.selectedClientId.value
                  : null;
              return Container(
                width: 260,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: DropdownButton<int>(
                  value: selected,
                  hint: Text('All Clients', style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  style: TextStyle(fontSize: 13, color: AppColor.fontColorBlack),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('All Clients')),
                    ...clients.map((c) => DropdownMenuItem<int>(
                          value: c.userId,
                          child: Text(c.label, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (v) => controller.selectedClientId.value = v,
                ),
              );
            })(),
            // Apply
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: controller.applyFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
              ),
            ),
            // Clear
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  // ─── KPI row ───────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    return Obx(() {
      // Org-wide figures come from getCollectionsKPIs (invoices vs approved
      // receipts); a client filter narrows them to that client's bookings.
      final filtered = controller.selectedClientId.value != null;
      final rows = controller.clientReceivables;
      final billed = filtered
          ? rows.fold(0.0, (s, r) => s + r.billed)
          : controller.totalBilled.value;
      final collected = filtered
          ? rows.fold(0.0, (s, r) => s + r.paid)
          : controller.totalCollected.value;
      final outstanding = filtered
          ? rows.fold(0.0, (s, r) => s + r.outstanding)
          : controller.totalOutstanding.value;
      final rate = billed > 0 ? (collected / billed * 100).clamp(0, 100) : 0.0;

      return LayoutBuilder(builder: (context, constraints) {
        // Two cards per row on phones, four on wide screens.
        final perRow = constraints.maxWidth < 600 ? 2 : 4;
        final width = (constraints.maxWidth - 14 * (perRow - 1)) / perRow;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _kpiCard('Total Outstanding', _fmtFull(outstanding), Colors.red,    Icons.account_balance_wallet_outlined, width),
            _kpiCard('Total Billed',       _fmtFull(billed),      Colors.blue,   Icons.receipt_long_outlined, width),
            _kpiCard('Total Collected',    _fmtFull(collected),   Colors.green,  Icons.payments_outlined, width),
            _kpiCard('Collection Rate',    '${rate.toStringAsFixed(1)}%', const Color(0xFF7C3AED), Icons.pie_chart_outline, width),
          ],
        );
      });
    });
  }

  Widget _kpiCard(String label, String value, Color color, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── aging summary ─────────────────────────────────────────────────────────

  Widget _buildAgingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aging Summary', style: AppTextStyles.semiBold18),
        const SizedBox(height: 12),
        Obx(() {
          // Org-wide AR aging from getAgingReport (unpaid invoice balances).
          final buckets = controller.agingBuckets;
          if (buckets.isEmpty) {
            return Text(
              controller.isSummaryLoading.value ? 'Loading…' : 'No outstanding invoices.',
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            );
          }
          const colors = [Colors.green, Colors.amber, Colors.orange, Colors.deepOrange, Colors.red];
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < buckets.length; i++)
                _agingBox(
                  '${buckets[i].label} (${buckets[i].count})',
                  _fmt(buckets[i].amount),
                  colors[i.clamp(0, colors.length - 1)],
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _agingBox(String label, String amount, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(amount, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── client outstanding list ────────────────────────────────────────────────

  Widget _buildClientList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Outstanding by Client', style: AppTextStyles.semiBold18),
        const SizedBox(height: 12),
        Obx(() {
          final clients = controller.clientReceivables;
          if (clients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 56, color: AppColor.divColor),
                    const SizedBox(height: 12),
                    Text('No clients found', style: AppTextStyles.regular16Gre),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.divColor),
            ),
            child: horizontalTable(DataTable(
                headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                dataTextStyle: const TextStyle(fontSize: 13),
                columnSpacing: 28,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Bookings'),    numeric: true),
                  DataColumn(label: Text('Billed'),      numeric: true),
                  DataColumn(label: Text('Paid'),        numeric: true),
                  DataColumn(label: Text('Outstanding'), numeric: true),
                ],
                rows: clients.map((r) {
                  final id          = r.client.userId;
                  final name        = r.client.name.isNotEmpty ? r.client.name : 'Client #$id';
                  final billed      = r.billed;
                  final paid        = r.paid;
                  final outstanding = r.outstanding;

                  return DataRow(
                    onSelectChanged: (_) => Get.toNamed(
                      Routes.CLIENT_OUTSTANDING,
                      arguments: {'client_id': id, 'client_name': name},
                      parameters: {'client_id': '$id'},
                    ),
                    cells: [
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: AppColor.cPrimaryButtonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      )),
                      DataCell(Text('${r.client.bookingCount}')),
                      DataCell(Text(_fmtFull(billed),   style: TextStyle(color: AppColor.cPrimaryHeadingColor))),
                      DataCell(Text(_fmtFull(paid),     style: const TextStyle(color: Colors.green))),
                      DataCell(Text(
                        _fmtFull(outstanding),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: outstanding > 0 ? Colors.red : Colors.green,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              )),
          );
        }),
      ],
    );
  }
}
