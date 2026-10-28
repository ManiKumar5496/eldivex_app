import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';

import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/export_to_csv_common.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_users_model.dart';

class UsersController extends GetxController {
  final ApiService apiService = ApiService();
  // Resolve fresh on each access: this controller is permanent but
  // DashboardController is disposed on logout — a field captured at
  // construction would keep pointing at the dead instance.
  DashboardController get dashboardController =>
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());

  /// Logged-in admin id, read on every use. The controller can outlive a
  /// logout/login, so a value captured once would belong to the old session.
  String? get currentUserId => box.read("userId")?.toString();

  /// Filter Visibility
  RxBool isFilterVisible = false.obs;

  /// Text Controllers (create / edit form)
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final userPasswordController = TextEditingController().obs;
  final RxList<PlatformFile> uploadedDocuments = <PlatformFile>[].obs;

  void onDocumentsSelected(List<PlatformFile> files) {
    // Only one image is uploaded, so a new pick replaces the old one.
    uploadedDocuments.assignAll(files.take(1));
  }

  void onDocumentRemoved(PlatformFile file) {
    uploadedDocuments.remove(file);
  }

  /// Reactive Dropdown Values (create / edit form)
  RxString selectedRole = ''.obs;
  RxString selectedRoleId = ''.obs;
  RxString selectedCity = ''.obs;
  RxInt selectedBranchIdForUser = 0.obs;

  final Rxn<XFile> imageFile = Rxn<XFile>();
  RxString userGender = "".obs;

  // Loading states
  final RxBool isCreateLoading = false.obs;
  final RxBool isUpdateLoading = false.obs;
  final RxBool isTerminateLoading = false.obs;
  final Rx<GetEmployeeDetails?> editingUser = Rx<GetEmployeeDetails?>(null);

  Rx<dio.Response?> createUserResponse = Rx<dio.Response?>(null);

  /// Get users variables
  final RxBool getAllUsersLoading = false.obs;
  final RxString loadError = ''.obs;
  Rx<List<GetEmployeeDetails>> allUsers = Rx<List<GetEmployeeDetails>>([]);

  // ── Search & filter (client-side, over the org-scoped list the API returns) ──
  // The view renders `pagedUsers` (a page of `filteredUsers`), never `allUsers`
  // directly. The filter panel has its own controllers so editing a user never
  // silently filters the list (and vice versa).
  final TextEditingController searchController = TextEditingController();
  final TextEditingController filterNameController = TextEditingController();
  final TextEditingController filterPhoneController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString filterRole = ''.obs;   // role name, '' = All
  final RxString filterBranch = ''.obs; // branch name, '' = All
  final RxList<GetEmployeeDetails> filteredUsers = <GetEmployeeDetails>[].obs;

  // ── Client-side pagination over filteredUsers ──
  static const int pageSize = 10;
  final RxInt currentPage = 1.obs;

  int get totalPages {
    final n = filteredUsers.length;
    return n == 0 ? 1 : ((n + pageSize - 1) ~/ pageSize);
  }

  List<GetEmployeeDetails> get pagedUsers {
    final start = (currentPage.value - 1) * pageSize;
    if (start >= filteredUsers.length) return const [];
    final end = (start + pageSize).clamp(0, filteredUsers.length);
    return filteredUsers.sublist(start, end);
  }

  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void previousPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  VoidCallback? _tokenListener;
  String? _loadedForToken;

  @override
  void onInit() {
    super.onInit();
    // The shell registers this controller as permanent, so it survives a
    // logout. Reset everything when a different admin session starts so the
    // previous org's employees never show up.
    _tokenListener = box.listenKey('user_token', (value) {
      if (value != null && value.toString() != _loadedForToken) {
        resetForNewSession();
      }
    });
    getAllEmployeesFromApi();
  }

  @override
  void onClose() {
    _tokenListener?.call();
    super.onClose();
  }

  /// Drop all cached state and reload for the current session.
  void resetForNewSession() {
    clearFilters();
    userPasswordController.value.clear();
    uploadedDocuments.clear();
    allUsers.value = [];
    searchController.clear();
    filterNameController.clear();
    filterPhoneController.clear();
    searchQuery.value = '';
    filterRole.value = '';
    filterBranch.value = '';
    filteredUsers.clear();
    currentPage.value = 1;
    isFilterVisible.value = false;
    getAllEmployeesFromApi();
  }

  /// Free-text search box handler.
  void searchUsers(String query) {
    searchQuery.value = query;
    applyUserFilters();
  }

  /// Re-derive the visible list from the loaded users + active filters.
  /// Called after every API load and on each search/dropdown change.
  void applyUserFilters() {
    final q = searchQuery.value.toLowerCase().trim();
    final nameFilter = filterNameController.text.toLowerCase().trim();
    final phoneFilter =
        filterPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final roleFilter = filterRole.value.trim().toLowerCase();
    final branchFilter = filterBranch.value.trim().toLowerCase();
    filteredUsers.value = allUsers.value.where((u) {
      final matchesSearch = q.isEmpty ||
          u.userName.toLowerCase().contains(q) ||
          u.userEmail.toLowerCase().contains(q) ||
          u.userMobile.toLowerCase().contains(q) ||
          u.roleName.toLowerCase().contains(q);
      final matchesName =
          nameFilter.isEmpty || u.userName.toLowerCase().contains(nameFilter);
      final matchesPhone =
          phoneFilter.isEmpty || u.userMobile.contains(phoneFilter);
      final matchesRole =
          roleFilter.isEmpty || u.roleName.toLowerCase() == roleFilter;
      final matchesBranch = branchFilter.isEmpty ||
          branchNameForUser(u.userHomeBranch).toLowerCase() == branchFilter;
      return matchesSearch &&
          matchesName &&
          matchesPhone &&
          matchesRole &&
          matchesBranch;
    }).toList();
    currentPage.value = 1;
  }

  String branchNameForUser(int branchId) {
    final b = dashboardController.getAllBranches
        .firstWhereOrNull((e) => e.brId == branchId);
    return b?.brName ?? '';
  }

  /// Reset the list search/filters (distinct from the edit-form clearFilters()).
  void clearUserListFilters() {
    searchController.clear();
    filterNameController.clear();
    filterPhoneController.clear();
    searchQuery.value = '';
    filterRole.value = '';
    filterBranch.value = '';
    applyUserFilters();
  }

  /// Toggle filter visibility
  void toggleFilters() {
    isFilterVisible.value = !isFilterVisible.value;
  }

  /// Download the currently filtered list as CSV.
  void exportUsersCsv() {
    if (filteredUsers.isEmpty) {
      HelperUi.showToast(message: "No users to export", backgroundColor: Colors.orange);
      return;
    }
    ExportToCsv().exportToCSV(
      ['Name', 'Email', 'Mobile', 'Role', 'Branch', 'Status', 'Join Date'],
      filteredUsers
          .map((u) => [
                u.userName,
                u.userEmail,
                u.userMobile,
                u.roleName,
                branchNameForUser(u.userHomeBranch),
                u.isActive ? 'Active' : 'Terminated',
                u.createdOn.length >= 10 ? u.createdOn.substring(0, 10) : u.createdOn,
              ])
          .toList(),
      fileName: 'employees_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
  }

  /// Get users from API. org_id is taken from the JWT on the server.
  Future<void> getAllEmployeesFromApi() async {
    getAllUsersLoading.value = true;
    loadError.value = '';
    _loadedForToken = box.read("user_token")?.toString();
    try {
      final result = await apiService.getList<GetEmployeeDetails>(
        ApiConstants.getAllEmployees,
        (json) => GetEmployeeDetails.fromJson(json),
      );
      if (result == null) {
        loadError.value =
            ApiService.lastError ?? 'Could not load employees. Please try again.';
      }
      allUsers.value = result ?? [];
      applyUserFilters();
    } catch (e) {
      debugPrint("Error fetching users: $e");
      loadError.value = 'Could not load employees. Please try again.';
    } finally {
      getAllUsersLoading.value = false;
    }
  }

  // ── Form validation ─────────────────────────────────────────────────────────
  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _mobileRe = RegExp(r'^[0-9]{10,15}$');

  /// Returns an error message, or null when the form is valid.
  String? validateForm({required bool isEdit}) {
    if (firstNameController.text.trim().length < 2) {
      return 'First name is required (min 2 characters)';
    }
    final email = emailController.text.trim();
    if (email.isEmpty) return 'Email is required';
    if (!_emailRe.hasMatch(email)) return 'Enter a valid email address';
    final mobile = phoneController.text.trim();
    if (mobile.isEmpty) return 'Phone number is required';
    if (!_mobileRe.hasMatch(mobile)) {
      return 'Enter a valid mobile number (10 digits, numbers only)';
    }
    if (!isEdit && userPasswordController.value.text.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (selectedRoleId.value.isEmpty) return 'Please select a role';
    return null;
  }

  /// The backend stores a single user_name column, so first + last are joined.
  String get _fullName => [
        firstNameController.text.trim(),
        lastNameController.text.trim(),
      ].where((s) => s.isNotEmpty).join(' ');

  String _errorText(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError ?? fallback;
  }

  Future<void> createUser() async {
    final error = validateForm(isEdit: false);
    if (error != null) {
      HelperUi.showToast(message: error, backgroundColor: Colors.red);
      return;
    }

    isCreateLoading.value = true;
    final formData = dio.FormData();

    if (uploadedDocuments.isNotEmpty && uploadedDocuments.first.bytes != null) {
      final fileName = uploadedDocuments.first.name;
      formData.files.add(
        MapEntry(
          'user_image',
          dio.MultipartFile.fromBytes(
            uploadedDocuments.first.bytes!,
            filename: fileName,
          ),
        ),
      );
    }

    // Required fields (org_id is taken from the JWT on the server)
    formData.fields.addAll([
      MapEntry('user_name', _fullName),
      MapEntry('user_mobile', phoneController.text.trim()),
      MapEntry('user_email', emailController.text.trim()),
      MapEntry('user_password', userPasswordController.value.text),
      MapEntry('user_role', selectedRoleId.value),
    ]);
    final uid = currentUserId;
    if (uid != null && uid.isNotEmpty) {
      formData.fields.add(MapEntry('userId', uid));
    }

    // Optional — only send when set to avoid Joi rejection on empty strings
    if (userGender.value.isNotEmpty) {
      formData.fields.add(MapEntry('user_gender', _genderToInt(userGender.value).toString()));
    }
    if (selectedBranchIdForUser.value > 0) {
      final branchId = selectedBranchIdForUser.value.toString();
      formData.fields.add(MapEntry('user_home_branch', branchId));
      formData.fields.add(MapEntry('user_branch_access', branchId));
    }

    try {
      final response =
          await apiService.postForm(ApiConstants.createEmployee, formData);
      createUserResponse.value = response;

      if (ApiService.isOk(response)) {
        clearFilters();
        userPasswordController.value.clear();
        uploadedDocuments.clear();
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User Created Successfully", backgroundColor: Colors.green);
        HelperUi.safeBack(Routes.MAIN);
      } else {
        HelperUi.showToast(
          message: _errorText(response, 'User creation failed.'),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint("User creation error: $e");
      HelperUi.showToast(message: "Something went wrong!", backgroundColor: Colors.red);
    } finally {
      isCreateLoading.value = false;
    }
  }

  /// Clear the create / edit form.
  void clearFilters() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    userPasswordController.value.clear();
    selectedRole.value = '';
    selectedRoleId.value = '';
    selectedCity.value = '';
    selectedBranchIdForUser.value = 0;
    userGender.value = '';
    uploadedDocuments.clear();
    editingUser.value = null;
  }

  void loadUserForEdit(GetEmployeeDetails user) {
    clearFilters();
    editingUser.value = user;
    // user_name is a single column; split it back into first / last.
    final name = user.userName == 'NA' ? '' : user.userName.trim();
    final space = name.indexOf(' ');
    if (space > 0) {
      firstNameController.text = name.substring(0, space);
      lastNameController.text = name.substring(space + 1).trim();
    } else {
      firstNameController.text = name;
    }
    phoneController.text = user.userMobile == 'NA' ? '' : user.userMobile;
    emailController.text = user.userEmail == 'NA' ? '' : user.userEmail;
    selectedRoleId.value = user.userRole > 0 ? user.userRole.toString() : '';

    // map int gender back to string
    switch (user.userGender) {
      case 1:
        userGender.value = 'Male';
        break;
      case 2:
        userGender.value = 'Female';
        break;
      case 3:
        userGender.value = 'Other';
        break;
      default:
        userGender.value = '';
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

    final error = validateForm(isEdit: true);
    if (error != null) {
      HelperUi.showToast(message: error, backgroundColor: Colors.red);
      return;
    }

    isUpdateLoading.value = true;
    final formData = dio.FormData();

    if (uploadedDocuments.isNotEmpty && uploadedDocuments.first.bytes != null) {
      formData.files.add(MapEntry(
        'user_image',
        dio.MultipartFile.fromBytes(
          uploadedDocuments.first.bytes!,
          filename: uploadedDocuments.first.name,
        ),
      ));
    }

    formData.fields.addAll([
      MapEntry('id', user.id.toString()),
      MapEntry('user_name', _fullName),
      MapEntry('user_mobile', phoneController.text.trim()),
      MapEntry('user_email', emailController.text.trim()),
      MapEntry('user_role', selectedRoleId.value),
    ]);
    final uid = currentUserId;
    if (uid != null && uid.isNotEmpty) {
      formData.fields.add(MapEntry('userId', uid));
    }

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
      if (ApiService.isOk(response)) {
        clearFilters();
        getAllEmployeesFromApi();
        HelperUi.showToast(message: "User Updated Successfully", backgroundColor: Colors.green);
        HelperUi.safeBack(Routes.MAIN);
      } else {
        HelperUi.showToast(
          message: _errorText(response, 'Update failed.'),
          backgroundColor: Colors.red,
        );
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

  /// Returns true when the server confirmed the termination.
  Future<bool> terminateUser(int targetUserId) async {
    isTerminateLoading.value = true;
    try {
      // putRaw returns null on any non-2xx (Dio throws), so null = failure.
      final response = await apiService.putRaw(
        ApiConstants.terminateEmployee,
        {'id': targetUserId},
      );
      if (ApiService.isOk(response)) {
        await getAllEmployeesFromApi();
        HelperUi.showToast(message: "User terminated successfully", backgroundColor: Colors.green);
        return true;
      }
      HelperUi.showToast(
        message: _errorText(response, 'Termination failed.'),
        backgroundColor: Colors.red,
      );
      return false;
    } catch (e) {
      debugPrint("Terminate user error: $e");
      HelperUi.showToast(message: "Something went wrong!", backgroundColor: Colors.red);
      return false;
    } finally {
      isTerminateLoading.value = false;
    }
  }
}
