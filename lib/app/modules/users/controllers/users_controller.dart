import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';

import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_users_model.dart';

class UsersController extends GetxController {
  final ApiService apiService = ApiService();
 var dashboardController = Get.put(DashboardController());
 int userId = box.read("userId");
  /// Filter Visibility
  RxBool isFilterVisible = false.obs;

  /// Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final userPasswordController = TextEditingController().obs;
  final RxList<PlatformFile> uploadedDocuments = <PlatformFile>[].obs;

  void onDocumentsSelected(List<PlatformFile> files) {
    uploadedDocuments.addAll(files);
  }

  void onDocumentRemoved(PlatformFile file) {
    uploadedDocuments.remove(file);
  }


  /// Reactive Dropdown Values
  RxString selectedRole = ''.obs;
  RxString selectedRoleId = ''.obs;
  RxString selectedStatus = ''.obs;
  RxString selectedCity = ''.obs;
  RxString selectedState = ''.obs;
  RxString selectedCountry = ''.obs;

  /// Dropdown Lists
  final List<String> statuses = ['Active', 'Inactive', 'Pending'];
  final List<String> states = ['California', 'Texas', 'Florida', 'New York'];
  final List<String> countries = ['United States', 'Canada', 'United Kingdom'];

  final Rxn<XFile> imageFile = Rxn<XFile>();
  RxString userGender = "".obs;

  // Loading states
  final RxBool isCreateLoading = false.obs;
  final RxBool isUpdateUserLoading = false.obs;
  final RxBool getUserRoleLoading = false.obs;
  final RxBool getAllCitiesLoading = false.obs;
  final RxBool getAcademyLoading = false.obs;

  // Controllers
  // final dropDownSearchController = TextEditingController().obs;
  // final dropDownUserAcadamyController = TextEditingController().obs;
  // final mobileNumberController = TextEditingController().obs;
  // final userLocationController = TextEditingController().obs;
  // final userPasswordController = TextEditingController().obs;
  // final searchUserController = TextEditingController().obs;
  // final searchUserMobileController = TextEditingController().obs;
  // final searchUserEmailController = TextEditingController().obs;
  // final sortColumnIndex = 0.obs;
  // final isAscending = true.obs;

  // Data models
  //Rx<List<AllAcadamiesModel>> allCities = Rx<List<AllAcadamiesModel>>([]);

  Rx<dio.Response?> createUserResponse = Rx<dio.Response?>(null);

  /// Get users variables
  final RxBool getAllUsersLoading = false.obs;
  Rx<List<GetEmployeeDetails>> allUsers = Rx<List<GetEmployeeDetails>>([]);

  @override
  void onInit() {
    super.onInit();
    getAllEmployeesFromApi();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetAddressController.dispose();
    zipCodeController.dispose();
    companyNameController.dispose();
    jobTitleController.dispose();
    bioController.dispose();
    super.onClose();
  }

  /// Toggle filter visibility
  void toggleFilters() {
    isFilterVisible.value = !isFilterVisible.value;
  }

  /// Get users from API
  void getAllEmployeesFromApi() {
    getAllUsersLoading.value = true;
    apiService
        .getList<GetEmployeeDetails>(
      ApiConstants.getAllEmployees,
          (json) => GetEmployeeDetails.fromJson(json),
    )
        .then((result) {
      debugPrint("all users $result");
      allUsers.value = result ?? [];
    }).catchError((e) {
      debugPrint("Error fetching users: $e");
    }).whenComplete(() => getAllUsersLoading.value = false);
  }
  Future<void> createUser() async {
    isCreateLoading.value = true;
    final formData = dio.FormData();

    if (uploadedDocuments != []) {
      final fileName = uploadedDocuments.first.name;
      final bytes = await uploadedDocuments.first.bytes!;

      debugPrint("Uploading user_image: $fileName, ${uploadedDocuments}");

      formData.files.add(
        MapEntry(
          'user_image',
          dio.MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        ),
      );
    }

    formData.fields.addAll([
      MapEntry('user_name', firstNameController.value.text),
      MapEntry('user_gender', userGender.value),
      MapEntry('user_mobile', phoneController.value.text),
      MapEntry('user_email', emailController.value.text),
      MapEntry('user_password', userPasswordController.value.text),
      MapEntry('user_role', selectedRoleId.value),
      MapEntry('user_home_branch', selectedState.value),
      MapEntry('user_branch_access', selectedState.value),
      MapEntry('userId', userId.toString()),

      MapEntry('academy_id', selectedCity.value),
    ]);
    print("Uploading user with fields: ${formData.fields}");
    if (formData.files.isNotEmpty) {
      final file = formData.files.first.value;
      print("File name: ${file.filename}");
    }

    try {
      final response =
      await apiService.postForm(ApiConstants.createEmployee, formData);
      createUserResponse.value = response;

      if (response?.data['message'] == 'User created successfully.') {
        clearFilters();
        userPasswordController.value.clear();
        uploadedDocuments.clear();
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User Created Successfully");
        Get.back();
      } else {
        HelperUi.showToast(message: "User Creation Failed");
      }
    } catch (e) {
      debugPrint("User creation error: $e");
      HelperUi.showToast(message: "Something went wrong!");
    } finally {
      isCreateLoading.value = false;
    }
  }
  /// Clear all filters
  void clearFilters() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    streetAddressController.clear();
    zipCodeController.clear();
    companyNameController.clear();
    jobTitleController.clear();
    bioController.clear();
    selectedRole.value = '';
    selectedRoleId.value = '';
    selectedStatus.value = '';
    selectedCity.value = '';
    selectedState.value = '';
    selectedCountry.value = '';
  }


}