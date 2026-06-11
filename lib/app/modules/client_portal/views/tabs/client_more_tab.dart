import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/client_auth_controller.dart';
import '../../controllers/client_controller.dart';

class ClientMoreTab extends StatelessWidget {
  const ClientMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    final items = <(IconData, String, VoidCallback)>[
      (Icons.person_outline, 'My Profile', () => Get.toNamed(Routes.CLIENT_PROFILE)),
      (Icons.elderly_outlined, 'Patients', () => Get.toNamed(Routes.CLIENT_PATIENTS)),
      (Icons.support_agent_outlined, 'Support Tickets', () => Get.toNamed(Routes.CLIENT_SUPPORT)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(c.clientName,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
        ),
        const SizedBox(height: 8),
        ...items.map((e) => Card(
              elevation: 0,
              color: AppColor.whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColor.divColor)),
              child: ListTile(
                leading: Icon(e.$1, color: AppColor.cAppPrimaryColor),
                title: Text(e.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: e.$3,
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: ClientAuthController.logout,
          icon: Icon(Icons.logout, color: AppColor.calenderRed),
          label: Text('Logout', style: TextStyle(color: AppColor.calenderRed)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: AppColor.calenderRed),
          ),
        ),
      ],
    );
  }
}
