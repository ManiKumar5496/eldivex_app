import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_auth_controller.dart';
import '../../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientMoreTab extends StatelessWidget {
  const ClientMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    final items = <(IconData, String, VoidCallback)>[
      (LucideIcons.user, 'My Profile', () => Get.toNamed(Routes.CLIENT_PROFILE)),
      (LucideIcons.heartHandshake, 'Patients', () => Get.toNamed(Routes.CLIENT_PATIENTS)),
      (LucideIcons.headset, 'Support Tickets', () => Get.toNamed(Routes.CLIENT_SUPPORT)),
    ];

    return ListView(
      padding: HpUi.pagePadding(context, top: 20),
      children: [
        HpUi.tabHeader('More'),
        HpUi.card(
          child: Row(
            children: [
              AppAvatar(name: c.clientName, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Client account',
                        style: TextStyle(
                            fontSize: 13, color: AppColor.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HpUi.menuGroup(items),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: ClientAuthController.logout,
          icon: const Icon(LucideIcons.logOut, size: 18),
          label: const Text('Logout'),
          style: AppButtonStyles.dangerOutlined.merge(
            OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          ),
        ),
      ],
    );
  }
}
