import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_cg_details_model.dart';
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
  RxBool isAttendanceListLoading = false.obs;
  RxList<dynamic> attendanceList = <dynamic>[].obs;
  final RxMap<int, Map<String, dynamic>> attendanceDraft = <int, Map<String, dynamic>>{}.obs;
  Rx<DateTime> markAttendanceSelectedDate = DateTime.now().obs;
  final RxInt currentPage = 0.obs;
  final RxInt rowsPerPage = 20.obs;
  final RxString selectedTab = 'null'.obs;  // 'null' = All

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

  /// FILTERED LIST — only CGs with status 5
  List<GetCgDetails> get activeCgList =>
      getAllCgData.value.where((cg) => cg.hpRegStatus == 5).toList();

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
        .then((result) {
          getAllCgData.value = result ?? [];
        })
        .catchError((e) {
          debugPrint("Get HP error: $e");
        })
        .whenComplete(() => getAllCGLoading.value = false);
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
        "hp_reg_emergency_contact_phone": hpEmergencyPhoneController.text
            .trim(),
        "hp_reg_languages": hpSelectedLanguageIds.join(','),
        "hp_reg_branch_id": _branchNameToId(hpBranchId.value),
        "hp_reg_marital_status": _maritalStatusToId(hpMaritalStatus.value),
        "hp_reg_experience": hpExperienceController.text.trim(),
        "hp_reg_father_name": hpFatherNameController.text.trim(),
        "hp_reg_father_occupation": hpFatherOccupationController.text.trim(),
        "hp_reg_mother_name": hpMotherNameController.text.trim(),
        "hp_reg_identity_proof_type": hpIdentityProofType.value,
        "hp_reg_identity_proof_number": hpIdentityProofNumberController.text
            .trim(),
        "hp_reg_education": hpEducation.value,
        "livein_pay": liveInPayController.text.trim(),
        "liveout_pay": liveOutPayController.text.trim(),
        "monthly_livein_pay": monthlyLiveInPayController.text.trim(),
        "monthly_liveout_pay": monthlyLiveOutPayController.text.trim(),
        "hp_effect_date": DateTime.now().toIso8601String(),
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

      if (response?.data["status"] == true) {
        HelperUi.showToast(message: "Health Professional Created Successfully");
        clearFilters();
        getAllCgFromApi();
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


  void updateCgStatus( int cgId,int status) {
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
        if (statusMessage == 'Updated successfully.') {
          HelperUi.showToast(message: "Health Professional status updated successfully.");
                  onInit();

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
    isMarkCgAttendanceLoading.value = true;

    double workingHours = 0.0;
    if (checkIn != null && checkOut != null) {
      final inMin  = checkIn.hour * 60  + checkIn.minute;
      final outMin = checkOut.hour * 60 + checkOut.minute;
      workingHours = ((outMin - inMin) / 60.0).clamp(0.0, 24.0);
    }

    final attDetails = {
      'check_in':      checkIn  != null ? _fmtTime(checkIn)  : null,
      'check_out':     checkOut != null ? _fmtTime(checkOut) : null,
      'status':        status,
      'shift_type':    shiftType,
      'working_hours': workingHours,
      'notes':         notes,
    };

    final body = <String, dynamic>{
      'booking_id':  bookingId.toString(),
      'inv_id':      invoiceId.toString(),
      'from_date':   DateFormat('yyyy-MM-dd').format(attendanceDate),
      'att_details': jsonEncode(attDetails),
      'hp_id':       cgId,
    };

    try {
      await apiService.postRaw(ApiConstants.markCgAttendance, body);
      HelperUi.showToast(message: 'Attendance marked successfully');
    } catch (e) {
      HelperUi.showToast(
          message: 'Attendance marking failed: $e',
          backgroundColor: Colors.red);
    } finally {
      isMarkCgAttendanceLoading.value = false;
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
