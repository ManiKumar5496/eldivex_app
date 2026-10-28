import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/common_file_upload.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class RegisterCgView extends GetView<RegisterCgController> {
  const RegisterCgView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterCgController());
    SizeConfig.init(context);

    // This page is both a sidebar page and a pushed route (from Manage HP);
    // only show the back button when there is something to go back to.
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Register Health Professional',
                  subtitle:
                      'Add a new health professional with their personal, pay and document details',
                  onBack: canGoBack ? () => Get.back() : null,
                ),
                const SizedBox(height: 24),

                /// =========================
                /// PERSONAL INFORMATION
                /// =========================
                _section(
                  title: 'Personal Information',
                  subtitle: 'Name, contact and basic profile details',
                  icon: LucideIcons.user,
                  children: [
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
                    GestureDetector(
                      onTap: () => controller.pickDateOfBirth(context),
                      child: AbsorbPointer(
                        child: CommonTextField(
                          label: 'Date of Birth',
                          hint: 'YYYY-MM-DD',
                          controller: controller.hpDobController,
                          suffixIcon: Icon(LucideIcons.calendar,
                              size: 18, color: AppColor.textTertiary),
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
                  ],
                ),

                /// =========================
                /// ADDRESS DETAILS
                /// =========================
                _section(
                  title: 'Address Details',
                  subtitle: 'Where the health professional lives and which branch they belong to',
                  icon: LucideIcons.mapPin,
                  children: [
                    _FullWidth(
                      CommonTextField(
                        label: 'Address',
                        hint: 'Enter full address',
                        isMandatory: true,
                        controller: controller.hpAddressController,
                      ),
                    ),
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
                  ],
                ),

                /// =========================
                /// FAMILY INFORMATION
                /// =========================
                _section(
                  title: 'Family Information',
                  subtitle: 'Family details and an emergency contact',
                  icon: LucideIcons.users,
                  children: [
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
                  ],
                ),

                /// =========================
                /// IDENTITY INFORMATION
                /// =========================
                _section(
                  title: 'Identity Information',
                  subtitle: 'Government ID used for verification',
                  icon: LucideIcons.idCard,
                  children: [
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
                  ],
                ),

                /// =========================
                /// PROFESSIONAL INFORMATION
                /// =========================
                _section(
                  title: 'Professional Information',
                  subtitle: 'Qualifications and experience',
                  icon: LucideIcons.briefcase,
                  children: [
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
                  ],
                ),

                /// =========================
                /// PAY DETAILS
                /// =========================
                _section(
                  title: 'Pay Details',
                  subtitle: 'Daily and monthly rates for live-in and live-out shifts',
                  icon: LucideIcons.indianRupee,
                  children: [
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
                  ],
                ),

                /// =========================
                /// FILE UPLOAD
                /// =========================
                _section(
                  title: 'Upload Documents',
                  subtitle: 'Profile photo, ID proof and education certificate',
                  icon: LucideIcons.fileUp,
                  children: [
                    CommonFileUpload(
                      label: 'Profile Photo',
                      hint: 'Upload JPG / PNG',
                      allowMultiple: false,
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      onFilesSelected: controller.onDocumentsSelected,
                      onFileRemoved: controller.onDocumentRemoved,
                    ),
                    CommonFileUpload(
                      label: 'ID Proof Front Image',
                      hint: 'Upload JPG / PNG',
                      allowMultiple: false,
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      onFilesSelected: controller.onIdProofFrontSelected,
                      onFileRemoved: controller.onIdProofFrontRemoved,
                    ),
                    CommonFileUpload(
                      label: 'ID Proof Back Image',
                      hint: 'Upload JPG / PNG',
                      allowMultiple: false,
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      onFilesSelected: controller.onIdProofBackSelected,
                      onFileRemoved: controller.onIdProofBackRemoved,
                    ),
                    CommonFileUpload(
                      label: 'Education Certificate',
                      hint: 'Upload JPG / PNG / PDF',
                      allowMultiple: false,
                      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
                      onFilesSelected: controller.onEducationCertSelected,
                      onFileRemoved: controller.onEducationCertRemoved,
                    ),
                  ],
                ),

                /// =========================
                /// DECLARATION CHECKBOXES
                /// =========================
                AppCard(
                  title: 'Declaration',
                  subtitle: 'All three confirmations are required before saving',
                  icon: LucideIcons.shieldCheck,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Obx(() => Column(
                    children: [
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        dense: true,
                        title: Text(
                          'I confirm that the above details are correct',
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                        ),
                        value: controller.isDetailsConfirmed.value,
                        onChanged: (v) =>
                        controller.isDetailsConfirmed.value = v ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        dense: true,
                        title: Text(
                          'I agree to the Terms & Conditions',
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                        ),
                        value: controller.isTermsAccepted.value,
                        onChanged: (v) =>
                        controller.isTermsAccepted.value = v ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        dense: true,
                        title: Text(
                          'I accept the Privacy Policy',
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                        ),
                        value: controller.isPrivacyAccepted.value,
                        onChanged: (v) =>
                        controller.isPrivacyAccepted.value = v ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  )),
                ),

                const SizedBox(height: 24),

                /// =========================
                /// ACTION BUTTONS
                /// =========================
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    Obx(() => controller.isCreateLoading.value
                        ? const SizedBox(
                            height: 40,
                            width: 40,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(LucideIcons.check, size: 18),
                            label: const Text('Save Health Professional'),
                            onPressed: controller.isDetailsConfirmed.value &&
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= HELPERS =================

  /// A titled form section: two columns when there is room, one on phones.
  /// Wrap a child in [_FullWidth] to make it span both columns.
  Widget _section({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        child: LayoutBuilder(builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final twoColumns = maxW >= 560;
          final half = twoColumns ? ((maxW - 20) / 2).floorToDouble() : maxW;
          return Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              for (final child in children)
                SizedBox(
                  width: child is _FullWidth ? maxW : half,
                  child: child,
                ),
            ],
          );
        }),
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
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.textFieldBorderColor),
          ),
          child: controller.availableLanguages.isEmpty
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
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
                          selectedColor: AppColor.primarySoft,
                          checkmarkColor: AppColor.cPrimaryButtonColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColor.cPrimaryButtonColor
                                : AppColor.textPrimary,
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
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
}

/// Marks a form field that should span both columns of a [_section].
class _FullWidth extends StatelessWidget {
  const _FullWidth(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
