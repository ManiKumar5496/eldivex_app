import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/internal_transfer_controller.dart';
import '../../models/internal_transfer_model.dart';
import '../../models/active_booking_client_model.dart';
import '../../../../routes/app_pages.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class TransferListView extends StatefulWidget {
  const TransferListView({super.key});

  @override
  State<TransferListView> createState() => _TransferListViewState();
}

class _TransferListViewState extends State<TransferListView> {
  late final InternalTransferController ctrl;

  // Local filter state
  int? _selectedClientId;
  String _selectedStatus = 'All';

  final List<String> _statusOptions = [
    'All',
    'PENDING_APPROVAL',
    'COMPLETED',
    'REJECTED',
    'REVERSED',
  ];

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InternalTransferController>()) {
      ctrl = Get.find<InternalTransferController>();
    } else {
      ctrl = Get.put(InternalTransferController());
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  AppTone _typeTone(String type) {
    switch (type.toUpperCase()) {
      case 'OVERPAYMENT_TRANSFER':
        return AppTone.success;
      case 'RECEIPT_REALLOCATION':
        return AppTone.info;
      case 'CREDIT_BALANCE_TRANSFER':
        return AppTone.primary;
      case 'SERVICE_SWITCH':
        return AppTone.violet;
      default:
        return AppTone.neutral;
    }
  }

  void _applyFilters() {
    ctrl.loadTransfers(
      clientId: _selectedClientId?.toString(),
      status: _selectedStatus == 'All' ? null : _selectedStatus,
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: 'Internal Transfers',
              subtitle:
                  'Move credit balances between bookings of the same client',
              actions: [
                // New Transfer button
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.CREATE_TRANSFER),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Transfer'),
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
                  _buildFilterBar(),
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

  // ─────────────────────────────────────────────
  // KPI row (derived from the loaded list)
  // ─────────────────────────────────────────────

  Widget _buildKpis() {
    return Obx(() {
      final list = ctrl.transfers;
      String st(InternalTransferModel t) => t.status.toUpperCase();
      final pending = list.where((t) => st(t) == 'PENDING_APPROVAL').length;
      final completed =
          list.where((t) => st(t) == 'COMPLETED' || st(t) == 'APPROVED');
      final moved = completed.fold<double>(0, (s, t) => s + t.transferAmount);
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Transfers',
            value: '${list.length}',
            icon: LucideIcons.arrowLeftRight,
            caption: 'Matching the current filters',
          ),
          AppStatCard(
            label: 'Pending approval',
            value: '$pending',
            icon: LucideIcons.hourglass,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Completed',
            value: '${completed.length}',
            icon: LucideIcons.circleCheckBig,
            tone: AppTone.success,
          ),
          AppStatCard(
            label: 'Amount transferred',
            value: formatInr(moved),
            icon: LucideIcons.wallet,
            tone: AppTone.info,
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────
  // Filter bar
  // ─────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Client dropdown — getActiveClients is per booking, so dedupe by user_id.
          Obx(() {
            final clients = ClientOption.fromBookingRows(ctrl.activeClients);
            final selected = clients.any((c) => c.userId == _selectedClientId)
                ? _selectedClientId
                : null;
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: InputDecorator(
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    isDense: true,
                    value: selected,
                    icon: Icon(LucideIcons.chevronDown,
                        size: 18, color: AppColor.textTertiary),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    hint: Text(
                      'All Clients',
                      style:
                          TextStyle(color: AppColor.textTertiary, fontSize: 14),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Clients',
                            style: TextStyle(
                                fontSize: 14, color: AppColor.textSecondary)),
                      ),
                      ...clients.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c.userId,
                          child: Text(c.label,
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.textPrimary),
                              overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedClientId = v);
                      _applyFilters();
                    },
                  ),
                ),
              ),
            );
          }),
          // Status filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((s) {
              final isSelected = _selectedStatus == s;
              return FilterChip(
                label: Text(s == 'All' ? 'All' : humanizeLabel(s)),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) {
                  setState(() => _selectedStatus = s);
                  _applyFilters();
                },
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColor.cAppPrimaryColor
                      : AppColor.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColor.cAppPrimaryColor.withValues(alpha: 0.45)
                      : AppColor.divColor,
                ),
              );
            }).toList(),
          ),

          // Refresh
          IconButton(
            tooltip: 'Refresh',
            onPressed: _applyFilters,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Body
  // ─────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const SizedBox(height: 380, child: ShimmerLoader.table());
      }
      if (ctrl.transfers.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.arrowLeftRight,
          title: 'No internal transfers found',
          message:
              'Internal transfers move credit balances between bookings of the same client.',
        );
      }
      return horizontalTable(DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Client')),
          DataColumn(label: Text('From Booking')),
          DataColumn(label: Text('To Booking')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: ctrl.transfers.map((t) => _buildRow(t)).toList(),
      ));
    });
  }

  DataRow _buildRow(InternalTransferModel t) {
    return DataRow(cells: [
      // ID
      DataCell(Text(
        'IT-${t.id}',
        style: TextStyle(
            fontWeight: FontWeight.w600, color: AppColor.cAppPrimaryColor),
      )),

      // Client
      DataCell(Text(t.clientName ?? 'Client ${t.clientId}')),

      // From Booking
      DataCell(Text(t.sourceBookingRef ?? '#${t.sourceBookingId}')),

      // To Booking
      DataCell(Text(t.targetBookingRef ?? '#${t.targetBookingId}')),

      // Amount
      DataCell(Text(
        formatInr(t.transferAmount),
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()]),
      )),

      // Type chip
      DataCell(AppStatusBadge(
        label: humanizeLabel(t.transferType),
        tone: _typeTone(t.transferType),
        showDot: false,
        dense: true,
      )),

      // Status badge
      DataCell(AppStatusBadge.status(t.status)),

      // Date
      DataCell(Text(
        formatAccDate(t.createdOn, pattern: 'dd-MMM-yyyy', empty: '-'),
        style: TextStyle(color: AppColor.textSecondary),
      )),

      // Actions
      DataCell(IconButton(
        tooltip: 'View Details',
        onPressed: () => Get.toNamed(
          Routes.TRANSFER_DETAIL,
          arguments: t.id,
          parameters: {'id': '${t.id}'},
        ),
        icon: const Icon(LucideIcons.eye, size: 18),
      )),
    ]);
  }
}
