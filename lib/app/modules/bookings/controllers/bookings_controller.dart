import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:eldivex_app/app/widgets/helper_ui.dart';
import 'package:eldivex_app/app/widgets/export_to_csv_common.dart';
import 'package:dio/dio.dart' as dio;
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../settings/models/get_discount_models.dart';
import '../../users/controllers/users_controller.dart';
import '../../users/models/get_users_model.dart';
import '../models/get_booking_hp_model.dart';
import '../views/manage_bookings.dart';

/// Reuse an already-registered controller instead of replacing it.
T _findOrPut<T extends GetxController>(T Function() create) =>
    Get.isRegistered<T>() ? Get.find<T>() : Get.put<T>(create());

class BookingsController extends GetxController {
  // ─────────────────────────────────────────────
  // Filter Visibility
  // ─────────────────────────────────────────────
  RxBool isFilterVisible = false.obs;

  // ─────────────────────────────────────────────
  // Filter Text Controllers (bookings list only)
  // ─────────────────────────────────────────────
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bookingIdController = TextEditingController();

  // ─────────────────────────────────────────────
  // Booking Detail Text Controllers
  // ─────────────────────────────────────────────
  final TextEditingController detailUserIdController = TextEditingController();
  final TextEditingController detailUserNameController = TextEditingController();
  final TextEditingController detailUserMobileController = TextEditingController();
  final TextEditingController detailUserEmailController = TextEditingController();
  final TextEditingController detailPatientIdController = TextEditingController();
  final TextEditingController detailPatientNameController = TextEditingController();
  final TextEditingController detailPatientPhoneController = TextEditingController();
  final TextEditingController detailPatientEmailController = TextEditingController();

  // ── Address Detail Controllers ──
  final TextEditingController detailAddressTagController = TextEditingController();
  final TextEditingController detailCountryController = TextEditingController();
  final TextEditingController detailStateController = TextEditingController();
  final TextEditingController detailCityController = TextEditingController();
  final TextEditingController detailAddressLine1Controller = TextEditingController();
  final TextEditingController detailAddressLine2Controller = TextEditingController();
  final TextEditingController detailLandmarkController = TextEditingController();
  final TextEditingController detailLocalityController = TextEditingController();
  final TextEditingController detailPincodeController = TextEditingController();
  final TextEditingController oldClientIdController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController serviceCityController = TextEditingController();
  final TextEditingController careManagerController = TextEditingController();
  final TextEditingController finalRateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final RxString ageDisplay = ''.obs;
  final TextEditingController yearOfBirthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController medicalConditionController = TextEditingController();
  final TextEditingController specialRequirementsController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();

  // ── Create Booking form (kept separate from the list filters) ──
  final TextEditingController patientPhoneController = TextEditingController();
  final TextEditingController clientLookupPhoneController = TextEditingController();

  // ─────────────────────────────────────────────
  // FIX: Stable display controllers for Price Details section
  // These are created ONCE here and reused — never created inside build/Obx
  // ─────────────────────────────────────────────
  final TextEditingController finalRateDisplayController = TextEditingController(text: '0.00');
  final TextEditingController discountPercentDisplayController = TextEditingController(text: '0.00');
  final TextEditingController discountValueDisplayController = TextEditingController(text: '0.00');

  // ─────────────────────────────────────────────
  // Filter Date Values
  // ─────────────────────────────────────────────
  Rx<DateTime?> serviceStartedOnAfter = Rx<DateTime?>(null);
  Rx<DateTime?> serviceStartedOnBefore = Rx<DateTime?>(null);
  Rx<DateTime?> bookingSubmittedOnAfter = Rx<DateTime?>(null);
  Rx<DateTime?> bookingSubmittedOnBefore = Rx<DateTime?>(null);

  // ─────────────────────────────────────────────
  // Booking Detail Date/Time Values
  // ─────────────────────────────────────────────
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  Rx<DateTime?> holdStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> holdEndDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> serviceStartTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> serviceEndTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> preferredTime = Rx<TimeOfDay?>(null);

  // ─────────────────────────────────────────────
  // Dropdown Reactive Values
  // ─────────────────────────────────────────────
  final RxInt selectedCareManagerId = 0.obs;
  final RxInt selectedServiceFilterId = 0.obs;
  final RxInt selectedBranchFilterId = 0.obs;
  RxString selectedBookingStatus = ''.obs;
  RxList<String> selectedLanguages = <String>[].obs;
  RxString selectedRelation = 'Self'.obs;
  RxString selectedGender = 'Male'.obs;
  RxInt selectedAddressId = 0.obs;
  RxInt clientUserId = 0.obs;
  RxInt selectedBranchId = 0.obs;
  RxInt selectedCategoryId = 0.obs;
  RxInt selectedServiceId = 0.obs;
  RxString baseRate = "".obs;
  RxString baseDiscount = "".obs;
  RxString finalDiscount = "".obs;
  RxString cuponId = "".obs;
  RxString finalRateForBooking = "".obs;

  final Rx<CouponModel?> selectedCoupon = Rx<CouponModel?>(null);
  final RxDouble appliedDiscountPercentage = 0.0.obs;
  final RxDouble appliedDiscountValue = 0.0.obs;
  final RxDouble computedFinalRate = 0.0.obs;
  final RxString selectedLeadType = ''.obs;
  final Rx<DateTime?> selectedFollowupDate = Rx<DateTime?>(null);
  final RxInt selectedCareManagerIdForBooking = 0.obs;
  Rx<bool?> patientStaysAlone = Rx<bool?>(null);
  final UsersController userController = _findOrPut(() => UsersController());

  List<GetEmployeeDetails> get careManagers {
    return userController.allUsers.value
        .where((user) => user.userRole == 3)
        .toList();
  }

  final RxInt selectedCgIdForAssignment = RxInt(0);
  final RxBool isAssignCgLoading = RxBool(false);

  // ─────────────────────────────────────────────
  // Globally Active HP IDs (across all bookings)
  // Populated by loadGlobalActiveHpIds(); used to
  // exclude busy HPs from the Assign CG dialog.
  // ─────────────────────────────────────────────
  final RxSet<int> globalActiveHpIds = <int>{}.obs;
  final RxBool isGlobalActiveHpLoading = false.obs;

  Future<void> loadGlobalActiveHpIds() async {
    try {
      isGlobalActiveHpLoading.value = true;
      final result = await baseApi.getList<GetBookingHpModel>(
        '${ApiConstants.getBookingsHpApi}?status=4',
        (json) => GetBookingHpModel.fromJson(json),
      );
      if (result != null) {
        // getHPByBooking ignores the status query, so keep only rows that are
        // actually active (status 4) — otherwise every HP ever shortlisted on
        // any booking would be treated as busy.
        final ids = result
            .where((hp) => hp.status == 4)
            .map((hp) => hp.hpRegId ?? 0)
            .where((id) => id != 0)
            .toSet();
        globalActiveHpIds
          ..clear()
          ..addAll(ids);
      }
    } catch (e) {
      debugPrint('loadGlobalActiveHpIds error: $e');
    } finally {
      isGlobalActiveHpLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Response helpers
  // ─────────────────────────────────────────────
  static bool _isOk(dio.Response? r) => ApiService.isOk(r);

  /// Backend error text from a failed response. putRaw/getRaw return null on
  /// HTTP errors, so ApiService.lastError (then [fallback]) is used there.
  static String _errorFrom(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final details = data['details'];
      if (details is List && details.isNotEmpty && details.first is Map) {
        final m = (details.first as Map)['message'];
        if (m != null && m.toString().isNotEmpty) return m.toString();
      }
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) return msg.toString();
    }
    final last = ApiService.lastError;
    return (last != null && last.trim().isNotEmpty) ? last : fallback;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  static String _toStr(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    return s == 'NA' ? '' : s;
  }

  static String _fmtTime24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  void _showApiError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> assignCgToBooking({
    required int bookingId,
    required int cgId,
  }) async {
    if (isAssignCgLoading.value) return; // prevent rapid double-tap
    if (cgId <= 0) {
      _showApiError('Invalid Health Professional selected');
      return;
    }
    isAssignCgLoading.value = true;
    try {
      final result = await baseApi.postRaw(ApiConstants.assignCgApi, {
        'booking_id': bookingId,
        'hp_id': cgId,
      });
      if (!_isOk(result)) {
        selectedCgIdForAssignment.value = 0;
        _showApiError(_errorFrom(result, 'Failed to assign Health Professional'));
        return;
      }
      HelperUi.showToast(message: 'Health Professional assigned successfully');
      selectedCgIdForAssignment.value = 0;
      Get.back();
      getBookingsFromApiByBkId(bookingId);
      getHealthProffApi(bookingId);
      selectedHPTab.value = 0;
    } finally {
      isAssignCgLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Filter option lists (real data)
  // ─────────────────────────────────────────────
  /// Booking status codes ('1'..'7') and the labels getUserBookings returns.
  static const Map<String, String> bookingStatusLabels = {
    '1': 'Booking Submitted',
    '2': 'HP Assigned',
    '3': 'Booking Cancelled',
    '4': 'Service Started',
    '5': 'service on hold',
    '6': 'Service cancelled',
    '7': 'Service Suspended',
  };

  List<String> get bookingStatuses => bookingStatusLabels.values.toList();

  static String statusLabel(String? status) {
    final s = (status ?? '').trim();
    return bookingStatusLabels[s] ?? s;
  }

  /// Services of this org, `{id, name}`, for the list filter.
  final RxList<Map<String, dynamic>> filterServices = <Map<String, dynamic>>[].obs;

  Future<void> fetchFilterServices() async {
    final response = await baseApi.getRaw(ApiConstants.getServices());
    if (!_isOk(response) || response!.data is! List) return;
    final seen = <int>{};
    final out = <Map<String, dynamic>>[];
    for (final e in response.data as List) {
      if (e is! Map) continue;
      final id = _toInt(e['id']);
      final name = _toStr(e['name']);
      if (id == null || name.isEmpty || !seen.add(id)) continue;
      out.add({'id': id, 'name': name});
    }
    filterServices.value = out;
  }

  // ─────────────────────────────────────────────
  // API / Loading State
  // ─────────────────────────────────────────────
  final RxBool getAllBookingsLoading = false.obs;
  final RxBool getAllHPLoading = false.obs;
  final RxBool allBookingsByBookingIdLoading = false.obs;
  final RxBool isCreateBookingLoading = false.obs;
  final RxBool isUpdateAddressLoading = false.obs;
  final RxBool isUpdateBookingLoading = false.obs;
  final RxBool isUpdatePatientLoading = false.obs;
  final RxBool isUpdateUserLoading = false.obs;

  Rx<List<GetBookingsModel>> allBookings = Rx<List<GetBookingsModel>>([]);
  // What the bookings list view renders. Always derived from `allBookings`
  // (which the org-scoped API populates) through `applyBookingFilters()`.
  RxList<GetBookingsModel> filteredBookings = <GetBookingsModel>[].obs;
  Rx<List<GetBookingHpModel>> allBookingHpData = Rx<List<GetBookingHpModel>>([]);
  Rx<List<GetBookingsModel>> bookingsByBookingId = Rx<List<GetBookingsModel>>([]);

  // ─────────────────────────────────────────────
  // Client-side pagination over filteredBookings
  // ─────────────────────────────────────────────
  static const int bookingsPageSize = 20;
  final RxInt bookingsPage = 0.obs;

  int get bookingsPageCount {
    final n = filteredBookings.length;
    return n == 0 ? 1 : ((n - 1) ~/ bookingsPageSize) + 1;
  }

  List<GetBookingsModel> get pagedBookings {
    final start = bookingsPage.value * bookingsPageSize;
    if (start >= filteredBookings.length) return const [];
    final end = (start + bookingsPageSize).clamp(0, filteredBookings.length);
    return filteredBookings.sublist(start, end);
  }

  void goToBookingsPage(int page) {
    bookingsPage.value = page.clamp(0, bookingsPageCount - 1);
  }

  // ─────────────────────────────────────────────
  // HP Tab
  // ─────────────────────────────────────────────
  RxInt selectedHPTab = 0.obs;

  // ─────────────────────────────────────────────
  // Extension List
  // ─────────────────────────────────────────────
  RxInt selectedExtensionTab = 0.obs;
  Rx<DateTime?> extensionFilterDate = Rx<DateTime?>(null);

  List<GetBookingsModel> get extensionBookings =>
      allBookings.value.where((b) => (b.extensionStatus ?? 0) != 0).toList();

  List<GetBookingsModel> get todayExtensions =>
      extensionBookings.where((b) => b.extensionStatus == 1).toList();

  List<GetBookingsModel> get tomorrowExtensions =>
      extensionBookings.where((b) => b.extensionStatus == 2).toList();

  List<GetBookingsModel> get nextDayExtensions =>
      extensionBookings.where((b) => b.extensionStatus == 3).toList();

  List<GetBookingsModel> get currentExtensionTabBookings {
    List<GetBookingsModel> list;
    switch (selectedExtensionTab.value) {
      case 1:
        list = tomorrowExtensions;
        break;
      case 2:
        list = nextDayExtensions;
        break;
      default:
        list = todayExtensions;
    }
    if (extensionFilterDate.value != null) {
      final filterDate = extensionFilterDate.value!;
      list = list.where((b) {
        if (b.serviceEndDate == null) return false;
        return b.serviceEndDate!.year == filterDate.year &&
            b.serviceEndDate!.month == filterDate.month &&
            b.serviceEndDate!.day == filterDate.day;
      }).toList();
    }
    return list;
  }

  void clearExtensionFilter() {
    extensionFilterDate.value = null;
  }


// Status mapping:
// 1 = Shortlisted, 2 = Interview Stage, 3 = Finalized, 4 = Active HP, 5 = Released HP
  List<GetBookingHpModel> get shortlistedHPs =>
      allBookingHpData.value.where((hp) => hp.status == 1).toList();

  List<GetBookingHpModel> get interviewStageHPs =>
      allBookingHpData.value.where((hp) => hp.status == 2).toList();

  List<GetBookingHpModel> get finalizedHPs =>
      allBookingHpData.value.where((hp) => hp.status == 3).toList();

  List<GetBookingHpModel> get activeHPs =>
      allBookingHpData.value.where((hp) => hp.status == 4).toList();

  List<GetBookingHpModel> get releasedHPs =>
      allBookingHpData.value.where((hp) => hp.status == 5).toList();

  List<GetBookingHpModel> get currentTabHPs {
    switch (selectedHPTab.value) {
      case 0: return shortlistedHPs;
      case 1: return interviewStageHPs;
      case 2: return finalizedHPs;
      case 3: return activeHPs;
      case 4: return releasedHPs;
      default: return shortlistedHPs;
    }
  }
  // ─────────────────────────────────────────────
  // Dependencies
  // ─────────────────────────────────────────────
  final ApiService baseApi = ApiService();
  final DashboardController dashboardController = _findOrPut(() => DashboardController());
  final SettingsController settingsController = _findOrPut(() => SettingsController());

  // Languages from API
  final RxList<Map<String, dynamic>> languagesList = <Map<String, dynamic>>[].obs;
  final RxBool isLanguagesLoading = false.obs;

  List<String> get languageNames => languagesList
      .map((l) => _toStr(l['name']))
      .where((n) => n.isNotEmpty)
      .toList();

  /// Comma-separated language ids for the given names. Patient languages are
  /// stored as ids, the same as HP languages, so matchHP can compare them.
  String languageIdsFor(Iterable<String> names) {
    final ids = <String>[];
    for (final n in names) {
      final match = languagesList.firstWhereOrNull(
        (l) => _toStr(l['name']).toLowerCase() == n.toLowerCase(),
      );
      final id = match == null ? '' : _toStr(match['id']);
      if (id.isNotEmpty) ids.add(id);
    }
    return ids.join(',');
  }

  /// Language names from a stored value (ids or, for older rows, names).
  List<String> languageNamesFrom(String? raw) {
    final out = <String>[];
    for (final part in (raw ?? '').split(',')) {
      final p = part.trim();
      if (p.isEmpty || p == 'NA') continue;
      final byId = languagesList.firstWhereOrNull((l) => _toStr(l['id']) == p);
      final byName = languagesList.firstWhereOrNull(
          (l) => _toStr(l['name']).toLowerCase() == p.toLowerCase());
      final name = _toStr((byId ?? byName)?['name']);
      if (name.isNotEmpty && !out.contains(name)) out.add(name);
    }
    return out;
  }

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final argUserId =
        args is Map ? _toInt(args['userId']) : null;
    ensureBookingsLoaded(clientUserId: argUserId);
    if (dashboardController.getAllBranches.isEmpty) {
      dashboardController.getAllBranchesApi();
    }
    fetchLanguages();
    fetchFilterServices();
    // Auto-calculate age when year of birth changes
    yearOfBirthController.addListener(_calculateAgeFromYob);
  }

  void _calculateAgeFromYob() {
    final yobText = yearOfBirthController.text.trim();
    // Only auto-calculate when a complete, valid 4-digit year is present.
    // Otherwise leave the age field untouched so a populated or manually-typed
    // age is never wiped out by an incomplete YOB.
    if (yobText.length != 4) return;
    final yob = int.tryParse(yobText);
    if (yob != null && yob > 1900 && yob <= DateTime.now().year) {
      final age = (DateTime.now().year - yob).toString();
      ageController.text = age;
      ageDisplay.value = age;
    }
  }

  Future<void> fetchLanguages() async {
    try {
      isLanguagesLoading.value = true;
      final response = await baseApi.getRaw(ApiConstants.getAllLanguages);
      if (_isOk(response) && response!.data is List) {
        languagesList.value = (response.data as List)
            .whereType<Map>()
            .map((e) => <String, dynamic>{'id': e['id'], 'name': _toStr(e['name'])})
            .where((m) => (m['name'] as String).isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint("Fetch languages error: $e");
    } finally {
      isLanguagesLoading.value = false;
    }
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    userIdController.dispose();
    nameController.dispose();
    phoneController.dispose();
    bookingIdController.dispose();
    detailUserIdController.dispose();
    detailUserNameController.dispose();
    detailUserMobileController.dispose();
    detailUserEmailController.dispose();
    detailPatientIdController.dispose();
    detailPatientNameController.dispose();
    detailPatientPhoneController.dispose();
    detailPatientEmailController.dispose();
    detailAddressTagController.dispose();
    detailCountryController.dispose();
    detailStateController.dispose();
    detailCityController.dispose();
    detailAddressLine1Controller.dispose();
    detailAddressLine2Controller.dispose();
    detailLandmarkController.dispose();
    detailLocalityController.dispose();
    detailPincodeController.dispose();
    oldClientIdController.dispose();
    serviceController.dispose();
    serviceCityController.dispose();
    careManagerController.dispose();
    finalRateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    ageController.dispose();
    yearOfBirthController.dispose();
    weightController.dispose();
    emailController.dispose();
    medicalConditionController.dispose();
    specialRequirementsController.dispose();
    patientNameController.dispose();
    patientPhoneController.dispose();
    clientLookupPhoneController.dispose();
    // FIX: dispose the new display controllers too
    finalRateDisplayController.dispose();
    discountPercentDisplayController.dispose();
    discountValueDisplayController.dispose();
  }

  // ─────────────────────────────────────────────
  // Filter Methods
  // ─────────────────────────────────────────────
  void toggleFilters() => isFilterVisible.value = !isFilterVisible.value;

  void clearFilters() {
    userIdController.clear();
    nameController.clear();
    phoneController.clear();
    bookingIdController.clear();
    serviceStartedOnAfter.value = null;
    serviceStartedOnBefore.value = null;
    bookingSubmittedOnAfter.value = null;
    bookingSubmittedOnBefore.value = null;
    selectedCareManagerId.value = 0;
    selectedServiceFilterId.value = 0;
    selectedBranchFilterId.value = 0;
    selectedBookingStatus.value = '';
    applyBookingFilters();
  }

  /// Applies the filter panel's inputs to the already-loaded bookings, in
  /// memory. No refetch — the list the API returned is already org-scoped, so
  /// filtering here can never surface another org's bookings.
  void searchBookings() {
    applyBookingFilters();
  }

  void applyBookingFilters() {
    final bookingId = bookingIdController.text.trim().toLowerCase();
    final name = nameController.text.trim().toLowerCase();
    final phone = phoneController.text.trim().toLowerCase();
    final userIdQ = userIdController.text.trim();
    final status = selectedBookingStatus.value.trim().toLowerCase();
    final branchId = selectedBranchFilterId.value;
    final serviceId = selectedServiceFilterId.value;
    final careManagerId = selectedCareManagerId.value;
    final startAfter = serviceStartedOnAfter.value;
    final startBefore = serviceStartedOnBefore.value;
    final submittedAfter = bookingSubmittedOnAfter.value;
    final submittedBefore = bookingSubmittedOnBefore.value;

    bool inRange(DateTime? d, DateTime? after, DateTime? before) {
      if (after == null && before == null) return true;
      if (d == null) return false;
      if (after != null && d.isBefore(DateTime(after.year, after.month, after.day))) {
        return false;
      }
      if (before != null &&
          d.isAfter(DateTime(before.year, before.month, before.day, 23, 59, 59))) {
        return false;
      }
      return true;
    }

    filteredBookings.value = allBookings.value.where((b) {
      final matchesBookingId =
          bookingId.isEmpty || b.id.toString().contains(bookingId);
      final matchesName =
          name.isEmpty || (b.userName ?? '').toLowerCase().contains(name);
      final matchesPhone =
          phone.isEmpty || (b.userMobile ?? '').toLowerCase().contains(phone);
      final matchesUserId = userIdQ.isEmpty || b.userId.toString() == userIdQ;
      final matchesStatus =
          status.isEmpty || statusLabel(b.status).toLowerCase() == status;
      final matchesBranch = branchId == 0 || b.branchId == branchId;
      final matchesService = serviceId == 0 || b.serviceTypeId == serviceId;
      final matchesCareManager =
          careManagerId == 0 || b.hpManager == careManagerId;
      final matchesStart =
          inRange(b.serviceStartDate, startAfter, startBefore);
      final matchesSubmitted =
          inRange(b.originalBookingDate ?? b.createdOn, submittedAfter, submittedBefore);
      return matchesBookingId &&
          matchesName &&
          matchesPhone &&
          matchesUserId &&
          matchesStatus &&
          matchesBranch &&
          matchesService &&
          matchesCareManager &&
          matchesStart &&
          matchesSubmitted;
    }).toList();
    bookingsPage.value = 0;
  }

  // ─────────────────────────────────────────────
  // CSV export of the filtered list
  // ─────────────────────────────────────────────
  void exportBookingsCsv() {
    if (filteredBookings.isEmpty) {
      HelperUi.showToast(message: 'No bookings to export');
      return;
    }
    final df = DateFormat('yyyy-MM-dd');
    String d(DateTime? v) => v == null ? '' : df.format(v);
    ExportToCsv().exportToCSV(
      const [
        'Booking ID', 'Status', 'Created On', 'Client', 'Client Mobile',
        'Patient', 'Service', 'Branch', 'Start Date', 'End Date',
        'Base Rate', 'Final Rate', 'Care Manager',
      ],
      filteredBookings
          .map((b) => [
                'BK-${b.id}',
                statusLabel(b.status),
                d(b.createdOn),
                b.userName ?? '',
                b.userMobile ?? '',
                b.patientName ?? '',
                b.serviceName ?? '',
                b.branchName ?? '',
                d(b.serviceStartDate),
                d(b.serviceEndDate),
                b.baseRate,
                b.finalRate?.toStringAsFixed(2) ?? '',
                b.careManagerName ?? '',
              ])
          .toList(),
      fileName: 'bookings_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv',
    );
  }

  // ─────────────────────────────────────────────
  // API – Get Bookings
  // ─────────────────────────────────────────────
  /// Client id the current `allBookings` list is scoped to (null = all).
  int? _loadedBookingsScope;
  bool _bookingsLoadedOnce = false;

  /// Loads the bookings list for the given scope unless it is already loaded
  /// (or loading). Views call this once from initState, never from build().
  void ensureBookingsLoaded({int? clientUserId}) {
    if (_bookingsLoadedOnce && _loadedBookingsScope == clientUserId) return;
    if (clientUserId != null) {
      getBookingsFromUserCreation(clientUserId: clientUserId);
    } else {
      getBookingsFromApi();
    }
  }

  Future<void> getBookingsFromApi() => _loadBookings(null);

  Future<void> getBookingsFromUserCreation({int? clientUserId}) =>
      _loadBookings(clientUserId);

  Future<void> _loadBookings(int? clientUserId) async {
    _loadedBookingsScope = clientUserId;
    _bookingsLoadedOnce = true;
    getAllBookingsLoading.value = true;
    try {
      final url = clientUserId != null
          ? '${ApiConstants.getBookingsApi}?user_id=$clientUserId'
          : ApiConstants.getBookingsApi;
      final result = await baseApi.getList<GetBookingsModel>(
        url,
        (json) => GetBookingsModel.fromJson(json),
      );
      // A newer request for a different scope may have started meanwhile.
      if (_loadedBookingsScope != clientUserId) return;
      if (result == null) {
        _bookingsLoadedOnce = false;
        _showApiError(ApiService.lastError ?? 'Failed to load bookings');
        return;
      }
      allBookings.value = result;
      applyBookingFilters();
    } finally {
      getAllBookingsLoading.value = false;
    }
  }

  Future<void> getBookingsFromApiByBkId(int bkId) async {
    allBookingsByBookingIdLoading.value = true;
    try {
      final result = await baseApi.getList<GetBookingsModel>(
        '${ApiConstants.getBookingsApi}?id=$bkId',
        (json) => GetBookingsModel.fromJson(json),
      );
      bookingsByBookingId.value = result ?? [];
      if (bookingsByBookingId.value.isNotEmpty) {
        _populateEditForm(bookingsByBookingId.value.first);
      }
    } catch (e) {
      debugPrint('Error fetching booking by id: $e');
    } finally {
      allBookingsByBookingIdLoading.value = false;
    }
  }

  Future<void> getHealthProffApi(int bookingId) async {
    getAllHPLoading.value = true;
    try {
      final result = await baseApi.getList<GetBookingHpModel>(
        "${ApiConstants.getBookingsHpApi}?bkng_id=$bookingId",
        (json) => GetBookingHpModel.fromJson(json),
      );
      allBookingHpData.value = result ?? [];
    } finally {
      getAllHPLoading.value = false;
    }
  }

  /// Rate change history for a booking (edx_rate_history). Returns null when
  /// the request fails; the error has already been shown.
  Future<List<Map<String, dynamic>>?> fetchRateHistory(int bookingId) async {
    final response = await baseApi.getRaw(ApiConstants.getRateHistory(bookingId));
    if (!_isOk(response) || response!.data is! List) {
      _showApiError(_errorFrom(response, 'Failed to load rate history'));
      return null;
    }
    return (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Load for Edit View
  // ─────────────────────────────────────────────
  void loadBookingForEdit(int bookingId) {
    if (bookingsByBookingId.value.isNotEmpty &&
        bookingsByBookingId.value.first.id == bookingId) {
      _populateEditForm(bookingsByBookingId.value.first);
      return;
    }
    getBookingsFromApiByBkId(bookingId);
  }

  // ─────────────────────────────────────────────
  // Populate Form Fields from Model
  // ─────────────────────────────────────────────
  void _populateEditForm(GetBookingsModel booking) {
    // ── User details ──────────────────────────
    detailUserIdController.text = 'USR-${booking.userId}';
    detailUserNameController.text = booking.userName ?? '';
    detailUserMobileController.text = booking.userMobile ?? '';
    detailUserEmailController.text = booking.userEmail ?? '';

    // ── Patient details ───────────────────────
    detailPatientIdController.text = 'PAT-${booking.patientId}';
    detailPatientNameController.text = booking.patientName ?? '';
    detailPatientPhoneController.text = booking.patientPhoneNumber ?? booking.userMobile ?? '';
    detailPatientEmailController.text = booking.patientEmail ?? '';

    ageController.text = booking.patientAge?.toString() ?? '';
    yearOfBirthController.text = booking.patientYob?.toString() ?? '';
    weightController.text = booking.patientWeight?.toString() ?? '';

    // ── Gender ───────────────────────────────
    switch (booking.patientGender) {
      case 2:
        selectedGender.value = 'Female';
        break;
      case 3:
        selectedGender.value = 'Other';
        break;
      default:
        selectedGender.value = 'Male';
    }

    // ── Languages / relation / stays alone (when the API returns them) ──
    selectedLanguages.value = languageNamesFrom(booking.patientLanguages);
    final relation = (booking.patientRelation ?? '').trim();
    selectedRelation.value =
        relation.isEmpty || relation == 'NA' ? 'Self' : relation;
    patientStaysAlone.value = booking.patientIsStayAlone == null
        ? null
        : booking.patientIsStayAlone == 1;

    // ── Booking / service details ─────────────
    oldClientIdController.text = booking.branchId.toString();
    serviceCityController.text = booking.branchCity ?? '';
    careManagerController.text = booking.hpManager?.toString() ?? '';
    finalRateController.text = booking.baseRate;
    baseRate.value = booking.baseRate;

    // ── Restore previously persisted discount / final rate so the price
    //    section reflects what was saved instead of resetting to base rate. ──
    final baseRateValue = double.tryParse(booking.baseRate) ?? 0.0;
    final persistedFinalRate = booking.finalRate ?? baseRateValue;
    final restoredDiscount =
        (baseRateValue - persistedFinalRate).clamp(0.0, baseRateValue);
    appliedDiscountValue.value = restoredDiscount;
    appliedDiscountPercentage.value =
        baseRateValue > 0 ? (restoredDiscount / baseRateValue) * 100 : 0.0;
    computedFinalRate.value = persistedFinalRate;
    finalDiscount.value = restoredDiscount.toStringAsFixed(2);
    cuponId.value = booking.couponDiscountId?.toString() ?? '';

    // ── Dates ─────────────────────────────────
    startDate.value = booking.serviceStartDate;
    endDate.value = booking.serviceEndDate;
    holdStartDate.value = booking.holdStartDate;
    holdEndDate.value = booking.holdEndDate;

    // ── Times ─────────────────────────────────
    serviceStartTime.value = _parseTimeString(booking.serviceStartTime);
    serviceEndTime.value = _parseTimeString(booking.serviceEndTime);

    startTimeController.text =
        serviceStartTime.value != null ? _formatTimeOfDay(serviceStartTime.value!) : '';
    endTimeController.text =
        serviceEndTime.value != null ? _formatTimeOfDay(serviceEndTime.value!) : '';

    // ── Health / notes ────────────────────────
    medicalConditionController.text = booking.patientConditionsOthers ?? '';
    specialRequirementsController.text = booking.splCareRequirements ?? '';

    // ── IDs ───────────────────────────────────
    selectedBranchId.value = booking.branchId;
    selectedAddressId.value = booking.addressId;

    // ── Address ────────────────────────────────
    detailAddressTagController.text = booking.addressTagName ?? '';
    detailCountryController.text = booking.country ?? '';
    detailStateController.text = booking.state ?? '';
    detailCityController.text = booking.city ?? '';
    detailAddressLine1Controller.text = booking.addressLine1 ?? '';
    detailAddressLine2Controller.text = booking.addressLine2 ?? '';
    detailLandmarkController.text = booking.landmark ?? '';
    detailLocalityController.text = booking.locality ?? '';
    detailPincodeController.text = booking.pincode ?? '';

    // ── Lead & Care Manager ────────────────────
    selectedLeadType.value = booking.leadPotential ?? '';
    selectedFollowupDate.value = booking.followupDate;
    selectedCareManagerIdForBooking.value = booking.hpManager ?? 0;

    // FIX: sync display controllers after populating base rate
    _syncDisplayControllers();
  }

  // ─────────────────────────────────────────────
  // FIX: Keep display controllers in sync with computed values
  // Called after any change to base rate or coupon
  // ─────────────────────────────────────────────
  void _syncDisplayControllers() {
    final base = double.tryParse(finalRateController.text) ?? 0.0;
    computedFinalRate.value = base - appliedDiscountValue.value;
    finalRateDisplayController.text = computedFinalRate.value.toStringAsFixed(2);
    discountPercentDisplayController.text = appliedDiscountPercentage.value.toStringAsFixed(2);
    discountValueDisplayController.text = appliedDiscountValue.value.toStringAsFixed(2);
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return _formatTimeOfDay(time);
  }

  // ─────────────────────────────────────────────
  // Date / Time Pickers
  // ─────────────────────────────────────────────
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Keeps showDatePicker's `initialDate >= firstDate` assertion satisfied.
  static DateTime _clampInitial(DateTime? initial, DateTime first) {
    final f = _dateOnly(first);
    final i = _dateOnly(initial ?? first);
    return i.isBefore(f) ? f : i;
  }

  Future<void> selectStartDate(BuildContext context) async {
    final first = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampInitial(startDate.value, first),
      firstDate: _dateOnly(first),
      lastDate: DateTime(2100),
    );
    if (picked != null) onCreateStartDateSelected(picked);
  }

  Future<void> selectEndDate(BuildContext context) async {
    final first = startDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampInitial(endDate.value, first),
      firstDate: _dateOnly(first),
      lastDate: DateTime(2100),
    );
    if (picked != null) endDate.value = picked;
  }

  /// Start date on the create form; drops an end date that would now precede it.
  void onCreateStartDateSelected(DateTime date) {
    startDate.value = date;
    if (endDate.value != null && _dateOnly(endDate.value!).isBefore(_dateOnly(date))) {
      endDate.value = null;
    }
  }

  void onCreateEndDateSelected(DateTime date) {
    if (startDate.value != null &&
        _dateOnly(date).isBefore(_dateOnly(startDate.value!))) {
      _showApiError('End date cannot be before the start date');
      return;
    }
    endDate.value = date;
  }

  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: preferredTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) preferredTime.value = picked;
  }

  // ─────────────────────────────────────────────
  // Branch / Category / Service Selection
  // ─────────────────────────────────────────────
  void onBranchSelected(int? branchId) {
    if (branchId != null && branchId != selectedBranchId.value) {
      selectedBranchId.value = branchId;
      dashboardController.selectedBranchId.value = branchId;
      selectedCategoryId.value = 0;
      selectedServiceId.value = 0;
      dashboardController.selectedCategoryId.value = 0;
      dashboardController.getServicesByCityId.clear();
      dashboardController.getCategoriesList();
    }
  }

  void onCategorySelected(int? categoryId) {
    if (categoryId != null && categoryId != selectedCategoryId.value) {
      selectedCategoryId.value = categoryId;
      dashboardController.selectedCategoryId.value = categoryId;
      selectedServiceId.value = 0;
      dashboardController.getServicesByCityId.clear();
      dashboardController.getServiceListById();
    }
  }

  void onServiceSelected(int? serviceId) {
    if (serviceId != null) selectedServiceId.value = serviceId;
  }

  // ─────────────────────────────────────────────
  // Create Booking – client lookup & addresses
  // ─────────────────────────────────────────────
  /// The client (edx_client_app_users row) the new booking is for.
  final Rxn<Map<String, dynamic>> selectedClient = Rxn<Map<String, dynamic>>();
  final RxBool isClientLookupLoading = false.obs;
  final RxList<Map<String, dynamic>> clientAddresses = <Map<String, dynamic>>[].obs;
  final RxBool isClientAddressesLoading = false.obs;
  final RxBool isAddAddressLoading = false.obs;

  int get selectedClientId => _toInt(selectedClient.value?['id']) ?? 0;

  Map<String, dynamic> _clientFromJson(Map json) => {
        'id': _toInt(json['id']) ?? 0,
        'name': _toStr(json['user_name']),
        'phone': _toStr(json['phone_number']),
        'email': _toStr(json['user_email']),
      };

  Future<List<Map<String, dynamic>>?> _fetchClients(String query) async {
    final response =
        await baseApi.getRaw('${ApiConstants.getClientUserDetails}?$query');
    if (!_isOk(response) || response!.data is! List) {
      _showApiError(_errorFrom(response, 'Failed to look up client'));
      return null;
    }
    return (response.data as List)
        .whereType<Map>()
        .map(_clientFromJson)
        .where((c) => (c['id'] as int) > 0)
        .toList();
  }

  /// Looks the client up by exact phone number within this org.
  Future<void> lookupClientByPhone() async {
    final phone = clientLookupPhoneController.text.trim();
    if (phone.isEmpty) {
      _showApiError('Enter the client phone number to search');
      return;
    }
    isClientLookupLoading.value = true;
    try {
      final clients =
          await _fetchClients('phone_number=${Uri.encodeQueryComponent(phone)}');
      if (clients == null) return;
      if (clients.isEmpty) {
        _showApiError(
            'No client found with this phone number. Add the client in Client Users first.');
        return;
      }
      _selectClient(clients.first);
    } finally {
      isClientLookupLoading.value = false;
    }
  }

  /// Preselects a client passed in from the Client Users screen.
  Future<void> selectClientById(int userId) async {
    if (userId <= 0 || selectedClientId == userId) return;
    isClientLookupLoading.value = true;
    try {
      final clients = await _fetchClients('user_id=$userId');
      if (clients == null || clients.isEmpty) {
        _showApiError('Client #$userId was not found');
        return;
      }
      _selectClient(clients.first);
    } finally {
      isClientLookupLoading.value = false;
    }
  }

  void _selectClient(Map<String, dynamic> client) {
    selectedClient.value = client;
    clientLookupPhoneController.text = client['phone'] as String? ?? '';
    selectedAddressId.value = 0;
    loadClientAddresses();
  }

  void clearSelectedClient() {
    selectedClient.value = null;
    clientAddresses.clear();
    selectedAddressId.value = 0;
  }

  Future<void> loadClientAddresses({int? selectId}) async {
    final userId = selectedClientId;
    if (userId <= 0) return;
    isClientAddressesLoading.value = true;
    try {
      final response =
          await baseApi.getRaw(ApiConstants.getAddressByClient(userId.toString()));
      if (!_isOk(response) || response!.data is! List) {
        _showApiError(_errorFrom(response, 'Failed to load client addresses'));
        return;
      }
      final list = (response.data as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((a) => (_toInt(a['id']) ?? 0) > 0)
          .toList();
      clientAddresses.value = list;
      final ids = list.map((a) => _toInt(a['id'])!).toList();
      if (selectId != null && ids.contains(selectId)) {
        selectedAddressId.value = selectId;
      } else if (!ids.contains(selectedAddressId.value)) {
        selectedAddressId.value = ids.length == 1 ? ids.first : 0;
      }
    } finally {
      isClientAddressesLoading.value = false;
    }
  }

  static String addressLabel(Map<String, dynamic> a) {
    final tag = _toStr(a['address_tag_name']);
    final parts = [
      _toStr(a['address_line1']),
      _toStr(a['locality']),
      _toStr(a['city']),
      _toStr(a['pincode']),
    ].where((s) => s.isNotEmpty).join(', ');
    if (tag.isEmpty) return parts.isEmpty ? 'Address #${a['id']}' : parts;
    return parts.isEmpty ? tag : '$tag – $parts';
  }

  /// Adds an address for the selected client and selects it. Returns true on
  /// success.
  Future<bool> addClientAddress({
    required String addressTagName,
    required String country,
    required String state,
    required String city,
    required String addressLine1,
    required String addressLine2,
    required String landmark,
    required String locality,
    required String pincode,
  }) async {
    final userId = selectedClientId;
    if (userId <= 0) {
      _showApiError('Select a client first');
      return false;
    }
    isAddAddressLoading.value = true;
    try {
      final before = clientAddresses.map((a) => _toInt(a['id']) ?? 0).toSet();
      final response = await baseApi.postRaw(ApiConstants.addAddressByClient, {
        'user_id': userId,
        'address_tag_name': addressTagName,
        'country': country,
        'state': state,
        'city': city,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'landmark': landmark,
        'locality': locality,
        'pincode': pincode,
      });
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to add address'));
        return false;
      }
      final data = response!.data;
      int? newId = data is Map ? _toInt(data['address_id'] ?? data['id']) : null;
      await loadClientAddresses(selectId: newId);
      if (newId == null) {
        // addAddress does not return the id; pick the row that just appeared.
        final added = clientAddresses
            .map((a) => _toInt(a['id']) ?? 0)
            .where((id) => !before.contains(id))
            .fold<int>(0, (a, b) => b > a ? b : a);
        if (added > 0) selectedAddressId.value = added;
      }
      HelperUi.showToast(message: 'Address added');
      return true;
    } finally {
      isAddAddressLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Reset Create Booking form state
  // Called before navigating to the Create Booking screen
  // ─────────────────────────────────────────────
  void resetCreateBookingForm() {
    selectedAddressId.value = 0;
    selectedBranchId.value = 0;
    selectedCategoryId.value = 0;
    selectedServiceId.value = 0;
    selectedLanguages.clear();
    selectedGender.value = 'Male';
    selectedRelation.value = 'Self';
    patientStaysAlone.value = null;
    startDate.value = null;
    endDate.value = null;
    serviceStartTime.value = null;
    serviceEndTime.value = null;
    preferredTime.value = null;
    baseRate.value = '';
    baseDiscount.value = '';
    finalDiscount.value = '';
    cuponId.value = '';
    finalRateForBooking.value = '';
    appliedDiscountPercentage.value = 0.0;
    appliedDiscountValue.value = 0.0;
    computedFinalRate.value = 0.0;
    selectedCoupon.value = null;
    patientNameController.clear();
    patientPhoneController.clear();
    clientLookupPhoneController.clear();
    clearSelectedClient();
    emailController.clear();
    ageController.clear();
    ageDisplay.value = '';
    yearOfBirthController.clear();
    weightController.clear();
    medicalConditionController.clear();
    specialRequirementsController.clear();
    finalRateDisplayController.text = '0.00';
    discountPercentDisplayController.text = '0.00';
    discountValueDisplayController.text = '0.00';
  }

  // ─────────────────────────────────────────────
  // Create Booking
  // ─────────────────────────────────────────────
  Future<void> createBooking() async {
    if (!_validateCreateForm()) return;
    if (isCreateBookingLoading.value) return;
    isCreateBookingLoading.value = true;

    final genderMap = {'Male': 1, 'Female': 2, 'Other': 3};
    final languageIds = languageIdsFor(selectedLanguages);
    final patientPhone = patientPhoneController.text.trim();

    final Map<String, dynamic> body = {
      'branch_id': selectedBranchId.value,
      'user_id': selectedClientId,
      'service_start_date': DateFormat('yyyy-MM-dd').format(startDate.value!),
      'service_end_date': DateFormat('yyyy-MM-dd').format(endDate.value!),
      if (serviceStartTime.value != null)
        'service_start_time': _fmtTime24(serviceStartTime.value!),
      if (serviceEndTime.value != null)
        'service_end_time': _fmtTime24(serviceEndTime.value!),
      'patient_name': patientNameController.text.trim(),
      if (patientPhone.isNotEmpty) 'phone_number': patientPhone,
      if (emailController.text.trim().isNotEmpty)
        'email': emailController.text.trim(),
      if (int.tryParse(ageController.text.trim()) != null)
        'age': int.parse(ageController.text.trim()),
      if (int.tryParse(yearOfBirthController.text.trim()) != null)
        'yob': int.parse(yearOfBirthController.text.trim()),
      if (double.tryParse(weightController.text.trim()) != null)
        'weight': double.parse(weightController.text.trim()),
      if (languageIds.isNotEmpty) 'languages': languageIds,
      'relation': selectedRelation.value,
      'gender': genderMap[selectedGender.value] ?? 1,
      'is_stay_alone': patientStaysAlone.value == true ? 1 : 0,
      'address_id': selectedAddressId.value,
      'service_type_id': selectedServiceId.value,
      'base_rate': double.tryParse(baseRate.value) ?? 0,
      if (baseDiscount.value.isNotEmpty && baseDiscount.value != '0')
        'base_discount_percentage': double.tryParse(baseDiscount.value),
    };

    try {
      final result = await baseApi.postRaw(ApiConstants.createBookingApi, body);
      if (!_isOk(result)) {
        _showApiError(_errorFrom(result, 'Failed to create booking'));
        return;
      }
      final data = result!.data;
      final int? bookingId = data is Map ? _toInt(data['booking_id']) : null;
      if (bookingId == null) {
        _showApiError('Invalid booking ID returned from API');
        return;
      }

      // createBooking does not take the care notes or preferred time, so
      // persist them on the new booking through updateBooking.
      final notes = <String, dynamic>{
        if (medicalConditionController.text.trim().isNotEmpty)
          'patient_conditions_others': medicalConditionController.text.trim(),
        if (specialRequirementsController.text.trim().isNotEmpty)
          'spl_care_requirements': specialRequirementsController.text.trim(),
        if (preferredTime.value != null)
          'placement_time': _fmtTime24(preferredTime.value!),
      };
      if (notes.isNotEmpty) {
        final upd = await baseApi.putRaw(
          ApiConstants.updateBookingsEditApi,
          {'booking_id': bookingId, ...notes},
        );
        if (!_isOk(upd)) {
          _showApiError(
              'Booking BK-$bookingId was created, but saving the medical condition / '
              'requirements failed. Add them from Edit Booking.');
        }
      }

      HelperUi.showToast(message: 'Booking created successfully');
      getBookingsFromApi();
      Get.to(() => ManageBookingView(bookingId: bookingId));
    } finally {
      isCreateBookingLoading.value = false;
    }
  }

  bool _validateCreateForm() {
    void err(String m) => Get.snackbar('Validation Error', m);
    if (selectedClientId <= 0) {
      err('Select the client (search by phone number)');
      return false;
    }
    final name = patientNameController.text.trim();
    if (name.length < 2) {
      err('Patient name is required');
      return false;
    }
    final yob = int.tryParse(yearOfBirthController.text.trim());
    if (yob == null || yob < 1900 || yob > DateTime.now().year) {
      err('Enter a valid year of birth');
      return false;
    }
    final weight = double.tryParse(weightController.text.trim());
    if (weight == null || weight <= 0) {
      err('Enter a valid weight');
      return false;
    }
    if (patientStaysAlone.value == null) {
      err('Please select if patient stays alone');
      return false;
    }
    if (selectedAddressId.value <= 0) {
      err('Select or add the service address');
      return false;
    }
    final phone = patientPhoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^[0-9]{10,15}$').hasMatch(phone)) {
      err('Patient phone must be 10–15 digits');
      return false;
    }
    final email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      err('Enter a valid email address');
      return false;
    }
    if (medicalConditionController.text.trim().isEmpty) {
      err('Medical condition is required');
      return false;
    }
    if (startDate.value == null) {
      err('Start date is required');
      return false;
    }
    if (endDate.value == null) {
      err('End date is required');
      return false;
    }
    if (_dateOnly(endDate.value!).isBefore(_dateOnly(startDate.value!))) {
      err('End date cannot be before the start date');
      return false;
    }
    if (serviceStartTime.value == null || serviceEndTime.value == null) {
      err('Start and end time are required');
      return false;
    }
    if (selectedBranchId.value == 0) {
      err('Please select a branch');
      return false;
    }
    if (selectedCategoryId.value == 0) {
      err('Please select a service category');
      return false;
    }
    if (selectedServiceId.value == 0) {
      err('Please select a service');
      return false;
    }
    if ((double.tryParse(baseRate.value) ?? 0) <= 0) {
      err('The selected service has no rate');
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────
  // Cancel Booking
  // ─────────────────────────────────────────────
  final RxBool isCancelBookingLoading = false.obs;

  Future<void> cancelBooking(int bookingId, DateTime endDate, String reason) async {
    isCancelBookingLoading.value = true;
    try {
      final result = await baseApi.postRaw(ApiConstants.cancelBookingApi, {
        'booking_id': bookingId,
        'term_date': DateFormat('yyyy-MM-dd').format(endDate),
        'term_reason': reason,
        'booking_status': 5,
        'term_remarks': 'remarks not done',
      });
      if (!_isOk(result)) {
        _showApiError(_errorFrom(result, 'Failed to cancel booking'));
        return;
      }
      HelperUi.showToast(message: 'Booking cancelled successfully');
      Get.back();
      getBookingsFromApi();
    } finally {
      isCancelBookingLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Hold Booking
  // ─────────────────────────────────────────────
  final RxBool isHoldBookingLoading = false.obs;

  Future<void> holdBooking(
      int bookingId,
      DateTime holdStart,
      DateTime holdEnd,
      String reason,
      ) async {
    isHoldBookingLoading.value = true;
    try {
      final result = await baseApi.postRaw(ApiConstants.holdBookingApi, {
        'booking_id': bookingId,
        'hold_start_date': DateFormat('yyyy-MM-dd').format(holdStart),
        'hold_end_date': DateFormat('yyyy-MM-dd').format(holdEnd),
        'hold_reason': reason,
      });
      if (!_isOk(result)) {
        _showApiError(_errorFrom(result, 'Failed to hold booking'));
        return;
      }
      HelperUi.showToast(message: 'Service hold successful');
      getBookingsFromApiByBkId(bookingId);
    } finally {
      isHoldBookingLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Extend Service
  // ─────────────────────────────────────────────
  final RxBool isExtendServiceLoading = false.obs;

  Future<void> extendService(
    int bookingId,
    DateTime newStartDate,
    DateTime newEndDate,
    String notes,
  ) async {
    isExtendServiceLoading.value = true;

    // The backend derives the invoice amount from the booking's final rate and
    // keeps the existing service times when from/to time are omitted.
    final activeHp = activeHPs.isNotEmpty ? activeHPs.first : null;
    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'from_date': DateFormat('yyyy-MM-dd').format(newStartDate),
      'to_date': DateFormat('yyyy-MM-dd').format(newEndDate),
      if (notes.isNotEmpty) 'extension_notes': notes,
      if (serviceStartTime.value != null)
        'from_time': _fmtTime24(serviceStartTime.value!),
      if (serviceEndTime.value != null)
        'to_time': _fmtTime24(serviceEndTime.value!),
      if (activeHp != null && activeHp.hpUniqueId > 0) ...{
        'hp_id': activeHp.hpUniqueId,
        'hp_unique_id': activeHp.hpUniqueId,
      },
    };

    try {
      final result = await baseApi.postRaw(ApiConstants.extendServiceApi, body);
      if (!_isOk(result)) {
        _showApiError(_errorFrom(result, 'Service extension failed'));
        return;
      }
      HelperUi.showToast(message: 'Service extended successfully');
      getBookingsFromApiByBkId(bookingId);
      getBookingsFromApi();
    } finally {
      isExtendServiceLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Update HP Booking Status
  // ─────────────────────────────────────────────
  final RxBool isUpdateHPBookingLoading = false.obs;
  final RxBool isVerifyOtpLoading = false.obs;

  Future<void> updateHPBookingStatus({
    required int bookingId,
    required int hpUniqueId,
    required int status,
    String? interviewDate,
  }) async {
    isUpdateHPBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'hp_unique_id': hpUniqueId,
      'status': status,
      // Only pass interview_date when moving to Interview Stage (status 2)
      if (status == 2 && interviewDate != null) 'interview_date': interviewDate,
    };

    try {
      final response = await baseApi.putRaw(ApiConstants.updateHPBookingApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update caregiver status'));
        return;
      }
      HelperUi.showToast(message: 'Caregiver status updated successfully');
      getHealthProffApi(bookingId);
    } finally {
      isUpdateHPBookingLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Release HP (status → 5)
  // ─────────────────────────────────────────────
  Future<void> releaseHpFromBooking({
    required int bookingId,
    required int hpUniqueId,
  }) async {
    await updateHPBookingStatus(
      bookingId: bookingId,
      hpUniqueId: hpUniqueId,
      status: 5,
    );
    loadGlobalActiveHpIds();
  }

  // ─────────────────────────────────────────────
  // Verify OTP
  // ─────────────────────────────────────────────
  Future<void> verifyOtp({
    required int bookingId,
    required int hpUniqueId,
    required String otp,
  }) async {
    isVerifyOtpLoading.value = true;
    try {
      final result = await baseApi.postRaw(ApiConstants.verifyOtpApi, {
        'booking_id': bookingId,
        'hp_unique_id': hpUniqueId,
        'otp': otp,
      });
      if (!_isOk(result)) {
        _showApiError(_errorFrom(result, 'OTP verification failed'));
        return;
      }
      HelperUi.showToast(message: 'OTP verified successfully');
      // Close OTP dialog
      Get.back();
      // Refresh all booking data
      getBookingsFromApi();
      getBookingsFromApiByBkId(bookingId);
      getHealthProffApi(bookingId);
      // Navigate back to manage bookings screen
      Get.back();
    } finally {
      isVerifyOtpLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Update Booking (service dates / times)
  // ─────────────────────────────────────────────
  Future<void> updateBooking({
    required int bookingId,
    required int branchId,
    required DateTime serviceStartDate,
    required DateTime serviceEndDate,
    required TimeOfDay serviceStartTime,
    required TimeOfDay serviceEndTime,
    required int addressId,
  }) async {
    if (_dateOnly(serviceEndDate).isBefore(_dateOnly(serviceStartDate))) {
      _showApiError('End date cannot be before the start date');
      return;
    }
    isUpdateBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'branch_id': branchId,
      'service_start_date': DateFormat('yyyy-MM-dd').format(serviceStartDate),
      'service_end_date': DateFormat('yyyy-MM-dd').format(serviceEndDate),
      'service_start_time': _fmtTime24(serviceStartTime),
      'service_end_time': _fmtTime24(serviceEndTime),
      if (addressId > 0) 'address_id': addressId,
    };

    try {
      final response = await baseApi.putRaw(ApiConstants.updateBookingsEditApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update booking'));
        return;
      }
      HelperUi.showToast(message: 'Booking updated successfully');
      Get.back();
      startDate.value = serviceStartDate;
      endDate.value = serviceEndDate;
      this.serviceStartTime.value = serviceStartTime;
      this.serviceEndTime.value = serviceEndTime;
      getBookingsFromApiByBkId(bookingId);
      getBookingsFromApi();
    } finally {
      isUpdateBookingLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Update Patient
  // ─────────────────────────────────────────────
  Future<void> updatePatient({
    required int patientId,
    required String patientName,
    required String phoneNumber,
    required String email,
    required String age,
    required String yob,
    required String weight,
    required String gender,
    required List<String> languages,
    required String relation,
    required bool isStayAlone,
  }) async {
    isUpdatePatientLoading.value = true;

    final Map<String, String> genderMap = {'male': '1', 'female': '2', 'other': '3'};

    // updatePatient writes every column (blank → 'NA'), so always send the
    // full set including the real language ids and stays-alone flag.
    final Map<String, dynamic> body = {
      'patient_id': patientId.toString(),
      'patient_name': patientName,
      'phone_number': phoneNumber,
      'email': email,
      'age': age,
      'yob': yob,
      'weight': weight,
      'languages': languageIdsFor(languages),
      'relation': relation,
      'gender': genderMap[gender.toLowerCase()] ?? '1',
      // String so the backend's truthiness check keeps '0'.
      'is_stay_alone': isStayAlone ? '1' : '0',
    };

    try {
      final response = await baseApi.putRaw(ApiConstants.updatePatientApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update patient'));
        return;
      }
      HelperUi.showToast(message: 'Patient details updated successfully');
      Get.back();
      detailPatientNameController.text = patientName;
      detailPatientPhoneController.text = phoneNumber;
      detailPatientEmailController.text = email;
      ageController.text = age;
      yearOfBirthController.text = yob;
      weightController.text = weight;
      selectedGender.value = gender;
      selectedLanguages.value = List<String>.from(languages);
      selectedRelation.value = relation;
      patientStaysAlone.value = isStayAlone;
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingsByBookingId.value.first.id);
      }
    } finally {
      isUpdatePatientLoading.value = false;
    }
  }

  void initComputedFinalRate() {
    final base = double.tryParse(finalRateController.text) ?? 0.0;
    computedFinalRate.value = base;
    _syncDisplayControllers();
  }

  // FIX: applyCoupon now also updates stable display controllers AND the
  // persistence-bound fields (cuponId / finalDiscount) so the selected coupon
  // actually reaches the backend instead of being discarded on save.
  void applyCoupon(CouponModel? coupon) {
    selectedCoupon.value = coupon;

    final base = double.tryParse(finalRateController.text) ?? 0.0;

    if (coupon == null) {
      appliedDiscountPercentage.value = 0.0;
      appliedDiscountValue.value = 0.0;
      computedFinalRate.value = base;
      cuponId.value = '';
      finalDiscount.value = '0.00';
      _syncDisplayControllers();
      return;
    }

    final discountPercent = double.tryParse(coupon.discountPercentage) ?? 0.0;
    final upperLimit =
        double.tryParse(coupon.discountUpperLimitValue) ?? double.infinity;

    double discountValue = (base * discountPercent) / 100;

    if (upperLimit > 0 && discountValue > upperLimit) {
      discountValue = upperLimit;
    }

    appliedDiscountPercentage.value = discountPercent;
    appliedDiscountValue.value = discountValue;
    computedFinalRate.value = base - discountValue;
    // FIX: persist the coupon id and discount value so updateBookingsTotal
    // sends them to the API.
    cuponId.value = coupon.couponId > 0 ? coupon.couponId.toString() : '';
    finalDiscount.value = discountValue.toStringAsFixed(2);

    // FIX: sync display controllers so UI updates without inline controller creation
    _syncDisplayControllers();
  }

  // ─────────────────────────────────────────────
  // Effective final rate = base rate − applied discount (never below 0).
  // Computed fresh from the current base-rate field so it stays correct even
  // if the base rate was edited after a coupon was applied.
  // ─────────────────────────────────────────────
  double get effectiveFinalRate {
    final base = double.tryParse(finalRateController.text) ?? 0.0;
    final discounted = base - appliedDiscountValue.value;
    return discounted < 0 ? 0.0 : discounted;
  }

  // ─────────────────────────────────────────────
  // Update User (the booking's client)
  // ─────────────────────────────────────────────
  Future<void> updateUser({
    required int userId,
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    isUpdateUserLoading.value = true;

    final body = dio.FormData.fromMap({
      'user_id': userId.toString(),
      'user_name': name,
      'phone_number': phoneNumber,
      'user_email': email,
    });

    try {
      final response = await baseApi.putForm(ApiConstants.updateClientUserApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update user'));
        return;
      }
      HelperUi.showToast(message: 'User details updated successfully');
      Get.back();
      detailUserNameController.text = name;
      detailUserMobileController.text = phoneNumber;
      detailUserEmailController.text = email;
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingsByBookingId.value.first.id);
      }
    } finally {
      isUpdateUserLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Update Address
  // ─────────────────────────────────────────────
  Future<void> updateAddress({
    required int bookingId,
    required int clientUserId,
    required String addressTagName,
    required String country,
    required String state,
    required String city,
    required String addressLine1,
    required String addressLine2,
    required String landmark,
    required String locality,
    required String pincode,
  }) async {
    isUpdateAddressLoading.value = true;

    // The backend inserts a new address row owned by this user and points the
    // booking at it, so user_id must be the booking's client, not the admin.
    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'user_id': clientUserId,
      'address_tag_name': addressTagName,
      'country': country,
      'state': state,
      'city': city,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'landmark': landmark,
      'locality': locality,
      'pincode': pincode,
    };

    try {
      final response = await baseApi.putRaw(ApiConstants.updateAddressApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update address'));
        return;
      }
      HelperUi.showToast(message: 'Address updated successfully');
      Get.back();
      final data = response!.data;
      final newId = data is Map ? _toInt(data['address_id']) : null;
      if (newId != null) selectedAddressId.value = newId;
      detailAddressTagController.text = addressTagName;
      detailCountryController.text = country;
      detailStateController.text = state;
      detailCityController.text = city;
      detailAddressLine1Controller.text = addressLine1;
      detailAddressLine2Controller.text = addressLine2;
      detailLandmarkController.text = landmark;
      detailLocalityController.text = locality;
      detailPincodeController.text = pincode;
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingsByBookingId.value.first.id);
      }
    } finally {
      isUpdateAddressLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Combined update (rate, coupon, notes, lead, care manager)
  // ─────────────────────────────────────────────
  Future<void> updateBookingsTotal(int bookingId) async {
    if (!_validateEditForm()) return;
    if (isUpdateBookingLoading.value) return;
    isUpdateBookingLoading.value = true;

    final booking = bookingsByBookingId.value.firstWhereOrNull((b) => b.id == bookingId);
    // base_rate is the pre-discount daily rate (the edited rate field);
    // final_rate = base_rate − coupon discount. Both come from the same value
    // so they never disagree.
    final base = double.tryParse(finalRateController.text.trim()) ?? 0.0;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'branch_id': selectedBranchId.value,
      if (booking != null) 'user_id': booking.userId,
      if (booking != null) 'patient_id': booking.patientId,
      'service_start_date': DateFormat('yyyy-MM-dd').format(startDate.value!),
      'service_end_date': DateFormat('yyyy-MM-dd').format(endDate.value!),
      if (serviceStartTime.value != null)
        'service_start_time': _fmtTime24(serviceStartTime.value!),
      if (serviceEndTime.value != null)
        'service_end_time': _fmtTime24(serviceEndTime.value!),
      'hold_start_date': holdStartDate.value != null
          ? DateFormat('yyyy-MM-dd').format(holdStartDate.value!)
          : null,
      'hold_end_date': holdEndDate.value != null
          ? DateFormat('yyyy-MM-dd').format(holdEndDate.value!)
          : null,
      'base_rate': base.toStringAsFixed(2),
      'final_rate': effectiveFinalRate.toStringAsFixed(2),
      'coupon_discount_applied_value': appliedDiscountValue.value.toStringAsFixed(2),
      'coupon_discount_id': cuponId.value.isNotEmpty ? cuponId.value : null,
      'patient_conditions_others': medicalConditionController.text,
      'spl_care_requirements': specialRequirementsController.text,
      if (selectedAddressId.value > 0) 'address_id': selectedAddressId.value,
      "lead_potential": selectedLeadType.value.isEmpty ? null : selectedLeadType.value,
      "followup_date": selectedFollowupDate.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedFollowupDate.value!)
          : null,
      "hp_manager": selectedCareManagerIdForBooking.value == 0 ? null : selectedCareManagerIdForBooking.value,
    };

    try {
      final response = await baseApi.putRaw(ApiConstants.updateBookingsEditApi, body);
      if (!_isOk(response)) {
        _showApiError(_errorFrom(response, 'Failed to update booking'));
        return;
      }
      // Do NOT pop the navigation stack here. Callers (dialogs) close
      // themselves before calling this, and the inline "Update" buttons must
      // keep the user on the current screen. Just refresh the data.
      baseRate.value = base.toStringAsFixed(2);
      getBookingsFromApi();
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingId);
      }
      HelperUi.showToast(message: 'Booking updated successfully');
    } finally {
      isUpdateBookingLoading.value = false;
    }
  }

  bool _validateEditForm() {
    if (startDate.value == null) {
      Get.snackbar('Validation Error', 'Start date is required');
      return false;
    }
    if (endDate.value == null) {
      Get.snackbar('Validation Error', 'End date is required');
      return false;
    }
    if (_dateOnly(endDate.value!).isBefore(_dateOnly(startDate.value!))) {
      Get.snackbar('Validation Error', 'End date cannot be before the start date');
      return false;
    }
    if (finalRateController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Rate is required');
      return false;
    }
    final rate = double.tryParse(finalRateController.text) ?? 0;
    if (rate <= 0) {
      Get.snackbar('Validation Error', 'Rate must be a positive number');
      return false;
    }
    if (effectiveFinalRate <= 0) {
      Get.snackbar('Validation Error', 'The discount leaves a final rate of 0');
      return false;
    }
    return true;
  }
}
