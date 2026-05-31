import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../controllers/client_users_controller.dart';

class AddClientUserDetails extends GetView<ClientUsersController> {
  const AddClientUserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(ClientUsersController());

    // ── Read arguments passed from CreateClientUser → addUserClient()
    // Sent as: Get.toNamed(Routes.addClientDetails,
    //           arguments: {"userId": userId, "isNewUser": isNewUser})
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final int userId = args['userId'] ?? 0;
    final bool isNewUser = args['isNewUser'] ?? true;
    final String phoneNumber = args['phoneNumber'] ?? '';

    // Set phone number from previous screen and fetch user details
    if (phoneNumber.isNotEmpty) {
      controller.clientPhoneController.text = phoneNumber.replaceAll('+91', '');
      controller.fetchUserDetailsByPhone(phoneNumber.replaceAll('+91', ''));
    }

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back button + Title row ──────────────────────
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.offAllNamed(Routes.MAIN),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                SizedBox(width: SizeConfig.spacingXS),
                Text(
                  'Add Client Details',
                  style: TextStyle(
                    fontSize: SizeConfig.fontH1,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: "poppins_regular",
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.spacingMD),

            // ── Loading indicator while fetching user details ─
            Obx(() => controller.isFetchingUserDetails.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink()),

            _buildSectionCard(
              title: 'User Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── Full Name ──────────────────────────────────────
              _buildLabel('Full Name', hint: 'e.g. Irfan Ahmed', required: true),
              SizedBox(height: SizeConfig.spacingXS),
              _buildTextField(
                ctrl: controller.fullNameController,
                hint: 'Enter full name',
              ),
              SizedBox(height: SizeConfig.spacingMD),

              // ── Phone + Email ──────────────────────────────────
              SizeConfig.adaptiveLayout(
                mobile: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Phone Number', required: true),
                    SizedBox(height: SizeConfig.spacingXS),
                    _buildPhoneField(),
                    SizedBox(height: SizeConfig.spacingMD),
                    _buildLabel('Email',
                        hint: 'Multiple emails separated by commas, no spaces.'),
                    SizedBox(height: SizeConfig.spacingXS),
                    _buildTextField(
                      ctrl: controller.clientEmailController,
                      hint: 'Enter email address',
                      inputType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                tablet: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Phone Number', required: true),
                          SizedBox(height: SizeConfig.spacingXS),
                          _buildPhoneField(),
                        ],
                      ),
                    ),
                    SizedBox(width: SizeConfig.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Email',
                              hint: 'Multiple emails separated by commas, no spaces.'),
                          SizedBox(height: SizeConfig.spacingXS),
                          _buildTextField(
                            ctrl: controller.clientEmailController,
                            hint: 'Enter email address',
                            inputType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.spacingMD),

              // ── Service City + Lead Source ─────────────────────
              SizeConfig.adaptiveLayout(
                mobile: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Service City', required: true),
                    SizedBox(height: SizeConfig.spacingXS),
                    _buildBranchDropdown(),
                    SizedBox(height: SizeConfig.spacingMD),
                    _buildLabel('Lead Source', required: true),
                    SizedBox(height: SizeConfig.spacingXS),
                    _buildDropdown(
                      obs: controller.selectedLeadSource,
                      items: controller.leadSourceList,
                      hint: 'Select lead source',
                      onChanged: (v) =>
                      controller.selectedLeadSource.value = v ?? '',
                    ),
                  ],
                ),
                tablet: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Service City', required: true),
                          SizedBox(height: SizeConfig.spacingXS),
                          _buildBranchDropdown(),
                        ],
                      ),
                    ),
                    SizedBox(width: SizeConfig.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Lead Source', required: true),
                          SizedBox(height: SizeConfig.spacingXS),
                          _buildDropdown(
                            obs: controller.selectedLeadSource,
                            items: controller.leadSourceList,
                            hint: 'Select lead source',
                            onChanged: (v) =>
                            controller.selectedLeadSource.value = v ?? '',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.spacingMD),

              // ── Lead Type ──────────────────────────────────────
              _buildLabel('Lead Type', required: true),
              SizedBox(height: SizeConfig.spacingXS),
              _buildDropdown(
                obs: controller.selectedLeadType,
                items: controller.leadTypeList,
                hint: 'Select lead type',
                onChanged: (v) => controller.selectedLeadType.value = v ?? '',
                clearable: true,
              ),
              SizedBox(height: SizeConfig.spacingMD),

              // ── Enquired For ───────────────────────────────────
              _buildLabel('Enquired For', required: true),
              SizedBox(height: SizeConfig.spacingXS),
              _buildCategoryDropdown(),
              SizedBox(height: SizeConfig.spacingMD),

              // ── Internal Remarks ───────────────────────────────
              _buildLabel('Internal Remarks'),
              SizedBox(height: SizeConfig.spacingXS),
              _buildTextField(
                ctrl: controller.internalRemarksController,
                hint: 'Enter internal remarks...',
                maxLines: 4,
              ),
              SizedBox(height: SizeConfig.spacingXL),


              // ── Next Button  ───────────────────────────────────
              // userId and isNewUser read from args above and forwarded here
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                      () => SizedBox(
                    width: SizeConfig.isMobile ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: controller.clientDetailsUpdateLoading.value
                          ? null
                          : () =>
                          controller.validateAndNext(userId, isNewUser),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        disabledBackgroundColor:
                        AppColor.cPrimaryButtonColor.withOpacity(0.6),
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.isMobile
                              ? SizeConfig.spacingXL
                              : 40,
                          vertical: SizeConfig.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(SizeConfig.radiusSM),
                        ),
                        elevation: 0,
                      ),
                      child: controller.clientDetailsUpdateLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: SizeConfig.fontBody,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: "poppins_regular",
                            ),
                          ),
                          SizedBox(width: SizeConfig.spacingXS),
                          Icon(Icons.arrow_forward,
                              size: SizeConfig.iconSM,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET HELPERS ───────────────────────────────────────────────

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: SizeConfig.fontH2,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryButtonColor,
                fontFamily: "poppins_regular",
              )),
          SizedBox(height: SizeConfig.spacingLG),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {String? hint, bool required = false}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: label,
          style: TextStyle(
            fontSize: SizeConfig.fontBodySmall,
            fontWeight: FontWeight.w500,
            color: required ? AppColor.cPrimaryButtonColor : AppColor.unSelectedMenu,
            fontFamily: "poppins_regular",
          ),
        ),
        if (hint != null)
          TextSpan(
            text: '  ($hint)',
            style: TextStyle(
              fontSize: SizeConfig.fontCaption,
              color: AppColor.unSelectedMenu,
              fontFamily: "poppins_regular",
            ),
          ),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    String? hint,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: inputType,
      style: TextStyle(
          fontSize: SizeConfig.fontBody,
          color: Colors.black87,
          fontFamily: "poppins_regular"),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: SizeConfig.fontBody,
            color: Colors.grey.shade400,
            fontFamily: "poppins_regular"),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.spacingMD, vertical: SizeConfig.spacingMD),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
            borderSide: BorderSide(color: AppColor.divColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
            borderSide: BorderSide(color: AppColor.divColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
            borderSide:
            BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5)),
      ),
    );
  }

  static const List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'flag': '🇮🇳'},
    {'code': '+1', 'flag': '🇺🇸'},
    {'code': '+44', 'flag': '🇬🇧'},
    {'code': '+971', 'flag': '🇦🇪'},
    {'code': '+65', 'flag': '🇸🇬'},
    {'code': '+61', 'flag': '🇦🇺'},
    {'code': '+49', 'flag': '🇩🇪'},
    {'code': '+33', 'flag': '🇫🇷'},
    {'code': '+81', 'flag': '🇯🇵'},
    {'code': '+86', 'flag': '🇨🇳'},
    {'code': '+966', 'flag': '🇸🇦'},
    {'code': '+974', 'flag': '🇶🇦'},
    {'code': '+968', 'flag': '🇴🇲'},
    {'code': '+60', 'flag': '🇲🇾'},
    {'code': '+977', 'flag': '🇳🇵'},
    {'code': '+94', 'flag': '🇱🇰'},
    {'code': '+880', 'flag': '🇧🇩'},
  ];

  Widget _buildPhoneField() {
    return Row(
      children: [
        Obx(() => Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
          decoration: BoxDecoration(
            color: AppColor.fieldColorGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.radiusSM),
              bottomLeft: Radius.circular(SizeConfig.radiusSM),
            ),
            border: Border.all(color: AppColor.divColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCountryCode.value,
              icon: Icon(Icons.arrow_drop_down,
                  size: SizeConfig.iconSM, color: Colors.grey),
              style: TextStyle(
                  fontSize: SizeConfig.fontBody,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: "poppins_regular"),
              items: _countryCodes
                  .map((cc) => DropdownMenuItem<String>(
                        value: cc['code'],
                        child: Text('${cc['flag']} ${cc['code']}',
                            style: TextStyle(
                                fontSize: SizeConfig.fontBody,
                                fontFamily: "poppins_regular")),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.selectedCountryCode.value = v;
              },
            ),
          ),
        )),
        Container(height: 50, width: 1, color: AppColor.divColor),
        Expanded(
          child: TextFormField(
            controller: controller.clientPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            style: TextStyle(
                fontSize: SizeConfig.fontBody, fontFamily: "poppins_regular"),
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: TextStyle(
                  fontSize: SizeConfig.fontBody, color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColor.fieldColorGrey,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spacingMD,
                  vertical: SizeConfig.spacingMD),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(SizeConfig.radiusSM),
                    bottomRight: Radius.circular(SizeConfig.radiusSM),
                  ),
                  borderSide: BorderSide(color: AppColor.divColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(SizeConfig.radiusSM),
                    bottomRight: Radius.circular(SizeConfig.radiusSM),
                  ),
                  borderSide: BorderSide(color: AppColor.divColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(SizeConfig.radiusSM),
                    bottomRight: Radius.circular(SizeConfig.radiusSM),
                  ),
                  borderSide: BorderSide(
                      color: AppColor.cPrimaryButtonColor, width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Obx(() {
      if (controller.dashboardController.getAllBranchesLoading.value) {
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final branches = controller.dashboardController.getAllBranches;
      final currentValue = controller.selectedServiceCityId.value;
      // Only use the value if it matches an item in the list
      final hasMatch = currentValue.isNotEmpty &&
          branches.any((b) => b.brId.toString() == currentValue);
      return AppDropdown<String>(
        hint: 'Select city',
        value: hasMatch ? currentValue : null,
        items: branches
            .map((branch) => DropdownMenuItem<String>(
                  value: branch.brId.toString(),
                  child: Text(branch.brName),
                ))
            .toList(),
        onChanged: (v) {
          controller.selectedServiceCityId.value = v ?? '';
          final selected = branches.firstWhereOrNull(
              (b) => b.brId.toString() == v);
          controller.selectedCity.value = selected?.brName ?? '';
        },
      );
    });
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (controller.dashboardController.getCategoriesLoading.value) {
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final categories = controller.dashboardController.categoriesList;
      final currentValue = controller.selectedEnquiredFor.value;
      final hasMatch = currentValue.isNotEmpty &&
          categories.any((c) => c.id.toString() == currentValue);
      return AppDropdown<String>(
        hint: 'Select service',
        value: hasMatch ? currentValue : null,
        items: categories
            .map((cat) => DropdownMenuItem<String>(
                  value: cat.id.toString(),
                  child: Text(cat.catName),
                ))
            .toList(),
        onChanged: (v) {
          controller.selectedEnquiredFor.value = v ?? '';
        },
      );
    });
  }

  Widget _buildDropdown({
    required RxString obs,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    bool clearable = false,
  }) {
    return Obx(
      () => AppDropdown<String>(
        hint: hint,
        value: obs.value.isEmpty ? null : obs.value,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        clearable: clearable,
        onClear: clearable ? () => obs.value = '' : null,
      ),
    );
  }
}