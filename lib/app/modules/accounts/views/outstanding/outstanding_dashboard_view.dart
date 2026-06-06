import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/outstanding_controller.dart';

class OutstandingDashboardView extends GetView<OutstandingController> {
  const OutstandingDashboardView({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(2)}';
  }

  String _fmtFull(double v) => '₹${v.toStringAsFixed(2)}';

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
            if (controller.isLoading.value) {
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
          Text('Accounts Receivable', style: AppTextStyles.heading),
          const Spacer(),
          TextButton.icon(
            onPressed: controller.loadActiveClients,
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
            // Client dropdown — plain DropdownButton avoids FormField.value deprecation
            Container(
              width: 240,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: DropdownButton<int>(
                value: controller.selectedClientId.value,
                hint: Text('All Clients', style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('All Clients')),
                  ...controller.activeClients.map((c) {
                    final id   = (c['id'] as num?)?.toInt() ?? 0;
                    final name = c['name']?.toString() ?? 'Client $id';
                    return DropdownMenuItem<int>(value: id, child: Text(name, overflow: TextOverflow.ellipsis));
                  }),
                ],
                onChanged: (v) => controller.selectedClientId.value = v,
              ),
            ),
            // From date
            SizedBox(
              width: 160,
              height: 44,
              child: TextField(
                controller: controller.fromDateCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'From Date',
                  hintText: 'YYYY-MM-DD',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
                ),
              ),
            ),
            // To date
            SizedBox(
              width: 160,
              height: 44,
              child: TextField(
                controller: controller.toDateCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'To Date',
                  hintText: 'YYYY-MM-DD',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
                ),
              ),
            ),
            // Apply
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: controller.applyFilters,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: Colors.white,
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
      // Aggregate across all client outstanding entries from active clients.
      // The controller exposes clientOutstanding (single) so we derive totals
      // from the ledger for the dashboard level.
      final entries = controller.ledgerEntries;

      double totalBilled    = 0;
      double totalCollected = 0;

      for (final e in entries) {
        if (e.direction == 'DEBIT') totalBilled    += e.amount;
        if (e.direction == 'CREDIT') totalCollected += e.amount;
      }

      final totalOutstanding = totalBilled - totalCollected;
      final collectionRate   = totalBilled > 0
          ? (totalCollected / totalBilled * 100).clamp(0, 100)
          : 0.0;

      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _kpiCard('Total Outstanding', _fmtFull(totalOutstanding), Colors.red,    Icons.account_balance_wallet_outlined),
          _kpiCard('Total Billed',       _fmtFull(totalBilled),      Colors.blue,   Icons.receipt_long_outlined),
          _kpiCard('Total Collected',    _fmtFull(totalCollected),   Colors.green,  Icons.payments_outlined),
          _kpiCard('Collection Rate',    '${collectionRate.toStringAsFixed(1)}%', const Color(0xFF7C3AED), Icons.pie_chart_outline),
        ],
      );
    });
  }

  Widget _kpiCard(String label, String value, Color color, IconData icon) {
    return Container(
      width: 210,
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
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
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
          // Derive aging buckets from clientOutstanding if present,
          // otherwise show zeroed placeholder buckets.
          final obs = controller.clientOutstanding.value;
          final buckets = obs?.agingBuckets;

          double current = 0, b3160 = 0, b6190 = 0, b90plus = 0;

          if (buckets != null && buckets.isNotEmpty) {
            for (final b in buckets) {
              final lbl = b.label.toLowerCase();
              if (lbl.contains('current')) {
                current += b.amount;
              } else if (lbl.contains('31')) {
                b3160 += b.amount;
              } else if (lbl.contains('61')) {
                b6190 += b.amount;
              } else if (lbl.contains('90')) {
                b90plus += b.amount;
              }
            }
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _agingBox('Current',  _fmt(current),  Colors.green),
              _agingBox('31 – 60',  _fmt(b3160),    Colors.amber.shade700),
              _agingBox('61 – 90',  _fmt(b6190),    Colors.orange),
              _agingBox('90+',      _fmt(b90plus),  Colors.red),
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
          final clients = controller.activeClients;
          if (clients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 56, color: Colors.grey.shade300),
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
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
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
                  DataColumn(label: Text('Billed'),      numeric: true),
                  DataColumn(label: Text('Paid'),        numeric: true),
                  DataColumn(label: Text('Write-offs'),  numeric: true),
                  DataColumn(label: Text('Credits'),     numeric: true),
                  DataColumn(label: Text('Outstanding'), numeric: true),
                ],
                rows: clients.map((c) {
                  final id       = (c['id'] as num?)?.toInt() ?? 0;
                  final name     = c['name']?.toString() ?? 'Client $id';
                  final billed   = (c['total_billed']        as num?)?.toDouble() ?? 0.0;
                  final paid     = (c['total_paid']          as num?)?.toDouble() ?? 0.0;
                  final writeOff = (c['total_write_off']     as num?)?.toDouble() ?? 0.0;
                  final credits  = (c['total_credit_applied'] as num?)?.toDouble() ?? 0.0;
                  final outstanding = (c['outstanding_amount'] as num?)?.toDouble()
                      ?? (billed - paid - writeOff - credits);

                  return DataRow(
                    onSelectChanged: (_) => Get.toNamed(
                      '/accounts/outstanding/client',
                      arguments: {'client_id': id, 'client_name': name},
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
                      DataCell(Text(_fmtFull(billed),   style: TextStyle(color: AppColor.cPrimaryHeadingColor))),
                      DataCell(Text(_fmtFull(paid),     style: const TextStyle(color: Colors.green))),
                      DataCell(Text(_fmtFull(writeOff), style: const TextStyle(color: Colors.orange))),
                      DataCell(Text(_fmtFull(credits),  style: TextStyle(color: AppColor.cPrimaryButtonColor))),
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
              ),
            ),
          );
        }),
      ],
    );
  }
}
