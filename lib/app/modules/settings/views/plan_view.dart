import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/lucide_icons.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/plan_controller.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String _money(dynamic v) => _inr.format(num.tryParse('${v ?? ''}') ?? 0);

/// 'YYYY-MM-DD…' → '29 Oct 2026', else the fallback.
String _date(dynamic v, [String fallback = '—']) {
  final d = DateTime.tryParse('${v ?? ''}');
  return d == null ? fallback : DateFormat('dd MMM yyyy').format(d);
}

int? _int(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');

/// Settings → Plan & Renewal (Super Admin only). [embedded]: shown as a page
/// of the admin shell (sidebar) rather than as its own route.
class PlanView extends GetView<PlanController> {
  const PlanView({super.key, this.embedded = false});

  final bool embedded;

  // The shell page has no route binding.
  @override
  PlanController get controller => Get.isRegistered<PlanController>()
      ? Get.find<PlanController>()
      : Get.put(PlanController());

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(narrow ? 16 : 24),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Obx(_body),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final sub = controller.subscription.value;
    final pending = controller.pendingRequest.value;

    final header = AppPageHeader(
      title: 'Plan & Renewal',
      subtitle: 'Your Eldivex plan, how much of it you use, and renewal requests.',
      // Inside the shell, Get.back() would pop the whole shell.
      onBack: embedded ? null : () => Get.back(),
      actions: [
        ElevatedButton.icon(
          onPressed: sub == null || pending != null ? null : _openRequestDialog,
          icon: const Icon(LucideIcons.calendarPlus, size: 18),
          label: const Text('Request Extension'),
        ),
      ],
    );

    if (sub == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          if (controller.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            AppEmptyState(
              icon: LucideIcons.cloudOff,
              title: 'Could not load your plan',
              message: controller.loadError.value.isNotEmpty
                  ? controller.loadError.value
                  : 'No subscription was found for your organisation.',
              actionLabel: 'Try again',
              actionIcon: LucideIcons.refreshCw,
              onAction: controller.load,
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 24),
        if (pending != null) ...[
          _pendingBanner(pending),
          const SizedBox(height: 16),
        ],
        AppResponsiveGrid(
          minItemWidth: 340,
          maxColumns: 2,
          children: [_planCard(sub), _usageCard(sub)],
        ),
        const SizedBox(height: 16),
        _historyCard(),
      ],
    );
  }

  // ── Current plan ───────────────────────────────────────────────────────────

  Widget _planCard(Map<String, dynamic> sub) {
    final status = '${sub['status'] ?? ''}';
    final daysLeft = _int(sub['days_left']);
    final hasEnd = sub['expires_on'] != null;

    final AppTone expiryTone;
    final String expiryNote;
    if (!hasEnd) {
      expiryTone = AppTone.success;
      expiryNote = 'No end date';
    } else if (daysLeft != null && daysLeft < 0) {
      expiryTone = AppTone.danger;
      expiryNote = 'Expired ${-daysLeft} day${daysLeft == -1 ? '' : 's'} ago';
    } else if (daysLeft != null && daysLeft <= 30) {
      expiryTone = AppTone.warning;
      expiryNote = daysLeft == 0 ? 'Expires today' : '$daysLeft day${daysLeft == 1 ? '' : 's'} left';
    } else {
      expiryTone = AppTone.success;
      expiryNote = '${daysLeft ?? '—'} days left';
    }

    return AppCard(
      title: 'Current plan',
      subtitle: 'What your organisation is subscribed to',
      icon: LucideIcons.award,
      iconTone: AppTone.violet,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${sub['plan_name'] ?? '—'}',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColor.textPrimary),
                ),
              ),
              AppStatusBadge.status(status),
            ],
          ),
          const SizedBox(height: 4),
          Text('${_money(sub['price_per_month'])} / month',
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary)),
          const SizedBox(height: 16),
          AppInfoRow(label: 'Started', value: _date(sub['started_on']), horizontal: true, labelWidth: 110),
          AppInfoRow(
            label: 'Expires',
            horizontal: true,
            labelWidth: 110,
            valueWidget: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(_date(sub['expires_on'], 'No end date'),
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary)),
                if (hasEnd) AppStatusBadge(label: expiryNote, tone: expiryTone, dense: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 12),
          Text('Features',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColor.textTertiary)),
          const SizedBox(height: 6),
          ..._features(sub['features']).entries.map((e) => _featureRow(e.key, e.value)),
        ],
      ),
    );
  }

  Map<String, bool> _features(dynamic raw) {
    dynamic v = raw;
    if (v is String) {
      try {
        v = jsonDecode(v);
      } catch (_) {
        v = null;
      }
    }
    if (v is! Map) return const {};
    return {for (final e in v.entries) '${e.key}': e.value == true};
  }

  Widget _featureRow(String key, bool enabled) {
    final name = key.replaceAll('_', ' ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(enabled ? LucideIcons.circleCheck : LucideIcons.circleX,
              size: 16, color: enabled ? AppColor.success : AppColor.lightGrey),
          const SizedBox(width: 10),
          Text(name.isEmpty ? key : name[0].toUpperCase() + name.substring(1),
              style: TextStyle(
                  fontSize: 13.5,
                  color: enabled ? AppColor.textPrimary : AppColor.textTertiary)),
        ],
      ),
    );
  }

  // ── Usage ──────────────────────────────────────────────────────────────────

  Widget _usageCard(Map<String, dynamic> sub) {
    final u = controller.usage;
    return AppCard(
      title: 'Usage',
      subtitle: 'Against your plan limits',
      icon: LucideIcons.clipboardList,
      iconTone: AppTone.info,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _usageBar(LucideIcons.calendarDays, 'Bookings this month',
              _int(u['bookings_this_month']) ?? 0, _int(u['booking_limit'])),
          const SizedBox(height: 18),
          _usageBar(LucideIcons.users, 'Active caregivers',
              _int(u['active_caregivers']) ?? 0, _int(u['hp_limit'])),
        ],
      ),
    );
  }

  /// A limit of 0 / null is unlimited.
  Widget _usageBar(IconData icon, String label, int used, int? limit) {
    final unlimited = limit == null || limit <= 0;
    final ratio = unlimited ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final tone = unlimited || ratio < 0.8
        ? AppTone.primary
        : ratio < 1 ? AppTone.warning : AppTone.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColor.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 13.5, color: AppColor.textSecondary)),
            ),
            Text(unlimited ? '$used · Unlimited' : '$used / $limit',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColor.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: unlimited ? 0 : ratio,
            minHeight: 8,
            backgroundColor: AppColor.surfaceMuted,
            color: tone.color,
          ),
        ),
      ],
    );
  }

  // ── Pending request + history ──────────────────────────────────────────────

  String _requestSummary(Map<String, dynamic> r) {
    final months = _int(r['extend_months']) ?? 0;
    final plan = r['requested_plan_name'] ?? r['current_plan_name'] ?? 'plan';
    final change = r['requested_plan_id'] != r['current_plan_id']
        ? 'Change to $plan'
        : 'Extend $plan';
    return '$change by $months month${months == 1 ? '' : 's'}';
  }

  Widget _pendingBanner(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTone.warning.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTone.warning.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.hourglass, color: AppTone.warning.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request #${r['id']} is waiting for approval',
                    style: TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text('${_requestSummary(r)} · sent ${_date(r['requested_on'])}',
                    style: TextStyle(fontSize: 13, color: AppColor.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: controller.isSubmitting.value
                ? null
                : () => controller.withdraw(_int(r['id']) ?? 0),
            icon: const Icon(LucideIcons.undo2, size: 16),
            label: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Widget _historyCard() {
    final list = controller.requests;
    return AppCard(
      title: 'Requests',
      subtitle: 'Extension and plan change requests sent to the Eldivex team',
      icon: LucideIcons.history,
      padding: EdgeInsets.zero,
      child: list.isEmpty
          ? const AppEmptyState(
              icon: LucideIcons.history,
              title: 'No requests yet',
              message: 'Use "Request Extension" to renew or change your plan.',
              compact: true,
            )
          : Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: AppColor.borderSubtle),
                  _historyRow(list[i]),
                ],
              ],
            ),
    );
  }

  Widget _historyRow(Map<String, dynamic> r) {
    final status = '${r['status'] ?? ''}';
    final details = <String>[
      'Sent ${_date(r['requested_on'])}${r['requested_by_name'] != null ? ' by ${r['requested_by_name']}' : ''}',
      if (status == 'APPROVED')
        r['new_expires_on'] != null ? 'Valid until ${_date(r['new_expires_on'])}' : 'No end date',
      if ('${r['notes'] ?? ''}'.isNotEmpty) 'Your note: ${r['notes']}',
      if ('${r['resolution_notes'] ?? ''}'.isNotEmpty) 'Eldivex: ${r['resolution_notes']}',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${r['id']} · ${_requestSummary(r)}',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.textPrimary)),
                const SizedBox(height: 4),
                for (final d in details)
                  Text(d, style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppStatusBadge.status(status),
        ],
      ),
    );
  }

  // ── Request dialog ─────────────────────────────────────────────────────────

  void _openRequestDialog() {
    final sub = controller.subscription.value!;
    final currentPlanId = _int(sub['plan_id']);
    final planIds = controller.plans.map((p) => _int(p['id'])).whereType<int>().toList();
    final planId = Rxn<int>(planIds.contains(currentPlanId)
        ? currentPlanId
        : (planIds.isNotEmpty ? planIds.first : currentPlanId));
    final months = 12.obs;
    final notesCtrl = TextEditingController();

    num priceOf(int? id) {
      final p = controller.plans.firstWhereOrNull((p) => _int(p['id']) == id);
      return num.tryParse('${p?['price_per_month'] ?? sub['price_per_month'] ?? ''}') ?? 0;
    }

    Get.dialog(
      AppDialog(
        title: 'Request Extension',
        subtitle: 'The Eldivex team reviews it and updates your plan.',
        icon: LucideIcons.calendarPlus,
        tone: AppTone.primary,
        maxWidth: 520,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isSubmitting.value || planId.value == null
                    ? null
                    : () async {
                        final ok = await controller.requestExtension(
                          planId: planId.value!,
                          months: months.value,
                          notes: notesCtrl.text,
                        );
                        if (ok) Get.back();
                      },
                icon: const Icon(LucideIcons.send, size: 16),
                label: Text(controller.isSubmitting.value ? 'Sending…' : 'Send Request'),
              )),
        ],
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDropdown<int>(
                  label: 'Plan',
                  hint: 'Select plan',
                  value: planIds.contains(planId.value) ? planId.value : null,
                  items: [
                    for (final p in controller.plans)
                      DropdownMenuItem<int>(
                        value: _int(p['id']),
                        child: Text(
                          '${p['name']} · ${_money(p['price_per_month'])}/month'
                          '${_int(p['id']) == currentPlanId ? ' (current)' : ''}',
                        ),
                      ),
                  ],
                  onChanged: (v) => planId.value = v,
                ),
                const SizedBox(height: 16),
                Text('Extend by',
                    style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColor.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in PlanController.extendOptions)
                      ChoiceChip(
                        label: Text(m == 12 ? '1 year' : '$m month${m == 1 ? '' : 's'}'),
                        selected: months.value == m,
                        onSelected: (_) => months.value = m,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Note for the Eldivex team (optional)',
                    hintText: 'e.g. payment reference, preferred start date',
                  ),
                ),
                const SizedBox(height: 4),
                AppInfoRow(
                  label: 'Estimated cost',
                  horizontal: true,
                  labelWidth: 130,
                  value: '${_money(priceOf(planId.value) * months.value)}'
                      ' (${months.value} × ${_money(priceOf(planId.value))})',
                ),
              ],
            )),
      ),
    ).whenComplete(notesCtrl.dispose);
  }
}
