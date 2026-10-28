import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
            tooltip: 'Edit profile',
            icon: const Icon(LucideIcons.pencil, size: 20),
            onPressed: () => _editSheet(context, c),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (c.loadingProfile.value && c.profile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = c.profile.value;
        if (p == null) {
          return AppEmptyState(
            icon: LucideIcons.userX,
            tone: AppTone.danger,
            title: 'Could not load profile.',
            message: 'Please check your connection and try again.',
            actionLabel: 'Retry',
            actionIcon: LucideIcons.refreshCw,
            onAction: c.fetchProfile,
          );
        }
        final name = '${p['hp_reg_first_name'] ?? ''} ${p['hp_reg_last_name'] ?? ''}';
        return ListView(
          padding: HpUi.pagePadding(context, top: 20),
          children: [
            HpUi.card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  AppAvatar(
                    name: name,
                    imageUrl: p['hp_reg_photo_url']?.toString(),
                    size: 80,
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColor.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Caregiver',
                      style: TextStyle(
                          fontSize: 13, color: AppColor.textTertiary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HpUi.section(
              title: 'Contact',
              icon: LucideIcons.phone,
              children: [
                HpUi.kv('Phone', '${p['hp_reg_phone_number'] ?? '—'}'),
                HpUi.kv('Email', '${p['hp_reg_email'] ?? '—'}'),
                HpUi.kv('Emergency', '${p['hp_reg_emergency_contact_phone'] ?? '—'}'),
              ],
            ),
            const SizedBox(height: 16),
            HpUi.section(
              title: 'Address',
              icon: LucideIcons.house,
              children: [
                HpUi.kv('Address', '${p['hp_reg_address'] ?? '—'}'),
                HpUi.kv('City', '${p['hp_reg_city'] ?? '—'}'),
                HpUi.kv('State', '${p['hp_reg_state'] ?? '—'}'),
                HpUi.kv('Pincode', '${p['hp_reg_pin_code'] ?? '—'}'),
                HpUi.kv('Languages', '${p['hp_reg_languages'] ?? '—'}'),
              ],
            ),
            const SizedBox(height: 16),
            HpUi.section(
              title: 'Work & pay',
              icon: LucideIcons.briefcase,
              children: [
                HpUi.kv('Experience', '${p['hp_reg_experience'] ?? '—'} yrs'),
                HpUi.kv('Education', '${p['hp_reg_education'] ?? '—'}'),
                HpUi.kv('Live-in / day', HpUi.money(p['livein_pay'])),
                HpUi.kv('Live-out / day', HpUi.money(p['liveout_pay'])),
              ],
            ),
            const SizedBox(height: 16),
            HpUi.section(
              title: 'KYC',
              icon: LucideIcons.idCard,
              children: [
                HpUi.kv('ID type', '${p['hp_reg_identity_proof_type'] ?? '—'}'),
                HpUi.kv('ID number', '${p['hp_reg_identity_proof_number'] ?? '—'}'),
              ],
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
      builder: (_) => HpUi.sheet(
        title: 'Edit profile',
        subtitle: 'Update your contact and address details',
        icon: LucideIcons.pencil,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        children: [
          _field('Phone', phone),
          _field('Emergency contact', emergency),
          _field('Address', address),
          _field('City', city),
          _field('Pincode', pincode),
          _field('Languages (comma separated)', languages),
          const SizedBox(height: 6),
          Obx(() => HpUi.primaryButton(
                label: 'Save',
                loading: c.busy.value,
                onTap: () async {
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
              )),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return HpUi.field(label, TextField(controller: ctrl));
  }
}
