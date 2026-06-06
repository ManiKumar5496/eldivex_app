import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../models/client_user_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'package:dio/dio.dart' as dio;

class ClientUsersController extends GetxController {
  final DashboardController dashboardController = Get.put(DashboardController());

  // Step 1 - CreateClientUser screen
  final TextEditingController phoneNumberControllerClient =
      TextEditingController(text: "+91");
  final RxBool isSearchUserLoading = false.obs;
  final RxString selectedCountryCode = '+91'.obs;

  // Step 2 - AddClientUserDetails screen
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController clientPhoneController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController internalRemarksController =
      TextEditingController();
  final RxString selectedCity = ''.obs;
  final RxString selectedLeadSource = ''.obs;
  final RxString selectedLeadType = ''.obs;
  final RxString selectedEnquiredFor = ''.obs;
  final RxBool clientDetailsUpdateLoading = false.obs;

  // Manage-list screen fields (separate from Step 2 fields)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoadingClientUsers = false.obs;
  final RxBool showFilters = false.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedServiceCityId = ''.obs;
  final RxList<ClientUserModel> clientUsers = <ClientUserModel>[].obs;
  final RxBool isLoading = false.obs;
  final ApiService apiService = ApiService();
  final RxInt currentPage = 0.obs;
  final RxInt rowsPerPage = 10.obs;
  // Dropdown data
  final List<String> leadSourceList = [
    'IVR',
    'Website',
    'Social Media',
    'Referral',
    'Walk-in',
    'Google Ads',
    'Other',
  ];
  final List<String> leadTypeList = [
    'Hot',
    'Warm',
    'Cold',
    'Lost',
  ];
  // enquiredFor now fetched from masterServices via dashboardController.categoriesList

  // STEP 1 - Search/add user by phone, navigate with userId + isNewUser
  Future<void> addUserClient() async {
    // Strip country-code prefix so the API receives the bare number (e.g. "9876543210")
    final rawPhone = phoneNumberControllerClient.text
        .replaceFirst(selectedCountryCode.value, '')
        .trim();

    if (rawPhone.isEmpty || rawPhone.length < 10) {
      HelperUi.showToast(message: "Please enter a valid 10-digit phone number");
      return;
    }

    try {
      isSearchUserLoading.value = true;
      final box = GetStorage();
      final orgId = box.read("org_id") ?? 1;
      final response = await apiService.postRaw(ApiConstants.addClientUser, {
        "phone_number": rawPhone,
        "country_code": selectedCountryCode.value,
        "org_id": orgId,
      });
      if (response != null && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final int userId = data['userId'] ?? 0;
        final bool isNewUser = data['isNewUser'] ?? true;
        if (userId != 0) {
          Get.toNamed(
            Routes.addClientDetails,
            arguments: {
              "userId": userId,
              "isNewUser": isNewUser,
              "phoneNumber": phoneNumberControllerClient.text,
            },
          );
        }
        HelperUi.showToast(message: "User fetched successfully");
      } else if (response?.statusCode == 401) {
        HelperUi.showToast(message: "Invalid details. Please try again.");
      } else {
        HelperUi.showToast(message: "Something went wrong. Please try again.");
      }
    } catch (error) {
      HelperUi.showToast(message: "An error occurred: $error");
    } finally {
      isSearchUserLoading.value = false;
    }
  }

  // STEP 2 - Fetch existing user details by phone number
  final RxBool isFetchingUserDetails = false.obs;

  Future<void> fetchUserDetailsByPhone(String phoneNumber) async {
    try {
      isFetchingUserDetails.value = true;
      // Use Uri to safely encode the phone number in the query string
      final uri = Uri.parse(ApiConstants.getClientUserDetails)
          .replace(queryParameters: {'phone_number': phoneNumber});
      final response = await apiService.getRaw(uri.toString());
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        Map<String, dynamic>? userData;
        if (data is List && data.isNotEmpty) {
          userData = data[0] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          userData = data;
        }
        if (userData != null) {
          final user = ClientUserModel.fromJson(userData);
          if (user.userName != null && user.userName!.isNotEmpty) {
            fullNameController.text = user.userName!;
          }
          if (user.userEmail != null && user.userEmail!.isNotEmpty) {
            clientEmailController.text = user.userEmail!;
          }
          if (user.userServiceCity != null) {
            selectedServiceCityId.value = user.userServiceCity.toString();
            // Also set city name from branch list if available
            final branch = dashboardController.getAllBranches.firstWhereOrNull(
                (b) => b.brId == user.userServiceCity);
            if (branch != null) {
              selectedCity.value = branch.brName;
            }
          } else if (user.userLocation != null && user.userLocation!.isNotEmpty) {
            selectedCity.value = user.userLocation!;
          }
          if (user.enquiredForOther != null && user.enquiredForOther!.isNotEmpty) {
            internalRemarksController.text = user.enquiredForOther!;
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch user details error: $e");
    } finally {
      isFetchingUserDetails.value = false;
    }
  }

  // STEP 2 - Validate details form then navigate to bookings
  // userId & isNewUser come from Get.arguments read in AddClientUserDetails
  void validateAndNext(int userId, bool isNewUser) {
    if (fullNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter full name");
      return;
    }

    if (clientPhoneController.text.trim().isEmpty ||
        clientPhoneController.text.trim().length < 10) {
      HelperUi.showToast(message: "Please enter valid phone number");
      return;
    }

    if (clientEmailController.text.trim().isEmpty ||
        !GetUtils.isEmail(clientEmailController.text.trim())) {
      HelperUi.showToast(message: "Please enter valid email");
      return;
    }

    if (selectedServiceCityId.value.isEmpty) {
      HelperUi.showToast(message: "Please select service city");
      return;
    }

    if (selectedLeadSource.value.isEmpty) {
      HelperUi.showToast(message: "Please select lead source");
      return;
    }

    if (selectedLeadType.value.isEmpty) {
      HelperUi.showToast(message: "Please select lead type");
      return;
    }

    if (selectedEnquiredFor.value.isEmpty) {
      HelperUi.showToast(message: "Please select enquired for");
      return;
    }

    _submitUserDetails(userId, isNewUser);
  }

  int _leadSourceId(String label) => leadSourceList.indexOf(label) + 1;
  int _leadTypeId(String label) => leadTypeList.indexOf(label) + 1;

  Future<void> _submitUserDetails(int userId, bool isNewUser) async {
    try {
      clientDetailsUpdateLoading.value = true;

      final body = dio.FormData.fromMap({
        "id": userId.toString(),
        "user_name": fullNameController.text.trim(),
        "user_email": clientEmailController.text.trim(),
        "user_location": selectedCity.value,
        //"user_gender": selectedGender.value,
        "is_new_user_flag": isNewUser ? "1" : "0",
        "user_service_city": selectedServiceCityId.value,
        "user_source": _leadSourceId(selectedLeadSource.value).toString(),
        "lead_potential": _leadTypeId(selectedLeadType.value).toString(),
        "enquired_for": selectedEnquiredFor.value,
        "enquired_for_other": internalRemarksController.text.trim(),
      });

      final response = await apiService.putForm(
        ApiConstants.putClientUserDetails,
        body,
      );

      if (response != null && response.statusCode == 200) {
        HelperUi.showToast(
          message: "User details updated successfully",
        );

        // Navigate only after success
        Get.offNamed(
          Routes.BOOKINGS,
          arguments: {
            "userId": userId,
            "isNewUser": isNewUser,
          },
        );
      } else {
        HelperUi.showToast(
          message: "Failed to update user. Please try again.",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      HelperUi.showToast(
        message: "Error: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      clientDetailsUpdateLoading.value = false;
    }
  }

  void toggleFilters() => showFilters.toggle();

  void clearFilters() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
  }

  void fetchClients() {
    fetchClientUsers();
  }

  // Fetch all client users from API
  Future<void> fetchClientUsers() async {
    try {
      isLoadingClientUsers.value = true;
      final orgId = GetStorage().read("org_id") ?? 1;

      final result = await apiService.getList<ClientUserModel>(
        '${ApiConstants.getClientUserDetails}?org_id=$orgId',
            (json) => ClientUserModel.fromJson(json),
      );

      if (result != null) {
        clientUsers.value = result;
      }
    } catch (e) {
      HelperUi.showToast(
        message: "Failed to load clients: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoadingClientUsers.value = false;
    }
  }

  void viewClient(int userId) {
    // Navigate to bookings for this client
    Get.toNamed(
      Routes.BOOKINGS,
      arguments: {"userId": userId, "isNewUser": false},
    );
  }

  void editClient(int userId, bool isNewUser) {
    // Navigate to edit user details
    Get.toNamed(
      Routes.addClientDetails,
      arguments: {"userId": userId, "isNewUser": isNewUser},
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchClientUsers();
    if (dashboardController.getAllBranches.isEmpty) {
      dashboardController.getAllBranchesApi();
    }
    if (dashboardController.categoriesList.isEmpty) {
      dashboardController.getCategoriesList();
    }
  }

  @override
  void onClose() {
    phoneNumberControllerClient.dispose();
    fullNameController.dispose();
    clientPhoneController.dispose();
    clientEmailController.dispose();
    internalRemarksController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
