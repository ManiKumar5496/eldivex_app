import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';

/// Drives the first-login Terms & Conditions gate.
///
/// The user must scroll to the very bottom of the document before the "I have
/// read and agree" checkbox unlocks, and must tick it before "Agree & Continue"
/// unlocks. Only then does acceptance get recorded and the app enter the
/// dashboard. Declining clears the session and returns to login.
class TermsController extends GetxController {
  final ApiService apiService = ApiService();
  final ScrollController scrollController = ScrollController();

  final isLoading    = true.obs;
  final isSubmitting = false.obs;
  final loadError    = ''.obs;

  final title         = ''.obs;
  final content       = ''.obs;
  final version       = 0.obs;
  final effectiveFrom = ''.obs;
  final termsId       = 0.obs;

  /// True once the user has scrolled to (near) the end of the document.
  final reachedBottom = false.obs;
  /// True once the user ticks the acknowledgement checkbox.
  final agreed = false.obs;

  bool get canAgree => reachedBottom.value && agreed.value && !isSubmitting.value;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchTerms();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    // Within 24px of the end counts as "read to the bottom". Also treat a
    // document short enough not to scroll as already fully read.
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 24) {
      reachedBottom.value = true;
    }
  }

  Future<void> fetchTerms() async {
    try {
      isLoading.value = true;
      loadError.value = '';
      final response = await apiService.getRaw(ApiConstants.getCurrentTerms);

      if (response != null && response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final terms = (data['terms'] as Map?) ?? const {};
        title.value         = (terms['title'] ?? 'Terms & Conditions').toString();
        content.value       = (terms['content'] ?? '').toString();
        version.value       = int.tryParse('${terms['version'] ?? 0}') ?? 0;
        effectiveFrom.value = (terms['effective_from'] ?? '').toString();
        termsId.value       = int.tryParse('${terms['id'] ?? 0}') ?? 0;

        // If the backend says it's already accepted, don't trap the user here.
        if (data['accepted'] == true) {
          _proceedToApp();
          return;
        }
      } else {
        loadError.value = 'Unable to load the Terms & Conditions. Please retry.';
      }
    } catch (_) {
      loadError.value = 'Something went wrong while loading the Terms.';
    } finally {
      isLoading.value = false;
      // Re-evaluate scroll state after the content lays out (short docs).
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  Future<void> accept() async {
    if (!canAgree) return;
    try {
      isSubmitting.value = true;
      final response = await apiService.postRaw(
        ApiConstants.acceptTerms,
        {'terms_id': termsId.value},
      );

      if (response != null && response.statusCode == 200) {
        box.write('terms_accepted', true);
        box.write('terms_version', version.value);
        HelperUi.showToast(message: 'Terms accepted. Welcome!');
        _proceedToApp();
      } else if (response != null &&
          response.data is Map &&
          response.data['code'] == 'TERMS_OUTDATED') {
        // A newer version was published while this page was open — reload it.
        HelperUi.showToast(message: 'Terms were updated. Reloading the latest version.');
        reachedBottom.value = false;
        agreed.value = false;
        await fetchTerms();
      } else {
        final msg = (response?.data is Map)
            ? (response!.data['message']?.toString())
            : null;
        HelperUi.showToast(
          message: msg ?? 'Could not record your acceptance. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } catch (_) {
      HelperUi.showToast(
        message: 'Could not record your acceptance. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Declining is a hard stop — the user cannot use the app without accepting.
  void decline() {
    for (final k in ['user_token', 'role_id', 'org_id', 'user', 'selected_page_index']) {
      box.remove(k);
    }
    box.remove('terms_accepted');
    Get.offAllNamed(Routes.LOGIN);
    HelperUi.showToast(
      message: 'You must accept the Terms & Conditions to use Eldivex.',
    );
  }

  void _proceedToApp() {
    box.write('terms_accepted', true);
    Get.offAllNamed(Routes.MAIN);
  }
}
