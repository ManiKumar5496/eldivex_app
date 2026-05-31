import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:eldivex_app/app/widgets/helper_ui.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../settings/models/get_discount_models.dart';
import '../../users/controllers/users_controller.dart';
import '../../users/models/get_users_model.dart';
import '../models/get_booking_hp_model.dart';
import '../views/manage_bookings.dart';

class BookingsController extends GetxController {
  // ─────────────────────────────────────────────
  // Filter Visibility
  // ─────────────────────────────────────────────
  RxBool isFilterVisible = false.obs;

  // ─────────────────────────────────────────────
  // Filter Text Controllers
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
  final TextEditingController yearOfBirthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userIdControllerCreateBooking = TextEditingController();
  final TextEditingController medicalConditionController = TextEditingController();
  final TextEditingController specialRequirementsController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();

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
  RxString selectedService = ''.obs;
  RxString selectedBranch = ''.obs;
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
  UsersController userController = Get.put(UsersController());

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
        final ids = result
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

  void _resetCouponState() {
    selectedCoupon.value = null;
    appliedDiscountPercentage.value = 0.0;
    appliedDiscountValue.value = 0.0;
  }

  // ─────────────────────────────────────────────
  // Release HP (status → 5)
  // ─────────────────────────────────────────────
  void releaseHpFromBooking({
    required int bookingId,
    required int hpUniqueId,
  }) {
    updateHPBookingStatus(
      bookingId: bookingId,
      hpUniqueId: hpUniqueId,
      status: 5,
    );
    // Remove from global active set immediately (optimistic update)
    // The real HP reg ID will be refreshed by getHealthProffApi inside updateHPBookingStatus
    loadGlobalActiveHpIds();
  }

  Future<void> assignCgToBooking({
    required int bookingId,
    required int cgId,
  }) async {
    if (isAssignCgLoading.value) return; // prevent rapid double-tap
    try {
      isAssignCgLoading.value = true;

      final Map<String, dynamic> body = {
        'booking_id': bookingId,
        'hp_id': cgId,
      };

      baseApi
          .postRaw(ApiConstants.assignCgApi, body)
          .then((result) {
        final data = result?.data as Map<String, dynamic>?;
        if (data == null) {
          Get.snackbar(
            'Error',
            'Invalid response from server',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return;
        }

        HelperUi.showToast(message: 'Health Professional assigned successfully');

        selectedCgIdForAssignment.value = 0;
        Get.back();
        getBookingsFromApiByBkId(bookingId);
        getHealthProffApi(bookingId);
        selectedHPTab.value = 0;
      })
          .catchError((e) {
        selectedCgIdForAssignment.value = 0; // reset on failure
        Get.snackbar(
          'Error',
          'Failed to assign Health Professional: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      })
          .whenComplete(() => isAssignCgLoading.value = false);
    } catch (e) {
      isAssignCgLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

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

  // ─────────────────────────────────────────────
  // Static Dropdown Lists
  // ─────────────────────────────────────────────
  final List<String> services = [
    'Premium Care Package',
    'Physical Therapy',
    'Home Nursing',
    'Rehabilitation',
    'Elder Care',
  ];

  final List<String> branches = [
    'San Francisco',
    'Los Angeles',
    'New York',
    'Chicago',
    'Boston',
  ];

  final List<String> bookingStatuses = [
    'Confirmed',
    'Pending',
    'Completed',
    'Cancelled',
    'In Progress',
  ];

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
  Rx<List<GetBookingHpModel>> allBookingHpData = Rx<List<GetBookingHpModel>>([]);
  Rx<List<GetBookingsModel>> bookingsByBookingId = Rx<List<GetBookingsModel>>([]);

  final int userId = box.read("userId") ?? 0;

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
  final DashboardController dashboardController = Get.put(DashboardController());
  final SettingsController settingsController = Get.put(SettingsController());

  // Languages from API
  final RxList<Map<String, dynamic>> languagesList = <Map<String, dynamic>>[].obs;
  final RxBool isLanguagesLoading = false.obs;

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final hasUserId = args is Map<String, dynamic> && args['userId'] != null;
    if (!hasUserId) {
      getBookingsFromApi();
    }
    if (dashboardController.getAllBranches.isEmpty) {
      dashboardController.getAllBranchesApi();
    }
    fetchLanguages();
    // Auto-calculate age when year of birth changes
    yearOfBirthController.addListener(_calculateAgeFromYob);
  }

  void _calculateAgeFromYob() {
    final yobText = yearOfBirthController.text.trim();
    if (yobText.length == 4) {
      final yob = int.tryParse(yobText);
      if (yob != null && yob > 1900 && yob <= DateTime.now().year) {
        final age = DateTime.now().year - yob;
        ageController.text = age.toString();
      }
    }
  }

  Future<void> fetchLanguages() async {
    try {
      isLanguagesLoading.value = true;
      final response = await baseApi.getRaw(ApiConstants.getAllLanguages);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          languagesList.value = data
              .map((e) => {'id': e['id'], 'name': e['name']})
              .toList()
              .cast<Map<String, dynamic>>();
        }
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
    userIdControllerCreateBooking.dispose();
    medicalConditionController.dispose();
    specialRequirementsController.dispose();
    patientNameController.dispose();
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
    selectedService.value = '';
    selectedBranch.value = '';
    selectedBookingStatus.value = '';
  }

  void searchBookings() {
    debugPrint('Filtering: userId=${userIdController.text} name=${nameController.text}');
    getBookingsFromApi();
  }

  // ─────────────────────────────────────────────
  // API – Get Bookings
  // ─────────────────────────────────────────────
  void getBookingsFromApi() {
    getAllBookingsLoading.value = true;
    baseApi
        .getList<GetBookingsModel>(
      ApiConstants.getBookingsApi,
          (json) => GetBookingsModel.fromJson(json),
    )
        .then((result) => allBookings.value = result ?? [])
        .catchError((e) {
          debugPrint('Error fetching bookings: $e');
          return <GetBookingsModel>[];
        })
        .whenComplete(() => getAllBookingsLoading.value = false);
  }

  void getBookingsFromUserCreation({int? clientUserId}) {
    getAllBookingsLoading.value = true;
    baseApi
        .getList<GetBookingsModel>(
      '${ApiConstants.getBookingsApi}?user_id=$clientUserId',
          (json) => GetBookingsModel.fromJson(json),
    )
        .then((result) => allBookings.value = result ?? [])
        .catchError((e) {
          debugPrint('Error fetching bookings: $e');
          return <GetBookingsModel>[];
        })
        .whenComplete(() => getAllBookingsLoading.value = false);
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

  void getHealthProffApi(int bookingId) {
    getAllHPLoading.value = true;
    baseApi
        .getList<GetBookingHpModel>(
      "${ApiConstants.getBookingsHpApi}?bkng_id=$bookingId",
          (json) => GetBookingHpModel.fromJson(json),
    )
        .then((result) => allBookingHpData.value = result ?? [])
        .catchError((e) {
          debugPrint('Error fetching bookings Hp: $e');
          return <GetBookingHpModel>[];
        })
        .whenComplete(() => getAllHPLoading.value = false);
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

    // ── Booking / service details ─────────────
    oldClientIdController.text = booking.branchId.toString();
    serviceCityController.text = booking.branchCity ?? '';
    careManagerController.text = booking.hpManager?.toString() ?? '';
    finalRateController.text = booking.baseRate;
    baseRate.value = booking.baseRate;

    // ── Dates ─────────────────────────────────
    startDate.value = booking.serviceStartDate;
    endDate.value = booking.serviceEndDate;
    holdStartDate.value = booking.holdStartDate;
    holdEndDate.value = booking.holdEndDate;

    // ── Times ─────────────────────────────────
    serviceStartTime.value = _parseTimeString(booking.serviceStartTime);
    serviceEndTime.value = _parseTimeString(booking.serviceEndTime);

    if (serviceStartTime.value != null) {
      startTimeController.text = _formatTimeOfDay(serviceStartTime.value!);
    }
    if (serviceEndTime.value != null) {
      endTimeController.text = _formatTimeOfDay(serviceEndTime.value!);
    }

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

    debugPrint('Form populated for booking id: ${booking.id}');
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
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
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
  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) startDate.value = picked;
  }

  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) endDate.value = picked;
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
    phoneController.clear();
    emailController.clear();
    ageController.clear();
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
  void createBooking() {
    if (!_validateCreateForm()) return;
    isCreateBookingLoading.value = true;

    final genderMap = {'Male': 1, 'Female': 2, 'Other': 3};

    final Map<String, dynamic> body = {
      'branch_id': selectedBranchId.value,
      'user_id': int.tryParse(userIdControllerCreateBooking.text.trim()) ?? 0,
      'service_start_date': startDate.value != null
          ? DateFormat('yyyy-MM-dd').format(startDate.value!)
          : null,
      'service_end_date': endDate.value != null
          ? DateFormat('yyyy-MM-dd').format(endDate.value!)
          : null,
      'service_start_time': serviceStartTime.value != null
          ? '${serviceStartTime.value!.hour.toString().padLeft(2, '0')}:'
          '${serviceStartTime.value!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'service_end_time': serviceEndTime.value != null
          ? '${serviceEndTime.value!.hour.toString().padLeft(2, '0')}:'
          '${serviceEndTime.value!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'patient_name': patientNameController.text.trim(),
      if (phoneController.text.trim().isNotEmpty)
        'phone_number': phoneController.text.trim(),
      if (emailController.text.trim().isNotEmpty)
        'email': emailController.text.trim(),
      if (ageController.text.trim().isNotEmpty)
        'age': int.tryParse(ageController.text.trim()),
      if (yearOfBirthController.text.trim().isNotEmpty)
        'yob': int.tryParse(yearOfBirthController.text.trim()),
      if (weightController.text.trim().isNotEmpty)
        'weight': double.tryParse(weightController.text.trim()),
      if (selectedLanguages.isNotEmpty)
        'languages': selectedLanguages.join(','),
      'relation': selectedRelation.value,
      'gender': genderMap[selectedGender.value] ?? 1,
      'is_stay_alone': patientStaysAlone.value == true ? 1 : 0,
      'address_id': selectedAddressId.value > 0 ? selectedAddressId.value : null,
      'service_type_id': selectedServiceId.value,
      'base_rate': double.tryParse(baseRate.value) ?? 0,
      if (baseDiscount.value.isNotEmpty && baseDiscount.value != '0')
        'base_discount_percentage': double.tryParse(baseDiscount.value),
    };

    baseApi
        .postRaw(ApiConstants.createBookingApi, body)
        .then((result) {
      final data = result?.data as Map<String, dynamic>?;
      if (data == null || data['booking_id'] == null) {
        Get.snackbar('Error', 'Invalid booking ID returned from API');
        return;
      }
      final int bookingId = data['booking_id'];
      HelperUi.showToast(message: 'Booking created successfully');
      getBookingsFromApi();
      Get.to(() => ManageBookingView(bookingId: bookingId));
    })
        .catchError((e) {
      Get.snackbar(
        'Error',
        'Failed to create booking: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    })
        .whenComplete(() => isCreateBookingLoading.value = false);
  }

  bool _validateCreateForm() {
    if (patientNameController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Patient name is required');
      return false;
    }
    if (userIdControllerCreateBooking.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'User ID is required');
      return false;
    }
    if (yearOfBirthController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Year of birth is required');
      return false;
    }
    if (weightController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Weight is required');
      return false;
    }
    if (patientStaysAlone.value == null) {
      Get.snackbar('Validation Error', 'Please select if patient stays alone');
      return false;
    }
    if (medicalConditionController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Medical condition is required');
      return false;
    }
    if (startDate.value == null) {
      Get.snackbar('Validation Error', 'Start date is required');
      return false;
    }
    if (endDate.value == null) {
      Get.snackbar('Validation Error', 'End date is required');
      return false;
    }
    if (selectedBranchId.value == 0) {
      Get.snackbar('Validation Error', 'Please select a branch');
      return false;
    }
    if (selectedCategoryId.value == 0) {
      Get.snackbar('Validation Error', 'Please select a service category');
      return false;
    }
    if (selectedServiceId.value == 0) {
      Get.snackbar('Validation Error', 'Please select a service');
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────
  // Cancel Booking
  // ─────────────────────────────────────────────
  final RxBool isCancelBookingLoading = false.obs;

  void cancelBooking(int bookingId, DateTime endDate, String reason) {
    isCancelBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'term_date': DateFormat('yyyy-MM-dd').format(endDate),
      'term_reason': reason,
      'booking_status': 5,
      'term_remarks': 'remarks not done',
    };

    baseApi
        .postRaw(ApiConstants.cancelBookingApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Booking cancelled successfully');
      Get.back();
      getBookingsFromApi();
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to cancel booking: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isCancelBookingLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Hold Booking
  // ─────────────────────────────────────────────
  final RxBool isHoldBookingLoading = false.obs;

  void holdBooking(
      int bookingId,
      DateTime holdStart,
      DateTime holdEnd,
      String reason,
      ) {
    isHoldBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'hold_start_date': DateFormat('yyyy-MM-dd').format(holdStart),
      'hold_end_date': DateFormat('yyyy-MM-dd').format(holdEnd),
      'hold_reason': reason,
    };

    baseApi
        .postRaw(ApiConstants.holdBookingApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Service hold successful');
      getBookingsFromApiByBkId(bookingId);
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to hold booking: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isHoldBookingLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Extend Service
  // ─────────────────────────────────────────────
  final RxBool isExtendServiceLoading = false.obs;

  void extendService(
    int bookingId,
    DateTime newStartDate,
    DateTime newEndDate,
    String notes,
  ) {
    isExtendServiceLoading.value = true;

    String fmtTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'extension_notes': notes,
      'from_date': DateFormat('yyyy-MM-dd').format(newStartDate),
      'to_date': DateFormat('yyyy-MM-dd').format(newEndDate),
      'from_time': serviceStartTime.value != null
          ? fmtTime(serviceStartTime.value!)
          : '00:00:00',
      'to_time': serviceEndTime.value != null
          ? fmtTime(serviceEndTime.value!)
          : '00:00:00',
      'inv_raised_amnt': finalRateController.text.isNotEmpty
          ? finalRateController.text
          : '0',
      'inv_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'hp_id': activeHPs.isNotEmpty
          ? activeHPs.first.hpUniqueId.toString()
          : '',
    };

    baseApi
        .postRaw(ApiConstants.extendServiceApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Service extended successfully');
      getBookingsFromApiByBkId(bookingId);
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Service extension failed: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isExtendServiceLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Update HP Booking Status
  // ─────────────────────────────────────────────
  final RxBool isUpdateHPBookingLoading = false.obs;
  final RxBool isVerifyOtpLoading = false.obs;

  void updateHPBookingStatus({
    required int bookingId,
    required int hpUniqueId,
    required int status,
    String? interviewDate,
  }) {
    isUpdateHPBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'hp_unique_id': hpUniqueId,
      'status': status,
    };

    // Only pass interview_date when moving to Interview Stage (status 2)
    if (status == 2 && interviewDate != null) {
      body['interview_date'] = interviewDate;
    }

    debugPrint('updateHPBookingStatus body: $body');

    baseApi
        .putRaw(ApiConstants.updateHPBookingApi, body)
        .then((response) {
      if (response != null) {
        HelperUi.showToast(message: 'Caregiver status updated successfully');
        getHealthProffApi(bookingId);
      } else {
        HelperUi.showToast(
          message: 'Failed to update status',
          backgroundColor: Colors.red,
        );
      }
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to update status: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isUpdateHPBookingLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Verify OTP
  // ─────────────────────────────────────────────
  void verifyOtp({
    required int bookingId,
    required int hpUniqueId,
    required String otp,
  }) {
    isVerifyOtpLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId.toString(),
      'hp_unique_id': hpUniqueId,
      'otp': otp,
    };

    baseApi
        .postRaw(ApiConstants.verifyOtpApi, body)
        .then((result) {
      if (result != null && result.statusCode == 200) {
        HelperUi.showToast(message: 'OTP verified successfully');
        // Close OTP dialog
        Get.back();
        // Refresh all booking data
        getBookingsFromApi();
        getBookingsFromApiByBkId(bookingId);
        getHealthProffApi(bookingId);
        // Navigate back to manage bookings screen
        Get.back();
      } else {
        final data = result?.data as Map<String, dynamic>?;
        HelperUi.showToast(
          message: data?['message'] ?? 'OTP verification failed',
          backgroundColor: Colors.red,
        );
      }
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'OTP verification failed: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isVerifyOtpLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Update Booking (full edit)
  // ─────────────────────────────────────────────
  void updateBooking({
    required int bookingId,
    required int branchId,
    required DateTime serviceStartDate,
    required DateTime serviceEndDate,
    required TimeOfDay serviceStartTime,
    required TimeOfDay serviceEndTime,
    required int addressId,
  }) {
    isUpdateBookingLoading.value = true;

    String fmtTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

    final Map<String, dynamic> body = {
      'branch_id': branchId.toString(),
      'service_start_date': DateFormat('yyyy-MM-dd').format(serviceStartDate),
      'service_end_date': DateFormat('yyyy-MM-dd').format(serviceEndDate),
      'service_start_time': fmtTime(serviceStartTime),
      'service_end_time': fmtTime(serviceEndTime),
      'address_id': addressId.toString(),
      'booking_id': bookingId.toString(),
      'final_discount_applied_value': finalDiscount.value.toString(),
      'final_rate': finalRateController.text,
      'coupon_discount_id': cuponId.value.isNotEmpty ? cuponId.value : null,
    };

    baseApi
        .putRaw(ApiConstants.updateBookingsEditApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Booking updated successfully');
      startDate.value = serviceStartDate;
      endDate.value = serviceEndDate;
      this.serviceStartTime.value = serviceStartTime;
      this.serviceEndTime.value = serviceEndTime;
      selectedBranchId.value = branchId;
      selectedAddressId.value = addressId;
      getBookingsFromApiByBkId(bookingId);
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to update booking: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isUpdateBookingLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Update Patient
  // ─────────────────────────────────────────────
  void updatePatient({
    required int patientId,
    required String patientName,
    required String phoneNumber,
    required String email,
    required String age,
    required String yob,
    required String weight,
    required String gender,
    required String language,
    required String relation,
    required String isStayAlone,
  }) {
    isUpdatePatientLoading.value = true;

    final Map<String, String> genderMap = {'male': '1', 'female': '2', 'other': '3'};
    final Map<String, String> langMap = {
      'english': '1',
      'telugu': '2',
      'hindi': '3',
      'tamil': '4',
    };

    final Map<String, dynamic> body = {
      'patient_name': patientName,
      'phone_number': phoneNumber,
      'email': email,
      'age': age,
      'yob': yob,
      'weight': weight,
      'languages': langMap[language.toLowerCase()] ?? '1',
      'relation': relation,
      'gender': genderMap[gender.toLowerCase()] ?? '1',
      'is_stay_alone': isStayAlone,
      'patient_id': patientId.toString(),
    };

    baseApi
        .putRaw(ApiConstants.updatePatientApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Patient details updated successfully');
      detailPatientNameController.text = patientName;
      detailPatientPhoneController.text = phoneNumber;
      detailPatientEmailController.text = email;
      ageController.text = age;
      yearOfBirthController.text = yob;
      weightController.text = weight;
      selectedGender.value = gender;
      selectedLanguages.value = language.isNotEmpty ? language.split(',') : [];
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingsByBookingId.value.first.id);
      }
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to update patient: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isUpdatePatientLoading.value = false);
  }

  void initComputedFinalRate() {
    final base = double.tryParse(finalRateController.text) ?? 0.0;
    computedFinalRate.value = base;
    _syncDisplayControllers();
  }

  // FIX: applyCoupon now also updates stable display controllers
  void applyCoupon(CouponModel? coupon) {
    selectedCoupon.value = coupon;

    final base = double.tryParse(finalRateController.text) ?? 0.0;

    if (coupon == null) {
      appliedDiscountPercentage.value = 0.0;
      appliedDiscountValue.value = 0.0;
      computedFinalRate.value = base;
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

    // FIX: sync display controllers so UI updates without inline controller creation
    _syncDisplayControllers();
  }

  // ─────────────────────────────────────────────
  // Update User
  // ─────────────────────────────────────────────
  void updateUser({
    required int userId,
    required String name,
    required String phoneNumber,
    required String email,
  }) {
    isUpdateUserLoading.value = true;

    final body = dio.FormData.fromMap({
      'user_id': userId.toString(),
      'user_name': name,
      'phone_number': phoneNumber,
      'user_email': email,
    });

    baseApi
        .putForm(ApiConstants.updateClientUserApi, body)
        .then((_) {
      HelperUi.showToast(message: 'User details updated successfully');
      detailUserNameController.text = name;
      detailUserMobileController.text = phoneNumber;
      detailUserEmailController.text = email;
      if (bookingsByBookingId.value.isNotEmpty) {
        getBookingsFromApiByBkId(bookingsByBookingId.value.first.id);
      }
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to update user: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isUpdateUserLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Update Address
  // ─────────────────────────────────────────────
  void updateAddress({
    required int bookingId,
    required String addressTagName,
    required String country,
    required String state,
    required String city,
    required String addressLine1,
    required String addressLine2,
    required String landmark,
    required String locality,
    required String pincode,
  }) {
    isUpdateAddressLoading.value = true;

    final Map<String, dynamic> body = {
      'booking_id': bookingId,
      'address_tag_name': addressTagName,
      'country': country,
      'state': state,
      'city': city,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'landmark': landmark,
      'locality': locality,
      'pincode': pincode,
      'user_id': userId.toString(),
    };

    baseApi
        .putRaw(ApiConstants.updateAddressApi, body)
        .then((_) {
      HelperUi.showToast(message: 'Address updated successfully');
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
    })
        .catchError((e) {
      HelperUi.showToast(
        message: 'Failed to update address: $e',
        backgroundColor: Colors.red,
      );
    })
        .whenComplete(() => isUpdateAddressLoading.value = false);
  }

  // ─────────────────────────────────────────────
  // Legacy combined update
  // ─────────────────────────────────────────────
  void updateBookingsTotal(int bookingId) {
    if (!_validateEditForm()) return;
    isCreateBookingLoading.value = true;

    final Map<String, dynamic> body = {
      'id': bookingId,
      'branch_id': selectedBranchId.value.toString(),
      'user_id': detailUserIdController.text.replaceAll('USR-', ''),
      'patient_id': detailPatientIdController.text.replaceAll('PAT-', ''),
      'service_start_date': startDate.value != null
          ? DateFormat('yyyy-MM-dd').format(startDate.value!)
          : null,
      'service_end_date': endDate.value != null
          ? DateFormat('yyyy-MM-dd').format(endDate.value!)
          : null,
      'service_start_time': serviceStartTime.value != null
          ? '${serviceStartTime.value!.hour.toString().padLeft(2, '0')}:'
          '${serviceStartTime.value!.minute.toString().padLeft(2, '0')}:00'
          : startTimeController.text,
      'service_end_time': serviceEndTime.value != null
          ? '${serviceEndTime.value!.hour.toString().padLeft(2, '0')}:'
          '${serviceEndTime.value!.minute.toString().padLeft(2, '0')}:00'
          : endTimeController.text,
      'hold_start_date': holdStartDate.value != null
          ? DateFormat('yyyy-MM-dd').format(holdStartDate.value!)
          : null,
      'hold_end_date': holdEndDate.value != null
          ? DateFormat('yyyy-MM-dd').format(holdEndDate.value!)
          : null,
      'base_rate': baseRate.value.toString(),
      'final_rate': finalRateController.text,
      'patient_conditions_others': medicalConditionController.text,
      'spl_care_requirements': specialRequirementsController.text,
      'address_id': selectedAddressId.value.toString(),
      "lead_potential": selectedLeadType.value.isEmpty ? null : selectedLeadType.value,
      "followup_date": selectedFollowupDate.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedFollowupDate.value!)
          : null,
      "hp_manager": selectedCareManagerIdForBooking.value,
    };

    baseApi
        .putRaw(ApiConstants.updateBookingsEditApi, body)
        .then((response) {
      if (response != null) {
        Get.back();
        Get.back();
        getBookingsFromApi();
        HelperUi.showToast(message: 'Booking updated successfully');
      } else {
        HelperUi.showToast(message: 'Failed to update booking');
      }
    })
        .catchError((e) {
      HelperUi.showToast(message: 'Failed to update booking: $e');
    })
        .whenComplete(() => isCreateBookingLoading.value = false);
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
    if (endDate.value!.isBefore(startDate.value!)) {
      Get.snackbar('Validation Error', 'End date must be after start date');
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
    return true;
  }
}