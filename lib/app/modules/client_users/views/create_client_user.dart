import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_text_form_field.dart';
import '../controllers/client_users_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Add Client',
                  subtitle:
                      'Enter phone number to search or create a new client',
                  breadcrumbs:
                      showBackButton ? const ['Clients', 'Add Client'] : const [],
                  // Same behaviour as the AppBar's automatic back button.
                  onBack: showBackButton
                      ? () => Navigator.of(context).maybePop()
                      : null,
                ),
                const SizedBox(height: 24),
                AppCard(
                  title: 'Search Client User',
                  subtitle:
                      'Existing clients open directly; new numbers start a new client',
                  icon: LucideIcons.userSearch,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Phone Field ──────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Container(
                                height: 50,
                                margin: const EdgeInsets.only(bottom: 1),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColor.fieldColorGrey,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColor.divColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.selectedCountryCode.value,
                                    dropdownColor: AppColor.whiteColor,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                    icon: Icon(
                                        LucideIcons.chevronDown,
                                        size: 18,
                                        color: AppColor.textTertiary),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.textPrimary,
                                    ),
                                    items: ClientUsersController.countryCodes
                                        .map((cc) => DropdownMenuItem<String>(
                                              value: cc['code'],
                                              child: Text(
                                                  '${cc['flag']} ${cc['code']}'),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: FormTextField(
                              label: 'Phone Number',
                              hint: 'e.g. 9876543210',
                              controller: controller.phoneNumberControllerClient,
                              prefixIcon: LucideIcons.phone,
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

                      const SizedBox(height: 24),

                      // ── Search Button ────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(
                          () => SizedBox(
                            width: SizeConfig.isMobile ? double.infinity : null,
                            child: ElevatedButton.icon(
                              onPressed: controller.isSearchUserLoading.value
                                  ? null
                                  : () => controller.addUserClient(),
                              icon: controller.isSearchUserLoading.value
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColor.textTertiary,
                                      ),
                                    )
                                  : const Icon(LucideIcons.search, size: 18),
                              label: const Text('Search / Add User'),
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
        ),
      ),
    );
  }
}
