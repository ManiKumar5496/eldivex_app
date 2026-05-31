import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/common_file_upload.dart';
import '../../../widgets/elevated_button_common.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';

class RegisterCgView extends GetView<RegisterCgController> {
  const RegisterCgView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterCgController());
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('Personal Information'),
                _twoFieldRow(
                  CommonTextField(
                    label: 'First Name',
                    hint: 'Enter first name',
                    isMandatory: true,
                    controller: controller.hpFirstNameController,
                  ),
                  CommonTextField(
                    label: 'Last Name',
                    hint: 'Enter last name',
                    isMandatory: true,
                    controller: controller.hpLastNameController,
                  ),
                ),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Email',
                    hint: 'example@mail.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: controller.hpEmailController,
                  ),
                  CommonTextField(
                    label: 'Phone',
                    hint: '9876543210',
                    keyboardType: TextInputType.phone,
                    isMandatory: true,
                    controller: controller.hpPhoneController,
                  ),
                ),

                _twoFieldRow(
                  GestureDetector(
                    onTap: () => controller.pickDateOfBirth(context),
                    child: AbsorbPointer(
                      child: CommonTextField(
                        label: 'Date of Birth',
                        hint: 'YYYY-MM-DD',
                        controller: controller.hpDobController,
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                    ),
                  ),
                  Obx(() => CommonDropdown(
                    label: 'Gender',
                    hint: 'Select gender',
                    isMandatory: true,
                    value: controller.hpGender.value.isEmpty
                        ? null
                        : controller.hpGender.value,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (v) => controller.hpGender.value = v!,
                  )),
                ),

                _twoFieldRow(
                  Obx(() => CommonDropdown(
                    label: 'Marital Status',
                    hint: 'Select marital status',
                    value: controller.hpMaritalStatus.value.isEmpty
                        ? null
                        : controller.hpMaritalStatus.value,
                    items: const ['Single', 'Married', 'Divorced'],
                    onChanged: (v) =>
                    controller.hpMaritalStatus.value = v!,
                  )),
                  _buildLanguagesMultiSelect(),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// ADDRESS DETAILS
                /// =========================
                sectionTitle('Address Details'),

                CommonTextField(
                  label: 'Address',
                  hint: 'Enter full address',
                  isMandatory: true,
                  controller: controller.hpAddressController,
                ),
                const SizedBox(height: 8),

                _twoFieldRow(
                  CommonTextField(
                    label: 'City',
                    hint: 'Enter city',
                    onChanged: (v) => controller.hpCity.value = v,
                  ),
                  CommonTextField(
                    label: 'State',
                    hint: 'Enter state',
                    onChanged: (v) => controller.hpState.value = v,
                  ),
                ),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Pin Code',
                    hint: 'Enter pin code',
                    keyboardType: TextInputType.number,
                    isMandatory: true,
                    controller: controller.hpPinCodeController,
                  ),
                  Obx(() => CommonDropdown(
                    label: 'Branch',
                    hint: 'Select branch',
                    isMandatory: true,
                    value: controller.hpBranchId.value.isEmpty
                        ? null
                        : controller.hpBranchId.value,
                    items: controller.dashboardController.getAllBranches
                        .map((e) => e.brName)
                        .toList(),
                    onChanged: (v) =>
                    controller.hpBranchId.value = v!,
                  )),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// FAMILY INFORMATION
                /// =========================
                sectionTitle('Family Information'),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Father Name',
                    hint: 'Enter father name',
                    controller: controller.hpFatherNameController,
                  ),
                  CommonTextField(
                    label: 'Father Occupation',
                    hint: 'Enter occupation',
                    controller: controller.hpFatherOccupationController,
                  ),
                ),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Mother Name',
                    hint: 'Enter mother name',
                    controller: controller.hpMotherNameController,
                  ),
                  CommonTextField(
                    label: 'Emergency Contact',
                    hint: 'Enter emergency number',
                    keyboardType: TextInputType.phone,
                    controller: controller.hpEmergencyPhoneController,
                  ),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// IDENTITY INFORMATION
                /// =========================
                sectionTitle('Identity Information'),

                _twoFieldRow(
                  Obx(() => CommonDropdown(
                    label: 'ID Proof Type',
                    hint: 'Select ID proof',
                    isMandatory: true,
                    value: controller.hpIdentityProofType.value.isEmpty
                        ? null
                        : controller.hpIdentityProofType.value,
                    items: const ['Aadhaar', 'PAN', 'Voter ID'],
                    onChanged: (v) =>
                    controller.hpIdentityProofType.value = v!,
                  )),
                  CommonTextField(
                    label: 'ID Proof Number',
                    hint: 'Enter ID number',
                    isMandatory: true,
                    controller:
                    controller.hpIdentityProofNumberController,
                  ),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// PROFESSIONAL INFORMATION
                /// =========================
                sectionTitle('Professional Information'),

                _twoFieldRow(
                  Obx(() => CommonDropdown(
                    label: 'Education',
                    hint: 'Select education',
                    isMandatory: true,
                    value: controller.hpEducation.value.isEmpty
                        ? null
                        : controller.hpEducation.value,
                    items: const [
                      'Below 10th',
                      'Secondary (10th)',
                      'Intermediate (12th)',
                      'Diploma',
                      'ANM',
                      'GDA',
                      'GNM',
                      'Nursing',
                    ],
                    onChanged: (v) => controller.hpEducation.value = v!,
                  )),
                  CommonTextField(
                    label: 'Experience',
                    hint: 'Years of experience',
                    controller: controller.hpExperienceController,
                  ),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// PAY DETAILS
                /// =========================
                sectionTitle('Pay Details'),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Live-in Pay',
                    hint: 'Enter amount',
                    keyboardType: TextInputType.number,
                    controller: controller.liveInPayController,
                  ),
                  CommonTextField(
                    label: 'Live-out Pay',
                    hint: 'Enter amount',
                    keyboardType: TextInputType.number,
                    controller: controller.liveOutPayController,
                  ),
                ),

                _twoFieldRow(
                  CommonTextField(
                    label: 'Monthly Live-in Pay',
                    hint: 'Enter monthly amount',
                    keyboardType: TextInputType.number,
                    controller:
                    controller.monthlyLiveInPayController,
                  ),
                  CommonTextField(
                    label: 'Monthly Live-out Pay',
                    hint: 'Enter monthly amount',
                    keyboardType: TextInputType.number,
                    controller:
                    controller.monthlyLiveOutPayController,
                  ),
                ),

                const SizedBox(height: 32),

                /// =========================
                /// FILE UPLOAD
                /// =========================
                sectionTitle('Upload Documents'),

                CommonFileUpload(
                  label: 'Profile Photo',
                  hint: 'Upload JPG / PNG',
                  allowMultiple: false,
                  allowedExtensions: const ['jpg', 'jpeg', 'png'],
                  onFilesSelected: controller.onDocumentsSelected,
                  onFileRemoved: controller.onDocumentRemoved,
                ),

                const SizedBox(height: 20),

                CommonFileUpload(
                  label: 'ID Proof Front Image',
                  hint: 'Upload JPG / PNG',
                  allowMultiple: false,
                  allowedExtensions: const ['jpg', 'jpeg', 'png'],
                  onFilesSelected: controller.onIdProofFrontSelected,
                  onFileRemoved: controller.onIdProofFrontRemoved,
                ),

                const SizedBox(height: 20),

                CommonFileUpload(
                  label: 'ID Proof Back Image',
                  hint: 'Upload JPG / PNG',
                  allowMultiple: false,
                  allowedExtensions: const ['jpg', 'jpeg', 'png'],
                  onFilesSelected: controller.onIdProofBackSelected,
                  onFileRemoved: controller.onIdProofBackRemoved,
                ),

                const SizedBox(height: 20),

                CommonFileUpload(
                  label: 'Education Certificate',
                  hint: 'Upload JPG / PNG / PDF',
                  allowMultiple: false,
                  allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
                  onFilesSelected: controller.onEducationCertSelected,
                  onFileRemoved: controller.onEducationCertRemoved,
                ),

                const SizedBox(height: 32),

                /// =========================
                /// DECLARATION CHECKBOXES
                /// =========================
                sectionTitle('Declaration'),

                Obx(() => Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I confirm that the above details are correct',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: controller.isDetailsConfirmed.value,
                      onChanged: (v) =>
                      controller.isDetailsConfirmed.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I agree to the Terms & Conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: controller.isTermsAccepted.value,
                      onChanged: (v) =>
                      controller.isTermsAccepted.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I accept the Privacy Policy',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: controller.isPrivacyAccepted.value,
                      onChanged: (v) =>
                      controller.isPrivacyAccepted.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                )),

                const SizedBox(height: 40),

                /// =========================
                /// ACTION BUTTONS
                /// =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => controller.isCreateLoading.value
                        ? const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButtonCommon(
                            buttonColor: AppColor.cPrimaryButtonColor,
                            buttonText: 'Save Health Professional',
                            onTap: controller.isDetailsConfirmed.value &&
                                    controller.isTermsAccepted.value &&
                                    controller.isPrivacyAccepted.value
                                ? controller.createCg
                                : () {
                                    HelperUi.showToast(
                                      message:
                                          'Please confirm details, accept terms and privacy policy',
                                    );
                                  },
                          ),
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

  /// ================= HELPERS =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Register Health Professional',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildLanguagesMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.cPrimarySubHeadingColorGrey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.textFieldBorderColor),
          ),
          child: controller.availableLanguages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.availableLanguages.map((lang) {
                        final id = lang['id'] as int;
                        final name = lang['name'] as String;
                        final isSelected =
                            controller.hpSelectedLanguageIds.contains(id);
                        return FilterChip(
                          label: Text(name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              controller.hpSelectedLanguageIds.add(id);
                            } else {
                              controller.hpSelectedLanguageIds.remove(id);
                            }
                          },
                          selectedColor:
                              AppColor.cPrimaryButtonColor.withOpacity(0.2),
                          checkmarkColor: AppColor.cPrimaryButtonColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColor.cPrimaryButtonColor
                                : Colors.black87,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        )),
      ],
    );
  }

  Widget _twoFieldRow(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      ),
    );
  }

}
