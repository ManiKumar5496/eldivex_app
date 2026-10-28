import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  // Client-side search over the org-scoped banner list the API returns.
  final RxString searchQuery = ''.obs;
  final RxList<GetAllBannersModel> filteredBanners = <GetAllBannersModel>[].obs;

  @override
  void onInit() {
    getBannersFromApi();
    super.onInit();
  }

  void searchBanners(String query) {
    searchQuery.value = query;
    _applyBannerFilters();
  }

  void _applyBannerFilters() {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredBanners.value = List.from(allBannersData.value);
      return;
    }
    filteredBanners.value = allBannersData.value.where((b) {
      return (b.bannerName ?? '').toLowerCase().contains(q) ||
          (b.bannerDescription ?? '').toLowerCase().contains(q);
    }).toList();
  }

  final RxList<PlatformFile> bannersUploaded = <PlatformFile>[].obs;
  // Bumped after a successful create so the upload widget (which keeps its
  // own selection state) is rebuilt empty.
  final RxInt formVersion = 0.obs;
  final RxString loadError = ''.obs;
  final RxnInt togglingBannerId = RxnInt();

  void onDocumentsSelected(List<PlatformFile> files) {
    // Single-image upload: a new pick replaces the previous one.
    bannersUploaded.assignAll(files.take(1));
  }

  void onDocumentRemoved(PlatformFile file) {
    bannersUploaded.remove(file);
  }

  String _errorText(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError ?? fallback;
  }

  Future<void> getBannersFromApi() async {
    getAllBannersLoading.value = true;
    loadError.value = '';
    final result = await baseApi.getList<GetAllBannersModel>(
      ApiConstants.getAllBanners,
      (json) => GetAllBannersModel.fromJson(json),
    );
    if (result == null) {
      loadError.value = ApiService.lastError ?? 'Failed to load banners.';
    } else {
      allBannersData.value = result;
    }
    _applyBannerFilters();
    getAllBannersLoading.value = false;
  }

  Future<void> updateBannerStatus(int status, int id) async {
    if (togglingBannerId.value != null) return;
    togglingBannerId.value = id;
    try {
      final response = await baseApi
          .patchApi("${ApiConstants.updateBannerStatus}?id=$id&status=$status");
      if (ApiService.isOk(response)) {
        HelperUi.showToast(
          message: status == 1 ? "Banner is now visible." : "Banner hidden.",
          backgroundColor: Colors.green,
        );
      } else {
        HelperUi.showToast(
          message: _errorText(response, "Failed to update banner status."),
          backgroundColor: Colors.red,
        );
      }
    } finally {
      togglingBannerId.value = null;
      // Reload either way so the toggle reflects the stored status.
      await getBannersFromApi();
    }
  }

  Future<void> createBanner() async {
    if (bannerNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter banner name.", backgroundColor: Colors.red);
      return;
    }

    if (bannersUploaded.isEmpty) {
      HelperUi.showToast(message: "Please upload a banner image.", backgroundColor: Colors.red);
      return;
    }

    final file = bannersUploaded.first;
    if (file.bytes == null) {
      HelperUi.showToast(message: "Invalid file selected.", backgroundColor: Colors.red);
      return;
    }

    createBannersLoading.value = true;

    try {
      final formData = dio.FormData();

      /// Add Image
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

      if (ApiService.isOk(response)) {
        HelperUi.showToast(
            message: "Banner created successfully.", backgroundColor: Colors.green);

        /// Clear form and stay on the page (this is a shell page, so
        /// Get.back() would pop the whole admin shell).
        bannerNameController.clear();
        bannerDescriptionController.clear();
        bannersUploaded.clear();
        formVersion.value++;
        getBannersFromApi();
      } else {
        HelperUi.showToast(
          message: _errorText(response, "Failed to create banner."),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Banner creation error: $e");
      HelperUi.showToast(
          message: "Something went wrong. Please try again.",
          backgroundColor: Colors.red);
    } finally {
      createBannersLoading.value = false;
    }
  }

  @override
  void onClose() {
    bannerNameController.dispose();
    bannerDescriptionController.dispose();
    super.onClose();
  }
}
