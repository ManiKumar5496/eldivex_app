import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';

class HpProfileView extends StatelessWidget {
  const HpProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    if (c.profile.value == null) c.fetchProfile();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editSheet(context, c),
          ),
        ],
      ),
      body: Obx(() {
        if (c.loadingProfile.value && c.profile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = c.profile.value;
        if (p == null) return HpUi.empty('Could not load profile.');
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.15),
                    backgroundImage: (p['hp_reg_photo_url'] != null)
                        ? NetworkImage(p['hp_reg_photo_url'])
                        : null,
                    child: p['hp_reg_photo_url'] == null
                        ? Icon(Icons.person, size: 40, color: AppColor.cAppPrimaryColor)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text('${p['hp_reg_first_name'] ?? ''} ${p['hp_reg_last_name'] ?? ''}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cPrimaryHeadingColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Contact'),
                  HpUi.kv('Phone', '${p['hp_reg_phone_number'] ?? '—'}'),
                  HpUi.kv('Email', '${p['hp_reg_email'] ?? '—'}'),
                  HpUi.kv('Emergency', '${p['hp_reg_emergency_contact_phone'] ?? '—'}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Address'),
                  HpUi.kv('Address', '${p['hp_reg_address'] ?? '—'}'),
                  HpUi.kv('City', '${p['hp_reg_city'] ?? '—'}'),
                  HpUi.kv('State', '${p['hp_reg_state'] ?? '—'}'),
                  HpUi.kv('Pincode', '${p['hp_reg_pin_code'] ?? '—'}'),
                  HpUi.kv('Languages', '${p['hp_reg_languages'] ?? '—'}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Work & pay'),
                  HpUi.kv('Experience', '${p['hp_reg_experience'] ?? '—'} yrs'),
                  HpUi.kv('Education', '${p['hp_reg_education'] ?? '—'}'),
                  HpUi.kv('Live-in / day', HpUi.money(p['livein_pay'])),
                  HpUi.kv('Live-out / day', HpUi.money(p['liveout_pay'])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('KYC'),
                  HpUi.kv('ID type', '${p['hp_reg_identity_proof_type'] ?? '—'}'),
                  HpUi.kv('ID number', '${p['hp_reg_identity_proof_number'] ?? '—'}'),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _editSheet(BuildContext context, HpController c) {
    final p = c.profile.value ?? {};
    final phone = TextEditingController(text: '${p['hp_reg_phone_number'] ?? ''}');
    final address = TextEditingController(text: '${p['hp_reg_address'] ?? ''}');
    final city = TextEditingController(text: '${p['hp_reg_city'] ?? ''}');
    final pincode = TextEditingController(text: '${p['hp_reg_pin_code'] ?? ''}');
    final languages = TextEditingController(text: '${p['hp_reg_languages'] ?? ''}');
    final emergency = TextEditingController(text: '${p['hp_reg_emergency_contact_phone'] ?? ''}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              const SizedBox(height: 12),
              _field('Phone', phone),
              _field('Emergency contact', emergency),
              _field('Address', address),
              _field('City', city),
              _field('Pincode', pincode),
              _field('Languages (comma separated)', languages),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: c.busy.value
                          ? null
                          : () async {
                              final ok = await c.updateProfile({
                                'hp_reg_phone_number': phone.text.trim(),
                                'hp_reg_emergency_contact_phone': emergency.text.trim(),
                                'hp_reg_address': address.text.trim(),
                                'hp_reg_city': city.text.trim(),
                                'hp_reg_pin_code': pincode.text.trim(),
                                'hp_reg_languages': languages.text.trim(),
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

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
