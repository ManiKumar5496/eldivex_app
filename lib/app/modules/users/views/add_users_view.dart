import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:get/get.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
// import '../../../widgets/common_file_upload.dart';
import '../../../widgets/helper_ui.dart';
import '../../../routes/app_pages.dart';
import '../controllers/users_controller.dart';

class AddUsersView extends GetView<UsersController> {
  const AddUsersView({super.key});

  bool get isEditMode => controller.editingUser.value != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fieldColorGrey,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.clearFilters();
            HelperUi.safeBack(Routes.MAIN);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Edit User' : 'User Management',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEditMode ? 'Update user information' : 'Create or edit user information',
              style: TextStyle(color: AppColor.fontColorGrey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.divColor),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.fontColorGrey,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: 'First Name',
                        hint: 'Enter first name',
                        isMandatory: true,
                        prefixIcon: Icons.person_outline,
                        controller: controller.firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonTextField(
                        label: 'Last Name',
                        hint: 'Enter last name',
                        prefixIcon: Icons.person_outline,
                        controller: controller.lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: 'Email Address',
                        hint: 'user@example.com',
                        isMandatory: true,
                        prefixIcon: Icons.email_outlined,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonTextField(
                        label: 'Phone Number',
                        hint: '10-digit mobile, e.g. 9876543210',
                        isMandatory: true,
                        prefixIcon: Icons.phone_outlined,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Password is only set at creation; edits keep the existing one.
                if (!isEditMode) ...[
                  CommonTextField(
                    label: 'User Password',
                    hint: 'Minimum 8 characters',
                    prefixIcon: Icons.lock_outline,
                    isMandatory: true,
                    controller: controller.userPasswordController.value,
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Obx(() => CommonDropdown(
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
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
                  ],
                ),

                const SizedBox(height: 32),

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

                // const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        HelperUi.safeBack(Routes.MAIN);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}