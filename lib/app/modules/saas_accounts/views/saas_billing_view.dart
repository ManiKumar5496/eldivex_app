import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';
import '../models/saas_billing_invoice_model.dart';

class SaasBillingView extends GetView<SaasAccountsController> {
  const SaasBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('SaaS Billing', style: AppTextStyles.semiBold16),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showGenerateDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Generate Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                foregroundColor: AppColor.buttonTextWhite,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.loadingInvoices.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.billingInvoices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: AppColor.divColor),
                    const SizedBox(height: 12),
                    Text('No invoices yet.', style: AppTextStyles.regular14Gre),
                  ],
                ),
              );
            }
            return _InvoiceTable();
          }),
        ),
      ],
    );
  }

  void _showGenerateDialog(BuildContext context) {
    // Pre-load invoices for duplicate check
    controller.fetchBillingInvoices();
    Get.dialog(_GenerateInvoiceDialog());
  }
}

// ── Invoice table ─────────────────────────────────────────────────────────────

class _InvoiceTable extends GetView<SaasAccountsController> {
  const _InvoiceTable();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => DataTable(
            headingRowColor:
                WidgetStateProperty.all(AppColor.cAppBackgroundColor),
            columnSpacing: 18,
            columns: const [
              DataColumn(label: Text('Org')),
              DataColumn(label: Text('Period')),
              DataColumn(label: Text('Plan')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Due Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.billingInvoices.map((inv) {
              return DataRow(cells: [
                DataCell(Text(inv.orgName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
                DataCell(Text(inv.periodLabel,
                    style: const TextStyle(fontSize: 13))),
                DataCell(Text(inv.planName,
                    style: const TextStyle(fontSize: 12))),
                DataCell(Text(
                  '₹${inv.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                )),
                DataCell(_InvoiceStatusBadge(inv.status)),
                DataCell(Text(
                  inv.dueDate != null && inv.dueDate!.length >= 10
                      ? inv.dueDate!.substring(0, 10)
                      : '—',
                  style: const TextStyle(fontSize: 12),
                )),
                DataCell(inv.status != 'Paid'
                    ? TextButton(
                        onPressed: () => _markPaid(inv),
                        child: const Text('Mark Paid'),
                      )
                    : Text(
                        inv.paidAt != null && inv.paidAt!.length >= 10
                            ? 'Paid ${inv.paidAt!.substring(0, 10)}'
                            : 'Paid',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green),
                      )),
              ]);
            }).toList(),
          )),
    );
  }

  void _markPaid(SaasBillingInvoiceModel inv) {
    final txnCtrl  = TextEditingController();
    final dateCtrl = TextEditingController(
        text: DateTime.now().toString().substring(0, 10));

    Get.dialog(AlertDialog(
      title: Text('Mark Invoice Paid — ${inv.orgName} (${inv.periodLabel})'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: 'Payment Date',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: txnCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction Reference (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() => ElevatedButton(
              onPressed: controller.saving.value
                  ? null
                  : () async {
                      Get.back();
                      await controller.markInvoicePaid(
                        inv.id,
                        txnCtrl.text.trim().isEmpty ? null : txnCtrl.text.trim(),
                        dateCtrl.text.trim().isEmpty ? null : dateCtrl.text.trim(),
                      );
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite),
              child: controller.saving.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.buttonTextWhite))
                  : const Text('Confirm Payment'),
            )),
      ],
    ));
  }
}

// ── Generate invoice dialog ───────────────────────────────────────────────────

class _GenerateInvoiceDialog extends GetView<SaasAccountsController> {
  _GenerateInvoiceDialog();

  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final existing = controller.existingInvoiceForPeriod(
        controller.billingOrgId.value,
        controller.billingMonth.value,
        controller.billingYear.value,
      );

      return AlertDialog(
        title: const Text('Generate Subscription Invoice'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: controller.billingOrgId.value == 0
                    ? null
                    : controller.billingOrgId.value,
                decoration: const InputDecoration(
                  labelText: 'Organisation *',
                  border: OutlineInputBorder(),
                ),
                items: controller.accounts
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  controller.billingOrgId.value = v ?? 0;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: controller.billingMonth.value,
                      decoration: const InputDecoration(
                        labelText: 'Month *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(_monthName(i + 1)),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) controller.billingMonth.value = v;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: controller.billingYear.value,
                      decoration: const InputDecoration(
                        labelText: 'Year *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        3,
                        (i) => DropdownMenuItem(
                          value: DateTime.now().year - i,
                          child: Text('${DateTime.now().year - i}'),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) controller.billingYear.value = v;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (existing != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Invoice already exists for this period (ID: ${existing.id}). '
                          'Status: ${existing.status}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (leave blank for plan default)',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (v) =>
                    controller.billingAmount.value =
                        double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.dueDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Due Date (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: existing != null || controller.saving.value
                ? null
                : () async {
                    Get.back();
                    await controller.generateInvoice();
                  },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                foregroundColor: AppColor.buttonTextWhite),
            child: existing != null
                ? const Text('Already Generated')
                : controller.saving.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.buttonTextWhite))
                    : const Text('Generate'),
          ),
        ],
      );
    });
  }

  String _monthName(int m) => [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];
}

// ── Invoice status badge ─────────────────────────────────────────────────────

class _InvoiceStatusBadge extends StatelessWidget {
  const _InvoiceStatusBadge(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Paid'    => Colors.green,
      'Sent'    => Colors.blue,
      'Overdue' => Colors.red,
      _         => AppColor.fontColorGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
