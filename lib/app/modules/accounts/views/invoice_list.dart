import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../controllers/accounts_controller.dart';
import '../models/invoice_model.dart';
import '../models/provisional_receipt_model.dart';
import '../models/parse_utils.dart';
import 'accounts_format.dart';
import 'manage_reciepts.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    // AccountsBinding is tied to a named route and never fires when this view
    // is embedded directly in the side-menu pages list — so we must ensure the
    // controller exists before calling find().
    final ctrl = Get.isRegistered<AccountsController>()
        ? Get.find<AccountsController>()
        : Get.put(AccountsController());
    SizeConfig.init(context);
    final embedded = accountsIsEmbeddedInTabs(context);
    final isMobile = SizeConfig.isMobile;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: accountsPagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (embedded)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildBulkButton(ctrl),
                ),
              )
            else ...[
              AppPageHeader(
                title: 'Invoices',
                subtitle: 'Bill clients, track balances and collect payments',
                actions: [_buildBulkButton(ctrl)],
              ),
              SizedBox(height: isMobile ? 16 : 24),
            ],
            _buildHeader(ctrl),
            const SizedBox(height: 16),
            _buildAgingPanel(ctrl),
            if (isMobile) ...[
              _buildSearchBar(ctrl),
              const SizedBox(height: 12),
              _buildInvoiceBody(ctrl, context),
            ] else
              AppCard(
                padding: EdgeInsets.zero,
                title: 'All invoices',
                actions: [
                  _searchField(ctrl, width: 280),
                  Obx(() => _buildStatusChipRow(ctrl)),
                  accountsToolbarIconButton(
                    icon: LucideIcons.refreshCw,
                    tooltip: 'Refresh',
                    onPressed: ctrl.fetchInvoices,
                  ),
                ],
                child: _buildInvoiceBody(ctrl, context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceBody(AccountsController ctrl, BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingInvoices.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 56),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (ctrl.filteredInvoices.isEmpty) {
        return AppEmptyState(
          icon: LucideIcons.receiptText,
          title: 'No invoices found',
          message: 'Try a different search or status filter.',
          actionLabel: 'Refresh',
          actionIcon: LucideIcons.refreshCw,
          onAction: ctrl.fetchInvoices,
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildInvoiceCards(ctrl, context),
        tablet: _buildInvoiceTable(ctrl, context),
        desktop: _buildInvoiceTable(ctrl, context),
      );
    });
  }

  Widget _buildBulkButton(AccountsController ctrl) {
    return Obx(() => ElevatedButton.icon(
          onPressed: ctrl.isBulkGenerating.value
              ? null
              : () => _showBulkGenerateDialog(ctrl),
          icon: ctrl.isBulkGenerating.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColor.textTertiary),
                )
              : const Icon(LucideIcons.sparkles, size: 18),
          label: const Text('Generate invoices'),
        ));
  }

  // ─────────────────────────────────────────────
  // KPI Summary
  // ─────────────────────────────────────────────
  Widget _buildHeader(AccountsController ctrl) {
    final currencyFormat = inrFormat;
    final isMobile = SizeConfig.isMobile;
    return Obx(() => AppResponsiveGrid(
          minItemWidth: isMobile ? 150 : 200,
          maxColumns: 4,
          spacing: isMobile ? 12 : 16,
          children: [
            AppStatCard(
              label: 'Total invoiced',
              value: currencyFormat.format(ctrl.totalBilled.value),
              icon: LucideIcons.receiptText,
              tone: AppTone.info,
            ),
            AppStatCard(
              label: 'Collected',
              value: currencyFormat.format(ctrl.totalCollected.value),
              icon: LucideIcons.banknote,
              tone: AppTone.success,
            ),
            AppStatCard(
              label: 'Outstanding',
              value: currencyFormat.format(ctrl.totalOutstanding.value),
              icon: LucideIcons.wallet,
              tone: AppTone.warning,
            ),
            AppStatCard(
              label: 'Overdue',
              value: '${ctrl.overdueCount.value}',
              caption: 'invoices past due',
              icon: LucideIcons.triangleAlert,
              tone: AppTone.danger,
            ),
          ],
        ));
  }

  // ─────────────────────────────────────────────
  // Search Bar / toolbar
  // ─────────────────────────────────────────────
  Widget _searchField(AccountsController ctrl, {double? width}) {
    return AppSearchField(
      controller: ctrl.searchInvoiceController,
      onChanged: ctrl.searchInvoices,
      hint: 'Search by invoice ID, client name, booking ID…',
      width: width,
    );
  }

  /// Mobile toolbar: search + refresh, with the status filter underneath.
  Widget _buildSearchBar(AccountsController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _searchField(ctrl)),
            const SizedBox(width: 8),
            accountsToolbarIconButton(
              icon: LucideIcons.refreshCw,
              tooltip: 'Refresh',
              onPressed: ctrl.fetchInvoices,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Status filter
        Obx(() => _buildStatusChipRow(ctrl)),
      ],
    );
  }

  Widget _buildStatusChipRow(AccountsController ctrl) {
    final statuses = ['', 'Pending', 'Paid', 'Partially Paid', 'Overdue'];
    // Read the observable value here — synchronously inside the Obx closure —
    // so GetX tracks it. Callbacks below are lazy and .value reads there
    // are outside the Obx tracking context, which triggers the "improper use" error.
    final currentFilter = ctrl.invoiceStatusFilter.value;
    final segRadius = BorderRadius.circular(AppRadius.sm);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColor.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) {
            final label = s.isEmpty ? 'All' : s;
            final selected = currentFilter == s;
            return Container(
              decoration: BoxDecoration(
                color: selected ? AppColor.whiteColor : Colors.transparent,
                borderRadius: segRadius,
                boxShadow: selected ? AppShadows.card : null,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: segRadius,
                  onTap: () {
                    // Filter the loaded list — the full list also feeds
                    // the record-receipt sheet.
                    ctrl.invoiceStatusFilter.value = s;
                    ctrl.searchInvoices(ctrl.searchInvoiceController.text);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? AppColor.textPrimary
                              : AppColor.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AR Aging Panel
  // ─────────────────────────────────────────────
  Widget _buildAgingPanel(AccountsController ctrl) {
    return Obx(() {
      if (ctrl.isLoadingAging.value) return const SizedBox.shrink();
      if (ctrl.agingBuckets.isEmpty) return const SizedBox.shrink();

      // Colour by bucket (severity increases left→right). The backend labels
      // are 'Current (Not Due)', '1–30 Days' (en dash) … '90+ Days'.
      Color bucketColor(String label) {
        final l = label.replaceAll('–', '-').toLowerCase();
        if (l.startsWith('current')) return AppColor.success;
        if (l.startsWith('1-30')) return AppColor.info;
        if (l.startsWith('31-60')) return AppColor.warning;
        if (l.startsWith('61-90')) return AppColor.danger.withValues(alpha: 0.7);
        if (l.startsWith('90')) return AppColor.danger;
        return AppColor.textTertiary;
      }
      final fmt = NumberFormat.compactCurrency(
        locale: 'en_IN',
        symbol: '₹',
      );

      final buckets = ctrl.agingBuckets
          .map((bucket) => _AgingBucket(
                label: toStr(bucket['label']),
                count: toInt(bucket['count']),
                amount: toDouble(bucket['amount']),
              ))
          .toList();
      final total = buckets.fold<double>(
          0, (sum, b) => sum + (b.amount > 0 ? b.amount : 0));

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AppCard(
          title: 'AR aging',
          subtitle: 'Outstanding balance by days overdue',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (total > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        for (final b in buckets)
                          if (b.amount > 0)
                            Expanded(
                              flex: ((b.amount / total) * 1000)
                                  .round()
                                  .clamp(1, 1000),
                              child: Container(
                                margin: const EdgeInsets.only(right: 2),
                                color: bucketColor(b.label),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppResponsiveGrid(
                minItemWidth: 130,
                maxColumns: 5,
                spacing: 12,
                children: buckets.map((b) {
                  final color = bucketColor(b.label);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              b.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt.format(b.amount),
                          style: accountsAmountStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b.count} invoice${b.count == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Desktop / Tablet Table
  // ─────────────────────────────────────────────
  Widget _buildInvoiceTable(AccountsController ctrl, BuildContext context) {
    final currFmt = inrFormat;
    // No Obx here — this method is called as an adaptiveLayout argument inside
    // the outer Obx in _buildInvoiceBody(), so reactive reads are tracked there.
    return horizontalTable(
      DataTable(
        columns: [
          const DataColumn(label: Text('Invoice')),
          const DataColumn(label: Text('Client')),
          if (!SizeConfig.isTablet)
            const DataColumn(label: Text('Service / Period')),
          const DataColumn(label: Text('Amount'), numeric: true),
          const DataColumn(label: Text('Paid'), numeric: true),
          const DataColumn(label: Text('Balance'), numeric: true),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: ctrl.filteredInvoices.map((inv) {
          return DataRow(
            cells: [
              DataCell(
                accountsCellStack(
                  inv.invoiceId,
                  subtitle: 'Bkg #${inv.bookingId}',
                  titleColor: AppColor.cPrimaryButtonColor,
                ),
              ),
              DataCell(
                accountsCellStack(inv.clientName, subtitle: inv.patientName),
              ),
              if (!SizeConfig.isTablet)
                DataCell(
                  accountsCellStack(
                    inv.serviceName ?? '—',
                    subtitle: '${inv.periodFrom} → ${inv.periodTo}',
                    titleWeight: FontWeight.w400,
                  ),
                ),
              DataCell(
                Text(
                  currFmt.format(inv.totalAmount),
                  style: accountsAmountStyle(),
                ),
              ),
              DataCell(
                Text(
                  currFmt.format(inv.paidAmount),
                  style: accountsAmountStyle(
                    color: AppColor.success,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DataCell(
                Text(
                  currFmt.format(inv.balanceDue),
                  style: accountsAmountStyle(
                    color: inv.balanceDue > 0
                        ? AppColor.danger
                        : AppColor.success,
                  ),
                ),
              ),
              DataCell(_statusChip(inv.status)),
              DataCell(_actionsMenu(inv, ctrl, context)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Mobile Cards
  // ─────────────────────────────────────────────
  Widget _buildInvoiceCards(AccountsController ctrl, BuildContext context) {
    final currFmt = inrFormat;
    // No Obx here — called as an adaptiveLayout argument inside the outer Obx.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final inv in ctrl.filteredInvoices)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _invoiceCard(inv, ctrl, currFmt, context),
          ),
      ],
    );
  }

  Widget _invoiceCard(
    InvoiceModel inv,
    AccountsController ctrl,
    NumberFormat fmt,
    BuildContext context,
  ) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: accountsCellStack(
                  inv.invoiceId,
                  subtitle: 'Booking #${inv.bookingId}',
                  titleColor: AppColor.cPrimaryButtonColor,
                ),
              ),
              _statusChip(inv.status),
              const SizedBox(width: 4),
              _actionsMenu(inv, ctrl, context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 12, right: 8),
            child: Divider(height: 1, color: AppColor.borderSubtle),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 16,
                      color: AppColor.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        inv.clientName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.stethoscope,
                      size: 16,
                      color: AppColor.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        inv.serviceName ?? '—',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.calendarRange,
                          size: 16,
                          color: AppColor.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${inv.periodFrom} → ${inv.periodTo}',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColor.textTertiary),
                        ),
                      ],
                    ),
                    if (inv.dueDate != null)
                      Text(
                        'Due: ${inv.dueDate}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: inv.status == 'Overdue'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: inv.status == 'Overdue'
                              ? AppColor.danger
                              : AppColor.textTertiary,
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColor.borderSubtle),
                ),
                Row(
                  children: [
                    _amountItem(
                        'Total', inv.totalAmount, AppColor.textPrimary, fmt),
                    _amountItem('Paid', inv.paidAmount, AppColor.success, fmt),
                    _amountItem(
                      'Balance',
                      inv.balanceDue,
                      inv.balanceDue > 0 ? AppColor.danger : AppColor.success,
                      fmt,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountItem(
    String label,
    double amount,
    Color color,
    NumberFormat fmt,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              fmt.format(amount),
              maxLines: 1,
              style: accountsAmountStyle(color: color, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared Widgets
  // ─────────────────────────────────────────────
  Widget _statusChip(String status) => accountsStatusChip(status);

  /// Opens the record-payment sheet for [inv]. Inside AccountsView it also
  /// switches to the receipts tab; in the side-menu shell (no tab bar) the
  /// sheet opens in place.
  void _raiseReceipt(InvoiceModel inv, BuildContext context) {
    DefaultTabController.maybeOf(context)?.animateTo(2);
    ManageRecieptsView.openRecordSheet(context, invoice: inv);
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.textSecondary),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _actionsMenu(InvoiceModel inv, AccountsController ctrl, BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: Icon(LucideIcons.ellipsis, color: AppColor.textTertiary, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _showInvoiceDetail(inv, ctrl, context);
            break;
          case 'raise_receipt':
            _raiseReceipt(inv, context);
            break;
          case 'payment_link':
            ctrl.sendPaymentLink(inv);
            break;
          case 'copy_link':
            Clipboard.setData(
              ClipboardData(
                text: 'Invoice ${inv.invoiceId} — Amount: ₹${inv.totalAmount}',
              ),
            );
            Get.snackbar(
              'Copied',
              'Invoice info copied',
              snackPosition: SnackPosition.BOTTOM,
            );
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('view', LucideIcons.eye, 'View Details'),
        if (inv.balanceDue > 0)
          _menuItem('raise_receipt', LucideIcons.receiptText, 'Raise Receipt'),
        if (inv.balanceDue > 0)
          _menuItem('payment_link', LucideIcons.link, 'Send Payment Link'),
        _menuItem('copy_link', LucideIcons.copy, 'Copy Invoice Info'),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Invoice Detail Dialog — Clean, Amount Only
  // ─────────────────────────────────────────────
  void _showInvoiceDetail(InvoiceModel inv, AccountsController ctrl, BuildContext tabContext) {
    final currFmt = inrFormat;
    Get.dialog(
      AppDialog(
        title: 'Invoice details',
        subtitle: inv.invoiceId,
        icon: LucideIcons.receiptText,
        maxWidth: 620,
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (inv.balanceDue > 0)
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _raiseReceipt(inv, tabContext);
              },
              icon: const Icon(LucideIcons.receiptText, size: 18),
              label: const Text('Raise receipt'),
            ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusChip(inv.status),
            const SizedBox(height: 20),

            // ── Client Info ──
            _detailSection('Client Information', [
              _detailRow('Client Name', inv.clientName),
              _detailRow('Mobile', inv.clientMobile),
              _detailRow('Patient', inv.patientName),
            ]),
            _sectionDivider(),

            // ── Service Info ──
            _detailSection('Service Details', [
              _detailRow('Booking ID', '#${inv.bookingId}'),
              _detailRow('Service', inv.serviceName ?? '—'),
              _detailRow('Branch', inv.branchName ?? '—'),
              _detailRow('Period From', inv.periodFrom),
              _detailRow('Period To', inv.periodTo),
              _detailRow('Service Days', '${inv.totalDays} days'),
              _detailRow('Rate / Day', currFmt.format(inv.dailyRate)),
            ]),
            _sectionDivider(),

            // ── Billing — Amount Only, No Tax ──
            _detailSection('Billing Summary', [
              if (inv.invoiceDate != null)
                _detailRow('Invoice Date', inv.invoiceDate!),
              if (inv.dueDate != null)
                _detailRow(
                  'Due Date',
                  inv.dueDate!,
                  valueColor:
                      inv.status == 'Overdue' ? AppColor.danger : null,
                ),
              Divider(height: 16, color: AppColor.borderSubtle),
              _detailRow(
                'Invoice Amount',
                '${inv.totalDays} days × ${currFmt.format(inv.dailyRate)} = ${currFmt.format(inv.totalAmount)}',
                isBold: true,
              ),
              _detailRow(
                'Paid Amount',
                currFmt.format(inv.paidAmount),
                valueColor: AppColor.success,
              ),
              _detailRow(
                'Balance Due',
                currFmt.format(inv.balanceDue),
                valueColor:
                    inv.balanceDue > 0 ? AppColor.danger : AppColor.success,
                isBold: true,
              ),
            ]),
            _sectionDivider(),

            // ── Linked Receipts (payments made against this invoice) ──
            _detailSection('Linked Receipts', []),
            Obx(() {
              final linked = ctrl.receipts
                  .where((r) => r.bookingId == inv.bookingId)
                  .toList();
              if (linked.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No receipts recorded yet',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.textTertiary,
                    ),
                  ),
                );
              }
              return Column(
                children: linked
                    .map((r) => _linkedReceiptRow(r, currFmt))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _sectionDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, color: AppColor.borderSubtle),
      );

  Widget _linkedReceiptRow(ProvisionalReceipt r, NumberFormat fmt) {
    final statusTone = r.status == 'Approved'
        ? AppTone.success
        : r.status == 'Cancelled'
            ? AppTone.danger
            : AppTone.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.receiptNumber,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.paymentMode}  •  ${formatAccDate(r.receiptDate, pattern: 'yyyy-MM-dd')}',
                  style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            fmt.format(r.totalAmount),
            style: accountsAmountStyle(),
          ),
          const SizedBox(width: 10),
          AppStatusBadge(label: r.status, tone: statusTone, dense: true),
        ],
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.5, color: AppColor.textTertiary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: valueColor ?? AppColor.textPrimary,
                fontFeatures: accountsTabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Bulk Generate Dialog
  // ─────────────────────────────────────────────
  void _showBulkGenerateDialog(AccountsController ctrl) {
    final now = DateTime.now();
    int month = now.month;
    int year = now.year;
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    Get.dialog(
      AppDialog(
        title: 'Generate monthly invoices',
        icon: LucideIcons.sparkles,
        maxWidth: 440,
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.bulkGenerateInvoices(month: month, year: year);
            },
            child: const Text('Generate'),
          ),
        ],
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will generate invoices for all active bookings that don\'t yet have an invoice for the selected month.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        initialValue: month,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                        ),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(months[i]),
                          ),
                        ),
                        onChanged: (v) => setState(() => month = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        initialValue: year,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                        ),
                        items: [now.year - 1, now.year, now.year + 1]
                            .map(
                              (y) => DropdownMenuItem(
                                value: y,
                                child: Text('$y'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => year = v!),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AgingBucket {
  const _AgingBucket({
    required this.label,
    required this.count,
    required this.amount,
  });
  final String label;
  final int count;
  final double amount;
}
