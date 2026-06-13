import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

import 'package:intl/intl.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_cg_details_model.dart';
import '../../bookings/models/get_booking_hp_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class RegisterCgController extends GetxController {
  final ApiService apiService = ApiService();
  final dashboardController = Get.put(DashboardController());
  final int userId = box.read("userId");

  /// UI STATE
  RxBool isFilterVisible = false.obs;
  RxBool isCreateLoading = false.obs;
  RxBool getAllCGLoading = false.obs;
  RxBool manageCgStatusLoading = false.obs;

  /// TEXT CONTROLLERS
  final TextEditingController hpFirstNameController = TextEditingController();
  final TextEditingController hpLastNameController = TextEditingController();
  final TextEditingController hpEmailController = TextEditingController();
  final TextEditingController hpPhoneController = TextEditingController();
  final TextEditingController hpAddressController = TextEditingController();
  final TextEditingController hpPinCodeController = TextEditingController();

  final TextEditingController hpDobController = TextEditingController();
  final TextEditingController hpEmergencyPhoneController =
      TextEditingController();
  final TextEditingController hpFatherNameController = TextEditingController();
  final TextEditingController hpFatherOccupationController =
      TextEditingController();
  final TextEditingController hpMotherNameController = TextEditingController();
  final TextEditingController hpIdentityProofNumberController =
      TextEditingController();

  final TextEditingController hpExperienceController = TextEditingController();

  final TextEditingController liveInPayController = TextEditingController();
  final TextEditingController liveOutPayController = TextEditingController();
  final TextEditingController monthlyLiveInPayController =
      TextEditingController();
  final TextEditingController monthlyLiveOutPayController =
      TextEditingController();

  /// DROPDOWN / RX VALUES
  RxString hpGender = ''.obs;
  RxString hpCity = ''.obs;
  RxString hpState = ''.obs;
  RxString hpBranchId = ''.obs;
  RxString hpMaritalStatus = ''.obs;
  final RxList<int> hpSelectedLanguageIds = <int>[].obs;
  final RxList<Map<String, dynamic>> availableLanguages =
      <Map<String, dynamic>>[].obs;
  RxString hpEducation = ''.obs;
  RxString hpIdentityProofType = ''.obs;
  RxBool isDetailsConfirmed = false.obs;
  RxBool isTermsAccepted = false.obs;
  RxBool isPrivacyAccepted = false.obs;
  RxBool isMarkCgAttendanceLoading = false.obs;
  // hpRegIds whose attendance request is currently in flight (per-row spinner).
  final RxSet<int> markingHpIds = <int>{}.obs;
  // True while a "Submit All" batch request is running.
  RxBool isSubmittingAttendanceBatch = false.obs;
  RxBool isAttendanceListLoading = false.obs;
  RxList<dynamic> attendanceList = <dynamic>[].obs;
  final RxMap<int, Map<String, dynamic>> attendanceDraft = <int, Map<String, dynamic>>{}.obs;

  // hpRegId → bkngId for active (status=4) HP assignments
  final RxMap<int, int> activeHpBookingIdMap = <int, int>{}.obs;
  // hpRegId → {in_time, out_time} from the booking assignment
  final RxMap<int, Map<String, String?>> activeHpShiftMap = <int, Map<String, String?>>{}.obs;
  Rx<DateTime> markAttendanceSelectedDate = DateTime.now().obs;
  final RxInt currentPage = 0.obs;
  final RxInt rowsPerPage = 20.obs;
  final RxString selectedTab = 'null'.obs;  // 'null' = All

  // ── Search / Filter State ────────────────────────────────────────────────
  final RxString searchQueryManageCg = ''.obs;
  final RxString attendanceStatusFilter = 'all'.obs;
  final RxString attendanceFilterType = 'date'.obs;
  final Rx<DateTime> attendanceFilterDate = DateTime.now().obs;
  final Rx<DateTime> attendanceFilterMonth = DateTime.now().obs;
  final RxString markAttendanceSearch = ''.obs;

  /// FILE UPLOAD
  final RxList<PlatformFile> hpUploadedDocuments = <PlatformFile>[].obs;
  final RxList<PlatformFile> hpIdProofFrontDocs = <PlatformFile>[].obs;
  final RxList<PlatformFile> hpIdProofBackDocs = <PlatformFile>[].obs;
  final RxList<PlatformFile> hpEducationCertDocs = <PlatformFile>[].obs;

  void onDocumentsSelected(List<PlatformFile> files) {
    hpUploadedDocuments.addAll(files);
  }
  void onIdProofFrontSelected(List<PlatformFile> files) {
    hpIdProofFrontDocs.addAll(files);
  }
  void onIdProofFrontRemoved(PlatformFile file) {
    hpIdProofFrontDocs.remove(file);
  }
  void onIdProofBackSelected(List<PlatformFile> files) {
    hpIdProofBackDocs.addAll(files);
  }
  void onIdProofBackRemoved(PlatformFile file) {
    hpIdProofBackDocs.remove(file);
  }
  void onEducationCertSelected(List<PlatformFile> files) {
    hpEducationCertDocs.addAll(files);
  }
  void onEducationCertRemoved(PlatformFile file) {
    hpEducationCertDocs.remove(file);
  }
  void fetchCgByTab(int? status) {
    // Call your API with status filter, or just filter locally
    // e.g. if filtering locally, no API call needed — _filteredList() handles it
  }
  void onDocumentRemoved(PlatformFile file) {
    hpUploadedDocuments.remove(file);
  }

  /// API DATA
  Rx<List<GetCgDetails>> getAllCgData = Rx<List<GetCgDetails>>([]);
  Rx<dio.Response?> createCgResponse = Rx<dio.Response?>(null);

  // ── Phase 4.4: Assign-dialog filter + AI suggested HPs ─────────────────────
  final RxnInt  filterAssignBranchId = RxnInt();
  final RxString filterAssignLanguage = ''.obs;
  final RxBool  matchedHPsLoading = false.obs;
  final RxList<Map<String, dynamic>> matchedHPs = <Map<String, dynamic>>[].obs;
  final RxInt   assignDialogTab = 0.obs; // 0 = All HPs, 1 = AI Suggested

  Future<void> fetchMatchedHPs(int bookingId) async {
    matchedHPsLoading.value = true;
    matchedHPs.clear();
    try {
      final response = await apiService.getRaw(ApiConstants.matchHP(bookingId));
      if (response?.statusCode == 200) {
        final data = response!.data as Map<String, dynamic>;
        final list = (data['matches'] as List? ?? []);
        matchedHPs.value = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('[matchHP] fetchMatchedHPs error: $e');
    } finally {
      matchedHPsLoading.value = false;
    }
  }

  /// Only HPs with an active booking assignment (status=4 in edx_booking_hp)
  List<GetCgDetails> get activeCgList => getAllCgData.value
      .where((cg) => activeHpBookingIdMap.containsKey(cg.hpRegId))
      .toList();

  /// LIFECYCLE
  @override
  void onInit() {
    super.onInit();
    getAllCgFromApi();
    fetchLanguages();
  }

  @override
  void onClose() {
    hpFirstNameController.dispose();
    hpLastNameController.dispose();
    hpEmailController.dispose();
    hpPhoneController.dispose();
    hpAddressController.dispose();
    hpPinCodeController.dispose();
    hpDobController.dispose();
    hpEmergencyPhoneController.dispose();
    hpFatherNameController.dispose();
    hpFatherOccupationController.dispose();
    hpMotherNameController.dispose();
    hpIdentityProofNumberController.dispose();
    hpExperienceController.dispose();
    liveInPayController.dispose();
    liveOutPayController.dispose();
    monthlyLiveInPayController.dispose();
    monthlyLiveOutPayController.dispose();
    super.onClose();
  }

  /// FETCH LANGUAGES FROM API
  void fetchLanguages() {
    apiService.getRaw(ApiConstants.getMasterLanguages).then((response) {
      if (response != null && response.data is List) {
        availableLanguages.value = List<Map<String, dynamic>>.from(response.data);
      }
    }).catchError((e) {
      debugPrint("Fetch languages error: $e");
    });
  }

  /// PICK DATE OF BIRTH
  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      hpDobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// TOGGLE FILTER
  void toggleFilters() {
    isFilterVisible.toggle();
  }

  /// GET ALL HP
  void getAllCgFromApi() {
    getAllCGLoading.value = true;

    apiService
        .getList<GetCgDetails>(
          ApiConstants.getHp,
          (json) => GetCgDetails.fromJson(json),
        )
        .then((result) async {
          getAllCgData.value = result ?? [];
          await fetchActiveHpBookings();
        })
        .catchError((e) {
          debugPrint("Get HP error: $e");
          _initAttendanceDrafts();
        })
        .whenComplete(() => getAllCGLoading.value = false);
  }

  Future<void> fetchActiveHpBookings() async {
    try {
      final result = await apiService.getList<GetBookingHpModel>(
        '${ApiConstants.getBookingsHpApi}?status=4',
        (json) => GetBookingHpModel.fromJson(json),
      );
      if (result != null) {
        for (final hp in result) {
          final regId = hp.hpRegId;
          if (regId == null || regId == 0) continue;
          // Only map HPs with a real booking id. Attendance is FK-bound to a
          // booking, so HPs without one must not surface in the mark list.
          if (hp.bkngId <= 0) continue;
          activeHpBookingIdMap[regId] = hp.bkngId;
          activeHpShiftMap[regId] = {
            'in_time': _trimToHHMM(hp.inTime),
            'out_time': _trimToHHMM(hp.outTime),
          };
        }
      }
    } catch (e) {
      debugPrint('fetchActiveHpBookings error: $e');
    }
    _initAttendanceDrafts();
  }

  /// Trims "HH:MM:SS" → "HH:MM" so _parseTime in the view can parse it.
  String? _trimToHHMM(String? t) {
    if (t == null || t.isEmpty) return null;
    final parts = t.split(':');
    if (parts.length < 2) return null;
    return '${parts[0]}:${parts[1]}';
  }

  void _initAttendanceDrafts() {
    for (final cg in activeCgList) {
      if (!attendanceDraft.containsKey(cg.hpRegId)) {
        final shift = activeHpShiftMap[cg.hpRegId];
        attendanceDraft[cg.hpRegId] = {
          'status': 'present',
          'shift_type': 'live_out',
          'check_in': shift?['in_time'],
          'check_out': shift?['out_time'],
        };
      }
    }
  }

  /// VALIDATE MANDATORY FIELDS
  bool validateMandatoryFields() {
    if (hpFirstNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter First Name");
      return false;
    }
    if (hpLastNameController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter Last Name");
      return false;
    }
    if (hpPhoneController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter Phone Number");
      return false;
    }
    if (hpGender.value.isEmpty) {
      HelperUi.showToast(message: "Please select Gender");
      return false;
    }
    if (hpAddressController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter Address");
      return false;
    }
    if (hpPinCodeController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter Pin Code");
      return false;
    }
    if (hpBranchId.value.isEmpty) {
      HelperUi.showToast(message: "Please select Branch");
      return false;
    }
    if (hpEducation.value.isEmpty) {
      HelperUi.showToast(message: "Please select Education");
      return false;
    }
    if (hpIdentityProofType.value.isEmpty) {
      HelperUi.showToast(message: "Please select ID Proof Type");
      return false;
    }
    if (hpIdentityProofNumberController.text.trim().isEmpty) {
      HelperUi.showToast(message: "Please enter ID Proof Number");
      return false;
    }
    return true;
  }

  /// FIELD MAPPERS
  int _genderToId(String gender) {
    switch (gender) {
      case 'Male':
        return 1;
      case 'Female':
        return 2;
      case 'Other':
        return 3;
      default:
        return 0;
    }
  }

  int _maritalStatusToId(String status) {
    switch (status) {
      case 'Single':
        return 1;
      case 'Married':
        return 2;
      case 'Divorced':
        return 3;
      default:
        return 0;
    }
  }

  int _branchNameToId(String branchName) {
    final branch = dashboardController.getAllBranches
        .firstWhereOrNull((e) => e.brName == branchName);
    return branch?.brId ?? 0;
  }

  /// CREATE HP
  Future<void> createCg() async {
    if (!validateMandatoryFields()) return;
    isCreateLoading.value = true;

    try {
      final formData = dio.FormData.fromMap({
        "hp_reg_first_name": hpFirstNameController.text.trim(),
        "hp_reg_last_name": hpLastNameController.text.trim(),
        "hp_reg_email": hpEmailController.text.trim(),
        "hp_reg_phone_number": hpPhoneController.text.trim(),
        "hp_reg_address": hpAddressController.text.trim(),
        "hp_reg_dob": hpDobController.text.trim(),
        "hp_reg_gender": _genderToId(hpGender.value),
        "hp_reg_city": hpCity.value,
        "hp_reg_state": hpState.value,
        "hp_reg_pin_code": hpPinCodeController.text.trim(),
        "hp_reg_emergency_contact_phone": hpEmergencyPhoneController.text.trim(),
        "hp_reg_languages": hpSelectedLanguageIds.join(','),
        "hp_reg_branch_id": _branchNameToId(hpBranchId.value),
        "hp_reg_marital_status": _maritalStatusToId(hpMaritalStatus.value),
        "hp_reg_experience": hpExperienceController.text.trim(),
        "hp_reg_father_name": hpFatherNameController.text.trim(),
        "hp_reg_father_occupation": hpFatherOccupationController.text.trim(),
        "hp_reg_mother_name": hpMotherNameController.text.trim(),
        "hp_reg_identity_proof_type": hpIdentityProofType.value,
        "hp_reg_identity_proof_number": hpIdentityProofNumberController.text.trim(),
        "hp_reg_education": hpEducation.value,
        "livein_pay": liveInPayController.text.trim(),
        "liveout_pay": liveOutPayController.text.trim(),
        "monthly_livein_pay": monthlyLiveInPayController.text.trim(),
        "monthly_liveout_pay": monthlyLiveOutPayController.text.trim(),
        "hp_effect_date": DateTime.now().toIso8601String(),
        "org_id": box.read("org_id") ?? 1,
      });

      if (hpUploadedDocuments.isNotEmpty) {
        final file = hpUploadedDocuments.first;
        formData.files.add(
          MapEntry(
            "hp_reg_photo",
            dio.MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }

      if (hpIdProofFrontDocs.isNotEmpty) {
        final file = hpIdProofFrontDocs.first;
        formData.files.add(
          MapEntry(
            "hp_reg_identity_proof_front_image",
            dio.MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }

      if (hpIdProofBackDocs.isNotEmpty) {
        final file = hpIdProofBackDocs.first;
        formData.files.add(
          MapEntry(
            "hp_reg_identity_proof_back_image",
            dio.MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }

      if (hpEducationCertDocs.isNotEmpty) {
        final file = hpEducationCertDocs.first;
        formData.files.add(
          MapEntry(
            "hp_reg_education_certificate",
            dio.MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      }

      final response = await apiService.postForm(
        ApiConstants.createHp,
        formData,
      );

      createCgResponse.value = response;

      // Backend returns 201 with { message: 'HP Profile created successfully.' }
      // and no "status" field, so key off the status code (mirrors createUser).
      final created = response?.statusCode == 201 ||
          response?.statusCode == 200 ||
          response?.data["status"] == true;

      if (created) {
        HelperUi.showToast(message: "Health Professional Created Successfully");
        clearFilters();
        getAllCgFromApi();
        // Jump to Manage HP page (index saved by SideMenuWidgetView when built)
        final targetIndex = box.read<int>('manage_hp_page_index') ?? 0;
        box.write('selected_page_index', targetIndex);
        Get.offAllNamed(Routes.MAIN);
      } else {
        HelperUi.showToast(
          message: response?.data["message"] ?? "Creation Failed",
        );
      }
    } catch (e) {
      debugPrint("Create HP error: $e");
      HelperUi.showToast(message: "Something went wrong");
    } finally {
      isCreateLoading.value = false;
    }
  }

  /// CLEAR FORM
  void clearFilters() {
    hpFirstNameController.clear();
    hpLastNameController.clear();
    hpEmailController.clear();
    hpPhoneController.clear();
    hpAddressController.clear();
    hpPinCodeController.clear();
    hpDobController.clear();
    hpEmergencyPhoneController.clear();
    hpFatherNameController.clear();
    hpFatherOccupationController.clear();
    hpMotherNameController.clear();
    hpIdentityProofNumberController.clear();
    hpEducation.value = '';
    hpExperienceController.clear();
    liveInPayController.clear();
    liveOutPayController.clear();
    monthlyLiveInPayController.clear();
    monthlyLiveOutPayController.clear();
    hpGender.value = '';
    hpCity.value = '';
    hpState.value = '';
    hpBranchId.value = '';
    hpMaritalStatus.value = '';
    hpSelectedLanguageIds.clear();
    hpIdentityProofType.value = '';
    hpUploadedDocuments.clear();
    hpIdProofFrontDocs.clear();
    hpIdProofBackDocs.clear();
    hpEducationCertDocs.clear();
  }


  void updateCgStatus(int cgId, int status, {bool navigateToManageHp = false}) {
    manageCgStatusLoading.value = true;

    apiService
        .patchApi("${ApiConstants.manageCgStatus}?id=$cgId&status=$status")
        .then((response) {
      manageCgStatusLoading.value = false;

      if (response == null) {
        HelperUi.showToast(message: "No response from server.");
        return;
      }

      Map<String, dynamic> responseData = response.data ?? {};
      var statusMessage = responseData['message'] ?? "No message provided.";
      debugPrint("Response from updateCgStatus: $responseData");

      if (response.statusCode == 200) {
        HelperUi.showToast(message: "Health Professional status updated successfully.");
        getAllCgFromApi();
        if (navigateToManageHp) {
          final targetIndex = box.read<int>('manage_hp_page_index') ?? 0;
          box.write('selected_page_index', targetIndex);
          Get.offAllNamed(Routes.MAIN);
        }
      } else if (response.statusCode == 401) {
        HelperUi.showToast(message: "Unauthorized access. Please log in again.");
      } else {
        HelperUi.showToast(message: statusMessage);
      }
    }).catchError((error) {
      manageCgStatusLoading.value = false;
      HelperUi.showToast(message: "Error updating status: $error");
    });
  }
  Future<void> markCgAttendance({
    required int bookingId,
    required DateTime attendanceDate,
    required String cgId,
    required int invoiceId,
    required String status,
    required String shiftType,
    TimeOfDay? checkIn,
    TimeOfDay? checkOut,
    String notes = '',
  }) async {
    // Guard: attendance is tied to a real booking via an FK on the backend.
    // Sending booking_id=0 (no active assignment) triggers a server-side FK
    // violation, so block it here with a clear message instead.
    if (bookingId <= 0) {
      HelperUi.showToast(
          message:
              'This HP has no active booking assigned — attendance cannot be marked.',
          backgroundColor: Colors.red);
      return;
    }

    final hpIdInt = int.tryParse(cgId) ?? 0;
    isMarkCgAttendanceLoading.value = true;
    if (hpIdInt > 0) markingHpIds.add(hpIdInt);

    final body = buildAttendanceRecord(
      bookingId:      bookingId,
      attendanceDate: attendanceDate,
      cgId:           cgId,
      invoiceId:      invoiceId,
      status:         status,
      shiftType:      shiftType,
      checkIn:        checkIn,
      checkOut:       checkOut,
      notes:          notes,
    );

    try {
      final resp = await apiService.postRaw(ApiConstants.markCgAttendance, body);
      if (resp != null && resp.statusCode == 201) {
        HelperUi.showToast(message: 'Attendance marked successfully');
        getAttendanceListFromApi();
      } else {
        final msg = resp?.data?['error'] ?? resp?.data?['message'] ?? 'Unknown error';
        HelperUi.showToast(
            message: 'Failed: $msg', backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint('markCgAttendance error: $e');
      HelperUi.showToast(
          message: 'Attendance marking failed. Check logs.',
          backgroundColor: Colors.red);
    } finally {
      isMarkCgAttendanceLoading.value = false;
      markingHpIds.remove(hpIdInt);
    }
  }

  /// Builds one attendance record payload. Working hours are computed
  /// server-side, so they are intentionally not sent.
  Map<String, dynamic> buildAttendanceRecord({
    required int bookingId,
    required DateTime attendanceDate,
    required String cgId,
    required int invoiceId,
    required String status,
    required String shiftType,
    TimeOfDay? checkIn,
    TimeOfDay? checkOut,
    String notes = '',
  }) {
    return <String, dynamic>{
      'booking_id': bookingId.toString(),
      'inv_id':     invoiceId > 0 ? invoiceId.toString() : null,
      'hp_id':      cgId,
      'att_date':   DateFormat('yyyy-MM-dd').format(attendanceDate),
      'from_date':  DateFormat('yyyy-MM-dd').format(attendanceDate), // legacy
      'status':     status,
      'shift_type': shiftType,
      'check_in':   checkIn  != null ? _fmtTime(checkIn)  : null,
      'check_out':  checkOut != null ? _fmtTime(checkOut) : null,
      'notes':      notes,
    };
  }

  /// Submits many attendance records in a single request. Returns the number
  /// saved; per-record failures are surfaced via a toast.
  Future<int> submitAttendanceBatch(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return 0;
    isSubmittingAttendanceBatch.value = true;
    try {
      final resp = await apiService.postRaw(
        ApiConstants.markCgAttendanceBatch,
        {'records': records},
      );
      final saved  = (resp?.data?['saved'] as num?)?.toInt() ?? 0;
      final failed = (resp?.data?['failed'] as List?) ?? const [];

      if (resp != null && (resp.statusCode == 200 || resp.statusCode == 201)) {
        HelperUi.showToast(
          message: failed.isEmpty
              ? 'Attendance saved for $saved HP(s)'
              : 'Saved $saved, ${failed.length} failed',
          backgroundColor: failed.isEmpty ? null : Colors.orange,
        );
        getAttendanceListFromApi();
      } else {
        final msg = resp?.data?['message'] ?? 'Unknown error';
        HelperUi.showToast(message: 'Failed: $msg', backgroundColor: Colors.red);
      }
      return saved;
    } catch (e) {
      debugPrint('submitAttendanceBatch error: $e');
      HelperUi.showToast(
          message: 'Batch submission failed. Check logs.',
          backgroundColor: Colors.red);
      return 0;
    } finally {
      isSubmittingAttendanceBatch.value = false;
    }
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> getAttendanceListFromApi({
    String? hpId,
    String? fromDate,
    String? toDate,
  }) async {
    isAttendanceListLoading.value = true;
    try {
      final params = <String>[];
      if (hpId     != null && hpId.isNotEmpty)     params.add('hp_id=$hpId');
      if (fromDate != null && fromDate.isNotEmpty) params.add('from_date=$fromDate');
      if (toDate   != null && toDate.isNotEmpty)   params.add('to_date=$toDate');

      final url = params.isEmpty
          ? ApiConstants.getAttendanceList
          : '${ApiConstants.getAttendanceList}?${params.join('&')}';

      final response = await apiService.getRaw(url);
      if (response != null && response.statusCode == 200 && response.data is List) {
        attendanceList.value = response.data as List<dynamic>;
      }
    } catch (e) {
      debugPrint('[Attendance] getAttendanceListFromApi error: $e');
    } finally {
      isAttendanceListLoading.value = false;
    }
  }
}
