import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
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
  final RxString loadError = ''.obs;
  final RxnInt togglingHostelId = RxnInt();

  // ── Detail / stays state ──────────────────────────────────────────────────────
  final Rx<GetHostelsModel?> selectedHostel = Rx<GetHostelsModel?>(null);
  final RxBool loadingStays = false.obs;
  final RxList<HostelStayModel> stays = <HostelStayModel>[].obs;
  final RxString staysError = ''.obs;

  // ── Caregiver picker state (loaded here, independent of other modules) ──────
  final RxBool loadingCgs = false.obs;
  final RxList<GetCgDetails> allCgs = <GetCgDetails>[].obs;
  // hp ids that currently have an open (not checked-out) stay in any hostel.
  final RxSet<int> hpIdsWithOpenStay = <int>{}.obs;

  // ── Settlement state ──────────────────────────────────────────────────────────
  final RxBool loadingSettlement = false.obs;
  final Rx<HostelSettlementModel?> settlement = Rx<HostelSettlementModel?>(null);
  final Rxn<int> settlementHostelId = Rxn<int>();
  final RxString settlementError = ''.obs;
  // Settlement saved in this session (createHostelSettlement → {id}); there is
  // no list endpoint, so mark-paid is offered for this one only.
  final RxnInt lastSettlementId = RxnInt();
  final RxString lastSettlementStatus = ''.obs;
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

  /// Map any stored variant ('male', 'MALE', '1', 'f', null…) to a dropdown
  /// item so DropdownButton never asserts on an unknown value.
  static String normalizeGenderLabel(String? v) {
    final s = (v ?? '').trim().toLowerCase();
    if (s == '2' || s == 'female' || s == 'f') return 'Female';
    return 'Male';
  }

  /// Only active hostels can be settled / assigned.
  List<GetHostelsModel> get activeHostels =>
      allHostels.where((h) => h.status == 1).toList();

  bool _isOk(dynamic res) => ApiService.isOk(res);

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
    loadError.value = '';
    try {
      final res = await _api.getRaw(ApiConstants.getHostels());
      if (_isOk(res) && res!.data is List) {
        allHostels.value = GetHostelsModel.listFromJson(res.data as List);
        final sel = settlementHostelId.value;
        if (sel != null && !activeHostels.any((h) => h.id == sel)) {
          settlementHostelId.value = null;
        }
      } else {
        loadError.value = ApiService.lastError ?? 'Failed to load hostels.';
      }
    } catch (e) {
      debugPrint('fetchHostels error: $e');
      loadError.value = 'Failed to load hostels.';
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
    gender.value = normalizeGenderLabel(h.gender);
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
      final ok = _isOk(res);
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

  /// Returns true when the server confirmed the change.
  Future<bool> toggleStatus(GetHostelsModel h) async {
    if (togglingHostelId.value != null) return false;
    togglingHostelId.value = h.id;
    try {
      final res = await _api.patchRaw(
        ApiConstants.toggleHostelStatus(h.id),
        {'status': h.status == 1 ? 0 : 1},
      );
      if (_isOk(res)) {
        HelperUi.showToast(
          message: h.status == 1 ? 'Hostel deactivated.' : 'Hostel activated.',
          backgroundColor: Colors.green,
        );
        await fetchHostels();
        return true;
      }
      HelperUi.showToast(
        message: _msg(res?.data) ?? ApiService.lastError ?? 'Failed to update status.',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      togglingHostelId.value = null;
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
    staysError.value = '';
    try {
      final res = await _api.getRaw(ApiConstants.getHostelStays(hostelId: hostelId));
      if (_isOk(res) && res!.data is List) {
        stays.value = HostelStayModel.listFromJson(res.data as List);
      } else {
        staysError.value = ApiService.lastError ?? 'Failed to load occupants.';
      }
    } catch (e) {
      debugPrint('fetchStays error: $e');
      staysError.value = 'Failed to load occupants.';
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

  /// Load the caregiver list (if not loaded yet) and the set of caregivers
  /// that already have an open stay. Called when the assign dialog opens.
  Future<void> loadCaregiverPicker() async {
    loadingCgs.value = true;
    try {
      final futures = <Future>[
        _api.getRaw(ApiConstants.getHostelStays(status: 'active')),
        if (allCgs.isEmpty)
          _api.getList<GetCgDetails>(
            ApiConstants.getHp,
            (json) => GetCgDetails.fromJson(json),
          ),
      ];
      final results = await Future.wait(futures);
      final staysRes = results[0];
      if (_isOk(staysRes) && staysRes.data is List) {
        hpIdsWithOpenStay.assignAll(
          HostelStayModel.listFromJson(staysRes.data as List)
              .where((st) => st.isOpen)
              .map((st) => st.hpId),
        );
      }
      if (results.length > 1 && results[1] is List<GetCgDetails>) {
        allCgs.assignAll(results[1] as List<GetCgDetails>);
      }
    } catch (e) {
      debugPrint('loadCaregiverPicker error: $e');
    } finally {
      loadingCgs.value = false;
    }
  }

  /// CGs eligible for a hostel: matching gender, not rejected/terminated
  /// (hp_reg_status 3/4), and without an open stay elsewhere.
  List<GetCgDetails> eligibleCgs(String hostelGender) {
    final target = _normalizeGender(hostelGender);
    return allCgs
        .where((cg) =>
            _normalizeGender(cg.hpRegGender) == target &&
            cg.hpRegStatus != 3 &&
            cg.hpRegStatus != 4 &&
            !hpIdsWithOpenStay.contains(cg.hpRegId))
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
      if (_isOk(res)) {
        HelperUi.showToast(message: 'Caregiver assigned.', backgroundColor: Colors.green);
        hpIdsWithOpenStay.add(hpId);
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

  /// Returns true when the stay was closed; the dialog stays open otherwise.
  Future<bool> closeStay(HostelStayModel stay, String checkOutDate) async {
    final inD = DateTime.tryParse(stay.checkInDate);
    final outD = DateTime.tryParse(checkOutDate);
    if (inD != null && outD != null &&
        DateTime(outD.year, outD.month, outD.day)
            .isBefore(DateTime(inD.year, inD.month, inD.day))) {
      HelperUi.showToast(
          message: 'Check-out cannot be before check-in.', backgroundColor: Colors.red);
      return false;
    }
    isSubmitting.value = true;
    try {
      // putRaw returns null on any non-2xx; the reason is in lastError.
      final res = await _api.putRaw(
        ApiConstants.closeHostelStay(stay.id),
        {'check_out_date': checkOutDate},
      );
      if (_isOk(res)) {
        HelperUi.showToast(message: 'Caregiver checked out.', backgroundColor: Colors.green);
        hpIdsWithOpenStay.remove(stay.hpId);
        await fetchStays(stay.hostelId);
        return true;
      }
      HelperUi.showToast(
        message: _msg(res?.data) ?? ApiService.lastError ?? 'Failed to close stay.',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Settlement ────────────────────────────────────────────────────────────────
  Future<void> fetchSettlement() async {
    final hostelId = settlementHostelId.value;
    if (hostelId == null) {
      HelperUi.showToast(message: 'Select a hostel first.', backgroundColor: Colors.orange);
      return;
    }
    final from = DateTime.tryParse(settlementFromCtrl.text);
    final to = DateTime.tryParse(settlementToCtrl.text);
    if (from == null || to == null) {
      HelperUi.showToast(message: 'Pick both From and To dates.', backgroundColor: Colors.orange);
      return;
    }
    if (from.isAfter(to)) {
      HelperUi.showToast(
          message: 'From date must be on or before To date.', backgroundColor: Colors.red);
      return;
    }
    loadingSettlement.value = true;
    settlement.value = null;
    settlementError.value = '';
    lastSettlementId.value = null;
    lastSettlementStatus.value = '';
    try {
      final res = await _api.getRaw(ApiConstants.getHostelSettlement(
        hostelId: hostelId,
        periodFrom: settlementFromCtrl.text,
        periodTo: settlementToCtrl.text,
      ));
      if (_isOk(res) && res!.data is Map) {
        settlement.value =
            HostelSettlementModel.fromJson(Map<String, dynamic>.from(res.data));
      } else {
        settlementError.value = ApiService.lastError ?? 'Failed to load settlement.';
      }
    } catch (e) {
      debugPrint('fetchSettlement error: $e');
      settlementError.value = 'Failed to load settlement.';
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
      if (_isOk(res)) {
        HelperUi.showToast(message: 'Settlement generated.', backgroundColor: Colors.green);
        final data = res!.data;
        final id = data is Map ? int.tryParse(data['id']?.toString() ?? '') : null;
        lastSettlementId.value = id;
        lastSettlementStatus.value = 'Pending';
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

  Future<bool> markSettlementPaid(int id, {String? paymentMode}) async {
    isSubmitting.value = true;
    try {
      final res = await _api.patchRaw(ApiConstants.markHostelSettlementPaid(id), {
        if (paymentMode != null && paymentMode.isNotEmpty) 'payment_mode': paymentMode,
      });
      if (_isOk(res)) {
        lastSettlementStatus.value = 'Paid';
        HelperUi.showToast(message: 'Settlement marked as paid.', backgroundColor: Colors.green);
        return true;
      }
      HelperUi.showToast(
        message: ApiService.lastError ?? 'Failed to mark settlement as paid.',
        backgroundColor: Colors.red,
      );
      return false;
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
