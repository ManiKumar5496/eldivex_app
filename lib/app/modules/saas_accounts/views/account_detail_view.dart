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
import 'widgets/usage_progress_bar.dart';

class AccountDetailView extends GetView<SaasAccountsController> {
  const AccountDetailView({super.key, required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(account.name,
            style: AppTextStyles.semiBold16.copyWith(color: Colors.black87)),
        actions: [
          _ActionMenu(account: account),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.loadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrgInfoCard(account: account),
              const SizedBox(height: 16),
              _SubscriptionCard(account: account),
              const SizedBox(height: 16),
              _UsageCard(),
              const SizedBox(height: 16),
              _SubHistoryCard(),
            ],
          ),
        );
      }),
    );
  }
}

// ── Org info ─────────────────────────────────────────────────────────────────

class _OrgInfoCard extends StatelessWidget {
  const _OrgInfoCard({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Organisation Info',
      child: Column(
        children: [
          _Row('Name', account.name),
          _Row('Slug', account.slug),
          _Row('Email', account.email.isEmpty ? '—' : account.email),
          _Row('Phone', account.phone.isEmpty ? '—' : account.phone),
          _Row('Address', account.address.isEmpty ? '—' : account.address),
          _Row('Status', account.status),
          _Row('Created', account.createdOn),
        ],
      ),
    );
  }
}

// ── Subscription card ─────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    final days = account.daysToExpiry;
    return _Card(
      title: 'Subscription',
      child: Column(
        children: [
          Row(
            children: [
              SaasPlanChip(account.planName),
              const SizedBox(width: 12),
              AccountStatusBadge(account.subStatus),
            ],
          ),
          const SizedBox(height: 12),
          if (account.expiresOn != null) ...[
            _Row(
              'Expires',
              account.expiresOn!,
              trailing: days != null && days <= 30
                  ? Text('($days days)',
                      style: TextStyle(
                          fontSize: 12,
                          color: days < 0
                              ? AppColor.calenderRed
                              : Colors.orange))
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Usage card ────────────────────────────────────────────────────────────────

class _UsageCard extends GetView<SaasAccountsController> {
  const _UsageCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final usage = controller.selectedUsage.value;
      if (usage == null) return const SizedBox.shrink();
      return _Card(
        title: 'Usage',
        child: Column(
          children: [
            UsageProgressBar(
              label: 'Bookings',
              used: usage.bookingsUsed,
              limit: usage.bookingsLimit,
              pct: usage.usagePctBookings,
            ),
            const SizedBox(height: 12),
            UsageProgressBar(
              label: 'Healthcare Providers (HPs)',
              used: usage.hpUsed,
              limit: usage.hpLimit,
              pct: usage.usagePctHp,
            ),
          ],
        ),
      );
    });
  }
}

// ── Subscription history ─────────────────────────────────────────────────────

class _SubHistoryCard extends GetView<SaasAccountsController> {
  const _SubHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.subHistory;
      if (history.isEmpty) return const SizedBox.shrink();
      return _Card(
        title: 'Subscription History',
        child: Column(
          children: history.map((sub) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.planName,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                            '${sub.startedOn} → ${sub.expiresOn ?? 'No expiry'}',
                            style: AppTextStyles.regular14Gre),
                        if (sub.activatedByName != null)
                          Text('By: ${sub.activatedByName}',
                              style: AppTextStyles.regular14Gre),
                      ],
                    ),
                  ),
                  AccountStatusBadge(sub.status),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ── Action menu ───────────────────────────────────────────────────────────────

class _ActionMenu extends GetView<SaasAccountsController> {
  const _ActionMenu({required this.account});
  final SaasAccountModel account;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black87),
      onSelected: (v) => _onAction(context, v),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'transition', child: Text('Change Status')),
        if (account.subStatus != 'cancelled')
          const PopupMenuItem(value: 'cancel', child: Text('Cancel Account')),
      ],
    );
  }

  void _onAction(BuildContext context, String action) {
    switch (action) {
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
          body:
              'This will permanently cancel the subscription for "${account.name}". '
              'The organisation\'s data is retained but access is blocked.',
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

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.semiBold16
                  .copyWith(color: AppColor.cPrimaryHeadingColor)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
