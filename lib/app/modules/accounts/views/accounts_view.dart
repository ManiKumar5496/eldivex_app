import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
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
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AccountsView extends GetView<AccountsController> {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    SizeConfig.init(context);

    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final isMobile = SizeConfig.isMobile;
    final h = isMobile ? 16.0 : 24.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(h, isMobile ? 16 : 24, h, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isMobile
              ? _buildMobileHeaderTop(context)
              : _buildDesktopHeaderTop(context),
          SizedBox(height: isMobile ? 16 : 20),
          _buildKpiStats(),
          SizedBox(height: isMobile ? 8 : 12),
          _buildTabBar(),
        ],
      ),
    );
  }

  // Mobile: title + period-close icon button on one line
  Widget _buildMobileHeaderTop(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AppPageHeader(title: 'Accounts')),
        const SizedBox(width: 8),
        _buildPeriodCloseButton(context),
      ],
    );
  }

  // Tablet/Desktop: title block with the period-close action on the right
  Widget _buildDesktopHeaderTop(BuildContext context) {
    return AppPageHeader(
      title: 'Accounts',
      subtitle: 'Billing, receipts, statements and revenue in one place',
      actions: [_buildPeriodCloseButton(context)],
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
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: tabLabels.map((l) => Tab(text: l)).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // KPI stats
  // ─────────────────────────────────────────────
  Widget _buildKpiStats() {
    final isMobile = SizeConfig.isMobile;

    // Phones scroll the tiles sideways so the tabs stay on screen.
    Widget layout(List<Widget> tiles) {
      if (!isMobile) {
        return AppResponsiveGrid(minItemWidth: 200, maxColumns: 4, children: tiles);
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < tiles.length; i++)
              Padding(
                padding: EdgeInsets.only(right: i < tiles.length - 1 ? 12 : 0),
                child: SizedBox(width: 200, child: tiles[i]),
              ),
          ],
        ),
      );
    }

    return Obx(() {
      if (controller.isLoadingKPIs.value) {
        return layout(List.generate(
          4,
          (_) => Container(
            height: 128,
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColor.borderSubtle),
            ),
          ),
        ));
      }
      return layout([
        AppStatCard(
          label: 'Total Outstanding',
          value: controller.formatCurrency(controller.totalOutstanding.value),
          caption: 'Unpaid invoice balance',
          tone: AppTone.warning,
          icon: LucideIcons.wallet,
        ),
        AppStatCard(
          label: 'Total Collected',
          value: controller.formatCurrency(controller.totalCollected.value),
          caption: 'Payments received',
          tone: AppTone.success,
          icon: LucideIcons.circleCheck,
        ),
        AppStatCard(
          label: 'Overdue',
          value: controller.formatCurrency(controller.overdueAmount.value),
          caption: '${controller.overdueCount.value} invoices',
          tone: AppTone.danger,
          icon: LucideIcons.triangleAlert,
        ),
        AppStatCard(
          label: 'Collection Rate',
          value: '${controller.collectionRate.value}%',
          caption: 'DSO: ${controller.dso.value} days',
          tone: AppTone.info,
          icon: LucideIcons.trendingUp,
        ),
      ]);
    });
  }

  // ─────────────────────────────────────────────
  // Period Close button
  // ─────────────────────────────────────────────
  Widget _buildPeriodCloseButton(BuildContext context) {
    final now = DateTime.now();
    return Obx(() {
      final isClosed = controller.isPeriodClosed(now.month, now.year);
      if (SizeConfig.isMobile) {
        return accountsToolbarIconButton(
          tooltip: isClosed
              ? 'Period ${now.month}/${now.year} is closed'
              : 'Close period ${now.month}/${now.year}',
          onPressed:
              isClosed ? null : () => _showPeriodCloseDialog(context),
          icon: isClosed ? LucideIcons.lock : LucideIcons.lockOpen,
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
            isClosed ? LucideIcons.lock : LucideIcons.lockOpen,
            size: 18,
          ),
          label: Text(isClosed ? 'Period closed' : 'Close period'),
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
        builder: (ctx, setState) => AppDialog(
          title: 'Close Financial Period',
          icon: LucideIcons.lockKeyhole,
          maxWidth: 440,
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.closePeriod(selectedMonth, selectedYear);
              },
              icon: const Icon(LucideIcons.lock, size: 18),
              label: const Text('Close period'),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.warningSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.triangleAlert,
                        color: AppColor.warning, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Closing a period locks all invoices and receipts '
                        'for that month. No backdated entries will be '
                        'allowed. This action cannot be undone.',
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppColor.textPrimary),
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
                        accountsFieldLabel('Month'),
                        accountsDropdownShell(
                          child: DropdownButton<int>(
                            icon: const Icon(LucideIcons.chevronDown, size: 18),
                            isExpanded: true,
                            value: selectedMonth,
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text(months[i],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.textPrimary)),
                              ),
                            ),
                            onChanged: (v) =>
                                setState(() => selectedMonth = v!),
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
                        accountsFieldLabel('Year'),
                        accountsDropdownShell(
                          child: DropdownButton<int>(
                            icon: const Icon(LucideIcons.chevronDown, size: 18),
                            isExpanded: true,
                            value: selectedYear,
                            items: [2025, 2026, 2027]
                                .map((y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.textPrimary)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedYear = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.closedPeriods.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Already closed:',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textTertiary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.closedPeriods.map((p) {
                        final m = p['period_month'];
                        final y = p['period_year'];
                        return AppStatusBadge(
                          label: '$m/$y',
                          tone: AppTone.neutral,
                          icon: LucideIcons.lock,
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tab 1: Active Booking Clients
  // ─────────────────────────────────────────────
  Widget _buildActiveClientsTab(BuildContext context) {
    final isMobile = SizeConfig.isMobile;
    final h = isMobile ? 16.0 : 24.0;
    final listBody = Obx(() {
      if (controller.isLoadingClients.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredClients.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.users,
          title: 'No active clients found',
          message: 'Try a different search or clear the filters.',
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileClientList(),
        tablet: _buildScrollableClientTable(),
        desktop: _buildScrollableClientTable(),
      );
    });

    if (isMobile) {
      return Padding(
        padding: EdgeInsets.fromLTRB(h, 16, h, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClientSearchBar(),
            Obx(() {
              if (controller.isFilterVisible.value) {
                return _buildClientFilters();
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 12),
            Expanded(child: listBody),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(h, 16, h, h),
      child: AppCard(
        expandChild: true,
        padding: EdgeInsets.zero,
        title: 'Active clients',
        actions: [
          _clientSearchField(width: 320),
          _filterToggleButton(),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.isFilterVisible.value) {
                return _buildClientFilters();
              }
              return const SizedBox.shrink();
            }),
            Expanded(child: listBody),
          ],
        ),
      ),
    );
  }

  Widget _clientSearchField({double? width}) {
    return AppSearchField(
      controller: controller.searchClientController,
      onChanged: controller.searchClients,
      hint: SizeConfig.isMobile
          ? 'Search clients…'
          : 'Search by client name, mobile, patient, booking ID…',
      width: width,
    );
  }

  Widget _filterToggleButton() {
    return Obx(() {
      final active = controller.isFilterVisible.value;
      if (SizeConfig.isMobile) {
        return accountsToolbarIconButton(
          icon: LucideIcons.listFilter,
          tooltip: 'Filters',
          onPressed: () => controller.isFilterVisible.toggle(),
        );
      }
      return OutlinedButton.icon(
        onPressed: () => controller.isFilterVisible.toggle(),
        style: active
            ? OutlinedButton.styleFrom(
                backgroundColor: AppColor.primarySoft,
                foregroundColor: AppColor.cAppPrimaryColor,
                side: BorderSide(
                    color: AppColor.cAppPrimaryColor.withValues(alpha: 0.4)),
              )
            : null,
        icon: const Icon(LucideIcons.listFilter, size: 18),
        label: const Text('Filters'),
      );
    });
  }

  /// Mobile toolbar: search + filter toggle.
  Widget _buildClientSearchBar() {
    return Row(
      children: [
        Expanded(child: _clientSearchField()),
        const SizedBox(width: 8),
        _filterToggleButton(),
      ],
    );
  }

  Widget _buildClientFilters() {
    if (SizeConfig.isMobile) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: _buildMobileFilters(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColor.surfaceMuted,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: _buildDesktopFilters(),
        ),
        Divider(height: 1, color: AppColor.borderSubtle),
      ],
    );
  }

  Widget _statusFilterField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        accountsFieldLabel('Status'),
        Obx(() => accountsDropdownShell(
              height: 48,
              child: DropdownButton<String>(
                icon: const Icon(LucideIcons.chevronDown, size: 18),
                isExpanded: true,
                value: controller.filterStatus.value.isEmpty
                    ? null
                    : controller.filterStatus.value,
                hint: Text('Select status',
                    style:
                        TextStyle(color: AppColor.textTertiary, fontSize: 14)),
                items: controller.statusOptions
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 14, color: AppColor.textPrimary))))
                    .toList(),
                onChanged: (v) => controller.filterStatus.value = v ?? '',
              ),
            )),
      ],
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
        const SizedBox(height: 16),
        CommonTextField(
          label: 'Client Name',
          hint: 'Enter client name',
          controller: controller.filterClientNameController,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          label: 'Mobile',
          hint: 'Enter mobile number',
          controller: controller.filterMobileController,
        ),
        const SizedBox(height: 16),
        _statusFilterField(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.clearFilters,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.applyClientFilters,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppResponsiveGrid(
          minItemWidth: 200,
          maxColumns: 4,
          spacing: 12,
          children: [
            CommonTextField(
              label: 'Booking ID',
              hint: 'Enter booking ID',
              controller: controller.filterBookingIdController,
            ),
            CommonTextField(
              label: 'Client Name',
              hint: 'Enter client name',
              controller: controller.filterClientNameController,
            ),
            CommonTextField(
              label: 'Mobile',
              hint: 'Enter mobile number',
              controller: controller.filterMobileController,
            ),
            _statusFilterField(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: controller.clearFilters,
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: controller.applyClientFilters,
              child: const Text('Apply'),
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
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: controller.filteredClients.length,
          itemBuilder: (_, i) =>
              _buildMobileClientCard(controller.filteredClients[i]),
        ));
  }

  Widget _buildMobileClientCard(ActiveBookingClient client) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Avatar + name/mobile | status + action menu
            Row(
              children: [
                AppAvatar(name: client.clientName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: accountsCellStack(client.clientName,
                      subtitle: client.clientMobile),
                ),
                _buildStatusChip(client.status),
                const SizedBox(width: 4),
                _buildClientActions(client),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 12, right: 8),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 2: Booking # + service name
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  AppStatusBadge(
                    label: '#${client.bookingId}',
                    tone: AppTone.primary,
                    showDot: false,
                    dense: true,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      client.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: AppColor.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Row 3: patient • city
            Text(
              '${client.patientName} • ${client.city}',
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, right: 8),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 4: Billed / Paid / Outstanding
            Row(
              children: [
                _mobileAmountLabel('Billed',
                    controller.formatCurrency(client.totalBilled),
                    AppColor.textPrimary),
                _mobileAmountLabel(
                    'Paid',
                    controller.formatCurrency(client.totalPaid),
                    AppColor.success),
                _mobileAmountLabel(
                    'Outstanding',
                    controller.formatCurrency(client.outstandingAmount),
                    client.outstandingAmount > 0
                        ? AppColor.danger
                        : AppColor.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileAmountLabel(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: accountsAmountStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tablet/Desktop: scrollable DataTable
  // ─────────────────────────────────────────────
  Widget _buildScrollableClientTable() {
    return Obx(() => SingleChildScrollView(
          child: horizontalTable(
            DataTable(
              columns: const [
                DataColumn(label: Text('Booking ID')),
                DataColumn(label: Text('Client Name')),
                DataColumn(label: Text('Patient')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('Billed'), numeric: true),
                DataColumn(label: Text('Paid'), numeric: true),
                DataColumn(label: Text('Outstanding'), numeric: true),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.filteredClients.map((client) {
                return DataRow(cells: [
                  DataCell(Text('#${client.bookingId}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.cPrimaryButtonColor))),
                  DataCell(accountsCellStack(client.clientName,
                      subtitle: client.clientMobile)),
                  DataCell(Text(client.patientName)),
                  DataCell(accountsCellStack(client.serviceName,
                      subtitle: client.serviceTypeName,
                      titleWeight: FontWeight.w400)),
                  DataCell(Text(client.city,
                      style: TextStyle(color: AppColor.textSecondary))),
                  DataCell(Text(
                      controller.formatCurrency(client.totalBilled),
                      style: accountsAmountStyle(fontWeight: FontWeight.w400))),
                  DataCell(Text(
                      controller.formatCurrency(client.totalPaid),
                      style: accountsAmountStyle(
                          color: AppColor.success,
                          fontWeight: FontWeight.w400))),
                  DataCell(Text(
                    controller.formatCurrency(client.outstandingAmount),
                    style: accountsAmountStyle(
                      color: client.outstandingAmount > 0
                          ? AppColor.danger
                          : AppColor.success,
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

  Widget _buildStatusChip(String status) => accountsStatusChip(status);

  Widget _buildClientActions(ActiveBookingClient client) {
    return Builder(builder: (ctx) => _clientActionsMenu(ctx, client));
  }

  /// Switches to [index] in the surrounding AccountsView tab bar. Returns
  /// false when the widget is not hosted inside the tabs.
  bool _goToTab(BuildContext ctx, int index) {
    final tabs = DefaultTabController.maybeOf(ctx);
    if (tabs == null) return false;
    tabs.animateTo(index);
    return true;
  }

  Widget _clientActionsMenu(BuildContext ctx, ActiveBookingClient client) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: Icon(LucideIcons.ellipsis,
          color: AppColor.textTertiary, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'receipt':
            if (!_goToTab(ctx, 2)) return;
            controller.selectInvoiceForBooking(client.bookingId);
            ManageRecieptsView.openRecordSheet(ctx,
                invoice: controller.selectedInvoiceForPayment.value);
            break;
          case 'statement':
            controller.viewStatementForClient(client);
            _goToTab(ctx, 3);
            break;
          case 'writeoff':
            controller.selectClientForWriteOff(client);
            _goToTab(ctx, 4);
            break;
          case 'claim':
            controller.selectedClientForClaim.value = client;
            _goToTab(ctx, 6);
            break;
        }
      },
      itemBuilder: (context) {
        final isCancelled = client.status == 'Cancelled';
        Widget item(IconData icon, String label, {bool enabled = true}) {
          final color = enabled ? null : AppColor.lightGrey;
          return Row(
            children: [
              Icon(icon,
                  size: 18, color: color ?? AppColor.textSecondary),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: color)),
            ],
          );
        }

        return [
          PopupMenuItem(
            value: 'receipt',
            enabled: !isCancelled,
            child: item(LucideIcons.receiptText, 'Raise Receipt',
                enabled: !isCancelled),
          ),
          PopupMenuItem(
            value: 'statement',
            child: item(LucideIcons.wallet,
                'View Statement'),
          ),
          PopupMenuItem(
            value: 'writeoff',
            enabled: !isCancelled,
            child: item(LucideIcons.banknoteX, 'Write-Off',
                enabled: !isCancelled),
          ),
          PopupMenuItem(
            value: 'claim',
            child: item(LucideIcons.heartPulse, 'Insurance Claim'),
          ),
        ];
      },
    );
  }
}
