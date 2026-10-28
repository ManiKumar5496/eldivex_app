import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../widgets/ui/ui.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
          padding: HpUi.pagePadding(context, top: 20),
          children: [
            HpUi.tabHeader('Accounts', subtitle: 'Your invoices, receipts and balance'),
            AppStatCard(
              label: 'Due',
              value: HpUi.money(o?['outstanding'] ?? 0),
              icon: LucideIcons.wallet,
              tone: AppTone.danger,
            ),
            const SizedBox(height: 12),
            AppResponsiveGrid(
              minItemWidth: 130,
              maxColumns: 2,
              spacing: 12,
              children: [
                AppStatCard(
                  label: 'Billed',
                  value: HpUi.money(o?['total_invoiced'] ?? 0),
                  icon: LucideIcons.receiptText,
                ),
                AppStatCard(
                  label: 'Paid',
                  value: HpUi.money(o?['total_paid'] ?? 0),
                  icon: LucideIcons.banknote,
                  tone: AppTone.success,
                ),
              ],
            ),
            const SizedBox(height: 24),
            HpUi.sectionTitle('Invoices'),
            _listCard(
              c.invoices.map(_invoiceTile).toList(),
              empty: const AppEmptyState(
                compact: true,
                icon: LucideIcons.receiptText,
                title: 'No invoices',
              ),
            ),
            const SizedBox(height: 24),
            HpUi.sectionTitle('Receipts'),
            _listCard(
              c.receipts.map(_receiptTile).toList(),
              empty: const AppEmptyState(
                compact: true,
                icon: LucideIcons.banknote,
                title: 'No receipts',
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Rows separated by hairlines inside a single card.
  Widget _listCard(List<Widget> rows, {required Widget empty}) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: rows.isEmpty
          ? empty
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, indent: 64, color: AppColor.borderSubtle),
                  rows[i],
                ],
              ],
            ),
    );
  }

  Widget _amount(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()]));
  }

  Widget _invoiceTile(Map<String, dynamic> i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const AppIconTile(
              icon: LucideIcons.receiptText, size: 36, tone: AppTone.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice #${i['id']} • ${i['invoice_type'] ?? ''}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text('${i['inv_start'] ?? ''} → ${i['inv_end'] ?? ''}',
                    style:
                        TextStyle(color: AppColor.textTertiary, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _amount(HpUi.money(i['inv_raised_amnt'])),
        ],
      ),
    );
  }

  Widget _receiptTile(Map<String, dynamic> r) {
    final paid = (r['status'] ?? '').toString().toLowerCase().contains('approv') ||
        (r['status'] ?? '') == 'paid';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const AppIconTile(
              icon: LucideIcons.banknote, size: 36, tone: AppTone.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r['receipt_number'] ?? 'Receipt'} • ${r['receipt_type'] ?? ''}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text('${r['receipt_date'] ?? ''} • ${r['payment_mode'] ?? ''}',
                    style:
                        TextStyle(color: AppColor.textTertiary, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _amount(HpUi.money(r['total_amount'])),
              const SizedBox(height: 4),
              AppStatusBadge(
                label: humanizeLabel('${r['status'] ?? ''}'),
                tone: paid ? AppTone.success : AppTone.warning,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
