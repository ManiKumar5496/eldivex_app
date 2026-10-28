import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../client_api_constants.dart';

/// Drives client login: resolve org from the shared link → phone → OTP.
class ClientAuthController extends GetxController {
  final ApiService _api = ApiService();
  final GetStorage box = GetStorage();

  final RxBool resolvingOrg = false.obs;
  final RxBool sendingOtp = false.obs;
  final RxBool verifying = false.obs;
  final RxBool otpSent = false.obs;

  final RxnInt orgId = RxnInt();
  final RxString orgName = ''.obs;
  final RxString phone = ''.obs;

  // Form fields live here (not in the view's build) so typed input survives
  // rebuilds.
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();
  final TextEditingController slugCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Restore the last resolved org instantly so a returning user never sees
    // the org-code screen (or a blank name) because of a slow/failed lookup.
    final cachedId = int.tryParse('${box.read('client_last_org_id') ?? ''}');
    if (cachedId != null && cachedId > 0) {
      orgId.value = cachedId;
      orgName.value = (box.read('client_last_org_name') ?? '').toString();
    }
    // Then refresh from the link params in the background (also covers a new
    // link pointing at a different organisation).
    final orgIdParam = (box.read('client_org_id_param') ?? '').toString();
    final slug = (box.read('client_org_slug') ?? '').toString();
    if (orgIdParam.isNotEmpty) {
      resolveOrgByRef(orgIdParam);
    } else if (slug.isNotEmpty) {
      resolveOrg(slug);
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    otpCtrl.dispose();
    slugCtrl.dispose();
    super.onClose();
  }

  void _cacheOrg() {
    if (orgId.value == null) return;
    box.write('client_last_org_id', orgId.value);
    box.write('client_last_org_name', orgName.value);
  }

  /// Manual fallback when no link params exist: accepts an org code
  /// (SUN-482913), a legacy numeric id, or a slug.
  Future<void> resolveManualEntry(String input) async {
    final ref = input.trim();
    if (ref.isEmpty) return;
    if (RegExp(r'^(\d+|[A-Za-z]{3}-\d{6})$').hasMatch(ref)) {
      box.write('client_org_id_param', ref.toUpperCase());
      await resolveOrgByRef(ref.toUpperCase());
    } else {
      await resolveOrg(ref);
    }
  }

  /// "Not your organisation?" — forget the remembered org and show the
  /// org-code entry again.
  void changeOrganisation() {
    for (final k in [
      'client_org_id_param',
      'client_org_slug',
      'client_last_org_id',
      'client_last_org_name',
    ]) {
      box.remove(k);
    }
    orgId.value = null;
    orgName.value = '';
    otpSent.value = false;
  }

  /// Resolve the organisation from the org_id carried in the link — either a
  /// numeric id (legacy orgs) or an org code like SUN-482913 (new orgs).
  Future<void> resolveOrgByRef(String ref) async {
    resolvingOrg.value = true;
    try {
      // Optimistically accept a numeric id so login works even if the lookup
      // fails; an org code MUST resolve since OTP calls need the numeric id.
      orgId.value = int.tryParse(ref);
      final res = await _api.getRaw(ClientApi.orgById(ref));
      if (res?.statusCode == 200 && res?.data is Map) {
        orgId.value = int.tryParse('${res!.data['org_id']}') ?? orgId.value;
        orgName.value = (res.data['org_name'] ?? '').toString();
        _cacheOrg();
      } else if (orgId.value == null) {
        HelperUi.showToast(
          message: 'Organisation not found. Please use the link shared with you.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      resolvingOrg.value = false;
    }
  }

  Future<void> resolveOrg(String slug) async {
    if (slug.trim().isEmpty) return;
    resolvingOrg.value = true;
    try {
      final res = await _api.getRaw(ClientApi.orgBySlug(slug.trim().toLowerCase()));
      if (res?.statusCode == 200 && res?.data is Map) {
        orgId.value = int.tryParse('${res!.data['org_id']}') ?? orgId.value;
        orgName.value = (res.data['org_name'] ?? '').toString();
        box.write('client_org_slug', (res.data['slug'] ?? slug).toString());
        _cacheOrg();
      } else if (orgId.value == null) {
        // Only complain when we have no org at all — a failed background
        // refresh must not wipe the remembered org.
        HelperUi.showToast(
          message: 'Organisation not found. Please use the link shared with you.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      resolvingOrg.value = false;
    }
  }

  Future<void> requestOtp(String phoneInput) async {
    if (orgId.value == null) {
      HelperUi.showToast(
        message: 'Please open your organisation link first.',
        backgroundColor: Get.theme.colorScheme.error,
      );
      return;
    }
    if (phoneInput.trim().length < 10) {
      HelperUi.showToast(
        message: 'Enter a valid 10-digit phone number.',
        backgroundColor: Colors.orange,
      );
      return;
    }
    sendingOtp.value = true;
    try {
      phone.value = phoneInput.trim();
      final res = await _api.postRaw(ClientApi.requestOtp, {
        'phone': phone.value,
        'org_id': orgId.value,
      });
      if (res?.statusCode == 200) {
        otpSent.value = true;
        // Only surfaced in debug builds; the backend sends it only in dev mode.
        final devOtp =
            kDebugMode && res?.data is Map ? res!.data['dev_otp'] : null;
        HelperUi.showToast(
          message: devOtp != null ? 'OTP sent (dev: $devOtp)' : 'OTP sent to your phone.',
          backgroundColor: Get.theme.colorScheme.primary,
        );
      } else if (res == null) {
        HelperUi.showToast(
          message: 'Cannot reach the server. Check your connection / API URL.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      } else {
        HelperUi.showToast(
          message: (res.data is Map ? (res.data['message'] ?? res.data['error'])?.toString() : null) ?? 'Could not send OTP.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      sendingOtp.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.trim().length < 4) {
      HelperUi.showToast(
        message: 'Enter the OTP you received.',
        backgroundColor: Colors.orange,
      );
      return;
    }
    verifying.value = true;
    try {
      final res = await _api.postRaw(ClientApi.verifyOtp, {
        'phone': phone.value,
        'org_id': orgId.value,
        'otp': otp.trim(),
      });
      if (res?.statusCode == 200 && res?.data is Map && res!.data['token'] != null) {
        box.write('client_token', res.data['token']);
        box.write('client_id', res.data['user_id']);
        box.write('client_org_id', int.tryParse('${res.data['org_id']}'));
        box.write('client_name', res.data['user_name']);
        box.write('active_session', 'client');
        box.write('last_portal', 'client');
        // Remember the org independently of the session so the next login
        // (after expiry/logout) is pre-scoped to it.
        box.write('client_last_org_id', int.tryParse('${res.data['org_id']}'));
        box.write('client_last_org_name', orgName.value);
        otpCtrl.clear();
        Get.offAllNamed(Routes.CLIENT_HOME);
        // First login created the account — send them to complete the profile.
        if (res.data['is_new_user'] == true) {
          Get.toNamed(Routes.CLIENT_PROFILE);
          HelperUi.showToast(
            message: 'Welcome! Please complete your profile.',
            backgroundColor: Colors.green,
          );
        }
      } else if (res == null) {
        HelperUi.showToast(
          message: 'Cannot reach the server. Check your connection / API URL.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      } else {
        HelperUi.showToast(
          message: (res.data is Map ? (res.data['message'] ?? res.data['error'])?.toString() : null) ?? 'Incorrect OTP.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      verifying.value = false;
    }
  }

  void resetOtp() => otpSent.value = false;

  static void logout() {
    final box = GetStorage();
    for (final k in ['client_token', 'client_id', 'client_org_id', 'client_name', 'active_session']) {
      box.remove(k);
    }
    Get.offAllNamed(Routes.CLIENT_LOGIN);
  }
}
