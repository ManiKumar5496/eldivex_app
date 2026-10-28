import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_text_form_field.dart';
import '../controllers/client_users_controller.dart';

class CreateClientUser extends GetView<ClientUsersController> {
  /// True when pushed on top of the shell (from Manage Users), so the page
  /// needs its own back button.
  final bool showBackButton;

  const CreateClientUser({super.key, this.showBackButton = false});

  // Registered once on first access (shell page has no route binding).
  @override
  ClientUsersController get controller =>
      Get.isRegistered<ClientUsersController>()
          ? Get.find<ClientUsersController>()
          : Get.put(ClientUsersController());

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: showBackButton
          ? AppBar(
              backgroundColor: AppColor.whiteColor,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColor.fontColorBlack),
              title: Text('Add Client',
                  style: TextStyle(color: AppColor.fontColorBlack)),
            )
          : null,
      body: Padding(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Client User',
              style: TextStyle(
                fontSize: SizeConfig.fontH1,
                fontWeight: FontWeight.bold,
                color: AppColor.fontColorBlack,
                fontFamily: "poppins_regular",
              ),
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Text(
              'Enter phone number to search or create a new client',
              style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey,
                fontFamily: "poppins_regular",
              ),
            ),

            SizedBox(height: SizeConfig.spacingLG),

            // ── Phone Field ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() => Container(
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 2),
                      padding:
                          EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radiusSM),
                        border: Border.all(color: AppColor.divColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedCountryCode.value,
                          dropdownColor: AppColor.whiteColor,
                          style: TextStyle(
                            fontSize: SizeConfig.fontBody,
                            color: AppColor.fontColorBlack,
                          ),
                          items: ClientUsersController.countryCodes
                              .map((cc) => DropdownMenuItem<String>(
                                    value: cc['code'],
                                    child: Text('${cc['flag']} ${cc['code']}'),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              controller.selectedCountryCode.value = v;
                            }
                          },
                        ),
                      ),
                    )),
                SizedBox(width: SizeConfig.spacingSM),
                Expanded(
                  child: FormTextField(
                    label: 'Phone Number',
                    hint: 'e.g. 9876543210',
                    controller: controller.phoneNumberControllerClient,
                    prefixIcon: Icons.phone,
                    required: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.spacingLG),

            // ── Search Button ────────────────────────────────────
            Obx(
                  () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSearchUserLoading.value
                      ? null
                      : () => controller.addUserClient(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    foregroundColor: AppColor.buttonTextWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                    ),
                    disabledBackgroundColor:
                    AppColor.cPrimaryButtonColor.withValues(alpha: 0.6),
                  ),
                  child: controller.isSearchUserLoading.value
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppColor.buttonTextWhite),
                    ),
                  )
                      : Text(
                    'Search / Add User',
                    style: TextStyle(
                      fontSize: SizeConfig.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}