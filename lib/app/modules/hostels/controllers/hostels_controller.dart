import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../../register_cg/controllers/register_cg_controller.dart';
import '../../register_cg/models/get_cg_details_model.dart';
import '../models/get_hostels_model.dart';
import '../models/hostel_settlement_model.dart';
import '../models/hostel_stay_model.dart';

class HostelsController extends GetxController {
  final ApiService _api = ApiService();

  // ── List state ──────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<GetHostelsModel> allHostels = <GetHostelsModel>[].obs;
  final RxString searchQuery = ''.obs;

  // ── Detail / stays state ──────────────────────────────────────────────────────
  final Rx<GetHostelsModel?> selectedHostel = Rx<GetHostelsModel?>(null);
  final RxBool loadingStays = false.obs;
  final RxList<HostelStayModel> stays = <HostelStayModel>[].obs;

  // ── Settlement state ──────────────────────────────────────────────────────────
  final RxBool loadingSettlement = false.obs;
  final Rx<HostelSettlementModel?> settlement = Rx<HostelSettlementModel?>(null);
  final Rxn<int> settlementHostelId = Rxn<int>();
  final settlementFromCtrl = TextEditingController();
  final settlementToCtrl = TextEditingController();

  // ── Create/edit form ───────────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final RxString gender = 'Male'.obs;
  final Rxn<int> editingHostelId = Rxn<int>();

  static const List<String> genders = ['Male', 'Female'];

  List<GetHostelsModel> get filteredHostels {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allHostels;
    return allHostels
        .where((h) =>
            h.hostelName.toLowerCase().contains(q) ||
            h.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    settlementFromCtrl.text =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    settlementToCtrl.text = DateFormat('yyyy-MM-dd').format(now);
    fetchHostels();
  }

  @override
  void onClose() {
    for (final c in [
      nameCtrl, addressCtrl, cityCtrl, stateCtrl, pincodeCtrl, rateCtrl,
      capacityCtrl, contactPersonCtrl, contactPhoneCtrl, contactEmailCtrl,
      settlementFromCtrl, settlementToCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  // ── Hostels CRUD ───────────────────────────────────────────────────────────
  Future<void> fetchHostels() async {
    isLoading.value = true;
    try {
      final res = await _api.getRaw(ApiConstants.getHostels());
      if (res?.statusCode == 200 && res?.data is List) {
        allHostels.value = GetHostelsModel.listFromJson(res!.data as List);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreate() {
    editingHostelId.value = null;
    _clearForm();
  }

  void prepareEdit(GetHostelsModel h) {
    editingHostelId.value = h.id;
    nameCtrl.text = h.hostelName;
    addressCtrl.text = h.address ?? '';
    cityCtrl.text = h.city ?? '';
    stateCtrl.text = h.state ?? '';
    pincodeCtrl.text = h.pincode ?? '';
    rateCtrl.text = h.ratePerDay == 0 ? '' : h.ratePerDay.toString();
    capacityCtrl.text = h.capacity?.toString() ?? '';
    contactPersonCtrl.text = h.contactPersonName ?? '';
    contactPhoneCtrl.text = h.contactPhone ?? '';
    contactEmailCtrl.text = h.contactEmail ?? '';
    gender.value = h.gender.isEmpty ? 'Male' : h.gender;
  }

  Future<bool> saveHostel() async {
    if (nameCtrl.text.trim().length < 3) {
      HelperUi.showToast(message: 'Hostel name must be at least 3 characters.', backgroundColor: Colors.red);
      return false;
    }
    final rate = double.tryParse(rateCtrl.text.trim());
    if (rate == null || rate <= 0) {
      HelperUi.showToast(message: 'Enter a valid rate per day.', backgroundColor: Colors.red);
      return false;
    }

    final body = <String, dynamic>{
      'hostel_name': nameCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'city': cityCtrl.text.trim(),
      'state': stateCtrl.text.trim(),
      'pincode': pincodeCtrl.text.trim(),
      'gender': gender.value,
      'rate_per_day': rate,
      if (capacityCtrl.text.trim().isNotEmpty)
        'capacity': int.tryParse(capacityCtrl.text.trim()),
      'contact_person_name': contactPersonCtrl.text.trim(),
      'contact_phone': contactPhoneCtrl.text.trim(),
      'contact_email': contactEmailCtrl.text.trim(),
    };

    isSubmitting.value = true;
    try {
      final id = editingHostelId.value;
      final res = id == null
          ? await _api.postRaw(ApiConstants.createHostel, body)
          : await _api.putRaw(ApiConstants.updateHostel(id), body);
      final ok = res?.statusCode == 200 || res?.statusCode == 201;
      if (ok) {
        HelperUi.showToast(
          message: id == null ? 'Hostel created.' : 'Hostel updated.',
          backgroundColor: Colors.green,
        );
        await fetchHostels();
        return true;
      }
      HelperUi.showToast(
        message: _msg(res?.data) ?? 'Failed to save hostel.',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleStatus(GetHostelsModel h) async {
    final res = await _api.patchRaw(
      ApiConstants.toggleHostelStatus(h.id),
      {'status': h.status == 1 ? 0 : 1},
    );
    if (res?.statusCode == 200) {
      HelperUi.showToast(message: 'Hostel status updated.', backgroundColor: Colors.green);
      await fetchHostels();
    } else {
      HelperUi.showToast(message: 'Failed to update status.', backgroundColor: Colors.red);
    }
  }

  // ── Detail / stays ────────────────────────────────────────────────────────────
  void openHostel(GetHostelsModel h) {
    selectedHostel.value = h;
    stays.clear();
    fetchStays(h.id);
  }

  Future<void> fetchStays(int hostelId) async {
    loadingStays.value = true;
    try {
      final res = await _api.getRaw(ApiConstants.getHostelStays(hostelId: hostelId));
      if (res?.statusCode == 200 && res?.data is List) {
        stays.value = HostelStayModel.listFromJson(res!.data as List);
      }
    } finally {
      loadingStays.value = false;
    }
  }

  int get activeOccupancy => stays.where((s) => s.status == 'active').length;

  /// CGs store gender as an integer (1=Male, 2=Female, 3=Other) while hostels
  /// store the label; normalise both before comparing.
  static String _normalizeGender(String v) {
    final s = v.trim().toLowerCase();
    if (s == '1' || s == 'male' || s == 'm') return 'male';
    if (s == '2' || s == 'female' || s == 'f') return 'female';
    return s;
  }

  /// CGs eligible for a hostel: matching gender, sourced from RegisterCgController.
  List<GetCgDetails> eligibleCgs(String hostelGender) {
    final RegisterCgController reg = Get.isRegistered<RegisterCgController>()
        ? Get.find<RegisterCgController>()
        : Get.put(RegisterCgController());
    final target = _normalizeGender(hostelGender);
    return reg.getAllCgData.value
        .where((cg) => _normalizeGender(cg.hpRegGender) == target)
        .toList();
  }

  Future<bool> assignCg({
    required int hostelId,
    required int hpId,
    required String checkInDate,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await _api.postRaw(ApiConstants.createHostelStay, {
        'hostel_id': hostelId,
        'hp_id': hpId,
        'check_in_date': checkInDate,
      });
      if (res?.statusCode == 201) {
        HelperUi.showToast(message: 'Caregiver assigned.', backgroundColor: Colors.green);
        await fetchStays(hostelId);
        return true;
      }
      HelperUi.showToast(
        message: _msg(res?.data) ?? 'Failed to assign caregiver.',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> closeStay(HostelStayModel stay, String checkOutDate) async {
    final res = await _api.putRaw(
      ApiConstants.closeHostelStay(stay.id),
      {'check_out_date': checkOutDate},
    );
    if (res?.statusCode == 200) {
      HelperUi.showToast(message: 'Stay closed.', backgroundColor: Colors.green);
      await fetchStays(stay.hostelId);
    } else {
      HelperUi.showToast(
        message: _msg(res?.data) ?? 'Failed to close stay.',
        backgroundColor: Colors.red,
      );
    }
  }

  // ── Settlement ────────────────────────────────────────────────────────────────
  Future<void> fetchSettlement() async {
    final hostelId = settlementHostelId.value;
    if (hostelId == null) {
      HelperUi.showToast(message: 'Select a hostel first.', backgroundColor: Colors.orange);
      return;
    }
    loadingSettlement.value = true;
    settlement.value = null;
    try {
      final res = await _api.getRaw(ApiConstants.getHostelSettlement(
        hostelId: hostelId,
        periodFrom: settlementFromCtrl.text,
        periodTo: settlementToCtrl.text,
      ));
      if (res?.statusCode == 200 && res?.data is Map) {
        settlement.value =
            HostelSettlementModel.fromJson(Map<String, dynamic>.from(res!.data));
      } else {
        HelperUi.showToast(
          message: _msg(res?.data) ?? 'Failed to load settlement.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      loadingSettlement.value = false;
    }
  }

  Future<void> generateSettlement({String? paymentMode}) async {
    final s = settlement.value;
    if (s == null) return;
    isSubmitting.value = true;
    try {
      final res = await _api.postRaw(ApiConstants.createHostelSettlement, {
        'hostel_id': s.hostelId,
        'period_from': s.periodFrom,
        'period_to': s.periodTo,
        if (paymentMode != null) 'payment_mode': paymentMode,
      });
      if (res?.statusCode == 201) {
        HelperUi.showToast(message: 'Settlement generated.', backgroundColor: Colors.green);
      } else {
        HelperUi.showToast(
          message: _msg(res?.data) ?? 'Failed to generate settlement.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _clearForm() {
    for (final c in [
      nameCtrl, addressCtrl, cityCtrl, stateCtrl, pincodeCtrl, rateCtrl,
      capacityCtrl, contactPersonCtrl, contactPhoneCtrl, contactEmailCtrl,
    ]) {
      c.clear();
    }
    gender.value = 'Male';
  }

  String? _msg(dynamic data) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    return null;
  }
}
