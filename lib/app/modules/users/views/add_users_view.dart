import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/common_file_upload.dart';
import '../controllers/users_controller.dart';

class AddUsersView extends GetView<UsersController> {
  const AddUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Create or edit user information',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: 'First Name',
                        hint: 'Enter first name',
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
                        prefixIcon: Icons.email_outlined,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonTextField(
                        label: 'Phone Number',
                        hint: '+1 (555) 000-0000',
                        prefixIcon: Icons.phone_outlined,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: 'User Password',
                        hint: 'password',
                        prefixIcon: Icons.person_outline,
                        controller: controller.userPasswordController.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final roles = controller
                            .dashboardController
                            .getMasterRolesData
                            .value;

                        return CommonDropdown(
                          label: 'User Role',
                          hint: 'Select Role',
                          value: controller.selectedRole.value.isEmpty
                              ? null
                              : controller.selectedRole.value,
                          items: roles.map((e) => e.roleName ?? "").toList(),
                          onChanged: (value) {
                            controller.selectedRole.value = value!;
                            final matchedRole = roles.firstWhere(
                              (e) => e.roleName == value,
                            );
                            controller.selectedRoleId.value =
                                matchedRole.id.toString();
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
                      child: Obx(
                            () => CommonDropdown(
                          label: 'Branch',
                          hint: 'Select City',
                          value: controller.selectedCity.value.isEmpty
                              ? null
                              : controller.selectedCity.value,
                          items: controller.dashboardController.getAllBranches
                              .map((e) => e.brName)
                              .toList(),
                          onChanged: (value) {
                            controller.selectedCity.value = value!;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CommonTextField(
                  label: 'Bio',
                  hint: 'Tell us about yourself...',
                  controller: controller.bioController,
                  maxLines: 4,
                ),

                const SizedBox(height: 32),

                // File Upload Section
                CommonFileUpload(
                  label: 'Documents Upload',
                  hint: 'Click to upload or drag and drop',
                  supportedFormats: 'PDF, DOC, JPG or PNG (Max 10MB each)',
                  maxFileSizeMB: 10,
                  allowMultiple: false,
                  allowedExtensions: [ 'jpg', 'jpeg', 'png'],
                  onFilesSelected: (files) {
                    // Handle file selection
                    controller.onDocumentsSelected(files);
                    print('Files selected: ${files.map((f) => f.name).join(', ')}');
                  },
                  onFileRemoved: (file) {
                    // Handle file removal
                    controller.onDocumentRemoved(file);
                    print('File removed: ${file.name}');
                  },
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
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
                        // Handle save logic here
                        controller.createUser();
                        print("Saving user...");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Save Changes'),
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