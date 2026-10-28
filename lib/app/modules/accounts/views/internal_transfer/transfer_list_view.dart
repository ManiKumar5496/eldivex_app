import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/internal_transfer_controller.dart';
import '../../models/internal_transfer_model.dart';
import '../../models/active_booking_client_model.dart';
import '../../../../routes/app_pages.dart';
import '../accounts_format.dart';

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

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'OVERPAYMENT_TRANSFER':
        return Colors.teal;
      case 'RECEIPT_REALLOCATION':
        return Colors.blue;
      case 'CREDIT_BALANCE_TRANSFER':
        return Colors.indigo;
      case 'SERVICE_SWITCH':
        return Colors.deepPurple;
      default:
        return AppColor.fontColorGrey;
    }
  }

  String _formatType(String type) {
    return type.replaceAll('_', ' ');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Filter bar
  // ─────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
            return Container(
              height: 44,
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: selected,
                  hint: Text(
                    'All Clients',
                    style: TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Clients',
                          style: TextStyle(fontSize: 14, color: AppColor.fontColorGrey)),
                    ),
                    ...clients.map((c) {
                      return DropdownMenuItem<int?>(
                        value: c.userId,
                        child: Text(c.label,
                            style: const TextStyle(fontSize: 14),
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
            );
          }),
          // Status filter chips
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusOptions.map((s) {
                  final isSelected = _selectedStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s == 'All' ? 'All' : _formatType(s)),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedStatus = s);
                        _applyFilters();
                      },
                      backgroundColor: AppColor.whiteColor,
                      selectedColor: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        fontSize: 12,
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
                }).toList(),
              ),
          ),

          // Refresh
          Tooltip(
            message: 'Refresh',
            child: InkWell(
              onTap: _applyFilters,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: Icon(Icons.refresh, color: AppColor.cPrimaryButtonColor, size: 20),
              ),
            ),
          ),
          // New Transfer button
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(Routes.CREATE_TRANSFER),
            icon: Icon(Icons.add, color: AppColor.buttonTextWhite, size: 18),
            label: Text(
              'New Transfer',
              style: TextStyle(color: AppColor.buttonTextWhite, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
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
        return const ShimmerLoader.table();
      }
      if (ctrl.transfers.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_outlined, size: 64, color: AppColor.divColor),
              const SizedBox(height: 12),
              Text('No internal transfers found', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Internal transfers move credit balances between bookings\nof the same client.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
              ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          width: double.infinity,
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
            columnSpacing: 16,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('From Booking')),
              DataColumn(label: Text('To Booking')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: ctrl.transfers.map((t) => _buildRow(t)).toList(),
          )),
        ),
      );
    });
  }

  DataRow _buildRow(InternalTransferModel t) {
    final statusColor = accountsStatusColor(t.status);
    final typeColor = _typeColor(t.transferType);

    return DataRow(cells: [
      // ID
      DataCell(Text(
        'IT-${t.id}',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      )),

      // Client
      DataCell(Text(
        t.clientName ?? 'Client ${t.clientId}',
        style: const TextStyle(fontSize: 13),
      )),

      // From Booking
      DataCell(Text(
        t.sourceBookingRef ?? '#${t.sourceBookingId}',
        style: AppTextStyles.regular14black,
      )),

      // To Booking
      DataCell(Text(
        t.targetBookingRef ?? '#${t.targetBookingId}',
        style: AppTextStyles.regular14black,
      )),

      // Amount
      DataCell(Text(
        formatInr(t.transferAmount),
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.teal, fontSize: 13),
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
          _formatType(t.transferType),
          style: TextStyle(
              color: typeColor, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      )),

      // Status badge
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _formatType(t.status),
          style: TextStyle(
              color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      )),

      // Date
      DataCell(Text(
        formatAccDate(t.createdOn, pattern: 'dd-MMM-yyyy', empty: '-'),
        style: const TextStyle(fontSize: 12),
      )),

      // Actions
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'View Details',
            child: InkWell(
              onTap: () => Get.toNamed(
                Routes.TRANSFER_DETAIL,
                arguments: t.id,
                parameters: {'id': '${t.id}'},
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
        ],
      )),
    ]);
  }
}
