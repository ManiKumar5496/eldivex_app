import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateUserRoles extends GetView<DashboardController> {
  const CreateUserRoles({super.key});

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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRoleDetailsCard(),
                const SizedBox(height: 20),
                _buildAccessListCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Create User Role',
      subtitle: 'Add a new role with access permissions',
      breadcrumbs: const ['Roles & Permissions', 'Create Role'],
      onBack: () => HelperUi.safeBack(Routes.MAIN),
    );
  }

  Widget _buildRoleDetailsCard() {
    return AppCard(
      title: 'Role Details',
      subtitle: 'Name the role so it is easy to pick when adding employees',
      icon: LucideIcons.idCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonTextField(
            label: 'Role Name',
            hint: 'Enter role name (e.g., Super Admin, Manager)',
            controller: controller.roleNameController,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            label: 'Role Description (Optional)',
            hint: 'Enter role description',
            controller: controller.roleDescriptionController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessListCard() {
    return AppCard(
      title: 'Access Permissions',
      subtitle: 'Modules people with this role can open',
      icon: LucideIcons.lockOpen,
      actions: [
        Obx(() => AppStatusBadge(
              label:
                  '${controller.selectedAccessList.length} permissions selected',
              tone: controller.selectedAccessList.isEmpty
                  ? AppTone.neutral
                  : AppTone.primary,
              showDot: false,
            )),
        Obx(() => controller.getMasterModuleData.isNotEmpty
            ? TextButton(
                onPressed: () {
                  if (controller.selectedAccessList.length ==
                      controller.getMasterModuleData.length) {
                    controller.selectedAccessList.clear();
                  } else {
                    controller.selectedAccessList.value = controller
                        .getMasterModuleData
                        .map((module) => module.id.toString())
                        .toList();
                  }
                },
                child: Text(
                  controller.selectedAccessList.length ==
                          controller.getMasterModuleData.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              )
            : const SizedBox.shrink()),
      ],
      child: Obx(() {
        // Show loading indicator while fetching
        if (controller.getMasterModuleListLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading access modules...',
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                ),
              ],
            ),
          );
        }

        // Show message if no modules available
        if (controller.getMasterModuleData.isEmpty) {
          return AppEmptyState(
            compact: true,
            icon: LucideIcons.info,
            title: 'No access modules available',
            actionLabel: 'Retry',
            actionIcon: LucideIcons.refreshCw,
            onAction: () => controller.getMasterModulesApi(),
          );
        }

        // Checkbox rows when modules are loaded
        return AppResponsiveGrid(
          minItemWidth: 220,
          maxColumns: 3,
          spacing: 10,
          children: controller.getMasterModuleData.map((module) {
            final moduleId = module.id.toString();
            final isSelected = controller.selectedAccessList.contains(moduleId);
            return _buildAccessChip(
              id: moduleId,
              label: module.moduleName,
              isSelected: isSelected,
            );
          }).toList(),
        );
      }),
    );
  }

  /// A module as a checkbox row; the whole row toggles it.
  Widget _buildAccessChip({
    required String id,
    required String label,
    required bool isSelected,
  }) {
    void onSelected(bool selected) {
      if (selected) {
        controller.selectedAccessList.add(id);
      } else {
        controller.selectedAccessList.remove(id);
      }
    }

    final radius = BorderRadius.circular(AppRadius.md);
    return Material(
      color: isSelected ? AppColor.primarySoft : AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isSelected
              ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.45)
              : AppColor.divColor,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => onSelected(!isSelected),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 12, 2),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (v) => onSelected(v ?? false),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColor.textPrimary
                        : AppColor.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: () {
            controller.clearRoleForm();
            HelperUi.safeBack(Routes.MAIN);
          },
          child: const Text('Cancel'),
        ),
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isCreateRoleLoading.value
              ? null
              : () => controller.createUserRole(),
          icon: controller.isCreateRoleLoading.value
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColor.textTertiary,
            ),
          )
              : const Icon(
            LucideIcons.check,
            size: 18,
          ),
          label: Text(
            controller.isCreateRoleLoading.value ? 'Creating...' : 'Create Role',
          ),
        )),
      ],
    );
  }
}
