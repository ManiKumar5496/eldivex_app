import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/invoice_model.dart';

class ManageRecieptsView extends GetView<AccountsController> {
  const ManageRecieptsView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(AccountsController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordReceiptSheet(context),
        backgroundColor: AppColor.cPrimaryButtonColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          SizeConfig.isMobile ? 'Record' : 'Record Receipt',
          style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.fontBody,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildReceiptSearchBar(),
          Expanded(child: _buildReceiptsList(context)),
        ],
      ),
    );
  }

  void _showRecordReceiptSheet(BuildContext context) {
    controller.clearRecordPaymentForm();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: SizeConfig.isMobile ? 0.92 : 0.85,
        maxChildSize: 0.95,
        minChildSize: SizeConfig.isMobile ? 0.85 : 0.6,
        expand: false,
        builder: (ctx2, scrollController) => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(SizeConfig.pagePadding.left,
                  SizeConfig.spacingMD, SizeConfig.spacingXS, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Record Receipt',
                      style: TextStyle(
                          fontSize: SizeConfig.fontH2,
                          fontWeight: FontWeight.w600,
                          color: AppColor.cPrimaryHeadingColor)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                    SizeConfig.pagePadding.left,
                    SizeConfig.spacingSM,
                    SizeConfig.pagePadding.right,
                    SizeConfig.spacingLG),
                child: _buildRecordReceiptContent(ctx),
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
        Text(
          'Select Invoice',
          style: TextStyle(
              fontSize: SizeConfig.fontBody,
              fontWeight: FontWeight.w500,
              color: AppColor.cPrimarySubHeadingColorGrey),
        ),
        SizedBox(height: SizeConfig.spacingXS),
        Obx(() {
          final pending = controller.invoicesWithBalance;
          if (pending.isEmpty) {
            return Container(
              width: double.infinity,
              padding: SizeConfig.cardPadding,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(SizeConfig.radiusSM),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green.shade400, size: 32),
                  SizedBox(height: SizeConfig.spacingXS),
                  Text('All invoices are fully paid',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: SizeConfig.fontBody)),
                  SizedBox(height: SizeConfig.spacingXS / 2),
                  Text('No outstanding balance on any invoice',
                      style: TextStyle(
                          fontSize: SizeConfig.fontBodySmall,
                          color: Colors.green.shade600)),
                ],
              ),
            );
          }
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
              border: Border.all(color: AppColor.textFieldBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value:
                    controller.selectedInvoiceForPayment.value?.invoiceDbId,
                hint: Text('Choose an invoice to settle',
                    style: TextStyle(
                        color: AppColor.fontColorGrey,
                        fontSize: SizeConfig.fontBody)),
                items: pending.map((inv) {
                  return DropdownMenuItem(
                    value: inv.invoiceDbId,
                    child: Text(
                      '${inv.invoiceId}  •  ${inv.clientName}  •  Balance: ${controller.formatCurrency(inv.balanceDue)}',
                      style: TextStyle(fontSize: SizeConfig.fontBodySmall),
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
            ),
          );
        }),
        SizedBox(height: SizeConfig.spacingMD),

        // Invoice summary card
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          if (inv == null) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: SizeConfig.cardPadding,
            margin: EdgeInsets.only(bottom: SizeConfig.spacingMD),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(inv.invoiceId,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: SizeConfig.fontBody,
                            color: AppColor.cPrimaryButtonColor)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spacingSM, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radiusSM),
                      ),
                      child: Text(inv.status,
                          style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade800)),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingXS),
                Text(inv.clientName,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: SizeConfig.fontBody)),
                Text('${inv.patientName}  •  ${inv.serviceName ?? ''}',
                    style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        color: AppColor.fontColorGrey)),
                SizedBox(height: SizeConfig.spacingSM),
                Row(
                  children: [
                    _summaryChip('Invoice',
                        controller.formatCurrency(inv.totalAmount),
                        Colors.blue),
                    SizedBox(width: SizeConfig.spacingXS),
                    _summaryChip(
                        'Paid',
                        controller.formatCurrency(inv.paidAmount),
                        Colors.green),
                    SizedBox(width: SizeConfig.spacingXS),
                    _summaryChip('Balance Due',
                        controller.formatCurrency(inv.balanceDue),
                        Colors.red),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingXS),
                Text(
                  'Period: ${inv.periodFrom}  →  ${inv.periodTo}',
                  style: TextStyle(
                      fontSize: SizeConfig.fontBodySmall,
                      color: AppColor.fontColorGrey),
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
        SizedBox(height: SizeConfig.spacingMD),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Payment Mode',
                    style: TextStyle(
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w500,
                        color: AppColor.cPrimarySubHeadingColorGrey)),
                Text(' *',
                    style: TextStyle(
                        color: Colors.red, fontSize: SizeConfig.fontBody)),
              ],
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Obx(() => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius:
                        BorderRadius.circular(SizeConfig.radiusMD),
                    border: Border.all(color: AppColor.textFieldBorderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.recordPaymentMode.value.isEmpty
                          ? null
                          : controller.recordPaymentMode.value,
                      hint: Text('Select payment mode',
                          style: TextStyle(
                              color: AppColor.fontColorGrey,
                              fontSize: SizeConfig.fontBody)),
                      items: controller.paymentModes
                          .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m,
                                  style: TextStyle(
                                      fontSize: SizeConfig.fontBody))))
                          .toList(),
                      onChanged: (v) =>
                          controller.recordPaymentMode.value = v ?? '',
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Transaction ID',
          hint: 'Enter transaction / reference ID (optional)',
          controller: controller.recordTransactionIdController,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Remarks',
          hint: 'Enter remarks (optional)',
          controller: controller.recordPaymentRemarksController,
          maxLines: 3,
        ),
        SizedBox(height: SizeConfig.spacingLG),

        // Balance preview
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          final enteredText = controller.recordPaymentAmountController.text;
          final entered = double.tryParse(enteredText) ?? 0;
          if (inv == null || entered <= 0) return const SizedBox.shrink();
          final remaining = inv.balanceDue - entered;
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.spacingMD, vertical: SizeConfig.spacingSM),
            margin: EdgeInsets.only(bottom: SizeConfig.spacingMD),
            decoration: BoxDecoration(
              color: remaining <= 0 ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              border: Border.all(
                color: remaining <= 0
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  remaining <= 0
                      ? 'Fully settled ✓'
                      : 'Remaining after payment:',
                  style: TextStyle(
                    fontSize: SizeConfig.fontBody,
                    color: remaining <= 0
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (remaining > 0)
                  Text(
                    controller.formatCurrency(remaining),
                    style: TextStyle(
                      fontSize: SizeConfig.fontBody,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade800,
                    ),
                  ),
              ],
            ),
          );
        }),

        SizedBox(
          width: double.infinity,
          height: 48,
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
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.check_circle_outline, size: SizeConfig.iconSM),
                label: Text('Record Payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  disabledBackgroundColor: Colors.green.shade200,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.radiusSM)),
                ),
              )),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.spacingSM, vertical: SizeConfig.spacingXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    color: Colors.grey.shade600)),
            SizedBox(height: SizeConfig.spacingXS / 2),
            Text(value,
                style: TextStyle(
                    fontSize: SizeConfig.fontBodySmall,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSearchBar() {
    return Padding(
      padding: SizeConfig.pagePadding,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.textFieldBorderColor),
        ),
        child: TextField(
          controller: controller.searchReceiptController,
          onChanged: controller.searchReceipts,
          style: TextStyle(fontSize: SizeConfig.fontBody),
          decoration: InputDecoration(
            hintText: 'Search by receipt number, client name, mobile...',
            hintStyle: TextStyle(
                color: AppColor.fontColorGrey, fontSize: SizeConfig.fontBody),
            prefixIcon: Icon(Icons.search,
                color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReceipts.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredReceipts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: Colors.grey.shade300),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No receipts found', style: AppTextStyles.regular16Gre),
            ],
          ),
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
      padding: EdgeInsets.fromLTRB(
          SizeConfig.pagePadding.left,
          SizeConfig.spacingXS,
          SizeConfig.pagePadding.right,
          80),
      itemCount: controller.filteredReceipts.length,
      itemBuilder: (_, i) =>
          _buildMobileReceiptCard(controller.filteredReceipts[i], context),
    );
  }

  Widget _buildMobileReceiptCard(dynamic receipt, BuildContext context) {
    final statusColor = controller.getStatusColor(receipt.status);
    final isPending = receipt.status == 'Pending';
    final InvoiceModel? linkedInv = controller.invoices
        .firstWhereOrNull((i) => i.bookingId == receipt.bookingId);

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: Colors.grey.shade200),
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
          // Row 1: Receipt # + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receipt.receiptNumber,
                      style: TextStyle(
                          color: AppColor.cPrimaryButtonColor,
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.fontBody)),
                  if (linkedInv != null)
                    Text(linkedInv.invoiceId,
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM,
                    vertical: SizeConfig.spacingXS),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(receipt.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: SizeConfig.fontCaption,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: Colors.grey.shade100),

          // Row 2: Client / Patient
          Text(receipt.clientName,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: SizeConfig.fontBody)),
          Text(receipt.patientName,
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption,
                  color: AppColor.fontColorGrey)),
          SizedBox(height: SizeConfig.spacingXS),

          // Row 3: Service name
          Text(receipt.serviceName,
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.fontColorGrey),
              overflow: TextOverflow.ellipsis),
          SizedBox(height: SizeConfig.spacingXS),

          // Row 4: Payment mode + Date range
          Row(
            children: [
              Icon(Icons.payment, size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
              SizedBox(width: SizeConfig.spacingXS),
              Text(receipt.paymentMode,
                  style: TextStyle(
                      fontSize: SizeConfig.fontBodySmall,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('${receipt.periodFrom} → ${receipt.periodTo}',
                  style: TextStyle(
                      fontSize: SizeConfig.fontCaption,
                      color: AppColor.fontColorGrey)),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: Colors.grey.shade100),

          // Row 5: Amount / Tax / Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _mobileAmountItem(
                  'Amount', controller.formatCurrency(receipt.amount), Colors.black87),
              _mobileAmountItem(
                  'Tax', controller.formatCurrency(receipt.taxAmount), Colors.grey),
              _mobileAmountItem('Total',
                  controller.formatCurrency(receipt.totalAmount), Colors.teal,
                  bold: true),
            ],
          ),

          // Bottom: Action buttons for Pending
          if (isPending) ...[
            Divider(height: SizeConfig.spacingLG, color: Colors.grey.shade100),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.cancelReceipt(receipt.id),
                      icon: Icon(Icons.close,
                          size: SizeConfig.iconSM, color: Colors.red),
                      label: Text('Cancel',
                          style: TextStyle(
                              color: Colors.red, fontSize: SizeConfig.fontBody)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.spacingSM),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.selectReceiptForPayment(receipt);
                        _showRecordReceiptSheet(context);
                      },
                      icon: Icon(Icons.check,
                          size: SizeConfig.iconSM, color: Colors.white),
                      label: Text('Approve',
                          style: TextStyle(
                              color: Colors.white, fontSize: SizeConfig.fontBody)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _mobileAmountItem(String label, String value, Color color,
      {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: SizeConfig.fontCaption, color: Colors.grey.shade600)),
        SizedBox(height: SizeConfig.spacingXS / 2),
        Text(value,
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color)),
      ],
    );
  }

  Widget _buildScrollableReceiptTable(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: SizeConfig.pagePadding.left, bottom: SizeConfig.spacingLG),
      child: Container(
        width: double.infinity,
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
              fontSize: SizeConfig.fontBodySmall,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
            columnSpacing: SizeConfig.spacingMD,
            horizontalMargin: SizeConfig.spacingSM,
            columns: const [
              DataColumn(label: Text('Receipt #')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Service')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Tax')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Mode')),
              DataColumn(label: Text('Period')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredReceipts.map((receipt) {
              final statusColor = controller.getStatusColor(receipt.status);
              final isPending = receipt.status == 'Pending';
              final InvoiceModel? linkedInv = controller.invoices
                  .firstWhereOrNull((i) => i.bookingId == receipt.bookingId);
              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.receiptNumber,
                        style: TextStyle(
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.fontBodySmall)),
                    if (linkedInv != null)
                      Text(linkedInv.invoiceId,
                          style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
                              color: Colors.teal.shade600,
                              fontWeight: FontWeight.w500)),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.clientName,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.fontBodySmall)),
                    Text(receipt.patientName,
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                  ],
                )),
                DataCell(Text(receipt.serviceName,
                    style:
                        TextStyle(fontSize: SizeConfig.fontBodySmall))),
                DataCell(Text(controller.formatCurrency(receipt.amount),
                    style:
                        TextStyle(fontSize: SizeConfig.fontBodySmall))),
                DataCell(Text(controller.formatCurrency(receipt.taxAmount),
                    style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        color: AppColor.fontColorGrey))),
                DataCell(Text(controller.formatCurrency(receipt.totalAmount),
                    style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        fontWeight: FontWeight.w600))),
                DataCell(Text(receipt.paymentMode,
                    style:
                        TextStyle(fontSize: SizeConfig.fontBodySmall))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.periodFrom,
                        style: TextStyle(fontSize: SizeConfig.fontBodySmall)),
                    Text('to ${receipt.periodTo}',
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                  ],
                )),
                DataCell(Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(receipt.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: SizeConfig.fontCaption,
                          fontWeight: FontWeight.w500)),
                )),
                DataCell(
                  isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Approve Payment',
                              child: InkWell(
                                onTap: () {
                                  controller
                                      .selectReceiptForPayment(receipt);
                                  _showRecordReceiptSheet(context);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.spacingSM,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius:
                                        BorderRadius.circular(SizeConfig.radiusSM),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Text('Approve',
                                      style: TextStyle(
                                          fontSize: SizeConfig.fontCaption,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                            SizedBox(width: SizeConfig.spacingXS),
                            Tooltip(
                              message: 'Cancel Receipt',
                              child: InkWell(
                                onTap: () =>
                                    controller.cancelReceipt(receipt.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.spacingSM,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius:
                                        BorderRadius.circular(SizeConfig.radiusSM),
                                    border: Border.all(
                                        color: Colors.red.shade200),
                                  ),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: SizeConfig.fontCaption,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500)),
                                ),
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
      ),
    );
  }
}
