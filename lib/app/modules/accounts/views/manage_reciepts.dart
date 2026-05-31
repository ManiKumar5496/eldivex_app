import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/invoice_model.dart';

class ManageRecieptsView extends GetView<AccountsController> {
  const ManageRecieptsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountsController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordReceiptSheet(context),
        backgroundColor: AppColor.cPrimaryButtonColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Record Receipt',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _buildReceiptSearchBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildReceiptsList(context)),
               // Expanded(flex: 2, child: _buildReceiptForm()),
              ],
            ),
          ),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Record Receipt',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.cPrimaryHeadingColor)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: _buildRecordReceiptContent(context),
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
        // ── Step 1: Select Invoice ──
        Text(
          'Select Invoice',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.cPrimarySubHeadingColorGrey),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final pending = controller.invoicesWithBalance;
          if (pending.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text('All invoices are fully paid',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('No outstanding balance on any invoice',
                      style: TextStyle(
                          fontSize: 12, color: Colors.green.shade600)),
                ],
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.textFieldBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: controller.selectedInvoiceForPayment.value?.invoiceDbId,
                hint: Text('Choose an invoice to settle',
                    style: TextStyle(
                        color: AppColor.fontColorGrey, fontSize: 14)),
                items: pending.map((inv) {
                  return DropdownMenuItem(
                    value: inv.invoiceDbId,
                    child: Text(
                      '${inv.invoiceId}  •  ${inv.clientName}  •  Balance: ${controller.formatCurrency(inv.balanceDue)}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  final inv = pending.firstWhereOrNull(
                      (i) => i.invoiceDbId == id);
                  if (inv != null) controller.selectInvoiceForPayment(inv);
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // ── Invoice summary card ──
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          if (inv == null) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
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
                            fontSize: 14,
                            color: AppColor.cPrimaryButtonColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(inv.status,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade800)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(inv.clientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                Text('${inv.patientName}  •  ${inv.serviceName ?? ''}',
                    style: TextStyle(
                        fontSize: 12, color: AppColor.fontColorGrey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _summaryChip('Invoice',
                        controller.formatCurrency(inv.totalAmount),
                        Colors.blue),
                    const SizedBox(width: 8),
                    _summaryChip('Paid',
                        controller.formatCurrency(inv.paidAmount),
                        Colors.green),
                    const SizedBox(width: 8),
                    _summaryChip('Balance Due',
                        controller.formatCurrency(inv.balanceDue),
                        Colors.red),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Period: ${inv.periodFrom}  →  ${inv.periodTo}',
                  style: TextStyle(
                      fontSize: 12, color: AppColor.fontColorGrey),
                ),
              ],
            ),
          );
        }),

        // ── Step 2: Payment details ──
        CommonTextField(
          label: 'Payment Amount',
          hint: 'Enter amount received',
          controller: controller.recordPaymentAmountController,
          keyboardType: TextInputType.number,
          isMandatory: true,
        ),
        const SizedBox(height: 14),

        // Payment Mode
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Payment Mode',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.cPrimarySubHeadingColorGrey)),
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColor.textFieldBorderColor),
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
                              fontSize: 14)),
                      items: controller.paymentModes
                          .map((m) => DropdownMenuItem(
                              value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) =>
                          controller.recordPaymentMode.value = v ?? '',
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 14),

        CommonTextField(
          label: 'Transaction ID',
          hint: 'Enter transaction / reference ID (optional)',
          controller: controller.recordTransactionIdController,
        ),
        const SizedBox(height: 14),

        CommonTextField(
          label: 'Remarks',
          hint: 'Enter remarks (optional)',
          controller: controller.recordPaymentRemarksController,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // ── Balance preview ──
        Obx(() {
          final inv = controller.selectedInvoiceForPayment.value;
          final enteredText = controller.recordPaymentAmountController.text;
          final entered = double.tryParse(enteredText) ?? 0;
          if (inv == null || entered <= 0) return const SizedBox.shrink();
          final remaining = inv.balanceDue - entered;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: remaining <= 0
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
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
                  remaining <= 0 ? 'Fully settled ✓' : 'Remaining after payment:',
                  style: TextStyle(
                    fontSize: 13,
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
                      fontSize: 14,
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
                        if (controller.selectedInvoiceForPayment.value == null) {
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
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Record Payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  disabledBackgroundColor: Colors.green.shade200,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSearchBar() {
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
                controller: controller.searchReceiptController,
                onChanged: controller.searchReceipts,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Search by receipt number, client name, mobile...',
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
        ],
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
              const SizedBox(height: 12),
              Text('No receipts found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, bottom: 20),
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
            columnSpacing: 16,
            horizontalMargin: 12,
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
              final statusColor =
                  controller.getStatusColor(receipt.status);
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
                            fontSize: 13)),
                    if (linkedInv != null)
                      Text(
                        linkedInv.invoiceId,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(receipt.patientName,
                        style: TextStyle(
                            fontSize: 11, color: AppColor.fontColorGrey)),
                  ],
                )),
                DataCell(Text(receipt.serviceName)),
                DataCell(Text(controller.formatCurrency(receipt.amount))),
                DataCell(Text(controller.formatCurrency(receipt.taxAmount),
                    style: TextStyle(
                        fontSize: 12, color: AppColor.fontColorGrey))),
                DataCell(Text(
                    controller.formatCurrency(receipt.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(receipt.paymentMode)),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(receipt.periodFrom,
                        style: const TextStyle(fontSize: 12)),
                    Text('to ${receipt.periodTo}',
                        style: TextStyle(
                            fontSize: 11, color: AppColor.fontColorGrey)),
                  ],
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(receipt.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
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
                                  controller.selectReceiptForPayment(receipt);
                                  _showRecordReceiptSheet(context);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Text('Approve',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Cancel Receipt',
                              child: InkWell(
                                onTap: () => controller.cancelReceipt(receipt.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.red.shade200),
                                  ),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 11,
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
      );
    });
  }

  // ── Legacy form content kept for reference; no longer mounted in the UI ──
  // ignore: unused_element
  Widget _buildReceiptFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Selected Client Info
            Obx(() {
              final client = controller.selectedClientForReceipt.value;
              if (client != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.clientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                                'Booking #${client.bookingId} | ${client.patientName} | ${client.serviceName}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColor.fontColorGrey)),
                            Text(
                                'Outstanding: ${controller.formatCurrency(client.outstandingAmount)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            controller.selectedClientForReceipt.value = null,
                      ),
                    ],
                  ),
                );
              }
              // Client Dropdown
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Client',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.cPrimarySubHeadingColorGrey)),
                  const SizedBox(height: 8),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColor.textFieldBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: Text('Choose active client',
                            style: TextStyle(
                                color: AppColor.fontColorGrey, fontSize: 14)),
                        items: controller.activeClients.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                                '${c.clientName} - #${c.bookingId}',
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (id) {
                          final client = controller.activeClients
                              .firstWhereOrNull((c) => c.id == id);
                          if (client != null) {
                            controller.selectClientForReceipt(client);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            CommonTextField(
              label: 'Amount',
              hint: 'Enter amount',
              controller: controller.receiptAmountController,
              keyboardType: TextInputType.number,
              isMandatory: true,
            ),
            const SizedBox(height: 14),

            // Payment Mode
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Payment Mode',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.cPrimarySubHeadingColorGrey)),
                    const Text(' *',
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColor.textFieldBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.receiptPaymentMode.value.isEmpty
                              ? null
                              : controller.receiptPaymentMode.value,
                          hint: Text('Select payment mode',
                              style: TextStyle(
                                  color: AppColor.fontColorGrey,
                                  fontSize: 14)),
                          items: controller.paymentModes
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) =>
                              controller.receiptPaymentMode.value = v ?? '',
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 14),

            CommonTextField(
              label: 'Transaction ID',
              hint: 'Enter transaction/reference ID',
              controller: controller.receiptTransactionIdController,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CommonTextField(
                    label: 'Period From',
                    hint: 'DD-MMM-YYYY',
                    controller: controller.receiptPeriodFromController,
                    isMandatory: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonTextField(
                    label: 'Period To',
                    hint: 'DD-MMM-YYYY',
                    controller: controller.receiptPeriodToController,
                    isMandatory: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CommonTextField(
              label: 'Remarks',
              hint: 'Enter remarks (optional)',
              controller: controller.receiptRemarksController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.createProvisionalReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Create Receipt',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
      ],
    );
  }
}
