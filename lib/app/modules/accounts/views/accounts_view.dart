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
        backgroundColor: AppColor.cAppBackgroundColor,
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
      padding: EdgeInsets.fromLTRB(
        SizeConfig.pagePadding.left,
        SizeConfig.spacingMD,
        SizeConfig.pagePadding.right,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.divColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeConfig.isMobile
              ? _buildMobileHeaderTop(context)
              : _buildDesktopHeaderTop(context),
          SizedBox(height: SizeConfig.spacingMD),
          _buildTabBar(),
        ],
      ),
    );
  }

  // Mobile: title + period-close icon | KPI horizontal scroll below
  Widget _buildMobileHeaderTop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Accounts',
                style: TextStyle(
                    fontSize: SizeConfig.fontH2,
                    fontWeight: FontWeight.w700,
                    color: AppColor.cPrimaryHeadingColor)),
            const Spacer(),
            _buildPeriodCloseButton(context),
          ],
        ),
        SizedBox(height: SizeConfig.spacingSM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildKpiStats(),
        ),
      ],
    );
  }

  // Tablet/Desktop: Row(title + period-close + Spacer + KPI Wrap)
  Widget _buildDesktopHeaderTop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accounts', style: AppTextStyles.heading),
        SizedBox(width: SizeConfig.spacingMD),
        _buildPeriodCloseButton(context),
        const Spacer(),
        _buildKpiStats(),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabLabels = SizeConfig.isMobile
        ? const [
            'Clients',
            'Invoices',
            'Receipts',
            'Statements',
            'Write-Off',
            'Credits',
            'Insurance',
            'Revenue',
          ]
        : const [
            'Active Clients',
            'Invoices',
            'Provisional Receipts',
            'Client Statements',
            'Write-Off',
            'Credit Notes',
            'Insurance Claims',
            'Revenue Recognition',
          ];

    return TabBar(
      labelColor: AppColor.cPrimaryButtonColor,
      unselectedLabelColor: AppColor.fontColorGrey,
      indicatorColor: AppColor.cPrimaryButtonColor,
      indicatorWeight: 3,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelStyle: TextStyle(
        fontSize: SizeConfig.fontBody,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: SizeConfig.fontBody,
        fontWeight: FontWeight.w400,
      ),
      tabs: tabLabels.map((l) => Tab(text: l)).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // KPI stats
  // ─────────────────────────────────────────────
  Widget _buildKpiStats() {
    return Obx(() {
      if (controller.isLoadingKPIs.value) {
        return Row(
          children: List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(left: SizeConfig.spacingSM),
              child: Container(
                width: 120,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColor.fieldColorGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      }
      return Wrap(
        spacing: SizeConfig.spacingSM,
        runSpacing: SizeConfig.spacingXS,
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
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingMD, vertical: SizeConfig.spacingXS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeConfig.iconSM, color: color),
          SizedBox(width: SizeConfig.spacingXS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: SizeConfig.fontCaption,
                      color: AppColor.fontColorGrey)),
              Text(value,
                  style: TextStyle(
                      fontSize: SizeConfig.fontBody,
                      fontWeight: FontWeight.w700,
                      color: color)),
              if (subtitle != null)
                Text(subtitle,
                    style: TextStyle(
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.fontColorGrey)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Period Close button
  // ─────────────────────────────────────────────
  Widget _buildPeriodCloseButton(BuildContext context) {
    final now = DateTime.now();
    return Obx(() {
      final isClosed = controller.isPeriodClosed(now.month, now.year);
      if (SizeConfig.isMobile) {
        return Tooltip(
          message: isClosed
              ? 'Period ${now.month}/${now.year} is closed'
              : 'Close period ${now.month}/${now.year}',
          child: IconButton(
            onPressed:
                isClosed ? null : () => _showPeriodCloseDialog(context),
            icon: Icon(
              isClosed ? Icons.lock : Icons.lock_open,
              size: SizeConfig.iconMD,
              color: isClosed ? AppColor.fontColorGrey : Colors.indigo,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        );
      }
      return Tooltip(
        message: isClosed
            ? 'Period ${now.month}/${now.year} is closed'
            : 'Close current period (${now.month}/${now.year})',
        child: OutlinedButton.icon(
          onPressed:
              isClosed ? null : () => _showPeriodCloseDialog(context),
          icon: Icon(
            isClosed ? Icons.lock : Icons.lock_open,
            size: 15,
            color: isClosed ? AppColor.fontColorGrey : Colors.indigo,
          ),
          label: Text(
            isClosed ? 'Period Closed' : 'Close Period',
            style: TextStyle(
              fontSize: SizeConfig.fontBodySmall,
              color: isClosed ? AppColor.fontColorGrey : Colors.indigo,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isClosed
                  ? AppColor.divColor
                  : Colors.indigo.withValues(alpha: 0.4),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.spacingSM, vertical: SizeConfig.spacingXS),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_clock, color: Colors.indigo, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Close Financial Period',
                  style: TextStyle(
                    fontSize: SizeConfig.fontBody,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: SizeConfig.isMobile ? double.maxFinite : 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeConfig.spacingSM),
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
                      SizedBox(width: SizeConfig.spacingXS),
                      Expanded(
                        child: Text(
                          'Closing a period locks all invoices and receipts '
                          'for that month. No backdated entries will be '
                          'allowed. This action cannot be undone.',
                          style: TextStyle(
                              fontSize: SizeConfig.fontBodySmall,
                              color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.spacingLG),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Month',
                              style: TextStyle(
                                  fontSize: SizeConfig.fontBodySmall,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.cPrimarySubHeadingColorGrey)),
                          SizedBox(height: SizeConfig.spacingXS),
                          Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.spacingSM),
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
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontBodySmall)),
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
                    SizedBox(width: SizeConfig.spacingSM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Year',
                              style: TextStyle(
                                  fontSize: SizeConfig.fontBodySmall,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.cPrimarySubHeadingColorGrey)),
                          SizedBox(height: SizeConfig.spacingXS),
                          Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.spacingSM),
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
                                              style: TextStyle(
                                                  fontSize:
                                                      SizeConfig.fontBodySmall)),
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
                SizedBox(height: SizeConfig.spacingMD),
                Obx(() {
                  if (controller.closedPeriods.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Already closed:',
                          style: TextStyle(
                              fontSize: SizeConfig.fontBodySmall,
                              color: AppColor.fontColorGrey)),
                      SizedBox(height: SizeConfig.spacingXS),
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
                              color: AppColor.fieldColorGrey,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColor.divColor),
                            ),
                            child: Text('$m/$y',
                                style: TextStyle(
                                    fontSize: SizeConfig.fontCaption,
                                    color: AppColor.fontColorGrey)),
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
                foregroundColor: AppColor.buttonTextWhite,
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
                        size: 64, color: AppColor.divColor),
                    SizedBox(height: SizeConfig.spacingSM),
                    Text('No active clients found',
                        style: AppTextStyles.regular16Gre),
                  ],
                ),
              );
            }
            return SizeConfig.adaptiveLayout(
              mobile: _buildMobileClientList(),
              tablet: _buildScrollableClientTable(),
              desktop: _buildScrollableClientTable(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildClientSearchBar() {
    return Padding(
      padding: SizeConfig.pagePadding,
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
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: SizeConfig.isMobile
                      ? 'Search clients...'
                      : 'Search by client name, mobile, patient, booking ID...',
                  hintStyle: TextStyle(
                      color: AppColor.fontColorGrey,
                      fontSize: SizeConfig.fontBody),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.spacingSM),
          InkWell(
            onTap: () => controller.isFilterVisible.toggle(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spacingMD),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list,
                      color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
                  if (!SizeConfig.isMobile) ...[
                    SizedBox(width: SizeConfig.spacingXS),
                    Text('Filters',
                        style: TextStyle(
                            color: AppColor.cPrimaryButtonColor,
                            fontSize: SizeConfig.fontBody)),
                  ],
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
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.pagePadding.left),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: SizeConfig.isMobile
          ? _buildMobileFilters()
          : _buildDesktopFilters(),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          label: 'Booking ID',
          hint: 'Enter booking ID',
          controller: controller.filterBookingIdController,
        ),
        SizedBox(height: SizeConfig.spacingSM),
        CommonTextField(
          label: 'Client Name',
          hint: 'Enter client name',
          controller: controller.filterClientNameController,
        ),
        SizedBox(height: SizeConfig.spacingSM),
        CommonTextField(
          label: 'Mobile',
          hint: 'Enter mobile number',
          controller: controller.filterMobileController,
        ),
        SizedBox(height: SizeConfig.spacingSM),
        Text('Status',
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColor.cPrimarySubHeadingColorGrey)),
        SizedBox(height: SizeConfig.spacingXS),
        Obx(() => Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.textFieldBorderColor),
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
                          fontSize: SizeConfig.fontBody)),
                  items: controller.statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => controller.filterStatus.value = v ?? '',
                ),
              ),
            )),
        SizedBox(height: SizeConfig.spacingMD),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: controller.applyClientFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Apply',
                      style: TextStyle(
                          color: AppColor.buttonTextWhite, fontSize: SizeConfig.fontBody)),
                ),
              ),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: controller.clearFilters,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Clear', style: TextStyle(fontSize: SizeConfig.fontBody)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
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
            SizedBox(width: SizeConfig.spacingSM),
            Expanded(
              child: CommonTextField(
                label: 'Client Name',
                hint: 'Enter client name',
                controller: controller.filterClientNameController,
              ),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            Expanded(
              child: CommonTextField(
                label: 'Mobile',
                hint: 'Enter mobile number',
                controller: controller.filterMobileController,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.spacingSM),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: TextStyle(
                          fontSize: SizeConfig.fontBody,
                          fontWeight: FontWeight.w500,
                          color: AppColor.cPrimarySubHeadingColorGrey)),
                  SizedBox(height: SizeConfig.spacingXS),
                  Obx(() => Container(
                        height: 44,
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spacingSM),
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
                                    fontSize: SizeConfig.fontBody)),
                            items: controller.statusOptions
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) =>
                                controller.filterStatus.value = v ?? '',
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            const Expanded(child: SizedBox()),
            SizedBox(width: SizeConfig.spacingSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: controller.applyClientFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spacingLG,
                            vertical: SizeConfig.spacingSM),
                      ),
                      child: Text('Apply',
                          style: TextStyle(color: AppColor.buttonTextWhite)),
                    ),
                    SizedBox(width: SizeConfig.spacingXS),
                    OutlinedButton(
                      onPressed: controller.clearFilters,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spacingLG,
                            vertical: SizeConfig.spacingSM),
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
    );
  }

  // ─────────────────────────────────────────────
  // Mobile: card list
  // ─────────────────────────────────────────────
  Widget _buildMobileClientList() {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.pagePadding.left,
              vertical: SizeConfig.spacingXS),
          itemCount: controller.filteredClients.length,
          itemBuilder: (_, i) =>
              _buildMobileClientCard(controller.filteredClients[i]),
        ));
  }

  Widget _buildMobileClientCard(ActiveBookingClient client) {
    final initials = client.clientName.isNotEmpty
        ? client.clientName
            .split(' ')
            .take(2)
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .join()
        : '?';

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + name/mobile | status + action menu
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                child: Text(initials,
                    style: TextStyle(
                        color: AppColor.cPrimaryButtonColor,
                        fontWeight: FontWeight.w700,
                        fontSize: SizeConfig.fontBody)),
              ),
              SizedBox(width: SizeConfig.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.clientName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.fontBody,
                            color: AppColor.cPrimaryHeadingColor)),
                    Text(client.clientMobile,
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                  ],
                ),
              ),
              _buildStatusChip(client.status),
              SizedBox(width: SizeConfig.spacingXS),
              _buildClientActions(client),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),

          // Row 2: Booking # + service name
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('#${client.bookingId}',
                    style: TextStyle(
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.cPrimaryButtonColor,
                        fontWeight: FontWeight.w500)),
              ),
              SizedBox(width: SizeConfig.spacingXS),
              Expanded(
                child: Text(
                  client.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: SizeConfig.fontBodySmall),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.spacingXS),

          // Row 3: patient • city
          Text(
            '${client.patientName} • ${client.city}',
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey),
          ),
          Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),

          // Row 4: Billed / Paid / Outstanding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _mobileAmountLabel('Billed',
                  controller.formatCurrency(client.totalBilled),
                  AppColor.fontColorGrey),
              _mobileAmountLabel(
                  'Paid',
                  controller.formatCurrency(client.totalPaid),
                  Colors.green),
              _mobileAmountLabel(
                  'Outstanding',
                  controller.formatCurrency(client.outstandingAmount),
                  client.outstandingAmount > 0 ? Colors.red : Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileAmountLabel(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: SizeConfig.fontBody,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: TextStyle(
                fontSize: SizeConfig.fontCaption,
                color: AppColor.fontColorGrey)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Tablet/Desktop: scrollable DataTable
  // ─────────────────────────────────────────────
  Widget _buildScrollableClientTable() {
    return Obx(() => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.pagePadding.left, vertical: 4),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.divColor),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColor.fieldColorGrey),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                dataTextStyle:
                    TextStyle(fontSize: SizeConfig.fontBodySmall),
                columnSpacing: SizeConfig.spacingMD,
                horizontalMargin: SizeConfig.spacingMD,
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
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: SizeConfig.fontBodySmall)),
                        Text(client.clientMobile,
                            style: TextStyle(
                                fontSize: SizeConfig.fontCaption,
                                color: AppColor.fontColorGrey)),
                      ],
                    )),
                    DataCell(Text(client.patientName)),
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(client.serviceName,
                            style: TextStyle(
                                fontSize: SizeConfig.fontBodySmall)),
                        if (client.serviceTypeName != null)
                          Text(client.serviceTypeName!,
                              style: TextStyle(
                                  fontSize: SizeConfig.fontCaption,
                                  color: AppColor.fontColorGrey)),
                      ],
                    )),
                    DataCell(Text(client.city)),
                    DataCell(Text(
                        controller.formatCurrency(client.totalBilled),
                        style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
                    DataCell(Text(
                        controller.formatCurrency(client.totalPaid),
                        style: TextStyle(
                            fontSize: SizeConfig.fontBodySmall,
                            color: Colors.green))),
                    DataCell(Text(
                      controller.formatCurrency(client.outstandingAmount),
                      style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
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
          ),
        ));
  }

  Widget _buildStatusChip(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingSM, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color,
            fontSize: SizeConfig.fontCaption,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildClientActions(ActiveBookingClient client) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
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
                Icon(Icons.receipt_long,
                    size: SizeConfig.iconSM,
                    color: isCancelled ? AppColor.lightGrey : Colors.blue),
                SizedBox(width: SizeConfig.spacingXS),
                Text('Raise Receipt',
                    style: TextStyle(
                        color:
                            isCancelled ? AppColor.lightGrey : null)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'statement',
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    size: SizeConfig.iconSM, color: Colors.green),
                SizedBox(width: SizeConfig.spacingXS),
                const Text('View Statement'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'writeoff',
            enabled: !isCancelled,
            child: Row(
              children: [
                Icon(Icons.money_off,
                    size: SizeConfig.iconSM,
                    color: isCancelled ? AppColor.lightGrey : Colors.orange),
                SizedBox(width: SizeConfig.spacingXS),
                Text('Write-Off',
                    style: TextStyle(
                        color: isCancelled ? AppColor.lightGrey : null)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'claim',
            child: Row(
              children: [
                Icon(Icons.health_and_safety,
                    size: SizeConfig.iconSM, color: Colors.indigo),
                SizedBox(width: SizeConfig.spacingXS),
                const Text('Insurance Claim'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
