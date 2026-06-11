import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';

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
        icon: const Icon(Icons.add),
        label: const Text('Request leave'),
      ),
      body: Obx(() {
        if (c.loadingLeave.value) return const Center(child: CircularProgressIndicator());
        if (c.leave.isEmpty) return HpUi.empty('No leave requests yet.', icon: Icons.beach_access);
        return RefreshIndicator(
          onRefresh: c.fetchLeave,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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
    final color = status == 'Approved'
        ? AppColor.lightGreen
        : status == 'Rejected'
            ? AppColor.calenderRed
            : Colors.orange;
    return HpUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${l['from_date'] ?? ''} → ${l['to_date'] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              ),
              HpUi.statusChip(status.toUpperCase(), color),
            ],
          ),
          if ((l['reason'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('${l['reason']}', style: TextStyle(color: AppColor.fontColorGrey)),
          ],
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Request leave',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Obx(() => OutlinedButton(onPressed: () => pick(from), child: Text('From: ${fmt(from.value)}')))),
                  const SizedBox(width: 8),
                  Expanded(child: Obx(() => OutlinedButton(onPressed: () => pick(to), child: Text('To: ${fmt(to.value)}')))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: reason, maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: c.busy.value
                          ? null
                          : () async {
                              if (from.value == null || to.value == null) {
                                Get.snackbar('Missing', 'Select both dates.');
                                return;
                              }
                              final ok = await c.requestLeave(fmt(from.value), fmt(to.value), reason.text.trim());
                              if (ok) Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: AppColor.buttonTextWhite,
                      ),
                      child: c.busy.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit'),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
