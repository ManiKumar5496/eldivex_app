import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/hp_auth_controller.dart';
import '../../controllers/hp_controller.dart';

class HpMoreTab extends StatelessWidget {
  const HpMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    final items = <(IconData, String, VoidCallback)>[
      (Icons.person_outline, 'My Profile', () => Get.toNamed(Routes.HP_PROFILE)),
      (Icons.receipt_long_outlined, 'Payslips & Payouts', () => Get.toNamed(Routes.HP_PAYSLIPS)),
      (Icons.support_agent_outlined, 'Support Tickets', () => Get.toNamed(Routes.HP_SUPPORT)),
      (Icons.beach_access_outlined, 'Leave Requests', () => Get.toNamed(Routes.HP_LEAVE)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(c.hpName,
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
          onPressed: HpAuthController.logout,
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
