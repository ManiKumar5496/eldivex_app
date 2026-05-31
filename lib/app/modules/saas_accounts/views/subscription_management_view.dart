import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';
import '../models/saas_account_model.dart';
import 'widgets/account_status_badge.dart';
import 'widgets/destructive_action_dialog.dart';
import 'widgets/plan_chip.dart';
import 'widgets/status_transition_dialog.dart';

class SubscriptionManagementView extends GetView<SaasAccountsController> {
  const SubscriptionManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingAccounts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final expiring = controller.accounts
          .where((a) => a.isExpiringSoon)
          .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expiring.isNotEmpty) ...[
              Text('Expiring Soon (${expiring.length})',
                  style: AppTextStyles.semiBold16
                      .copyWith(color: Colors.orange.shade700)),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: expiring.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _ExpiringCard(account: expiring[i]),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],
            Text('All Subscriptions',
                style: AppTextStyles.semiBold16),
            const SizedBox(height: 12),
            _SubscriptionTable(),
          ],
        ),
      );
    });
  }
}

class _ExpiringCard extends StatelessWidget {
  const _ExpiringCard({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    final days = account.daysToExpiry;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(account.name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          SaasPlanChip(account.planName),
          const Spacer(),
          Text(
            days != null && days >= 0
                ? 'Expires in $days days'
                : 'Expired',

            style: TextStyle(
                fontSize: 12,
                color:
                    days != null && days < 0 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTable extends GetView<SaasAccountsController> {
  const _SubscriptionTable();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => DataTable(
            headingRowColor:
                WidgetStateProperty.all(AppColor.cAppBackgroundColor),
            columnSpacing: 18,
            columns: const [
              DataColumn(label: Text('Organisation')),
              DataColumn(label: Text('Plan')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Started')),
              DataColumn(label: Text('Expires')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.accounts.map((a) {
              return DataRow(cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(a.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(a.email,
                          style: AppTextStyles.regular14Gre
                              .copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                DataCell(SaasPlanChip(a.planName)),
                DataCell(AccountStatusBadge(a.subStatus)),
                DataCell(Text(
                  a.createdOn.isNotEmpty && a.createdOn.length >= 10
                      ? a.createdOn.substring(0, 10)
                      : '—',
                  style: const TextStyle(fontSize: 12),
                )),
                DataCell(Text(
                  a.expiresOn != null && a.expiresOn!.length >= 10
                      ? a.expiresOn!.substring(0, 10)
                      : '—',
                  style: TextStyle(
                    fontSize: 12,
                    color: a.isExpiringSoon ? Colors.orange : null,
                  ),
                )),
                DataCell(_SubActionsMenu(account: a)),
              ]);
            }).toList(),
          )),
    );
  }
}

class _SubActionsMenu extends GetView<SaasAccountsController> {
  const _SubActionsMenu({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (v) => _handle(v),
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: 'transition', child: Text('Change Status')),
        if (account.subStatus != 'cancelled')
          const PopupMenuItem(
              value: 'cancel',
              child: Text('Cancel',
                  style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _handle(String v) {
    switch (v) {
      case 'transition':
        StatusTransitionDialog.show(
          orgId: account.id,
          orgName: account.name,
          currentStatus: account.subStatus,
        );
        break;
      case 'cancel':
        DestructiveActionDialog.show(
          tier: DestructiveTier.high,
          title: 'Cancel Subscription',
          body: 'Cancel subscription for "${account.name}"? '
              'Data is retained but access will be blocked.',
          confirmLabel: 'Cancel ${account.name}',
          requireSlug: account.slug,
          requireReason: true,
          onConfirm: (reason) => controller.transitionSubscriptionStatus(
            account.id,
            'cancelled',
            reason ?? 'Admin cancellation',
          ),
        );
        break;
    }
  }
}
