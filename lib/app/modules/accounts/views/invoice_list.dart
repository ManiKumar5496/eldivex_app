import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../controllers/accounts_controller.dart';
import '../models/invoice_model.dart';
import '../models/provisional_receipt_model.dart';

class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    // AccountsBinding is tied to a named route and never fires when this view
    // is embedded directly in the side-menu pages list — so we must ensure the
    // controller exists before calling find().
    Get.put(AccountsController());
    final ctrl = Get.isRegistered<AccountsController>()
        ? Get.find<AccountsController>()
        : Get.put(AccountsController());
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(ctrl),
          _buildSearchBar(ctrl),
          _buildAgingPanel(ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingInvoices.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.filteredInvoices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No invoices found',
                        style: AppTextStyles.regular16Gre,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: ctrl.fetchInvoices,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizeConfig.adaptiveLayout(
                mobile: _buildInvoiceCards(ctrl, context),
                tablet: _buildInvoiceTable(ctrl, context),
                desktop: _buildInvoiceTable(ctrl, context),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header with KPI Summary + Actions
  // ─────────────────────────────────────────────
  Widget _buildHeader(AccountsController ctrl) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    // Single Obx wraps the entire header — no nested Obx inside adaptiveLayout
    // arguments (they are eagerly evaluated and both Obx instances would be
    // created, but only one mounts, causing the GetX "improper use" error).
    return Obx(() {
      final bulkButton = ElevatedButton.icon(
        onPressed: ctrl.isBulkGenerating.value
            ? null
            : () => _showBulkGenerateDialog(ctrl),
        icon: ctrl.isBulkGenerating.value
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(Icons.auto_awesome, size: SizeConfig.iconSM),
        label: Text(
          SizeConfig.isMobile ? '' : 'Generate Invoices',
          style: TextStyle(fontSize: SizeConfig.fontBody),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.cPrimaryButtonColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingMD, vertical: 12),
        ),
      );

      return Container(
        padding: EdgeInsets.fromLTRB(
          SizeConfig.spacingLG,
          SizeConfig.spacingMD,
          SizeConfig.spacingLG,
          SizeConfig.spacingMD,
        ),
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
        child: SizeConfig.adaptiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoices', style: AppTextStyles.heading),
                  bulkButton,
                ],
              ),
              SizedBox(height: SizeConfig.spacingSM),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _kpiCard('Total Invoiced',
                        currencyFormat.format(ctrl.totalBilled.value),
                        Colors.blue),
                    const SizedBox(width: 10),
                    _kpiCard('Collected',
                        currencyFormat.format(ctrl.totalCollected.value),
                        Colors.green),
                    const SizedBox(width: 10),
                    _kpiCard('Outstanding',
                        currencyFormat.format(ctrl.totalOutstanding.value),
                        Colors.orange),
                    const SizedBox(width: 10),
                    _kpiCard('Overdue',
                        '${ctrl.overdueCount.value} invoices', Colors.red),
                  ],
                ),
              ),
            ],
          ),
          tablet: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoices', style: AppTextStyles.heading),
              Row(
                children: [
                  _kpiCard('Total Invoiced',
                      currencyFormat.format(ctrl.totalBilled.value),
                      Colors.blue),
                  const SizedBox(width: 12),
                  _kpiCard('Collected',
                      currencyFormat.format(ctrl.totalCollected.value),
                      Colors.green),
                  const SizedBox(width: 12),
                  _kpiCard('Outstanding',
                      currencyFormat.format(ctrl.totalOutstanding.value),
                      Colors.orange),
                  const SizedBox(width: 12),
                  _kpiCard('Overdue', '${ctrl.overdueCount.value}',
                      Colors.red),
                  const SizedBox(width: 16),
                  bulkButton,
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.fontCaption,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: SizeConfig.spacingXS),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeConfig.fontH3,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Search Bar
  // ─────────────────────────────────────────────
  Widget _buildSearchBar(AccountsController ctrl) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.spacingMD),
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
                controller: ctrl.searchInvoiceController,
                onChanged: ctrl.searchInvoices,
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: 'Search by invoice ID, client name, booking ID…',
                  hintStyle: TextStyle(
                    color: AppColor.fontColorGrey,
                    fontSize: SizeConfig.fontBody,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.fontColorGrey,
                    size: SizeConfig.iconSM,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.spacingSM),
          // Status filter
          Obx(() => _buildStatusChipRow(ctrl)),
          SizedBox(width: SizeConfig.spacingSM),
          // Refresh
          InkWell(
            onTap: ctrl.fetchInvoices,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: Icon(
                Icons.refresh,
                color: AppColor.cPrimaryButtonColor,
                size: SizeConfig.iconSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChipRow(AccountsController ctrl) {
    final statuses = ['', 'Pending', 'Paid', 'Partially Paid', 'Overdue'];
    // Read the observable value here — synchronously inside the Obx closure —
    // so GetX tracks it. itemBuilder is a lazy callback and .value reads there
    // are outside the Obx tracking context, which triggers the "improper use" error.
    final currentFilter = ctrl.invoiceStatusFilter.value;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final s = statuses[i];
          final label = s.isEmpty ? 'All' : s;
          final selected = currentFilter == s;
          return GestureDetector(
            onTap: () {
              ctrl.invoiceStatusFilter.value = s;
              ctrl.fetchInvoices(status: s.isEmpty ? null : s);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColor.cPrimaryButtonColor
                    : AppColor.whiteColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.textFieldBorderColor,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColor.fontColorGrey,
                ),
              ),
            ),
          );
        },
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

      // Bucket display config: label → colour
      final bucketColors = {
        'Current': Colors.green,
        '1-30': Colors.lime.shade700,
        '31-60': Colors.orange,
        '61-90': Colors.deepOrange,
        '90+': Colors.red,
      };

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'AR Aging',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(days overdue)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ctrl.agingBuckets.map((bucket) {
                  final label = bucket['label'] as String? ?? '';
                  final count = bucket['count'] ?? 0;
                  final amount = (bucket['amount'] ?? 0).toDouble();
                  final color = bucketColors[label] ?? Colors.grey;
                  final fmt = NumberFormat.compactCurrency(
                    locale: 'en_IN',
                    symbol: '₹',
                  );
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fmt.format(amount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          '$count invoice${count == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Desktop / Tablet Table
  // ─────────────────────────────────────────────
  Widget _buildInvoiceTable(AccountsController ctrl, BuildContext context) {
    final currFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    // No Obx here — this method is called as an adaptiveLayout argument inside
    // the outer Obx in build(), so reactive reads are tracked there.
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.spacingMD),
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
              fontSize: SizeConfig.fontBodySmall,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
            columnSpacing: SizeConfig.responsive(
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            horizontalMargin: SizeConfig.spacingMD,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          inv.invoiceId,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.fontBodySmall,
                            color: AppColor.cPrimaryButtonColor,
                          ),
                        ),
                        Text(
                          'Bkg #${inv.bookingId}',
                          style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          inv.clientName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.fontBodySmall,
                          ),
                        ),
                        Text(
                          inv.patientName,
                          style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!SizeConfig.isTablet)
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            inv.serviceName ?? '—',
                            style: TextStyle(
                              fontSize: SizeConfig.fontBodySmall,
                            ),
                          ),
                          Text(
                            '${inv.periodFrom} → ${inv.periodTo}',
                            style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
                              color: AppColor.fontColorGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  DataCell(
                    Text(
                      currFmt.format(inv.totalAmount),
                      style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currFmt.format(inv.paidAmount),
                      style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currFmt.format(inv.balanceDue),
                      style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        fontWeight: FontWeight.w600,
                        color: inv.balanceDue > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  DataCell(_statusChip(inv.status)),
                  DataCell(_actionsMenu(inv, ctrl, context)),
                ],
              );
            }).toList(),
          ),
        ),
    );
  }

  // ─────────────────────────────────────────────
  // Mobile Cards
  // ─────────────────────────────────────────────
  Widget _buildInvoiceCards(AccountsController ctrl, BuildContext context) {
    final currFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    // No Obx here — called as an adaptiveLayout argument inside the outer Obx.
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingXS,
      ),
      itemCount: ctrl.filteredInvoices.length,
      itemBuilder: (_, i) {
        final inv = ctrl.filteredInvoices[i];
        return _invoiceCard(inv, ctrl, currFmt, context);
      },
    );
  }

  Widget _invoiceCard(
    InvoiceModel inv,
    AccountsController ctrl,
    NumberFormat fmt,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inv.invoiceId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColor.cPrimaryButtonColor,
                    ),
                  ),
                  Text(
                    'Booking #${inv.bookingId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.fontColorGrey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _statusChip(inv.status),
                  const SizedBox(width: 4),
                  _actionsMenu(inv, ctrl, context),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColor.fontColorGrey,
              ),
              const SizedBox(width: 6),
              Text(
                inv.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: AppColor.fontColorGrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  inv.serviceName ?? '—',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.cPrimarySubHeadingColorGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 16,
                color: AppColor.fontColorGrey,
              ),
              const SizedBox(width: 6),
              Text(
                '${inv.periodFrom} → ${inv.periodTo}',
                style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
              ),
              if (inv.dueDate != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Due: ${inv.dueDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: inv.status == 'Overdue'
                        ? Colors.red
                        : AppColor.fontColorGrey,
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountItem('Total', inv.totalAmount, Colors.black87, fmt),
              _amountItem('Paid', inv.paidAmount, Colors.green, fmt),
              _amountItem(
                'Balance',
                inv.balanceDue,
                inv.balanceDue > 0 ? Colors.red : Colors.green,
                fmt,
              ),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          fmt.format(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Shared Widgets
  // ─────────────────────────────────────────────
  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid':
        return Colors.green;
      case 'Partially Paid':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _actionsMenu(InvoiceModel inv, AccountsController ctrl, BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColor.fontColorGrey, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _showInvoiceDetail(inv, ctrl, context);
            break;
          case 'raise_receipt':
            final client = ctrl.activeClients.firstWhereOrNull(
              (c) => c.bookingId == inv.bookingId,
            );
            if (client != null) {
              ctrl.selectClientForReceipt(client);
            }
            DefaultTabController.of(context).animateTo(2);
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
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        if (inv.balanceDue > 0)
          const PopupMenuItem(
            value: 'raise_receipt',
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: 18, color: Colors.teal),
                SizedBox(width: 8),
                Text('Raise Receipt'),
              ],
            ),
          ),
        if (inv.balanceDue > 0)
          const PopupMenuItem(
            value: 'payment_link',
            child: Row(
              children: [
                Icon(Icons.link, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('Send Payment Link'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'copy_link',
          child: Row(
            children: [
              Icon(Icons.copy_outlined, size: 18, color: Colors.purple),
              SizedBox(width: 8),
              Text('Copy Invoice Info'),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Invoice Detail Dialog — Clean, Amount Only
  // ─────────────────────────────────────────────
  void _showInvoiceDetail(InvoiceModel inv, AccountsController ctrl, BuildContext tabContext) {
    final currFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: SizeConfig.responsive(
            mobile: 340.0,
            tablet: 520.0,
            desktop: 620.0,
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Details',
                          style: AppTextStyles.semiBold18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inv.invoiceId,
                          style: TextStyle(
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    _statusChip(inv.status),
                  ],
                ),
                const Divider(height: 28),

                // ── Client Info ──
                _detailSection('Client Information', [
                  _detailRow('Client Name', inv.clientName),
                  _detailRow('Mobile', inv.clientMobile),
                  _detailRow('Patient', inv.patientName),
                ]),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                // ── Billing — Amount Only, No Tax ──
                _detailSection('Billing Summary', [
                  if (inv.invoiceDate != null)
                    _detailRow('Invoice Date', inv.invoiceDate!),
                  if (inv.dueDate != null)
                    _detailRow(
                      'Due Date',
                      inv.dueDate!,
                      valueColor: inv.status == 'Overdue' ? Colors.red : null,
                    ),
                  const Divider(height: 16),
                  _detailRow(
                    'Invoice Amount',
                    '${inv.totalDays} days × ${currFmt.format(inv.dailyRate)} = ${currFmt.format(inv.totalAmount)}',
                    isBold: true,
                  ),
                  _detailRow(
                    'Paid Amount',
                    currFmt.format(inv.paidAmount),
                    valueColor: Colors.green,
                  ),
                  _detailRow(
                    'Balance Due',
                    currFmt.format(inv.balanceDue),
                    valueColor: inv.balanceDue > 0 ? Colors.red : Colors.green,
                    isBold: true,
                  ),
                ]),
                const SizedBox(height: 16),

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
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
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

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (inv.balanceDue > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          final client = ctrl.activeClients.firstWhereOrNull(
                            (c) => c.bookingId == inv.bookingId,
                          );
                          if (client != null) {
                            ctrl.selectClientForReceipt(client);
                          }
                          DefaultTabController.of(tabContext).animateTo(2);
                        },
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Raise Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    if (inv.balanceDue > 0) const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkedReceiptRow(ProvisionalReceipt r, NumberFormat fmt) {
    final statusColor = r.status == 'Approved'
        ? Colors.green
        : r.status == 'Cancelled'
            ? Colors.red
            : Colors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.receiptNumber,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColor.cPrimaryButtonColor,
                ),
              ),
              Text(
                '${r.paymentMode}  •  ${r.receiptDate.toLocal().toString().substring(0, 10)}',
                style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                fmt.format(r.totalAmount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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
            color: AppColor.cPrimaryHeadingColor,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColor.cPrimaryHeadingColor,
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Monthly Invoices',
                    style: AppTextStyles.semiBold18,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will generate invoices for all active bookings that don\'t yet have an invoice for the selected month.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.fontColorGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: month,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(),
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
                          initialValue: year,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                          items: [2025, 2026, 2027]
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          ctrl.bulkGenerateInvoices(month: month, year: year);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
