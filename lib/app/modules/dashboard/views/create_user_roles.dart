import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/helper_ui.dart';

class CreateUserRoles extends GetView<DashboardController> {
  const CreateUserRoles({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(DashboardController());
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                child: Column(
                  children: [
                    _buildRoleDetailsCard(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildAccessListCard(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 3),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColor.whiteColor,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 2,
        vertical: SizeConfig.blockSizeVertical * 2,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              size: SizeConfig.blockSizeHorizontal * 2,
              color: AppColor.fontColorGrey,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create User Role', style: AppTextStyles.heading),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Text(
                'Add a new role with access permissions',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role Details',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          CommonTextField(
            label: 'Role Name',
            hint: 'Enter role name (e.g., Super Admin, Manager)',
            controller: controller.roleNameController,
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Access Permissions',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.fontColorBlack,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                  Obx(() => Text(
                    '${controller.selectedAccessList.length} permissions selected',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                      color: AppColor.fontColorGrey,
                    ),
                  )),
                ],
              ),
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
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Obx(() {
            // Show loading indicator while fetching
            if (controller.getMasterRolesLoading.value) {
              return Center(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 3),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColor.cPrimaryButtonColor,
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      Text(
                        'Loading access modules...',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                          color: AppColor.fontColorGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show message if no modules available
            if (controller.getMasterRolesData.isEmpty) {
              return Center(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 3),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: SizeConfig.blockSizeHorizontal * 4,
                        color: AppColor.lightGrey,
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      Text(
                        'No access modules available',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                          color: AppColor.fontColorGrey,
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                      TextButton.icon(
                        onPressed: () => controller.getMasterRoles(),
                        icon: Icon(Icons.refresh,
                            size: SizeConfig.blockSizeHorizontal * 1.2),
                        label: Text(
                          'Retry',
                          style:
                          TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show chips when modules are loaded
            return Wrap(
              spacing: SizeConfig.blockSizeHorizontal * 1,
              runSpacing: SizeConfig.blockSizeVertical * 1,
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
        ],
      ),
    );
  }

  Widget _buildAccessChip({
    required String id,
    required String label,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.selectedAccessList.add(id);
        } else {
          controller.selectedAccessList.remove(id);
        }
      },
      labelStyle: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal * 1.1,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppColor.cPrimaryButtonColor : AppColor.fontColorGrey,
      ),
      backgroundColor: AppColor.whiteColor,
      selectedColor: AppColor.cPrimaryButtonColor.withOpacity(0.1),
      checkmarkColor: AppColor.cPrimaryButtonColor,
      side: BorderSide(
        color: isSelected ? AppColor.cPrimaryButtonColor : AppColor.divColor,
        width: isSelected ? 2 : 1,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 1.5,
        vertical: SizeConfig.blockSizeVertical * 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            controller.clearRoleForm();
            Get.back();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.fontColorGrey,
            side: BorderSide(color: AppColor.divColor),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 3,
              vertical: SizeConfig.blockSizeVertical * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.2),
          ),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isCreateRoleLoading.value
              ? null
              : () => controller.createUserRole(),
          icon: controller.isCreateRoleLoading.value
              ? SizedBox(
            width: SizeConfig.blockSizeHorizontal * 1.5,
            height: SizeConfig.blockSizeHorizontal * 1.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColor.buttonTextWhite,
            ),
          )
              : Icon(
            Icons.check,
            size: SizeConfig.blockSizeHorizontal * 1.5,
          ),
          label: Text(
            controller.isCreateRoleLoading.value ? 'Creating...' : 'Create Role',
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.2),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            foregroundColor: AppColor.buttonTextWhite,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 3,
              vertical: SizeConfig.blockSizeVertical * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        )),
      ],
    );
  }
}