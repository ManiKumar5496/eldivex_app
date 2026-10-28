import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:get/get.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
// import '../../../widgets/common_file_upload.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../../../routes/app_pages.dart';
import '../controllers/users_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AddUsersView extends GetView<UsersController> {
  const AddUsersView({super.key});

  bool get isEditMode => controller.editingUser.value != null;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
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
                AppPageHeader(
                  title: isEditMode ? 'Edit User' : 'Add User',
                  subtitle: isEditMode
                      ? 'Update user information'
                      : 'Create or edit user information',
                  breadcrumbs: [
                    'Employees',
                    isEditMode ? 'Edit User' : 'Add User',
                  ],
                  onBack: () {
                    controller.clearFilters();
                    HelperUi.safeBack(Routes.MAIN);
                  },
                ),
                const SizedBox(height: 24),

                // Personal Information
                AppCard(
                  title: 'Personal Information',
                  subtitle: 'Name and contact details',
                  icon: LucideIcons.user,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _twoColumns(
                        CommonTextField(
                          label: 'First Name',
                          hint: 'Enter first name',
                          isMandatory: true,
                          prefixIcon: LucideIcons.user,
                          controller: controller.firstNameController,
                        ),
                        CommonTextField(
                          label: 'Last Name',
                          hint: 'Enter last name',
                          prefixIcon: LucideIcons.user,
                          controller: controller.lastNameController,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _twoColumns(
                        CommonTextField(
                          label: 'Email Address',
                          hint: 'user@example.com',
                          isMandatory: true,
                          prefixIcon: LucideIcons.mail,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        CommonTextField(
                          label: 'Phone Number',
                          hint: '10-digit mobile, e.g. 9876543210',
                          isMandatory: true,
                          prefixIcon: LucideIcons.phone,
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _twoColumns(
                        Obx(() => CommonDropdown(
                              label: 'Gender',
                              hint: 'Select Gender',
                              value: controller.userGender.value.isEmpty
                                  ? null
                                  : controller.userGender.value,
                              items: const ['Male', 'Female', 'Other'],
                              onChanged: (value) {
                                controller.userGender.value = value ?? '';
                              },
                            )),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Role, branch and (on create) password
                AppCard(
                  title: 'Account & Access',
                  subtitle: 'Role, branch and sign-in details',
                  icon: LucideIcons.shieldUser,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _twoColumns(
                        Obx(() {
                          final roles =
                              controller.dashboardController.getMasterRolesData;
                          final names = roles
                              .map((e) => e.roleName)
                              .where((n) => n.isNotEmpty)
                              .toSet()
                              .toList();
                          final current = controller.selectedRole.value;

                          return CommonDropdown(
                            label: 'User Role',
                            hint: 'Select Role',
                            isMandatory: true,
                            value: names.contains(current) ? current : null,
                            items: names,
                            onChanged: (value) {
                              if (value == null) return;
                              controller.selectedRole.value = value;
                              final matchedRole = roles
                                  .firstWhereOrNull((e) => e.roleName == value);
                              controller.selectedRoleId.value =
                                  matchedRole?.id.toString() ?? '';
                            },
                          );
                        }),
                        Obx(() {
                          final branches = controller
                              .dashboardController.getAllBranches
                              .map((e) => e.brName)
                              .where((n) => n.isNotEmpty)
                              .toSet()
                              .toList();
                          final current = controller.selectedCity.value;
                          return CommonDropdown(
                            label: 'Branch',
                            hint: 'Select Branch',
                            value: branches.contains(current) ? current : null,
                            items: branches,
                            onChanged: (value) {
                              controller.selectedCity.value = value ?? '';
                              final branch = controller.dashboardController
                                  .getAllBranches
                                  .firstWhereOrNull((e) => e.brName == value);
                              controller.selectedBranchIdForUser.value =
                                  branch?.brId ?? 0;
                            },
                          );
                        }),
                      ),
                      // Password is only set at creation; edits keep the existing one.
                      if (!isEditMode) ...[
                        const SizedBox(height: 16),
                        _twoColumns(
                          CommonTextField(
                            label: 'User Password',
                            hint: 'Minimum 8 characters',
                            prefixIcon: LucideIcons.lock,
                            isMandatory: true,
                            controller: controller.userPasswordController.value,
                          ),
                          const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),

                // CommonFileUpload(
                //   label: 'Documents Upload',
                //   hint: 'Click to upload or drag and drop',
                //   supportedFormats: 'PDF, DOC, JPG or PNG (Max 10MB each)',
                //   maxFileSizeMB: 10,
                //   allowMultiple: false,
                //   allowedExtensions: ['jpg', 'jpeg', 'png'],
                //   onFilesSelected: (files) {
                //     controller.onDocumentsSelected(files);
                //   },
                //   onFileRemoved: (file) {
                //     controller.onDocumentRemoved(file);
                //   },
                // ),

                const SizedBox(height: 24),

                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        HelperUi.safeBack(Routes.MAIN);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.isCreateLoading.value ||
                            controller.isUpdateLoading.value) {
                          return;
                        }
                        if (isEditMode) {
                          controller.updateUser();
                        } else {
                          controller.createUser();
                        }
                      },
                      child: Obx(() {
                        final loading = isEditMode
                            ? controller.isUpdateLoading.value
                            : controller.isCreateLoading.value;
                        return loading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.buttonTextWhite),
                                ),
                              )
                            : Text(isEditMode ? 'Update User' : 'Save Changes');
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Two fields side by side on wide cards, stacked on narrow ones.
  Widget _twoColumns(Widget left, Widget right) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 640) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            left,
            if (right is! SizedBox) ...[const SizedBox(height: 16), right],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
    });
  }
}
