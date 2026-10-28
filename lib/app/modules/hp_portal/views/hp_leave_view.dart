import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpLeaveView extends StatefulWidget {
  const HpLeaveView({super.key});

  @override
  State<HpLeaveView> createState() => _HpLeaveViewState();
}

class _HpLeaveViewState extends State<HpLeaveView> {
  final c = Get.find<HpController>();

  @override
  void initState() {
    super.initState();
    c.fetchLeave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Leave requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _requestSheet(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Request leave'),
      ),
      body: Obx(() {
        if (c.loadingLeave.value) return const Center(child: CircularProgressIndicator());
        if (c.leave.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.umbrella,
            title: 'No leave requests yet.',
            message: 'Tap "Request leave" to apply for time off.',
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchLeave,
          child: ListView.separated(
            padding: HpUi.pagePadding(context, top: 20, bottom: 96),
            itemCount: c.leave.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tile(c.leave[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(Map<String, dynamic> l) {
    final status = '${l['status'] ?? 'Pending'}';
    final tone = status == 'Approved'
        ? AppTone.success
        : status == 'Rejected'
            ? AppTone.danger
            : AppTone.warning;
    return HpUi.card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: LucideIcons.calendar, tone: tone, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text('${l['from_date'] ?? ''} → ${l['to_date'] ?? ''}',
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge(
                        label: humanizeLabel(status), tone: tone, dense: true),
                  ],
                ),
                if ((l['reason'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${l['reason']}',
                      style: TextStyle(
                          fontSize: 13.5, color: AppColor.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _requestSheet(BuildContext context) {
    final reason = TextEditingController();
    final Rxn<DateTime> from = Rxn<DateTime>();
    final Rxn<DateTime> to = Rxn<DateTime>();

    String fmt(DateTime? d) => d == null
        ? 'Select'
        : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    Future<void> pick(Rxn<DateTime> target) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) target.value = picked;
    }

    Widget dateButton(String label, Rxn<DateTime> target) {
      return HpUi.field(
        label,
        Obx(() => OutlinedButton.icon(
              onPressed: () => pick(target),
              icon: Icon(LucideIcons.calendar,
                  size: 16, color: AppColor.textTertiary),
              label: Text(fmt(target.value),
                  style: TextStyle(
                      color: target.value == null
                          ? AppColor.textTertiary
                          : AppColor.textPrimary)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                alignment: Alignment.centerLeft,
              ),
            )),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HpUi.sheet(
        title: 'Request leave',
        subtitle: 'Choose the dates you will be away',
        icon: LucideIcons.umbrella,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: dateButton('From', from)),
              const SizedBox(width: 12),
              Expanded(child: dateButton('To', to)),
            ],
          ),
          HpUi.field(
            'Reason',
            TextField(
              controller: reason,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Add a short note'),
            ),
          ),
          const SizedBox(height: 6),
          Obx(() => HpUi.primaryButton(
                label: 'Submit',
                loading: c.busy.value,
                onTap: () async {
                  if (from.value == null || to.value == null) {
                    Get.snackbar('Missing', 'Select both dates.');
                    return;
                  }
                  final ok = await c.requestLeave(fmt(from.value), fmt(to.value), reason.text.trim());
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    );
  }
}
