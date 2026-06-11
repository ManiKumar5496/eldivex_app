import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../client_api_constants.dart';

/// Backs the whole client portal. Data is held as plain JSON maps — the backend
/// returns ready-to-render shapes.
class ClientController extends GetxController {
  final ApiService _api = ApiService();
  final GetStorage box = GetStorage();

  String get clientName => (box.read('client_name') ?? 'Client').toString();

  final RxBool loadingProfile = false.obs;
  final RxBool loadingBookings = false.obs;
  final RxBool loadingPatients = false.obs;
  final RxBool loadingAccounts = false.obs;
  final RxBool loadingSupport = false.obs;
  final RxBool busy = false.obs;

  final Rxn<Map<String, dynamic>> profile = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> outstanding = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> bookings = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> patients = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> invoices = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> receipts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> support = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> supportCategories = <Map<String, dynamic>>[].obs;

  final RxString bookingFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

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

  Future<void> refreshDashboard() async {
    await Future.wait([fetchProfile(), fetchBookings('all'), fetchOutstanding()]);
  }

  Future<void> fetchProfile() async {
    loadingProfile.value = true;
    try {
      profile.value = await _obj(ClientApi.me);
    } finally {
      loadingProfile.value = false;
    }
  }

  Future<void> fetchBookings(String filter) async {
    bookingFilter.value = filter;
    loadingBookings.value = true;
    try {
      bookings.value = await _list(ClientApi.bookings(filter));
    } finally {
      loadingBookings.value = false;
    }
  }

  /// Assigned caregiver(s) + service-start OTP for a booking.
  Future<List<Map<String, dynamic>>> fetchAssignedHp(int bookingId) =>
      _list(ClientApi.bookingHp(bookingId));

  /// Caregiver attendance over the booking's service period.
  Future<List<Map<String, dynamic>>> fetchBookingAttendance(int bookingId) =>
      _list(ClientApi.bookingAttendance(bookingId));

  Future<void> fetchPatients() async {
    loadingPatients.value = true;
    try {
      patients.value = await _list(ClientApi.patients);
    } finally {
      loadingPatients.value = false;
    }
  }

  Future<bool> updatePatient(int id, Map<String, dynamic> fields) async {
    busy.value = true;
    try {
      final res = await _api.putRaw(ClientApi.patientById(id), fields);
      final ok = res?.statusCode == 200;
      HelperUi.showToast(
        message: ok ? 'Patient updated.' : 'Update failed.',
        backgroundColor: ok ? Get.theme.colorScheme.primary : Get.theme.colorScheme.error,
      );
      if (ok) await fetchPatients();
      return ok;
    } finally {
      busy.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    busy.value = true;
    try {
      final res = await _api.putRaw(ClientApi.me, fields);
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

  // ── Accounts ─────────────────────────────────────────────────────────────
  Future<void> fetchAccounts() async {
    loadingAccounts.value = true;
    try {
      final results = await Future.wait([
        _list(ClientApi.invoices),
        _list(ClientApi.receipts),
      ]);
      invoices.value = results[0];
      receipts.value = results[1];
      outstanding.value = await _obj(ClientApi.outstanding);
    } finally {
      loadingAccounts.value = false;
    }
  }

  Future<void> fetchOutstanding() async {
    outstanding.value = await _obj(ClientApi.outstanding);
  }

  // ── Support ─────────────────────────────────────────────────────────────────
  Future<void> fetchSupport() async {
    loadingSupport.value = true;
    try {
      final results = await Future.wait([
        _list(ClientApi.support),
        _list(ClientApi.supportCategories),
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
      final res = await _api.postRaw(ClientApi.support, {
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
}
