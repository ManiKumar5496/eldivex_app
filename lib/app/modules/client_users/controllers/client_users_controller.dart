import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../models/client_user_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'package:dio/dio.dart' as dio;

class ClientUsersController extends GetxController {
  // Resolved on each access so a disposed DashboardController (after logout)
  // is never held on to.
  DashboardController get dashboardController =>
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());

  static const String defaultCountryCode = '+91';

  static const List<Map<String, String>> countryCodes = [
    {'code': '+91', 'flag': '🇮🇳'},
    {'code': '+1', 'flag': '🇺🇸'},
    {'code': '+44', 'flag': '🇬🇧'},
    {'code': '+971', 'flag': '🇦🇪'},
    {'code': '+65', 'flag': '🇸🇬'},
    {'code': '+61', 'flag': '🇦🇺'},
    {'code': '+49', 'flag': '🇩🇪'},
    {'code': '+33', 'flag': '🇫🇷'},
    {'code': '+81', 'flag': '🇯🇵'},
    {'code': '+86', 'flag': '🇨🇳'},
    {'code': '+966', 'flag': '🇸🇦'},
    {'code': '+974', 'flag': '🇶🇦'},
    {'code': '+968', 'flag': '🇴🇲'},
    {'code': '+60', 'flag': '🇲🇾'},
    {'code': '+977', 'flag': '🇳🇵'},
    {'code': '+94', 'flag': '🇱🇰'},
    {'code': '+880', 'flag': '🇧🇩'},
  ];

  // Step 1 - CreateClientUser screen
  final TextEditingController phoneNumberControllerClient =
      TextEditingController();
  final RxBool isSearchUserLoading = false.obs;
  final RxString selectedCountryCode = defaultCountryCode.obs;

  // Step 2 - AddClientUserDetails screen
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController clientPhoneController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController internalRemarksController =
      TextEditingController();
  final RxString detailsCountryCode = defaultCountryCode.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedLeadSource = ''.obs;
  final RxString selectedLeadType = ''.obs;
  final RxString selectedEnquiredFor = ''.obs;
  final RxString selectedServiceCityId = ''.obs;
  final RxBool clientDetailsUpdateLoading = false.obs;
  final RxBool isEditMode = false.obs;
  // Phone as stored on the server when the details form was opened; only a
  // changed number is sent back on save.
  String _loadedPhone = '';

  // Manage-list screen
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString filterLeadType = ''.obs;
  final RxString filterLeadSource = ''.obs;
  final RxBool isLoadingClientUsers = false.obs;
  final RxString loadError = ''.obs;
  final RxBool showFilters = false.obs;
  final RxList<ClientUserModel> clientUsers = <ClientUserModel>[].obs;
  final RxList<ClientUserModel> filteredClients = <ClientUserModel>[].obs;
  final ApiService apiService = ApiService();
  final RxInt currentPage = 0.obs; // 0-based
  final RxInt rowsPerPage = 10.obs;

  // Dropdown data — the 1-based position is the id stored by the backend.
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
  // enquiredFor is fetched from masterServices via dashboardController.categoriesList

  String _errorText(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError ?? fallback;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return fallback;
  }

  /// Split a stored phone ("+919876543210" or "9876543210") into
  /// (country code, local digits) using the known codes, longest first.
  static (String, String) splitPhone(String stored) {
    final s = stored.trim();
    if (s.startsWith('+')) {
      final codes = countryCodes.map((c) => c['code']!).toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      for (final code in codes) {
        if (s.startsWith(code)) {
          return (code, s.substring(code.length).replaceAll(RegExp(r'\D'), ''));
        }
      }
    }
    return (defaultCountryCode, s.replaceAll(RegExp(r'\D'), ''));
  }

  String? _phoneError(String digits, String countryCode) {
    if (countryCode == '+91') {
      return RegExp(r'^[6-9][0-9]{9}$').hasMatch(digits)
          ? null
          : 'Please enter a valid 10-digit Indian mobile number';
    }
    return RegExp(r'^[0-9]{6,15}$').hasMatch(digits)
        ? null
        : 'Please enter a valid phone number';
  }

  // STEP 1 - Find or create the client by phone (POST /createClientUser).
  // org comes from the JWT; this call issues no token.
  Future<void> addUserClient() async {
    final digits =
        phoneNumberControllerClient.text.replaceAll(RegExp(r'\D'), '');
    final err = _phoneError(digits, selectedCountryCode.value);
    if (err != null) {
      HelperUi.showToast(message: err, backgroundColor: Colors.red);
      return;
    }

    try {
      isSearchUserLoading.value = true;
      final response = await apiService.postRaw(ApiConstants.createClientUser, {
        "phone_number": digits,
        "country_code": selectedCountryCode.value,
      });
      if (ApiService.isOk(response) && response!.data is Map) {
        final data = response.data as Map;
        final int userId = _toInt(data['userId']);
        final bool isNewUser = _toBool(data['isNewUser'], fallback: true);
        if (userId == 0) {
          HelperUi.showToast(
              message: "Could not resolve the client. Please try again.",
              backgroundColor: Colors.red);
          return;
        }
        final countryCode = selectedCountryCode.value;
        phoneNumberControllerClient.clear();
        HelperUi.showToast(
          message: _errorText(response,
              isNewUser ? "Client created" : "Client found"),
          backgroundColor: Colors.green,
        );
        Get.toNamed(
          Routes.addClientDetails,
          arguments: {
            "userId": userId,
            "isNewUser": isNewUser,
            "phoneNumber": digits,
            "countryCode": countryCode,
          },
        );
      } else {
        HelperUi.showToast(
          message: _errorText(response, "Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      debugPrint("createClientUser error: $error");
      HelperUi.showToast(
          message: "Something went wrong. Please try again.",
          backgroundColor: Colors.red);
    } finally {
      isSearchUserLoading.value = false;
    }
  }

  // STEP 2 - Prepare the details form once per visit (called from initState,
  // never from build).
  final RxBool isFetchingUserDetails = false.obs;

  void openDetailsForm(Map<String, dynamic> args) {
    _resetDetailsForm();
    isEditMode.value = _toBool(args['isEdit']);
    final phone = args['phoneNumber']?.toString() ?? '';
    final cc = args['countryCode']?.toString();
    if (cc != null && cc.isNotEmpty) {
      detailsCountryCode.value = cc;
      clientPhoneController.text = phone.replaceAll(RegExp(r'\D'), '');
    } else if (phone.isNotEmpty) {
      final (code, digits) = splitPhone(phone);
      detailsCountryCode.value = code;
      clientPhoneController.text = digits;
    }
    _loadedPhone = '';
    final userId = _toInt(args['userId']);
    if (userId > 0) fetchUserDetailsById(userId);
    if (dashboardController.getAllBranches.isEmpty) {
      dashboardController.getAllBranchesApi();
    }
    if (dashboardController.categoriesList.isEmpty) {
      dashboardController.getCategoriesList();
    }
  }

  void _resetDetailsForm() {
    fullNameController.clear();
    clientPhoneController.clear();
    clientEmailController.clear();
    internalRemarksController.clear();
    detailsCountryCode.value = defaultCountryCode;
    selectedCity.value = '';
    selectedServiceCityId.value = '';
    selectedLeadSource.value = '';
    selectedLeadType.value = '';
    selectedEnquiredFor.value = '';
  }

  String _clean(String? v) =>
      (v == null || v.trim().isEmpty || v.trim() == 'NA') ? '' : v.trim();

  Future<void> fetchUserDetailsById(int userId) async {
    try {
      isFetchingUserDetails.value = true;
      final uri = Uri.parse(ApiConstants.getClientUserDetails)
          .replace(queryParameters: {'user_id': userId.toString()});
      final response = await apiService.getRaw(uri.toString());
      if (!ApiService.isOk(response)) return;
      final data = response!.data;
      Map<String, dynamic>? userData;
      if (data is List && data.isNotEmpty && data.first is Map) {
        userData = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        userData = Map<String, dynamic>.from(data);
      }
      if (userData == null) return;

      final user = ClientUserModel.fromJson(userData);
      final name = _clean(user.userName);
      if (name.isNotEmpty) fullNameController.text = name;
      final email = _clean(user.userEmail);
      if (email.isNotEmpty) clientEmailController.text = email;

      final storedPhone = _clean(user.phoneNumber);
      if (storedPhone.isNotEmpty) {
        _loadedPhone = storedPhone;
        final (code, digits) = splitPhone(storedPhone);
        detailsCountryCode.value = code;
        clientPhoneController.text = digits;
      }

      if (user.userServiceCity != null && user.userServiceCity! > 0) {
        selectedServiceCityId.value = user.userServiceCity.toString();
        final branch = dashboardController.getAllBranches
            .firstWhereOrNull((b) => b.brId == user.userServiceCity);
        selectedCity.value = branch?.brName ?? _clean(user.userLocation);
      } else {
        selectedCity.value = _clean(user.userLocation);
      }

      final src = user.userSource ?? 0;
      if (src >= 1 && src <= leadSourceList.length) {
        selectedLeadSource.value = leadSourceList[src - 1];
      }
      final lead = user.leadPotential ?? 0;
      if (lead >= 1 && lead <= leadTypeList.length) {
        selectedLeadType.value = leadTypeList[lead - 1];
      }
      if (user.enquiredFor != null && user.enquiredFor! > 0) {
        selectedEnquiredFor.value = user.enquiredFor.toString();
      }
      final remarks = _clean(user.enquiredForOther);
      if (remarks.isNotEmpty) internalRemarksController.text = remarks;
    } catch (e) {
      debugPrint("Fetch user details error: $e");
    } finally {
      isFetchingUserDetails.value = false;
    }
  }

  // STEP 2 - Validate details form then save
  // userId & isNewUser come from Get.arguments read in AddClientUserDetails
  void validateAndNext(int userId, bool isNewUser) {
    if (fullNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter full name", backgroundColor: Colors.red);
      return;
    }

    final phoneErr = _phoneError(
        clientPhoneController.text.trim(), detailsCountryCode.value);
    if (phoneErr != null) {
      HelperUi.showToast(message: phoneErr, backgroundColor: Colors.red);
      return;
    }

    // Email is optional, but must be a single valid address when given.
    final email = clientEmailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      HelperUi.showToast(message: "Please enter a valid email address", backgroundColor: Colors.red);
      return;
    }

    if (selectedServiceCityId.value.isEmpty) {
      HelperUi.showToast(message: "Please select service city", backgroundColor: Colors.red);
      return;
    }

    if (selectedLeadSource.value.isEmpty) {
      HelperUi.showToast(message: "Please select lead source", backgroundColor: Colors.red);
      return;
    }

    if (selectedLeadType.value.isEmpty) {
      HelperUi.showToast(message: "Please select lead type", backgroundColor: Colors.red);
      return;
    }

    if (selectedEnquiredFor.value.isEmpty) {
      HelperUi.showToast(message: "Please select enquired for", backgroundColor: Colors.red);
      return;
    }

    _submitUserDetails(userId, isNewUser);
  }

  int _leadSourceId(String label) => leadSourceList.indexOf(label) + 1;
  int _leadTypeId(String label) => leadTypeList.indexOf(label) + 1;

  Future<void> _submitUserDetails(int userId, bool isNewUser) async {
    try {
      clientDetailsUpdateLoading.value = true;

      final fields = <String, dynamic>{
        "id": userId.toString(),
        "user_name": fullNameController.text.trim(),
        "user_email": clientEmailController.text.trim(),
        "user_location": selectedCity.value,
        "user_service_city": selectedServiceCityId.value,
        "user_source": _leadSourceId(selectedLeadSource.value).toString(),
        "lead_potential": _leadTypeId(selectedLeadType.value).toString(),
        "enquired_for": selectedEnquiredFor.value,
        "enquired_for_other": internalRemarksController.text.trim(),
      };
      // Send the phone only when it was actually changed, in the same
      // "<code><digits>" form /createClientUser stores.
      final newPhone =
          '${detailsCountryCode.value}${clientPhoneController.text.trim()}';
      if (_loadedPhone.isNotEmpty &&
          splitPhone(_loadedPhone).$2 != clientPhoneController.text.trim()) {
        fields["phone_number"] = newPhone;
      }

      final response = await apiService.putForm(
        ApiConstants.putClientUserDetails,
        dio.FormData.fromMap(fields),
      );

      if (ApiService.isOk(response)) {
        HelperUi.showToast(
          message: "User details updated successfully",
          backgroundColor: Colors.green,
        );
        fetchClientUsers();

        if (isEditMode.value) {
          HelperUi.safeBack(Routes.MAIN);
        } else {
          // New/located client → continue to booking for them
          Get.offNamed(
            Routes.BOOKINGS,
            arguments: {
              "userId": userId,
              "isNewUser": isNewUser,
            },
          );
        }
      } else {
        HelperUi.showToast(
          message: _errorText(response, "Failed to update user. Please try again."),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint("saveUser error: $e");
      HelperUi.showToast(
        message: "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
      );
    } finally {
      clientDetailsUpdateLoading.value = false;
    }
  }

  // ── Manage list: search / filters / pagination (client-side over the
  // org-scoped list the API returns) ─────────────────────────────────────────

  void toggleFilters() => showFilters.toggle();

  void onSearchChanged(String q) {
    searchQuery.value = q;
    applyClientFilters();
  }

  void applyClientFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    final qDigits = q.replaceAll(RegExp(r'\D'), '');
    final type = filterLeadType.value;
    final source = filterLeadSource.value;
    filteredClients.value = clientUsers.where((u) {
      final matchesSearch = q.isEmpty ||
          (u.userName ?? '').toLowerCase().contains(q) ||
          (u.userEmail ?? '').toLowerCase().contains(q) ||
          (qDigits.isNotEmpty && (u.phoneNumber ?? '').contains(qDigits)) ||
          (u.id?.toString() ?? '') == q;
      final matchesType = type.isEmpty || u.leadPotentialLabel == type;
      final matchesSource = source.isEmpty || u.userSourceLabel == source;
      return matchesSearch && matchesType && matchesSource;
    }).toList();
    currentPage.value = 0;
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    filterLeadType.value = '';
    filterLeadSource.value = '';
    applyClientFilters();
  }

  int get totalPages {
    final n = filteredClients.length;
    final per = rowsPerPage.value;
    return n == 0 ? 1 : ((n + per - 1) ~/ per);
  }

  void goToPage(int page) {
    currentPage.value = page.clamp(0, totalPages - 1);
  }

  List<ClientUserModel> get pagedClients {
    final per = rowsPerPage.value;
    final page = currentPage.value.clamp(0, totalPages - 1);
    final start = page * per;
    if (start >= filteredClients.length) return const [];
    final end = (start + per).clamp(0, filteredClients.length);
    return filteredClients.sublist(start, end);
  }

  void fetchClients() {
    fetchClientUsers();
  }

  // Fetch all client users (org scoped by the JWT on the server)
  Future<void> fetchClientUsers() async {
    try {
      isLoadingClientUsers.value = true;
      loadError.value = '';

      final result = await apiService.getList<ClientUserModel>(
        ApiConstants.getClientUserDetails,
        (json) => ClientUserModel.fromJson(json),
      );

      if (result != null) {
        clientUsers.value = result;
      } else {
        loadError.value =
            ApiService.lastError ?? 'Could not load clients. Please try again.';
      }
      applyClientFilters();
    } catch (e) {
      debugPrint("fetchClientUsers error: $e");
      loadError.value = 'Could not load clients. Please try again.';
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

  void editClient(ClientUserModel user) {
    Get.toNamed(
      Routes.addClientDetails,
      arguments: {
        "userId": user.id ?? 0,
        "isNewUser": user.isNewUser,
        "phoneNumber": user.phoneNumber ?? '',
        "isEdit": true,
      },
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
    searchController.dispose();
    super.onClose();
  }
}
