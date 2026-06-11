import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../hp_api_constants.dart';

/// Backs the whole caregiver portal (dashboard + tabs + detail pages).
/// Holds data as plain JSON maps — the backend already returns ready-to-render
/// shapes, so dedicated model classes would add little here.
class HpController extends GetxController {
  final ApiService _api = ApiService();
  final GetStorage box = GetStorage();

  String get hpName => (box.read('hp_name') ?? 'Caregiver').toString();

  // Loading flags
  final RxBool loadingProfile = false.obs;
  final RxBool loadingBookings = false.obs;
  final RxBool loadingAttendance = false.obs;
  final RxBool loadingEarnings = false.obs;
  final RxBool loadingPayouts = false.obs;
  final RxBool loadingSupport = false.obs;
  final RxBool loadingLeave = false.obs;
  final RxBool busy = false.obs; // for check-in/out + form submits

  // Data
  final Rxn<Map<String, dynamic>> profile = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> todayEarnings = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> earningsSummary = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> bookings = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> attendance = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> payouts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> support = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> supportCategories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> leave = <Map<String, dynamic>>[].obs;

  final RxString bookingFilter = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _list(String endpoint) async {
    final res = await _api.getRaw(endpoint);
    if (res?.statusCode == 200 && res?.data is List) {
      return (res!.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> _obj(String endpoint) async {
    final res = await _api.getRaw(endpoint);
    if (res?.statusCode == 200 && res?.data is Map) {
      return Map<String, dynamic>.from(res!.data);
    }
    return null;
  }

  String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────
  Future<void> refreshDashboard() async {
    await Future.wait([fetchProfile(), fetchTodayEarnings(), fetchBookings('active')]);
  }

  Future<void> fetchProfile() async {
    loadingProfile.value = true;
    try {
      profile.value = await _obj(HpApi.me);
    } finally {
      loadingProfile.value = false;
    }
  }

  Future<void> fetchTodayEarnings() async {
    loadingEarnings.value = true;
    try {
      todayEarnings.value = await _obj(HpApi.earningsToday);
    } finally {
      loadingEarnings.value = false;
    }
  }

  // ── Bookings ──────────────────────────────────────────────────────────────
  Future<void> fetchBookings(String filter) async {
    bookingFilter.value = filter;
    loadingBookings.value = true;
    try {
      bookings.value = await _list(HpApi.bookings(filter));
    } finally {
      loadingBookings.value = false;
    }
  }

  /// First active booking — used by the dashboard check-in card.
  Map<String, dynamic>? get currentBooking =>
      bookings.isNotEmpty ? bookings.first : null;

  // ── Attendance ──────────────────────────────────────────────────────────────
  Future<void> fetchAttendance({String? from, String? to}) async {
    loadingAttendance.value = true;
    try {
      attendance.value = await _list(HpApi.attendance(from: from, to: to));
    } finally {
      loadingAttendance.value = false;
    }
  }

  Future<void> checkIn(int bookingId, {String? otp, double? lat, double? lng}) async {
    busy.value = true;
    try {
      final res = await _api.postRaw(HpApi.checkIn, {
        'booking_id': bookingId,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      });
      if (res?.statusCode == 201) {
        HelperUi.showToast(message: 'Checked in.', backgroundColor: Get.theme.colorScheme.primary);
        await Future.wait([fetchTodayEarnings(), fetchAttendance()]);
      } else {
        HelperUi.showToast(
          message: (res?.data is Map ? res!.data['message'] : null) ?? 'Check-in failed.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      busy.value = false;
    }
  }

  Future<void> checkOut() async {
    busy.value = true;
    try {
      final res = await _api.postRaw(HpApi.checkOut, {});
      if (res?.statusCode == 200) {
        HelperUi.showToast(message: 'Checked out.', backgroundColor: Get.theme.colorScheme.primary);
        await Future.wait([fetchTodayEarnings(), fetchAttendance()]);
      } else {
        HelperUi.showToast(
          message: (res?.data is Map ? res!.data['message'] : null) ?? 'Check-out failed.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      busy.value = false;
    }
  }

  bool get checkedInToday {
    final t = todayEarnings.value;
    return t != null && t['check_in'] != null && t['check_out'] == null;
  }

  // ── Earnings summary ─────────────────────────────────────────────────────────
  Future<void> fetchEarningsSummary(String from, String to) async {
    loadingEarnings.value = true;
    try {
      earningsSummary.value = await _obj(HpApi.earningsSummary(from, to));
    } finally {
      loadingEarnings.value = false;
    }
  }

  /// Convenience: current calendar month summary.
  Future<void> fetchMonthSummary() async {
    final now = DateTime.now();
    final from = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
    await fetchEarningsSummary(from, _today());
  }

  // ── Payouts / payslips ────────────────────────────────────────────────────
  Future<void> fetchPayouts() async {
    loadingPayouts.value = true;
    try {
      payouts.value = await _list(HpApi.payouts);
    } finally {
      loadingPayouts.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchPayslip(int id) => _obj(HpApi.payoutById(id));

  // ── Support ─────────────────────────────────────────────────────────────────
  Future<void> fetchSupport() async {
    loadingSupport.value = true;
    try {
      final results = await Future.wait([
        _list(HpApi.support),
        _list(HpApi.supportCategories),
      ]);
      support.value = results[0];
      supportCategories.value = results[1];
    } finally {
      loadingSupport.value = false;
    }
  }

  Future<bool> createSupport({
    required String title,
    required String description,
    int? categoryId,
  }) async {
    busy.value = true;
    try {
      final res = await _api.postRaw(HpApi.support, {
        'title': title,
        'description': description,
        if (categoryId != null) 'support_type_id': categoryId,
      });
      final ok = res?.statusCode == 201;
      HelperUi.showToast(
        message: ok ? 'Ticket created.' : 'Could not create ticket.',
        backgroundColor: ok ? Get.theme.colorScheme.primary : Get.theme.colorScheme.error,
      );
      if (ok) await fetchSupport();
      return ok;
    } finally {
      busy.value = false;
    }
  }

  // ── Leave ─────────────────────────────────────────────────────────────────
  Future<void> fetchLeave() async {
    loadingLeave.value = true;
    try {
      leave.value = await _list(HpApi.leave);
    } finally {
      loadingLeave.value = false;
    }
  }

  Future<bool> requestLeave(String fromDate, String toDate, String reason) async {
    busy.value = true;
    try {
      final res = await _api.postRaw(HpApi.leave, {
        'from_date': fromDate,
        'to_date': toDate,
        'reason': reason,
      });
      final ok = res?.statusCode == 201;
      HelperUi.showToast(
        message: ok ? 'Leave requested.' : 'Could not submit leave.',
        backgroundColor: ok ? Get.theme.colorScheme.primary : Get.theme.colorScheme.error,
      );
      if (ok) await fetchLeave();
      return ok;
    } finally {
      busy.value = false;
    }
  }

  // ── Profile update ───────────────────────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    busy.value = true;
    try {
      final res = await _api.putRaw(HpApi.me, fields);
      final ok = res?.statusCode == 200;
      HelperUi.showToast(
        message: ok ? 'Profile updated.' : 'Update failed.',
        backgroundColor: ok ? Get.theme.colorScheme.primary : Get.theme.colorScheme.error,
      );
      if (ok) await fetchProfile();
      return ok;
    } finally {
      busy.value = false;
    }
  }
}
