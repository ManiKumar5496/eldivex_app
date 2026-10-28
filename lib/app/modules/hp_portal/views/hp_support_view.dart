import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpSupportView extends StatefulWidget {
  const HpSupportView({super.key});

  @override
  State<HpSupportView> createState() => _HpSupportViewState();
}

class _HpSupportViewState extends State<HpSupportView> {
  final c = Get.find<HpController>();

  @override
  void initState() {
    super.initState();
    c.fetchSupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newTicketSheet(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New ticket'),
      ),
      body: Obx(() {
        if (c.loadingSupport.value) return const Center(child: CircularProgressIndicator());
        if (c.support.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.headset,
            title: 'No support tickets yet.',
            message: 'Need help? Raise a ticket and our team will get back to you.',
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchSupport,
          child: ListView.separated(
            padding: HpUi.pagePadding(context, top: 20, bottom: 96),
            itemCount: c.support.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tile(c.support[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(Map<String, dynamic> t) {
    final open = '${t['status'] ?? ''}' == '1';
    return HpUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('${t['title'] ?? '—'}',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
              ),
              const SizedBox(width: 8),
              AppStatusBadge(
                label: open ? 'Open' : 'Closed',
                tone: open ? AppTone.warning : AppTone.success,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${t['description'] ?? ''}',
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, height: 1.45, color: AppColor.textSecondary)),
          if ((t['category_name'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(LucideIcons.tag, size: 14, color: AppColor.textTertiary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('${t['category_name']}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textTertiary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _newTicketSheet(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final RxnInt categoryId = RxnInt();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HpUi.sheet(
        title: 'New support ticket',
        subtitle: 'Tell us what you need help with',
        icon: LucideIcons.headset,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        children: [
          HpUi.field(
            'Category',
            Obx(() => DropdownButtonFormField<int>(
                  initialValue: categoryId.value,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  decoration: const InputDecoration(hintText: 'Select a category'),
                  items: c.supportCategories
                      .map((cat) => DropdownMenuItem<int>(
                            value: cat['id'] is int ? cat['id'] : int.tryParse('${cat['id']}'),
                            child: Text('${cat['name']}'),
                          ))
                      .toList(),
                  onChanged: (v) => categoryId.value = v,
                )),
          ),
          HpUi.field(
            'Subject',
            TextField(
              controller: title,
              decoration: const InputDecoration(hintText: 'Short summary of the issue'),
            ),
          ),
          HpUi.field(
            'Describe the issue',
            TextField(
              controller: desc,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Add as much detail as you can'),
            ),
          ),
          const SizedBox(height: 6),
          Obx(() => HpUi.primaryButton(
                label: 'Submit',
                loading: c.busy.value,
                onTap: () async {
                  if (title.text.trim().isEmpty || desc.text.trim().isEmpty) {
                    Get.snackbar('Missing', 'Subject and description are required.');
                    return;
                  }
                  final ok = await c.createSupport(
                    title: title.text.trim(),
                    description: desc.text.trim(),
                    categoryId: categoryId.value,
                  );
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    );
  }
}
