import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_master_roles.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageMasterRoles extends GetView<DashboardController> {
  const ManageMasterRoles({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: SizeConfig.isMobile ? 16 : 24),
            Obx(() {
              if (controller.getMasterRolesLoading.value) {
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: HelperUi().loader(),
                );
              }
              return _buildRolesTable();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Roles & Permissions',
      subtitle: 'View and manage all roles',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(Routes.AddMasterRoles);
          },
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Role'),
        ),
      ],
    );
  }

  /// One row per role: identity on the left, the modules it can access as
  /// tags on the right (stacked on phones).
  Widget _buildRolesTable() {
    return AppCard(
      title: 'Roles',
      subtitle: 'Each role grants access to the modules listed beside it',
      icon: LucideIcons.shieldUser,
      padding: EdgeInsets.zero,
      footer: _buildTableFooter(),
      child: Obx(() {
        final roles = controller.getMasterRolesData;
        if (roles.isEmpty) {
          return AppEmptyState(
            compact: true,
            icon: LucideIcons.shieldUser,
            title: 'No roles yet',
            message: 'Create a role to control which modules employees can use.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!SizeConfig.isMobile) _buildListHeader(),
            for (var i = 0; i < roles.length; i++) ...[
              if (i > 0) Divider(height: 1, color: AppColor.borderSubtle),
              _buildRoleRow(roles[i]),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildListHeader() {
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColor.textTertiary,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(width: 280, child: Text('Role', style: style)),
          const SizedBox(width: 16),
          Expanded(child: Text('Access List', style: style)),
        ],
      ),
    );
  }

  Widget _buildRoleRow(GetMasterRoles role) {
    final identity = Row(
      children: [
        AppAvatar(
          name: role.roleName.isEmpty ? 'U' : role.roleName,
          size: 36,
          tone: AppTone.violet,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role.roleName.isEmpty ? 'N/A' : role.roleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Role ID ${role.id}',
                style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );

    final access = _buildAccessTags(role.modules);

    if (SizeConfig.isMobile) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [identity, const SizedBox(height: 12), access],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 280, child: identity),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: access,
            ),
          ),
        ],
      ),
    );
  }

  /// The role's comma-separated module list as tags.
  Widget _buildAccessTags(String modules) {
    final items = modules
        .split(',')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    if (items.isEmpty) {
      return Text(
        'No access list',
        style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final m in items)
          AppStatusBadge(
            label: m,
            tone: AppTone.neutral,
            showDot: false,
            dense: true,
          ),
      ],
    );
  }

  Widget _buildTableFooter() {
    return Obx(
      () => Text(
        'Showing ${controller.getMasterRolesData.length} roles',
        style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
      ),
    );
  }
}
