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

  @override
  void onInit() {
    super.onInit();
    // Prefer org_id from the shared link (no slug lookup needed); else slug.
    final orgIdParam = box.read('hp_org_id_param');
    final slug = (box.read('hp_org_slug') ?? '').toString();
    if (orgIdParam is int) {
      resolveOrgById(orgIdParam);
    } else if (slug.isNotEmpty) {
      resolveOrg(slug);
    }
  }

  /// Resolve the organisation from an org_id carried in the link.
  Future<void> resolveOrgById(int id) async {
    resolvingOrg.value = true;
    try {
      // Optimistically accept the id so login works even if the lookup fails;
      // enrich with the org name when available.
      orgId.value = id;
      final res = await _api.getRaw(HpApi.orgById(id));
      if (res?.statusCode == 200 && res?.data is Map) {
        orgName.value = (res!.data['org_name'] ?? '').toString();
        orgSlug.value = (res.data['slug'] ?? '').toString();
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
        orgId.value = res!.data['org_id'];
        orgName.value = (res.data['org_name'] ?? '').toString();
        orgSlug.value = (res.data['slug'] ?? slug).toString();
        box.write('hp_org_slug', orgSlug.value);
      } else {
        orgId.value = null;
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
      HelperUi.showToast(message: 'Enter a valid 10-digit phone number.');
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
        final devOtp = res?.data is Map ? res!.data['dev_otp'] : null;
        HelperUi.showToast(
          message: devOtp != null ? 'OTP sent (dev: $devOtp)' : 'OTP sent to your phone.',
          backgroundColor: Get.theme.colorScheme.primary,
        );
      } else {
        HelperUi.showToast(
          message: (res?.data is Map ? res!.data['message'] : null) ?? 'Could not send OTP.',
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
      HelperUi.showToast(message: 'Enter the OTP you received.');
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
        box.write('hp_org_id', res.data['org_id']);
        box.write('hp_name', res.data['hp_name']);
        box.write('active_session', 'hp');
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
          message: (res.data is Map ? res.data['message'] : null) ?? 'Incorrect OTP.',
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
