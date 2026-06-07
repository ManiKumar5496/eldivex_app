import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Manage services, branches, coupons, and system configuration.',
                style: AppTextStyles.regular14Gre,
              ),
              const SizedBox(height: 32),

              // ── Grid of setting tiles ──────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.4,
                    children: [
                      _SettingsTile(
                        icon: Icons.medical_services_outlined,
                        iconColor: AppColor.cAppPrimaryColor,
                        title: 'Services',
                        subtitle: 'Add and manage care services offered',
                        onTap: () =>
                            Get.toNamed(Routes.servicesManagement),
                      ),
                      _SettingsTile(
                        icon: Icons.account_balance_outlined,
                        iconColor: AppColor.cPrimaryButtonColor,
                        title: 'Branches',
                        subtitle: 'Manage city branch offices',
                        onTap: () =>
                            Get.toNamed(Routes.branchManagement),
                      ),
                      _SettingsTile(
                        icon: Icons.payments_outlined,
                        iconColor: AppColor.babyCColor,
                        title: 'HP Payouts',
                        subtitle: 'Track and record caregiver payments',
                        onTap: () => Get.toNamed(Routes.hpPayouts),
                      ),
                      _SettingsTile(
                        icon: Icons.local_offer_outlined,
                        iconColor: AppColor.consultCColor,
                        title: 'Coupons & OTP',
                        subtitle: 'Create discount coupons, retrieve booking OTPs',
                        onTap: () => Get.toNamed(Routes.settingsOtpCoupon),
                      ),
                      _SettingsTile(
                        icon: Icons.image_outlined,
                        iconColor: AppColor.careCColor,
                        title: 'Banners',
                        subtitle: 'Manage promotional banners',
                        onTap: () => Get.toNamed(Routes.BANNERS),
                      ),
                      _SettingsTile(
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: AppColor.fontColorGrey,
                        title: 'Roles',
                        subtitle: 'Configure access roles and permissions',
                        onTap: () => Get.toNamed(Routes.ROLE),
                      ),
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        iconColor: AppColor.cPrimaryButtonColor,
                        title: 'Appearance',
                        subtitle: 'Theme mode and brand color',
                        onTap: () => Get.toNamed(Routes.appearance),
                      ),
                      _SettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        iconColor: Colors.deepPurple,
                        title: 'Subscription',
                        subtitle: 'View your current plan and features',
                        onTap: () => _showSubscriptionDialog(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    final api = ApiService();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subscription'),
        content: SizedBox(
          width: 380,
          child: FutureBuilder(
            future: api.getRaw(ApiConstants.getSubscriptionStatus),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data?.data as Map<String, dynamic>?;
              if (data == null) {
                return const Text('Unable to fetch subscription details.');
              }
              final planName  = data['plan_name']?.toString()  ?? '—';
              final status    = data['status']?.toString()      ?? '—';
              final expiresOn = data['expires_on']?.toString();
              final features  = data['features'] is Map
                  ? data['features'] as Map
                  : <String, dynamic>{};

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subRow('Plan', planName,
                      valueColor: Colors.deepPurple),
                  _subRow('Status', status,
                      valueColor: status == 'active' ? Colors.green : Colors.orange),
                  if (expiresOn != null && expiresOn != 'null')
                    _subRow('Expires', expiresOn),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Features', style: AppTextStyles.regular14Gre),
                  const SizedBox(height: 8),
                  ...features.entries.map((e) => _featureRow(
                        e.key.toString().replaceAll('_', ' '),
                        e.value == true,
                      )),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _subRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.regular14Gre),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColor.fontColorBlack)),
        ],
      ),
    );
  }

  Widget _featureRow(String name, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: enabled ? Colors.green : AppColor.fontColorGrey,
          ),
          const SizedBox(width: 8),
          Text(
            name[0].toUpperCase() + name.substring(1),
            style: TextStyle(
                fontSize: 13,
                color: enabled ? AppColor.fontColorBlack : AppColor.fontColorGrey),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tile Widget ──────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColor.cAppBackgroundColor,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.divColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: AppTextStyles.regular16
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.regular12Gre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColor.lightGrey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
