import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';

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
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, c)),
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
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.15),
                  backgroundImage: p['user_image_url'] != null ? NetworkImage(p['user_image_url']) : null,
                  child: p['user_image_url'] == null
                      ? Icon(Icons.person, size: 40, color: AppColor.cAppPrimaryColor)
                      : null,
                ),
                const SizedBox(height: 10),
                Text('${p['user_name'] ?? ''}',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              ]),
            ),
            const SizedBox(height: 16),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Contact'),
                  HpUi.kv('Phone', '${p['phone_number'] ?? '—'}'),
                  HpUi.kv('Email', '${p['user_email'] ?? '—'}'),
                  HpUi.kv('Location', '${p['user_location'] ?? '—'}'),
                ],
              ),
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
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
              const SizedBox(height: 12),
              _f('Name', name),
              _f('Email', email),
              _f('Location', location),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: c.busy.value
                          ? null
                          : () async {
                              final ok = await c.updateProfile({
                                'user_name': name.text.trim(),
                                'user_email': email.text.trim(),
                                'user_location': location.text.trim(),
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

  Widget _f(String label, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
