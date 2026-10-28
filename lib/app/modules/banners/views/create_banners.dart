import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/common_file_upload.dart';
import '../../../widgets/common_text_form_field.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateBanners extends GetView<BannersController> {
  const CreateBanners({super.key});

  @override
  BannersController get controller => Get.isRegistered<BannersController>()
      ? Get.find<BannersController>()
      : Get.put(BannersController());

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AppCard(
              icon: LucideIcons.imagePlus,
              title: 'New banner',
              subtitle: 'Give the banner a name and upload its image.',
              footer: Align(
                alignment: Alignment.centerRight,
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.createBannersLoading.value
                          ? null
                          : controller.createBanner,
                      icon: controller.createBannersLoading.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.plus, size: 18),
                      label: Text(controller.createBannersLoading.value
                          ? "Creating Banner..."
                          : 'Create Banner'),
                    )),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormTextField(
                    label: 'Banner Name',
                    hint: 'Enter Banner name',
                    controller: controller.bannerNameController,
                    prefixIcon: LucideIcons.type,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    label: 'Banner Description',
                    hint: 'Enter Banner Description',
                    controller: controller.bannerDescriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => CommonFileUpload(
                        key: ValueKey(
                            'banner-upload-${controller.formVersion.value}'),
                        label: 'Banner Image',
                        hint: 'Upload JPG / PNG',
                        allowMultiple: false,
                        allowedExtensions: const ['jpg', 'jpeg', 'png'],
                        onFilesSelected: controller.onDocumentsSelected,
                        onFileRemoved: controller.onDocumentRemoved,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
        ),
      ),
    );
  }
}
