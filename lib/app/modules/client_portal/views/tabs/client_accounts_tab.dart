import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';

class ClientAccountsTab extends StatefulWidget {
  const ClientAccountsTab({super.key});

  @override
  State<ClientAccountsTab> createState() => _ClientAccountsTabState();
}

class _ClientAccountsTabState extends State<ClientAccountsTab> {
  final c = Get.find<ClientController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.invoices.isEmpty && c.receipts.isEmpty) c.fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: c.fetchAccounts,
      child: Obx(() {
        if (c.loadingAccounts.value && c.invoices.isEmpty && c.receipts.isEmpty) {
          return ListView(children: const [
            SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          ]);
        }
        final o = c.outstanding.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HpUi.card(
              child: Row(
                children: [
                  _stat('Billed', HpUi.money(o?['total_invoiced'] ?? 0), AppColor.cAppPrimaryColor),
                  _stat('Paid', HpUi.money(o?['total_paid'] ?? 0), AppColor.lightGreen),
                  _stat('Due', HpUi.money(o?['outstanding'] ?? 0), AppColor.calenderRed),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HpUi.sectionTitle('Invoices'),
            if (c.invoices.isEmpty)
              HpUi.empty('No invoices.', icon: Icons.receipt_long)
            else
              ...c.invoices.map(_invoiceTile),
            const SizedBox(height: 16),
            HpUi.sectionTitle('Receipts'),
            if (c.receipts.isEmpty)
              HpUi.empty('No receipts.', icon: Icons.payments_outlined)
            else
              ...c.receipts.map(_receiptTile),
          ],
        );
      }),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _invoiceTile(Map<String, dynamic> i) {
    return HpUi.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice #${i['id']} • ${i['invoice_type'] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.fontColorBlack)),
                Text('${i['inv_start'] ?? ''} → ${i['inv_end'] ?? ''}',
                    style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(HpUi.money(i['inv_raised_amnt']),
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.fontColorBlack)),
        ],
      ),
    );
  }

  Widget _receiptTile(Map<String, dynamic> r) {
    final paid = (r['status'] ?? '').toString().toLowerCase().contains('approv') ||
        (r['status'] ?? '') == 'paid';
    return HpUi.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r['receipt_number'] ?? 'Receipt'} • ${r['receipt_type'] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.fontColorBlack)),
                Text('${r['receipt_date'] ?? ''} • ${r['payment_mode'] ?? ''}',
                    style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(HpUi.money(r['total_amount']),
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.fontColorBlack)),
              HpUi.statusChip('${r['status'] ?? ''}', paid ? AppColor.lightGreen : Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}
