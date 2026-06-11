import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';

class ClientPatientsView extends StatefulWidget {
  const ClientPatientsView({super.key});

  @override
  State<ClientPatientsView> createState() => _ClientPatientsViewState();
}

class _ClientPatientsViewState extends State<ClientPatientsView> {
  final c = Get.find<ClientController>();

  @override
  void initState() {
    super.initState();
    c.fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Patients')),
      body: Obx(() {
        if (c.loadingPatients.value) return const Center(child: CircularProgressIndicator());
        if (c.patients.isEmpty) return HpUi.empty('No patients found.', icon: Icons.elderly);
        return RefreshIndicator(
          onRefresh: c.fetchPatients,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: c.patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tile(context, c.patients[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(BuildContext context, Map<String, dynamic> p) {
    return InkWell(
      onTap: () => _edit(context, p),
      borderRadius: BorderRadius.circular(14),
      child: HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text('${p['patient_name'] ?? '—'}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              ),
              Icon(Icons.edit_outlined, size: 18, color: AppColor.fontColorGrey),
            ]),
            const SizedBox(height: 4),
            HpUi.kv('Age', '${p['age'] ?? '—'}'),
            HpUi.kv('Relation', '${p['relation'] ?? '—'}'),
            HpUi.kv('Phone', '${p['phone_number'] ?? '—'}'),
            HpUi.kv('Languages', '${p['languages'] ?? '—'}'),
          ],
        ),
      ),
    );
  }

  void _edit(BuildContext context, Map<String, dynamic> p) {
    final id = p['id'] is int ? p['id'] : int.tryParse('${p['id']}') ?? 0;
    final name = TextEditingController(text: '${p['patient_name'] ?? ''}');
    final phone = TextEditingController(text: '${p['phone_number'] ?? ''}');
    final age = TextEditingController(text: '${p['age'] ?? ''}');
    final relation = TextEditingController(text: '${p['relation'] ?? ''}');
    final languages = TextEditingController(text: '${p['languages'] ?? ''}');

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
              Text('Edit patient',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              const SizedBox(height: 12),
              _f('Name', name),
              _f('Phone', phone),
              _f('Age', age, number: true),
              _f('Relation', relation),
              _f('Languages', languages),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: c.busy.value
                          ? null
                          : () async {
                              final ok = await c.updatePatient(id, {
                                'patient_name': name.text.trim(),
                                'phone_number': phone.text.trim(),
                                if (age.text.trim().isNotEmpty) 'age': int.tryParse(age.text.trim()),
                                'relation': relation.text.trim(),
                                'languages': languages.text.trim(),
                              });
                              if (ok) Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: AppColor.buttonTextWhite,
                      ),
                      child: c.busy.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save'),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(String label, TextEditingController ctrl, {bool number = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: ctrl,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
