import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../controllers/hp_auth_controller.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpMoreTab extends StatelessWidget {
  const HpMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    final items = <(IconData, String, VoidCallback)>[
      (LucideIcons.user, 'My Profile', () => Get.toNamed(Routes.HP_PROFILE)),
      (LucideIcons.receiptText, 'Payslips & Payouts', () => Get.toNamed(Routes.HP_PAYSLIPS)),
      (LucideIcons.headset, 'Support Tickets', () => Get.toNamed(Routes.HP_SUPPORT)),
      (LucideIcons.umbrella, 'Leave Requests', () => Get.toNamed(Routes.HP_LEAVE)),
    ];

    return ListView(
      padding: HpUi.pagePadding(context, top: 20),
      children: [
        HpUi.tabHeader('More'),
        HpUi.card(
          child: Row(
            children: [
              AppAvatar(name: c.hpName, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.hpName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Caregiver account',
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
          onPressed: HpAuthController.logout,
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
