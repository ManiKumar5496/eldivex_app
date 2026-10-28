import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/ui/ui.dart';
import '../../role/controllers/role_controller.dart';
import '../controllers/settings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(narrow ? 16 : 24),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppPageHeader(
                    title: 'Settings',
                    subtitle:
                        'Manage services, branches, coupons, and system configuration.',
                  ),
                  const SizedBox(height: 24),

                  // ── Grid of setting tiles ────────────────────────────────
                  AppResponsiveGrid(
                    minItemWidth: 300,
                    maxColumns: 3,
                    children: [
                      _SettingsTile(
                        icon: LucideIcons.stethoscope,
                        tone: AppTone.primary,
                        title: 'Services',
                        subtitle: 'Add and manage care services offered',
                        onTap: () => Get.toNamed(Routes.servicesManagement),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.landmark,
                        tone: AppTone.info,
                        title: 'Branches',
                        subtitle: 'Manage city branch offices',
                        onTap: () => Get.toNamed(Routes.branchManagement),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.banknote,
                        tone: AppTone.warning,
                        title: 'HP Payouts',
                        subtitle: 'Track and record caregiver payments',
                        onTap: () => Get.toNamed(Routes.hpPayouts),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.ticketPercent,
                        tone: AppTone.violet,
                        title: 'Coupons & OTP',
                        subtitle:
                            'Create discount coupons, retrieve booking OTPs',
                        onTap: () => Get.toNamed(Routes.settingsOtpCoupon),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.image,
                        tone: AppTone.success,
                        title: 'Banners',
                        subtitle: 'Manage promotional banners',
                        onTap: () => Get.toNamed(Routes.BANNERS),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.shieldUser,
                        tone: AppTone.neutral,
                        title: 'Roles',
                        subtitle: 'Configure access roles and permissions',
                        onTap: () => Get.toNamed(Routes.ROLE),
                      ),
                      _SettingsTile(
                        icon: LucideIcons.palette,
                        tone: AppTone.primary,
                        title: 'Appearance',
                        subtitle: 'Theme mode and brand color',
                        onTap: () => Get.toNamed(Routes.appearance),
                      ),
                      // Super Admin manages the plan; others just see it.
                      // Reactive: the role may finish loading after this page.
                      Obx(() => _isSuperAdmin()
                          ? _SettingsTile(
                              icon: LucideIcons.calendarPlus,
                              tone: AppTone.violet,
                              title: 'Plan & Renewal',
                              subtitle: 'Current plan, usage and extension requests',
                              onTap: () => Get.toNamed(Routes.planRenewal),
                            )
                          : _SettingsTile(
                              icon: LucideIcons.award,
                              tone: AppTone.violet,
                              title: 'Subscription',
                              subtitle: 'View your current plan and features',
                              onTap: () => _showSubscriptionDialog(context),
                            )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSuperAdmin() =>
      Get.isRegistered<RoleController>() && Get.find<RoleController>().isSuperAdmin;

  void _showSubscriptionDialog(BuildContext context) {
    final api = ApiService();
    showDialog(
      context: context,
      builder: (_) => AppDialog(
        title: 'Subscription',
        subtitle: 'Your current plan and enabled features',
        icon: LucideIcons.award,
        tone: AppTone.violet,
        maxWidth: 440,
        actions: [
          OutlinedButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
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
              return const AppEmptyState(
                icon: LucideIcons.cloudOff,
                title: 'Unable to fetch subscription details.',
                compact: true,
              );
            }
            final planName  = data['plan_name']?.toString()  ?? '—';
            final status    = data['status']?.toString()      ?? '—';
            final expiresOn = data['expires_on']?.toString();
            final features  = data['features'] is Map
                ? data['features'] as Map
                : <String, dynamic>{};

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _subRow('Plan', Text(
                  planName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                )),
                _subRow(
                  'Status',
                  AppStatusBadge(
                    label: humanizeLabel(status),
                    tone: status == 'active'
                        ? AppTone.success
                        : AppTone.warning,
                  ),
                ),
                if (expiresOn != null && expiresOn != 'null')
                  _subRow('Expires', Text(
                    expiresOn,
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                  )),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColor.borderSubtle),
                const SizedBox(height: 16),
                Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textTertiary,
                  ),
                ),
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
    );
  }

  Widget _subRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.5, color: AppColor.textTertiary)),
          const SizedBox(width: 12),
          Flexible(child: value),
        ],
      ),
    );
  }

  Widget _featureRow(String name, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? LucideIcons.circleCheck : LucideIcons.circleX,
            size: 16,
            color: enabled ? AppColor.success : AppColor.lightGrey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name[0].toUpperCase() + name.substring(1),
              style: TextStyle(
                  fontSize: 13.5,
                  color: enabled
                      ? AppColor.textPrimary
                      : AppColor.textTertiary),
            ),
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
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          AppIconTile(icon: icon, tone: tone, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(LucideIcons.chevronRight, color: AppColor.lightGrey, size: 20),
        ],
      ),
    );
  }
}
