import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/outstanding_controller.dart';
import '../../../../routes/app_pages.dart';
import '../../models/active_booking_client_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class OutstandingDashboardView extends GetView<OutstandingController> {
  const OutstandingDashboardView({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) => formatInrCompact(v);

  String _fmtFull(double v) => formatInr(v);

  /// Aging buckets run from current → oldest.
  static const _agingTones = [
    AppTone.success,
    AppTone.warning,
    AppTone.warning,
    AppTone.danger,
    AppTone.danger,
  ];

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available; loadActiveClients is called in onInit.
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.activeClients.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 20),
                  _buildKpiRow(),
                  const SizedBox(height: 20),
                  _buildAgingSection(),
                  const SizedBox(height: 20),
                  _buildClientList(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── page header ───────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return AppPageHeader(
      title: 'Accounts Receivable',
      subtitle: 'Outstanding balances, collections and invoice aging',
      actions: [
        OutlinedButton.icon(
          onPressed: controller.refreshDashboard,
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  // ─── filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Client filter — getActiveClients is per booking, so dedupe by user_id.
              (() {
                final clients =
                    ClientOption.fromBookingRows(controller.activeClients);
                final selected = clients
                        .any((c) => c.userId == controller.selectedClientId.value)
                    ? controller.selectedClientId.value
                    : null;
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      prefixIcon: Icon(LucideIcons.userSearch,
                          size: 18, color: AppColor.textTertiary),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 38, minHeight: 36),
                    ),
                    child: DropdownButton<int>(
                      value: selected,
                      hint: Text('All Clients',
                          style: TextStyle(
                              fontSize: 14, color: AppColor.textTertiary)),
                      isExpanded: true,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      icon: Icon(LucideIcons.chevronDown,
                          size: 18, color: AppColor.textTertiary),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                      items: [
                        const DropdownMenuItem<int>(
                            value: null, child: Text('All Clients')),
                        ...clients.map((c) => DropdownMenuItem<int>(
                              value: c.userId,
                              child: Text(c.label, overflow: TextOverflow.ellipsis),
                            )),
                      ],
                      onChanged: (v) => controller.selectedClientId.value = v,
                    ),
                  ),
                );
              })(),
              // Apply
              ElevatedButton.icon(
                onPressed: controller.applyFilters,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Reload'),
              ),
              // Clear
              OutlinedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(LucideIcons.x, size: 18),
                label: const Text('Clear'),
              ),
            ],
          )),
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

      // Two cards per row on phones, four on wide screens.
      return AppResponsiveGrid(
        minItemWidth: 150,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Total Outstanding',
            value: _fmtFull(outstanding),
            icon: LucideIcons.wallet,
            tone: AppTone.danger,
          ),
          AppStatCard(
            label: 'Total Billed',
            value: _fmtFull(billed),
            icon: LucideIcons.receiptText,
            tone: AppTone.info,
          ),
          AppStatCard(
            label: 'Total Collected',
            value: _fmtFull(collected),
            icon: LucideIcons.banknote,
            tone: AppTone.success,
          ),
          AppStatCard(
            label: 'Collection Rate',
            value: '${rate.toStringAsFixed(1)}%',
            icon: LucideIcons.chartPie,
            tone: AppTone.violet,
          ),
        ],
      );
    });
  }

  // ─── aging summary ─────────────────────────────────────────────────────────

  Widget _buildAgingSection() {
    return AppCard(
      title: 'Aging Summary',
      subtitle: 'Unpaid invoice balances by age',
      icon: LucideIcons.hourglass,
      iconTone: AppTone.warning,
      child: Obx(() {
        // Org-wide AR aging from getAgingReport (unpaid invoice balances).
        final buckets = controller.agingBuckets;
        if (buckets.isEmpty) {
          if (controller.isSummaryLoading.value) {
            return Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text('Loading…',
                    style:
                        TextStyle(fontSize: 13, color: AppColor.textTertiary)),
              ],
            );
          }
          return const AppEmptyState(
            icon: LucideIcons.circleCheck,
            tone: AppTone.success,
            title: 'No outstanding invoices.',
            compact: true,
          );
        }
        final total = buckets.fold<double>(0, (s, b) => s + b.amount);
        AppTone toneAt(int i) => _agingTones[i.clamp(0, _agingTones.length - 1)];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (total > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      for (var i = 0; i < buckets.length; i++)
                        if (buckets[i].amount > 0)
                          Expanded(
                            flex: ((buckets[i].amount / total) * 1000)
                                .round()
                                .clamp(1, 1000),
                            child: Container(color: toneAt(i).color),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppResponsiveGrid(
              minItemWidth: 150,
              maxColumns: 5,
              spacing: 12,
              children: [
                for (var i = 0; i < buckets.length; i++)
                  _agingBox(
                    '${buckets[i].label} (${buckets[i].count})',
                    _fmt(buckets[i].amount),
                    toneAt(i),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _agingBox(String label, String amount, AppTone tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: tone.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: AppColor.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(amount,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  // ─── client outstanding list ────────────────────────────────────────────────

  Widget _buildClientList() {
    return AppCard(
      title: 'Outstanding by Client',
      subtitle: 'Select a client to see the booking breakdown',
      icon: LucideIcons.users,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final clients = controller.clientReceivables;
        if (clients.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.users,
            title: 'No clients found',
          );
        }

        return horizontalTable(DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Bookings'), numeric: true),
            DataColumn(label: Text('Billed'), numeric: true),
            DataColumn(label: Text('Paid'), numeric: true),
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
                    AppAvatar(name: name, size: 30),
                    const SizedBox(width: 10),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
                DataCell(Text('${r.client.bookingCount}')),
                DataCell(Text(_fmtFull(billed))),
                DataCell(Text(_fmtFull(paid),
                    style: TextStyle(color: AppColor.success))),
                DataCell(Text(
                  _fmtFull(outstanding),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: outstanding > 0 ? AppColor.danger : AppColor.success,
                  ),
                )),
              ],
            );
          }).toList(),
        ));
      }),
    );
  }
}
