import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../hp_api_constants.dart';

/// Drives caregiver login: resolve org from the shared link → phone → OTP.
class HpAuthController extends GetxController {
  final ApiService _api = ApiService();
  final GetStorage box = GetStorage();

  final RxBool resolvingOrg = false.obs;
  final RxBool sendingOtp = false.obs;
  final RxBool verifying = false.obs;
  final RxBool otpSent = false.obs;

  final RxnInt orgId = RxnInt();
  final RxString orgName = ''.obs;
  final RxString orgSlug = ''.obs;
  final RxString phone = ''.obs;

  // Form fields live here (not in the view's build) so typed input survives
  // rebuilds.
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();
  final TextEditingController slugCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Restore the last resolved org instantly so a returning caregiver never
    // sees the org-code screen because of a slow/failed lookup.
    final cachedId = int.tryParse('${box.read('hp_last_org_id') ?? ''}');
    if (cachedId != null && cachedId > 0) {
      orgId.value = cachedId;
      orgName.value = (box.read('hp_last_org_name') ?? '').toString();
    }
    // Then refresh from the link params in the background (also covers a new
    // link pointing at a different organisation).
    final orgIdParam = (box.read('hp_org_id_param') ?? '').toString();
    final slug = (box.read('hp_org_slug') ?? '').toString();
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
    box.write('hp_last_org_id', orgId.value);
    box.write('hp_last_org_name', orgName.value);
  }

  /// Manual fallback when no link params exist: accepts an org code
  /// (SUN-482913), a legacy numeric id, or a slug.
  Future<void> resolveManualEntry(String input) async {
    final ref = input.trim();
    if (ref.isEmpty) return;
    if (RegExp(r'^(\d+|[A-Za-z]{3}-\d{6})$').hasMatch(ref)) {
      box.write('hp_org_id_param', ref.toUpperCase());
      await resolveOrgByRef(ref.toUpperCase());
    } else {
      await resolveOrg(ref);
    }
  }

  /// "Not your organisation?" — forget the remembered org and show the
  /// org-code entry again.
  void changeOrganisation() {
    for (final k in [
      'hp_org_id_param',
      'hp_org_slug',
      'hp_last_org_id',
      'hp_last_org_name',
    ]) {
      box.remove(k);
    }
    orgId.value = null;
    orgName.value = '';
    orgSlug.value = '';
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
      final res = await _api.getRaw(HpApi.orgById(ref));
      if (res?.statusCode == 200 && res?.data is Map) {
        orgId.value = int.tryParse('${res!.data['org_id']}') ?? orgId.value;
        orgName.value = (res.data['org_name'] ?? '').toString();
        orgSlug.value = (res.data['slug'] ?? '').toString();
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

  /// Resolve the organisation encoded in the shared link (`/hp?org=<slug>`).
  Future<void> resolveOrg(String slug) async {
    if (slug.trim().isEmpty) return;
    resolvingOrg.value = true;
    try {
      final res = await _api.getRaw(HpApi.orgBySlug(slug.trim().toLowerCase()));
      if (res?.statusCode == 200 && res?.data is Map) {
        orgId.value = int.tryParse('${res!.data['org_id']}') ?? orgId.value;
        orgName.value = (res.data['org_name'] ?? '').toString();
        orgSlug.value = (res.data['slug'] ?? slug).toString();
        box.write('hp_org_slug', orgSlug.value);
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

  /// Step 1 — request an OTP for the entered phone number.
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
      final res = await _api.postRaw(HpApi.requestOtp, {
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
      } else {
        HelperUi.showToast(
          message: (res?.data is Map ? (res!.data['message'] ?? res.data['error'])?.toString() : null) ?? 'Could not send OTP.',
          backgroundColor: Get.theme.colorScheme.error,
        );
      }
    } finally {
      sendingOtp.value = false;
    }
  }

  /// Step 2 — verify the OTP and persist the caregiver session.
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
      final res = await _api.postRaw(HpApi.verifyOtp, {
        'phone': phone.value,
        'org_id': orgId.value,
        'otp': otp.trim(),
      });
      if (res?.statusCode == 200 && res?.data is Map && res!.data['token'] != null) {
        // Persist the caregiver session under dedicated keys + flip the active
        // session so ApiService attaches the caregiver token from now on.
        box.write('hp_token', res.data['token']);
        box.write('hp_id', res.data['hp_id']);
        box.write('hp_org_id', int.tryParse('${res.data['org_id']}'));
        box.write('hp_name', res.data['hp_name']);
        box.write('active_session', 'hp');
        box.write('last_portal', 'hp');
        // Remember the org independently of the session so the next login
        // (after expiry/logout) is pre-scoped to it.
        box.write('hp_last_org_id', int.tryParse('${res.data['org_id']}'));
        box.write('hp_last_org_name', orgName.value);
        Get.offAllNamed(Routes.HP_HOME);
      } else if (res == null) {
        // Connection failed entirely — distinguish from a wrong OTP so the user
        // isn't misled into re-typing a correct code.
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

  /// Clears ONLY the caregiver session keys (admin session is untouched).
  static void logout() {
    final box = GetStorage();
    for (final k in ['hp_token', 'hp_id', 'hp_org_id', 'hp_name', 'active_session']) {
      box.remove(k);
    }
    Get.offAllNamed(Routes.HP_LOGIN);
  }
}
