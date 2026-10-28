import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientProfileView extends StatelessWidget {
  const ClientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    if (c.profile.value == null) c.fetchProfile();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(LucideIcons.pencil, size: 20),
            onPressed: () => _edit(context, c),
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
        final name = '${p['user_name'] ?? ''}';
        return ListView(
          padding: HpUi.pagePadding(context, top: 20),
          children: [
            HpUi.card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(children: [
                AppAvatar(
                  name: name,
                  imageUrl: p['user_image_url']?.toString(),
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
                Text('Client',
                    style:
                        TextStyle(fontSize: 13, color: AppColor.textTertiary)),
              ]),
            ),
            const SizedBox(height: 16),
            HpUi.section(
              title: 'Contact',
              icon: LucideIcons.phone,
              children: [
                HpUi.kv('Phone', '${p['phone_number'] ?? '—'}'),
                HpUi.kv('Email', '${p['user_email'] ?? '—'}'),
                HpUi.kv('Location', '${p['user_location'] ?? '—'}'),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _edit(BuildContext context, ClientController c) {
    final p = c.profile.value ?? {};
    final name = TextEditingController(text: '${p['user_name'] ?? ''}');
    final email = TextEditingController(text: '${p['user_email'] ?? ''}');
    final location = TextEditingController(text: '${p['user_location'] ?? ''}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HpUi.sheet(
        title: 'Edit profile',
        subtitle: 'Update your name, email and location',
        icon: LucideIcons.pencil,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        children: [
          _f('Name', name),
          _f('Email', email),
          _f('Location', location),
          const SizedBox(height: 6),
          Obx(() => HpUi.primaryButton(
                label: 'Save',
                loading: c.busy.value,
                onTap: () async {
                  final ok = await c.updateProfile({
                    'user_name': name.text.trim(),
                    'user_email': email.text.trim(),
                    'user_location': location.text.trim(),
                  });
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController ctrl) =>
      HpUi.field(label, TextField(controller: ctrl));
}
