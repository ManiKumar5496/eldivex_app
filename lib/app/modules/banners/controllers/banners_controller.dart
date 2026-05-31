import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_all_banners_model.dart';

class BannersController extends GetxController {
  final TextEditingController bannerNameController = TextEditingController();
  final TextEditingController bannerDescriptionController = TextEditingController();
  final RxBool getAllBannersLoading = false.obs;
  final RxBool createBannersLoading = false.obs;
  final ApiService baseApi = ApiService();
  Rx<List<GetAllBannersModel>> allBannersData = Rx<List<GetAllBannersModel>>([]);

  @override
  void onInit() {
    getBannersFromApi();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  final RxList<PlatformFile> bannersUploaded = <PlatformFile>[].obs;

  void onDocumentsSelected(List<PlatformFile> files) {
    bannersUploaded.addAll(files);
  }

  void onDocumentRemoved(PlatformFile file) {
    bannersUploaded.remove(file);
  }

  void getBannersFromApi() {
    getAllBannersLoading.value = true;
    baseApi
        .getList<GetAllBannersModel>(
      "${ApiConstants.getAllBanners}",
          (json) => GetAllBannersModel.fromJson(json),
    )
        .then((result) {
      debugPrint("all banners $result");
      allBannersData.value = result ?? [];
    }).catchError((e) {
      debugPrint("Error fetching users: $e");
    }).whenComplete(() => getAllBannersLoading.value = false);
  }

  void updateBannerStatus(int status, int id) {
    getAllBannersLoading.value = true;

    baseApi
        .patchApi("${ApiConstants.updateBannerStatus}?id=$id&status=$status")
        .then((response) {
      getAllBannersLoading.value = false;

      if (response == null) {
        HelperUi.showToast(message: "No response from server.");
        return;
      }

      Map<String, dynamic> responseData = response.data ?? {};
      var statusMessage = responseData['message'] ?? "No message provided.";
      debugPrint("Response from updateUserVisible: $responseData");

      if (response.statusCode == 200) {
        if (statusMessage == 'Updated successfully.') {
          HelperUi.showToast(message: "User status updated successfully.");
        } else {
          HelperUi.showToast(message: statusMessage);
        }
        onInit();
      } else if (response.statusCode == 401) {
        HelperUi.showToast(
            message: "Unauthorized access. Please log in again.");
      } else {
        HelperUi.showToast(
            message: "Failed to update status. Status: ${response.statusCode}");
      }
    }).catchError((error) {
      getAllBannersLoading.value = false;
      HelperUi.showToast(message: "Error updating status: $error");
    });
  }
  Future<void> createBanner() async {
    if (bannerNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter banner name.");
      return;
    }

    if (bannersUploaded.isEmpty) {
      HelperUi.showToast(message: "Please upload a banner image.");
      return;
    }

    createBannersLoading.value = true;

    try {
      final formData = dio.FormData();

      /// Add Image
      final file = bannersUploaded.first;

      if (file.bytes == null) {
        HelperUi.showToast(message: "Invalid file selected.");
        createBannersLoading.value = false;
        return;
      }

      formData.files.add(
        MapEntry(
          'banner_photo',
          dio.MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ),
      );

      /// Add Fields
      formData.fields.addAll([
        MapEntry('banner_name', bannerNameController.text.trim()),
        MapEntry('banner_description',
            bannerDescriptionController.text.trim()),
      ]);

      final response =
      await baseApi.postForm(ApiConstants.createBannersApi, formData);

      if (response != null && response.statusCode == 201) {
        HelperUi.showToast(message: "Banner created successfully.");

        /// Clear form
        bannerNameController.clear();
        bannerDescriptionController.clear();
        bannersUploaded.clear();
        getBannersFromApi();
        Get.back();
      } else if (response?.statusCode == 400) {
        HelperUi.showToast(message: "Invalid banner data.");
      } else if (response?.statusCode == 401) {
        HelperUi.showToast(message: "Unauthorized. Please login again.");
      } else {
        HelperUi.showToast(message: "Failed to create banner.");
      }
    } catch (e) {
      debugPrint("Banner creation error: $e");
      HelperUi.showToast(message: "Something went wrong. Please try again.");
    } finally {
      createBannersLoading.value = false;
    }
  }
}
