import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_text_form_field.dart';
import '../controllers/client_users_controller.dart';

class CreateClientUser extends GetView<ClientUsersController> {
  const CreateClientUser({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(ClientUsersController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
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
                color: Colors.black87,
                fontFamily: "poppins_regular",
              ),
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Text(
              'Enter phone number to search or create a new client',
              style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: Colors.grey.shade600,
                fontFamily: "poppins_regular",
              ),
            ),

            SizedBox(height: SizeConfig.spacingLG),

            // ── Phone Field ──────────────────────────────────────
            FormTextField(
              label: 'Phone Number',
              hint: 'e.g. +919876543210',
              controller: controller.phoneNumberControllerClient,
              prefixIcon: Icons.phone,
              required: true,
              keyboardType: TextInputType.phone,
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
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                    ),
                    disabledBackgroundColor:
                    AppColor.cPrimaryButtonColor.withOpacity(0.6),
                  ),
                  child: controller.isSearchUserLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
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