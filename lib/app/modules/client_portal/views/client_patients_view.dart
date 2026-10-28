import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
        if (c.patients.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.heartHandshake,
            title: 'No patients found.',
            message: 'Patients linked to your account will appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchPatients,
          child: ListView.separated(
            padding: HpUi.pagePadding(context, top: 20),
            itemCount: c.patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tile(context, c.patients[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(BuildContext context, Map<String, dynamic> p) {
    return HpUi.card(
      onTap: () => _edit(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            AppAvatar(name: '${p['patient_name'] ?? '—'}', size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${p['patient_name'] ?? '—'}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary)),
            ),
            Tooltip(
              message: 'Edit patient',
              child: Icon(LucideIcons.pencil,
                  size: 18, color: AppColor.textTertiary),
            ),
          ]),
          const SizedBox(height: 8),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 4),
          HpUi.kv('Age', '${p['age'] ?? '—'}'),
          HpUi.kv('Relation', '${p['relation'] ?? '—'}'),
          HpUi.kv('Phone', '${p['phone_number'] ?? '—'}'),
          HpUi.kv('Languages', '${p['languages'] ?? '—'}'),
        ],
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
      builder: (_) => HpUi.sheet(
        title: 'Edit patient',
        subtitle: 'Keep the patient details up to date',
        icon: LucideIcons.heartHandshake,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        children: [
          _f('Name', name),
          _f('Phone', phone),
          _f('Age', age, number: true),
          _f('Relation', relation),
          _f('Languages', languages),
          const SizedBox(height: 6),
          Obx(() => HpUi.primaryButton(
                label: 'Save',
                loading: c.busy.value,
                onTap: () async {
                  final ok = await c.updatePatient(id, {
                    'patient_name': name.text.trim(),
                    'phone_number': phone.text.trim(),
                    if (age.text.trim().isNotEmpty) 'age': int.tryParse(age.text.trim()),
                    'relation': relation.text.trim(),
                    'languages': languages.text.trim(),
                  });
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController ctrl, {bool number = false}) =>
      HpUi.field(
        label,
        TextField(
          controller: ctrl,
          keyboardType: number ? TextInputType.number : TextInputType.text,
        ),
      );
}
