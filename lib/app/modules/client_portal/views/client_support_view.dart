import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';

class ClientSupportView extends StatefulWidget {
  const ClientSupportView({super.key});

  @override
  State<ClientSupportView> createState() => _ClientSupportViewState();
}

class _ClientSupportViewState extends State<ClientSupportView> {
  final c = Get.find<ClientController>();

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
        onPressed: () => _newTicket(context),
        icon: const Icon(Icons.add),
        label: const Text('New ticket'),
      ),
      body: Obx(() {
        if (c.loadingSupport.value) return const Center(child: CircularProgressIndicator());
        if (c.support.isEmpty) return HpUi.empty('No support tickets yet.', icon: Icons.support_agent);
        return RefreshIndicator(
          onRefresh: c.fetchSupport,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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
          Row(children: [
            Expanded(
              child: Text('${t['title'] ?? '—'}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
            ),
            HpUi.statusChip(open ? 'OPEN' : 'CLOSED', open ? Colors.orange : AppColor.lightGreen),
          ]),
          const SizedBox(height: 6),
          Text('${t['description'] ?? ''}',
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColor.fontColorGrey)),
          if ((t['category_name'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('${t['category_name']}', style: TextStyle(color: AppColor.cAppPrimaryColor, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  void _newTicket(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final RxnInt categoryId = RxnInt();

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
              Text('New support ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<int>(
                    initialValue: categoryId.value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: c.supportCategories
                        .map((cat) => DropdownMenuItem<int>(
                              value: cat['id'] is int ? cat['id'] : int.tryParse('${cat['id']}'),
                              child: Text('${cat['name']}'),
                            ))
                        .toList(),
                    onChanged: (v) => categoryId.value = v,
                  )),
              const SizedBox(height: 10),
              TextField(controller: title,
                  decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: desc, maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Describe the issue', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: c.busy.value
                          ? null
                          : () async {
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
