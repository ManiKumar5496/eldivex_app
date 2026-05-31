import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';
import '../models/saas_account_model.dart';
import 'account_detail_view.dart';
import 'create_account_wizard.dart';
import 'widgets/account_status_badge.dart';
import 'widgets/destructive_action_dialog.dart';
import 'widgets/plan_chip.dart';
import 'widgets/status_transition_dialog.dart';

class AccountListTab extends GetView<SaasAccountsController> {
  const AccountListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterBar(),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.loadingAccounts.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.filteredAccounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No accounts found.',
                        style: AppTextStyles.regular14Gre),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: CreateAccountWizard.show,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create First Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }
            final isMobile = MediaQuery.of(context).size.width < 700;
            return isMobile ? _MobileList() : _DesktopTable();
          }),
        ),
      ],
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends GetView<SaasAccountsController> {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name, slug, email…',
              prefixIcon: const Icon(Icons.search, size: 18),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (_) => controller.applyFilters(),
          ),
        ),
        const SizedBox(width: 12),
        Obx(() => DropdownButton<String>(
              value:
                  controller.filterPlan.value.isEmpty ? null : controller.filterPlan.value,
              hint: const Text('Plan'),
              underline: const SizedBox.shrink(),
              items: ['', 'Starter', 'Growth', 'Enterprise']
                  .map((p) => DropdownMenuItem(
                      value: p, child: Text(p.isEmpty ? 'All Plans' : p)))
                  .toList(),
              onChanged: (v) {
                controller.filterPlan.value = v ?? '';
                controller.applyFilters();
              },
            )),
        const SizedBox(width: 12),
        Obx(() => DropdownButton<String>(
              value: controller.filterSubStatus.value.isEmpty
                  ? null
                  : controller.filterSubStatus.value,
              hint: const Text('Status'),
              underline: const SizedBox.shrink(),
              items: ['', 'trial', 'active', 'suspended', 'expired', 'cancelled']
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s.isEmpty ? 'All Status' : s)))
                  .toList(),
              onChanged: (v) {
                controller.filterSubStatus.value = v ?? '';
                controller.applyFilters();
              },
            )),
        const SizedBox(width: 12),
        Obx(() {
          final hasFilter = controller.filterPlan.value.isNotEmpty ||
              controller.filterSubStatus.value.isNotEmpty ||
              controller.searchCtrl.text.isNotEmpty;
          if (!hasFilter) return const SizedBox.shrink();
          return TextButton.icon(
            onPressed: controller.clearFilters,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
          );
        }),
      ],
    );
  }
}

// ── Desktop table ─────────────────────────────────────────────────────────────

class _DesktopTable extends GetView<SaasAccountsController> {
  const _DesktopTable();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => SingleChildScrollView(
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppColor.cAppBackgroundColor),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Organisation')),
                DataColumn(label: Text('Plan')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Expiry')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.filteredAccounts.map((a) {
                return DataRow(cells: [
                  DataCell(
                    InkWell(
                      onTap: () => _openDetail(a),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(a.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(a.slug,
                              style: AppTextStyles.regular14Gre
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  DataCell(SaasPlanChip(a.planName)),
                  DataCell(AccountStatusBadge(a.subStatus)),
                  DataCell(_ExpiryCell(account: a)),
                  DataCell(_ActionsMenu(account: a)),
                ]);
              }).toList(),
            ),
          )),
    );
  }

  void _openDetail(SaasAccountModel a) {
    Get.find<SaasAccountsController>().fetchAccountDetail(a);
    Get.to(() => AccountDetailView(account: a));
  }
}

// ── Mobile list ───────────────────────────────────────────────────────────────

class _MobileList extends GetView<SaasAccountsController> {
  const _MobileList();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
          itemCount: controller.filteredAccounts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final a = controller.filteredAccounts[i];
            return _AccountCard(account: a);
          },
        ));
  }
}

class _AccountCard extends GetView<SaasAccountsController> {
  const _AccountCard({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        controller.fetchAccountDetail(account);
        Get.to(() => AccountDetailView(account: account));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(account.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                AccountStatusBadge(account.subStatus),
              ],
            ),
            const SizedBox(height: 4),
            Text(account.slug, style: AppTextStyles.regular14Gre),
            const SizedBox(height: 8),
            Row(
              children: [
                SaasPlanChip(account.planName),
                const Spacer(),
                if (account.isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Expires in ${account.daysToExpiry} days',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expiry cell ───────────────────────────────────────────────────────────────

class _ExpiryCell extends StatelessWidget {
  const _ExpiryCell({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    if (account.expiresOn == null) return const Text('—');
    final days = account.daysToExpiry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(account.expiresOn!.substring(0, 10),
            style: const TextStyle(fontSize: 12)),
        if (days != null && days <= 30)
          Text(
            days < 0 ? 'Expired' : '$days days',
            style: TextStyle(
                fontSize: 11,
                color: days < 0 ? AppColor.calenderRed : Colors.orange,
                fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

// ── Actions menu ──────────────────────────────────────────────────────────────

class _ActionsMenu extends GetView<SaasAccountsController> {
  const _ActionsMenu({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (v) => _handle(context, v),
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: 'detail', child: Text('View Detail')),
        const PopupMenuItem(
            value: 'transition', child: Text('Change Status')),
        if (account.subStatus != 'cancelled')
          const PopupMenuItem(
              value: 'cancel',
              child: Text('Cancel Account',
                  style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _handle(BuildContext context, String action) {
    switch (action) {
      case 'detail':
        controller.fetchAccountDetail(account);
        Get.to(() => AccountDetailView(account: account));
        break;
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
          title: 'Cancel Account',
          body: 'This permanently cancels the subscription for "${account.name}". '
              'Data is retained but access is blocked.',
          confirmLabel: 'Permanently Cancel ${account.name}',
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
