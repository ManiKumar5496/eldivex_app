import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/common_file_upload.dart';
import '../../../widgets/common_text_form_field.dart';

class CreateBanners extends GetView<BannersController> {
  const CreateBanners({super.key});
  @override
  Widget build(BuildContext context) {
    final BannersController bannersController = Get.put(BannersController());
    return Scaffold(
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              FormTextField(
                label: 'Banner Name',
                hint: 'Enter Banner name',
                controller: controller.bannerNameController,
                prefixIcon: Icons.person_outline,
                required: true,
              ),
              SizedBox(height: 20),
          
              FormTextField(
                label: 'Banner Description',
                hint: 'Enter Banner Description',
                controller: controller.bannerDescriptionController,
                maxLines: 3,
              ),
              SizedBox(height: 20),
              CommonFileUpload(
                label: 'Banner Image',
                hint: 'Upload JPG / PNG',
                allowMultiple: false,
                allowedExtensions: const ['jpg', 'jpeg', 'png'],
                onFilesSelected: controller.onDocumentsSelected,
                onFileRemoved: controller.onDocumentRemoved,
              ),

              SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.createBannersLoading.value
                    ? null
                    : controller.createBanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor:
                  AppColor.cPrimaryButtonColor.withOpacity(0.6),
                ),
                child: controller.createBannersLoading.value
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Creating Banner...",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                )
                    : const Text(
                  'Create Banner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ))
            ]
          ),
        ),
      ),
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
}
