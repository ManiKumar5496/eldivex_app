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
  RxInt selectedBranchIdForUser = 0.obs;
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
  final RxBool isUpdateLoading = false.obs;
  final RxBool isTerminateLoading = false.obs;
  final Rx<GetEmployeeDetails?> editingUser = Rx<GetEmployeeDetails?>(null);

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


/// Toggle filter visibility
  void toggleFilters() {
    isFilterVisible.value = !isFilterVisible.value;
  }

  /// Get users from API
  void getAllEmployeesFromApi() {
    getAllUsersLoading.value = true;
    final orgId = box.read("org_id") ?? 1;
    apiService
        .getList<GetEmployeeDetails>(
      '${ApiConstants.getAllEmployees}?org_id=$orgId',
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

    if (uploadedDocuments.isNotEmpty) {
      final fileName = uploadedDocuments.first.name;
      final bytes = uploadedDocuments.first.bytes!; // Uint8List — no await needed

      debugPrint("Uploading user_image: $fileName");

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

    final orgId = box.read("org_id") ?? 1;

    // Required fields
    formData.fields.addAll([
      MapEntry('user_name', firstNameController.value.text.trim()),
      MapEntry('user_mobile', phoneController.value.text.trim()),
      MapEntry('user_email', emailController.value.text.trim()),
      MapEntry('user_password', userPasswordController.value.text),
      MapEntry('user_role', selectedRoleId.value),
      MapEntry('userId', userId.toString()),
      MapEntry('org_id', orgId.toString()),
    ]);

    // Optional — only send when set to avoid Joi rejection on empty strings
    if (userGender.value.isNotEmpty) {
      formData.fields.add(MapEntry('user_gender', _genderToInt(userGender.value).toString()));
    }
    if (selectedBranchIdForUser.value > 0) {
      final branchId = selectedBranchIdForUser.value.toString();
      formData.fields.add(MapEntry('user_home_branch', branchId));
      formData.fields.add(MapEntry('user_branch_access', branchId));
    }

    debugPrint("Uploading user with fields: ${formData.fields}");

    try {
      final response =
          await apiService.postForm(ApiConstants.createEmployee, formData);
      createUserResponse.value = response;

      if (response?.statusCode == 201 ||
          response?.data['message'] == 'User created successfully.') {
        clearFilters();
        userPasswordController.value.clear();
        uploadedDocuments.clear();
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User Created Successfully");
        Get.back();
      } else {
        final msg = (response?.data is Map)
            ? (response?.data['message'] as String? ??
                response?.data['error'] as String? ??
                'User creation failed.')
            : 'User creation failed.';
        HelperUi.showToast(message: msg, backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint("User creation error: $e");
      HelperUi.showToast(message: "Something went wrong!", backgroundColor: Colors.red);
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
    selectedBranchIdForUser.value = 0;
    selectedState.value = '';
    selectedCountry.value = '';
    userGender.value = '';
    editingUser.value = null;
  }

  void loadUserForEdit(GetEmployeeDetails user) {
    editingUser.value = user;
    firstNameController.text = user.userName;
    phoneController.text = user.userMobile;
    emailController.text = user.userEmail;
    selectedRoleId.value = user.userRole.toString();

    // map int gender back to string
    switch (user.userGender) {
      case 2:
        userGender.value = 'Female';
        break;
      case 3:
        userGender.value = 'Other';
        break;
      default:
        userGender.value = 'Male';
    }

    // match branch by ID
    final branch = dashboardController.getAllBranches
        .firstWhereOrNull((b) => b.brId == user.userHomeBranch);
    if (branch != null) {
      selectedCity.value = branch.brName;
      selectedBranchIdForUser.value = branch.brId;
    }

    // match role name
    final role = dashboardController.getMasterRolesData
        .firstWhereOrNull((r) => r.id.toString() == user.userRole.toString());
    if (role != null) selectedRole.value = role.roleName;
  }

  Future<void> updateUser() async {
    final user = editingUser.value;
    if (user == null) return;

    isUpdateLoading.value = true;
    final formData = dio.FormData();

    if (uploadedDocuments.isNotEmpty) {
      final fileName = uploadedDocuments.first.name;
      final bytes = uploadedDocuments.first.bytes!;
      formData.files.add(MapEntry(
        'user_image',
        dio.MultipartFile.fromBytes(bytes, filename: fileName),
      ));
    }

    final orgId = box.read("org_id") ?? 1;
    formData.fields.addAll([
      MapEntry('id', user.id.toString()),
      MapEntry('user_name', firstNameController.text.trim()),
      MapEntry('user_mobile', phoneController.text.trim()),
      MapEntry('user_email', emailController.text.trim()),
      MapEntry('user_role', selectedRoleId.value),
      MapEntry('userId', userId.toString()),
      MapEntry('org_id', orgId.toString()),
    ]);

    if (userGender.value.isNotEmpty) {
      formData.fields.add(MapEntry('user_gender', _genderToInt(userGender.value).toString()));
    }
    if (selectedBranchIdForUser.value > 0) {
      final branchId = selectedBranchIdForUser.value.toString();
      formData.fields.add(MapEntry('user_home_branch', branchId));
      formData.fields.add(MapEntry('user_branch_access', branchId));
    }

    try {
      final response = await apiService.putForm(ApiConstants.updateEmployee, formData);
      if (response?.statusCode == 201 ||
          response?.data['message'] == 'User updated successfully.') {
        clearFilters();
        editingUser.value = null;
        uploadedDocuments.clear();
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User Updated Successfully");
        Get.back();
      } else {
        final msg = (response?.data is Map)
            ? (response?.data['message'] as String? ?? 'Update failed.')
            : 'Update failed.';
        HelperUi.showToast(message: msg, backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint("Update user error: $e");
      HelperUi.showToast(message: "Something went wrong!", backgroundColor: Colors.red);
    } finally {
      isUpdateLoading.value = false;
    }
  }

  int _genderToInt(String gender) {
    switch (gender) {
      case 'Female': return 2;
      case 'Other': return 3;
      default: return 1; // Male
    }
  }

  Future<void> terminateUser(int targetUserId) async {
    isTerminateLoading.value = true;
    try {
      final response = await apiService.putRaw(
        ApiConstants.terminateEmployee,
        {'id': targetUserId},
      );
      if (response?.statusCode == 200) {
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User terminated successfully");
      } else {
        final msg = (response?.data is Map)
            ? (response?.data['message'] as String? ?? 'Termination failed.')
            : 'Termination failed.';
        HelperUi.showToast(message: msg, backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint("Terminate user error: $e");
      HelperUi.showToast(message: "Something went wrong!", backgroundColor: Colors.red);
    } finally {
      isTerminateLoading.value = false;
    }
  }


}