import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/invoice_model.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageRecieptsView extends GetView<AccountsController> {
  const ManageRecieptsView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) Get.put(AccountsController());
    final embedded = accountsIsEmbeddedInTabs(context);
    final isMobile = SizeConfig.isMobile;

    final recordButton = ElevatedButton.icon(
      onPressed: () => _showRecordReceiptSheet(context),
      icon: const Icon(LucideIcons.plus, size: 18),
      label: const Text('Record receipt'),
    );

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _showRecordReceiptSheet(context),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Record',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
      body: Padding(
        padding: accountsPagePadding(context, bottom: !isMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!embedded) ...[
              AppPageHeader(
                title: 'Receipts',
                subtitle: 'Provisional receipts recorded against client invoices',
                actions: isMobile ? const [] : [recordButton],
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
            if (isMobile) ...[
              _buildReceiptSearchBar(),
              const SizedBox(height: 12),
              Expanded(child: _buildReceiptsList(context)),
            ] else
              Expanded(
                child: AppCard(
                  expandChild: true,
                  padding: EdgeInsets.zero,
                  title: 'Provisional receipts',
                  actions: [
                    _buildReceiptSearchBar(width: 320),
                    if (embedded) recordButton,
                  ],
                  child: _buildReceiptsList(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opens the record-payment sheet from anywhere (e.g. the invoice list),
  /// optionally pre-selecting [invoice].
  static void openRecordSheet(BuildContext context, {InvoiceModel? invoice}) {
    const ManageRecieptsView()._showRecordReceiptSheet(context, invoice: invoice);
  }

  void _showRecordReceiptSheet(BuildContext context, {InvoiceModel? invoice}) {
    controller.clearRecordPaymentForm();
    if (invoice != null) controller.selectInvoiceForPayment(invoice);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColor.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: SizeConfig.isMobile ? 0.92 : 0.85,
        maxChildSize: 0.95,
        minChildSize: SizeConfig.isMobile ? 0.85 : 0.6,
        expand: false,
        builder: (ctx2, scrollController) => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  SizeConfig.isMobile ? 16 : 24, 16, 12, 16),
              child: Row(
                children: [
                  const AppIconTile(
                      icon: LucideIcons.receiptText, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Record receipt',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColor.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Record a payment received against an invoice',
                            style: TextStyle(
                                fontSize: 13, color: AppColor.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: Icon(LucideIcons.x,
                        size: 20, color: AppColor.textTertiary),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                    SizeConfig.isMobile ? 16 : 24,
                    20,
                    SizeConfig.isMobile ? 16 : 24,
                    32),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _buildRecordReceiptContent(ctx),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordReceiptContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        accountsFieldLabel('Select invoice'),
        Obx(() {
          final pending = controller.invoicesWithBalance;
          if (pending.isEmpty) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const AppEmptyState(
                compact: true,
                tone: AppTone.success,
                icon: LucideIcons.circleCheck,
                title: 'All invoices are fully paid',
                message: 'No outstanding balance on any invoice',
              ),
            );
          }
          return accountsDropdownShell(
            child: DropdownButton<int>(
              icon: const Icon(LucideIcons.chevronDown, size: 18),
              isExpanded: true,
              value: controller.selectedInvoiceForPayment.value?.invoiceDbId,
              hint: Text('Choose an invoice to settle',
                  style: TextStyle(
                      color: AppColor.textTertiary, fontSize: 14)),
              items: pending.map((inv) {
                return DropdownMenuItem(
                  value: inv.invoiceDbId,
                  child: Text(
                    '${inv.invoiceId}  •  ${inv.clientName}  •  Balance: ${controller.formatCurrency(inv.balanceDue)}',
                    style: TextStyle(fontSize: 13.5, color: AppColor.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (id) {
                final inv =
                    pending.firstWhereOrNull((i) => i.invoiceDbId == id);
                if (inv != null) controller.selectInvoiceForPayment(inv);
              },
            ),
          );
        }),
        const SizedBox(height: 16),

        // Invoice summary card
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          if (inv == null) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColor.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(inv.invoiceId,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColor.cPrimaryButtonColor)),
                    ),
                    accountsStatusChip(inv.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(inv.clientName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text('${inv.patientName}  •  ${inv.serviceName ?? ''}',
                    style: TextStyle(
                        fontSize: 13, color: AppColor.textTertiary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryChip('Invoice',
                        controller.formatCurrency(inv.totalAmount),
                        AppColor.textPrimary),
                    const SizedBox(width: 8),
                    _summaryChip(
                        'Paid',
                        controller.formatCurrency(inv.paidAmount),
                        AppColor.success),
                    const SizedBox(width: 8),
                    _summaryChip('Balance due',
                        controller.formatCurrency(inv.balanceDue),
                        AppColor.danger),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Period: ${inv.periodFrom}  →  ${inv.periodTo}',
                  style:
                      TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            ),
          );
        }),

        CommonTextField(
          label: 'Payment Amount',
          hint: 'Enter amount received',
          controller: controller.recordPaymentAmountController,
          keyboardType: TextInputType.number,
          isMandatory: true,
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountsFieldLabel('Payment Mode', required: true),
            Obx(() => accountsDropdownShell(
                  child: DropdownButton<String>(
                    icon: const Icon(LucideIcons.chevronDown, size: 18),
                    isExpanded: true,
                    value: controller.recordPaymentMode.value.isEmpty
                        ? null
                        : controller.recordPaymentMode.value,
                    hint: Text('Select payment mode',
                        style: TextStyle(
                            color: AppColor.textTertiary, fontSize: 14)),
                    items: controller.paymentModes
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.textPrimary))))
                        .toList(),
                    onChanged: (v) =>
                        controller.recordPaymentMode.value = v ?? '',
                  ),
                )),
          ],
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Transaction ID',
          hint: 'Enter transaction / reference ID (optional)',
          controller: controller.recordTransactionIdController,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Remarks',
          hint: 'Enter remarks (optional)',
          controller: controller.recordPaymentRemarksController,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Balance preview
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          final enteredText = controller.recordPaymentAmountController.text;
          final entered = double.tryParse(enteredText) ?? 0;
          if (inv == null || entered <= 0) return const SizedBox.shrink();
          final remaining = inv.balanceDue - entered;
          final settled = remaining <= 0;
          final tone = settled ? AppTone.success : AppTone.warning;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: tone.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                    settled
                        ? LucideIcons.circleCheck
                        : LucideIcons.info,
                    size: 18,
                    color: tone.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    settled
                        ? 'Fully settled ✓'
                        : 'Remaining after payment:',
                    style: TextStyle(
                      fontSize: 14,
                      color: tone.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (remaining > 0)
                  Text(
                    controller.formatCurrency(remaining),
                    style: accountsAmountStyle(
                        color: tone.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          );
        }),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoadingReceipts.value
                    ? null
                    : () async {
                        await controller.recordDirectPayment();
                        if (controller.selectedInvoiceForPayment.value ==
                            null) {
                          Get.back();
                        }
                      },
                icon: controller.isLoadingReceipts.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.buttonTextWhite),
                      )
                    : const Icon(LucideIcons.circleCheck, size: 18),
                label: const Text('Record payment'),
              )),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  maxLines: 1,
                  style: accountsAmountStyle(
                      color: valueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSearchBar({double? width}) {
    return AppSearchField(
      controller: controller.searchReceiptController,
      onChanged: controller.searchReceipts,
      hint: 'Search by receipt number, client name, mobile…',
      width: width,
    );
  }

  Widget _buildReceiptsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReceipts.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredReceipts.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.receiptText,
          title: 'No receipts found',
          message: 'Receipts recorded against invoices will appear here.',
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileReceiptList(context),
        tablet: _buildScrollableReceiptTable(context),
        desktop: _buildScrollableReceiptTable(context),
      );
    });
  }

  Widget _buildMobileReceiptList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: controller.filteredReceipts.length,
      itemBuilder: (_, i) =>
          _buildMobileReceiptCard(controller.filteredReceipts[i], context),
    );
  }

  Widget _buildMobileReceiptCard(dynamic receipt, BuildContext context) {
    final isPending = receipt.status == 'Pending';
    final InvoiceModel? linkedInv = controller.invoices
        .firstWhereOrNull((i) => i.bookingId == receipt.bookingId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Receipt # + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: accountsCellStack(
                    receipt.receiptNumber,
                    subtitle: linkedInv?.invoiceId,
                    titleColor: AppColor.cPrimaryButtonColor,
                  ),
                ),
                accountsStatusChip(receipt.status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 2: Client / Patient
            accountsCellStack(receipt.clientName,
                subtitle: receipt.patientName),
            const SizedBox(height: 6),

            // Row 3: Service name
            Text(receipt.serviceName,
                style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),

            // Row 4: Payment mode + Date range
            Row(
              children: [
                Icon(LucideIcons.banknote,
                    size: 16, color: AppColor.textTertiary),
                const SizedBox(width: 6),
                Text(receipt.paymentMode,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary)),
                const Spacer(),
                Text('${receipt.periodFrom} → ${receipt.periodTo}',
                    style: TextStyle(
                        fontSize: 12, color: AppColor.textTertiary)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 5: Amount / Tax / Total
            Row(
              children: [
                _mobileAmountItem(
                    'Amount', controller.formatCurrency(receipt.amount),
                    AppColor.textPrimary),
                _mobileAmountItem(
                    'Tax', controller.formatCurrency(receipt.taxAmount),
                    AppColor.textTertiary),
                _mobileAmountItem('Total',
                    controller.formatCurrency(receipt.totalAmount),
                    AppColor.textPrimary,
                    bold: true),
              ],
            ),

            // Bottom: Action buttons for Pending
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.cancelReceipt(receipt.id),
                      style: AppButtonStyles.dangerOutlined,
                      icon: const Icon(LucideIcons.x, size: 18),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveReceipt(receipt),
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mobileAmountItem(String label, String value, Color color,
      {bool bold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
          const SizedBox(height: 2),
          Text(value,
              style: accountsAmountStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildScrollableReceiptTable(BuildContext context) {
    return SingleChildScrollView(
      child: horizontalTable(
        DataTable(
          columns: const [
            DataColumn(label: Text('Receipt #')),
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Service')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Tax'), numeric: true),
            DataColumn(label: Text('Total'), numeric: true),
            DataColumn(label: Text('Mode')),
            DataColumn(label: Text('Period')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.filteredReceipts.map((receipt) {
            final isPending = receipt.status == 'Pending';
            final InvoiceModel? linkedInv = controller.invoices
                .firstWhereOrNull((i) => i.bookingId == receipt.bookingId);
            return DataRow(cells: [
              DataCell(accountsCellStack(
                receipt.receiptNumber,
                subtitle: linkedInv?.invoiceId,
                titleColor: AppColor.cPrimaryButtonColor,
              )),
              DataCell(accountsCellStack(receipt.clientName,
                  subtitle: receipt.patientName)),
              DataCell(Text(receipt.serviceName)),
              DataCell(Text(controller.formatCurrency(receipt.amount),
                  style: accountsAmountStyle(fontWeight: FontWeight.w400))),
              DataCell(Text(controller.formatCurrency(receipt.taxAmount),
                  style: accountsAmountStyle(
                      color: AppColor.textTertiary,
                      fontWeight: FontWeight.w400))),
              DataCell(Text(controller.formatCurrency(receipt.totalAmount),
                  style: accountsAmountStyle())),
              DataCell(Text(receipt.paymentMode)),
              DataCell(accountsCellStack(receipt.periodFrom,
                  subtitle: 'to ${receipt.periodTo}',
                  titleWeight: FontWeight.w400)),
              DataCell(accountsStatusChip(receipt.status)),
              DataCell(
                isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Approve Payment',
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  controller.approveReceipt(receipt),
                              style: AppButtonStyles.compact.merge(
                                  OutlinedButton.styleFrom(
                                      foregroundColor: AppColor.success)),
                              icon: const Icon(LucideIcons.check, size: 16),
                              label: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Cancel Receipt',
                            child: OutlinedButton(
                              onPressed: () =>
                                  controller.cancelReceipt(receipt.id),
                              style: AppButtonStyles.compact
                                  .merge(AppButtonStyles.dangerOutlined),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
