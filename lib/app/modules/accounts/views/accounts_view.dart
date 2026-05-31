import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/modules/accounts/views/client_statement.dart';
import 'package:eldivex_app/app/modules/accounts/views/credit_notes_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/insurance_claims_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/invoice_list.dart';
import 'package:eldivex_app/app/modules/accounts/views/manage_reciepts.dart';
import 'package:eldivex_app/app/modules/accounts/views/revenue_recognition_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/write_off_view.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/active_booking_client_model.dart';

class AccountsView extends GetView<AccountsController> {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountsController());
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    SizeConfig.init(context);

    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: TabBarView(
                children: [
                  _buildActiveClientsTab(context),
                  const InvoiceListView(),
                  const ManageRecieptsView(),
                  const ClientStatementView(),
                  const WriteOffView(),
                  const CreditNotesView(),
                  const InsuranceClaimsView(),
                  const RevenueRecognitionView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row + KPI stats + Period Close ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accounts', style: AppTextStyles.heading),
              const SizedBox(width: 16),
              _buildPeriodCloseButton(context),
              const Spacer(),
              _buildKpiStats(),
            ],
          ),
          const SizedBox(height: 16),
          // ── Tabs ──
          TabBar(
            labelColor: AppColor.cPrimaryButtonColor,
            unselectedLabelColor: AppColor.fontColorGrey,
            indicatorColor: AppColor.cPrimaryButtonColor,
            indicatorWeight: 3,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Active Clients'),
              Tab(text: 'Invoices'),
              Tab(text: 'Provisional Receipts'),
              Tab(text: 'Client Statements'),
              Tab(text: 'Write-Off'),
              Tab(text: 'Credit Notes'),
              Tab(text: 'Insurance Claims'),
              Tab(text: 'Revenue Recognition'),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // KPI stats — wired to real controller data
  // ─────────────────────────────────────────────
  Widget _buildKpiStats() {
    return Obx(() {
      if (controller.isLoadingKPIs.value) {
        return Row(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                width: 130,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      }
      return Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _kpiCard(
            label: 'Total Outstanding',
            value: controller.formatCurrency(controller.totalOutstanding.value),
            color: Colors.orange,
            icon: Icons.account_balance_wallet_outlined,
          ),
          _kpiCard(
            label: 'Total Collected',
            value: controller.formatCurrency(controller.totalCollected.value),
            color: Colors.green,
            icon: Icons.check_circle_outline,
          ),
          _kpiCard(
            label: 'Overdue',
            value: controller.formatCurrency(controller.overdueAmount.value),
            color: Colors.red,
            icon: Icons.warning_amber_outlined,
            subtitle: '${controller.overdueCount.value} invoices',
          ),
          _kpiCard(
            label: 'Collection Rate',
            value: '${controller.collectionRate.value}%',
            color: Colors.blue,
            icon: Icons.trending_up,
            subtitle: 'DSO: ${controller.dso.value} days',
          ),
        ],
      );
    });
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color)),
              if (subtitle != null)
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Period Close button + dialog
  // ─────────────────────────────────────────────
  Widget _buildPeriodCloseButton(BuildContext context) {
    final now = DateTime.now();
    return Obx(() {
      final isClosed = controller.isPeriodClosed(now.month, now.year);
      return Tooltip(
        message: isClosed
            ? 'Period ${now.month}/${now.year} is closed'
            : 'Close current period (${now.month}/${now.year})',
        child: OutlinedButton.icon(
          onPressed: isClosed
              ? null
              : () => _showPeriodCloseDialog(context),
          icon: Icon(
            isClosed ? Icons.lock : Icons.lock_open,
            size: 15,
            color: isClosed ? Colors.grey : Colors.indigo,
          ),
          label: Text(
            isClosed ? 'Period Closed' : 'Close Period',
            style: TextStyle(
              fontSize: 13,
              color: isClosed ? Colors.grey : Colors.indigo,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isClosed
                  ? Colors.grey.shade300
                  : Colors.indigo.withValues(alpha: 0.4),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    });
  }

  void _showPeriodCloseDialog(BuildContext context) {
    final now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear  = now.year;

    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_clock, color: Colors.indigo, size: 22),
              const SizedBox(width: 8),
              Text(
                'Close Financial Period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.amber.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Closing a period locks all invoices and receipts '
                          'for that month. No backdated entries will be '
                          'allowed. This action cannot be undone.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Month',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.cPrimarySubHeadingColorGrey)),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColor.textFieldBorderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedMonth,
                                items: List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(months[i],
                                        style: const TextStyle(fontSize: 13)),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => selectedMonth = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Year',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.cPrimarySubHeadingColorGrey)),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColor.textFieldBorderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedYear,
                                items: [2025, 2026, 2027]
                                    .map((y) => DropdownMenuItem(
                                          value: y,
                                          child: Text('$y',
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedYear = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Closed periods indicator
                Obx(() {
                  if (controller.closedPeriods.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Already closed:',
                          style: TextStyle(
                              fontSize: 12, color: AppColor.fontColorGrey)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: controller.closedPeriods.map((p) {
                          final m = p['period_month'];
                          final y = p['period_year'];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text('$m/$y',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey)),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel',
                  style: TextStyle(color: AppColor.fontColorGrey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.closePeriod(selectedMonth, selectedYear);
              },
              icon: const Icon(Icons.lock, size: 16),
              label: const Text('Close Period'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tab 1: Active Booking Clients
  // ─────────────────────────────────────────────
  Widget _buildActiveClientsTab(BuildContext context) {
    return Column(
      children: [
        _buildClientSearchBar(),
        Obx(() {
          if (controller.isFilterVisible.value) {
            return _buildClientFilters();
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingClients.value) {
              return const ShimmerLoader.table();
            }
            if (controller.filteredClients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No active clients found',
                        style: AppTextStyles.regular16Gre),
                  ],
                ),
              );
            }
            return _buildClientTable();
          }),
        ),
      ],
    );
  }

  Widget _buildClientSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
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
                controller: controller.searchClientController,
                onChanged: controller.searchClients,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Search by client name, mobile, patient, booking ID...',
                  hintStyle: TextStyle(
                      color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => controller.isFilterVisible.toggle(),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list,
                      color: AppColor.cPrimaryButtonColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Filters',
                      style: TextStyle(
                          color: AppColor.cPrimaryButtonColor, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  label: 'Booking ID',
                  hint: 'Enter booking ID',
                  controller: controller.filterBookingIdController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonTextField(
                  label: 'Client Name',
                  hint: 'Enter client name',
                  controller: controller.filterClientNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonTextField(
                  label: 'Mobile',
                  hint: 'Enter mobile number',
                  controller: controller.filterMobileController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.cPrimarySubHeadingColorGrey)),
                    const SizedBox(height: 8),
                    Obx(() => Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColor.textFieldBorderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: controller.filterStatus.value.isEmpty
                                  ? null
                                  : controller.filterStatus.value,
                              hint: Text('Select status',
                                  style: TextStyle(
                                      color: AppColor.fontColorGrey,
                                      fontSize: 14)),
                              items: controller.statusOptions
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  controller.filterStatus.value = v ?? '',
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: controller.applyClientFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Apply',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: controller.clearFilters,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientTable() {
    return Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              columnSpacing: 20,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('Booking ID')),
                DataColumn(label: Text('Client Name')),
                DataColumn(label: Text('Patient')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('Billed')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Outstanding')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.filteredClients.map((client) {
                return DataRow(cells: [
                  DataCell(Text('#${client.bookingId}',
                      style: AppTextStyles.regular14black)),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(client.clientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(client.clientMobile,
                          style: TextStyle(
                              fontSize: 12, color: AppColor.fontColorGrey)),
                    ],
                  )),
                  DataCell(Text(client.patientName)),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(client.serviceName,
                          style: const TextStyle(fontSize: 13)),
                      if (client.serviceTypeName != null)
                        Text(client.serviceTypeName!,
                            style: TextStyle(
                                fontSize: 11, color: AppColor.fontColorGrey)),
                    ],
                  )),
                  DataCell(Text(client.city)),
                  DataCell(Text(
                      controller.formatCurrency(client.totalBilled),
                      style: const TextStyle(fontSize: 13))),
                  DataCell(Text(
                      controller.formatCurrency(client.totalPaid),
                      style: const TextStyle(
                          fontSize: 13, color: Colors.green))),
                  DataCell(Text(
                    controller.formatCurrency(client.outstandingAmount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: client.outstandingAmount > 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  )),
                  DataCell(_buildStatusChip(client.status)),
                  DataCell(_buildClientActions(client)),
                ]);
              }).toList(),
            ),
          ),
        ));
  }

  Widget _buildStatusChip(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildClientActions(ActiveBookingClient client) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColor.fontColorGrey, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        switch (value) {
          case 'receipt':
            controller.selectClientForReceipt(client);
            DefaultTabController.of(Get.context!).animateTo(2);
            break;
          case 'statement':
            controller.viewStatementForClient(client);
            DefaultTabController.of(Get.context!).animateTo(3);
            break;
          case 'writeoff':
            controller.selectClientForWriteOff(client);
            DefaultTabController.of(Get.context!).animateTo(4);
            break;
          case 'claim':
            controller.selectedClientForClaim.value = client;
            DefaultTabController.of(Get.context!).animateTo(6);
            break;
        }
      },
      itemBuilder: (context) {
        final isCancelled = client.status == 'Cancelled';
        return [
          PopupMenuItem(
            value: 'receipt',
            enabled: !isCancelled,
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: 18,
                    color: isCancelled ? Colors.grey.shade400 : Colors.blue),
                const SizedBox(width: 8),
                Text('Raise Receipt',
                    style: TextStyle(
                        color: isCancelled ? Colors.grey.shade400 : null)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'statement',
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('View Statement'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'writeoff',
            enabled: !isCancelled,
            child: Row(
              children: [
                Icon(Icons.money_off, size: 18,
                    color: isCancelled ? Colors.grey.shade400 : Colors.orange),
                const SizedBox(width: 8),
                Text('Write-Off',
                    style: TextStyle(
                        color: isCancelled ? Colors.grey.shade400 : null)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'claim',
            child: Row(
              children: [
                Icon(Icons.health_and_safety, size: 18, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Insurance Claim'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
