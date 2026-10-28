import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';

/// Settings → Organisation Profile.
///
/// Manages the org's public identity — the details rendered on every outbound
/// client email (invoice + payment receipt): masthead name/logo/colour,
/// contact footer, GSTIN, payment terms and payment instructions.
/// Also drives the live email preview panel.
class OrgProfileController extends GetxController {
  final ApiService apiService = ApiService();

  // ── Form fields ────────────────────────────────────────────────────────────
  final nameCtrl        = TextEditingController();
  final taglineCtrl     = TextEditingController();
  final emailCtrl       = TextEditingController();
  final phoneCtrl       = TextEditingController();
  final addressCtrl     = TextEditingController();
  final websiteCtrl     = TextEditingController();
  final logoUrlCtrl     = TextEditingController();
  final gstinCtrl       = TextEditingController();
  final termsDaysCtrl   = TextEditingController(text: '15');
  final invoiceNotesCtrl = TextEditingController();

  /// Hex like #1E3A5F, or empty for the platform default.
  final RxString brandColor = ''.obs;

  /// Read-only identity shown in the header.
  final RxString orgCode = ''.obs;
  final RxString orgSlug = ''.obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPreviewLoading = false.obs;

  /// 0 = Invoice, 1 = Payment Receipt.
  final RxInt previewTab = 0.obs;

  final RxString invoiceHtml = ''.obs;
  final RxString receiptHtml = ''.obs;
  final RxString invoiceSubject = ''.obs;
  final RxString receiptSubject = ''.obs;
  final RxString senderLine = ''.obs;

  /// Bumped whenever preview HTML changes so the view registers a fresh
  /// iframe factory (HtmlElementView factories are immutable once created).
  final RxInt previewVersion = 0.obs;

  static const brandPresets = <String>[
    '#1E3A5F', '#0F766E', '#7C2D5E', '#3D5A2E', '#8A4B14', '#37415C',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    for (final c in [
      nameCtrl, taglineCtrl, emailCtrl, phoneCtrl, addressCtrl,
      websiteCtrl, logoUrlCtrl, gstinCtrl, termsDaysCtrl, invoiceNotesCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _str(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    return (s == 'null' || s == 'NA') ? '' : s;
  }

  /// Current form values as the API payload.
  Map<String, dynamic> _formPayload() => {
        'name':               nameCtrl.text.trim(),
        'tagline':            taglineCtrl.text.trim(),
        'email':              emailCtrl.text.trim(),
        'phone':              phoneCtrl.text.trim(),
        'address':            addressCtrl.text.trim(),
        'website':            websiteCtrl.text.trim(),
        'logo_url':           logoUrlCtrl.text.trim(),
        'gstin':              gstinCtrl.text.trim(),
        'brand_color':        brandColor.value,
        'payment_terms_days': int.tryParse(termsDaysCtrl.text.trim()) ?? 15,
        'invoice_notes':      invoiceNotesCtrl.text.trim(),
      };

  String? _validate() {
    if (nameCtrl.text.trim().isEmpty) {
      return 'Organisation name is required.';
    }
    final email = emailCtrl.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      return 'Billing email is not a valid email address.';
    }
    final terms = int.tryParse(termsDaysCtrl.text.trim());
    if (terms == null || terms < 1 || terms > 90) {
      return 'Payment terms must be between 1 and 90 days.';
    }
    for (final entry in {
      'Website': websiteCtrl.text.trim(),
      'Logo URL': logoUrlCtrl.text.trim(),
    }.entries) {
      if (entry.value.isNotEmpty &&
          !entry.value.startsWith(RegExp(r'https?://'))) {
        return '${entry.key} must start with http:// or https://';
      }
    }
    return null;
  }

  // ── API ────────────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await apiService.getRaw(ApiConstants.orgProfileApi);
      if (ApiService.isOk(response) && response!.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        nameCtrl.text         = _str(d['name']);
        taglineCtrl.text      = _str(d['tagline']);
        emailCtrl.text        = _str(d['email']);
        phoneCtrl.text        = _str(d['phone']);
        addressCtrl.text      = _str(d['address']);
        websiteCtrl.text      = _str(d['website']);
        logoUrlCtrl.text      = _str(d['logo_url']);
        gstinCtrl.text        = _str(d['gstin']);
        invoiceNotesCtrl.text = _str(d['invoice_notes']);
        brandColor.value      = _str(d['brand_color']);
        orgCode.value         = _str(d['org_code']);
        orgSlug.value         = _str(d['slug']);
        final terms = _str(d['payment_terms_days']);
        termsDaysCtrl.text = terms.isEmpty ? '15' : terms;
      } else {
        HelperUi.showToast(
          message: ApiService.lastError ?? 'Failed to load organisation profile.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('loadProfile error: $e');
      HelperUi.showToast(
          message: 'Failed to load organisation profile.', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
    // Initial preview from saved values.
    refreshPreview(showErrors: false);
  }

  Future<void> saveProfile() async {
    final error = _validate();
    if (error != null) {
      HelperUi.showToast(message: error, backgroundColor: Colors.red);
      return;
    }

    isSaving.value = true;
    try {
      final response =
          await apiService.putRaw(ApiConstants.orgProfileApi, _formPayload());
      // putRaw returns null on non-2xx; the backend reason is in lastError.
      if (ApiService.isOk(response)) {
        HelperUi.showToast(
            message: 'Organisation profile saved.', backgroundColor: Colors.green);
        refreshPreview(showErrors: false);
      } else {
        HelperUi.showToast(
          message: ApiService.lastError ?? 'Failed to save profile. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('saveProfile error: $e');
      HelperUi.showToast(
          message: 'Failed to save profile. Please try again.', backgroundColor: Colors.red);
    } finally {
      isSaving.value = false;
    }
  }

  /// Renders both templates on the backend using the CURRENT form values
  /// (unsaved drafts included), so the admin sees exactly what clients get.
  Future<void> refreshPreview({bool showErrors = true}) async {
    isPreviewLoading.value = true;
    try {
      final response = await apiService.postRaw(
        ApiConstants.orgEmailPreviewApi,
        _formPayload(),
      );
      if (ApiService.isOk(response) && response!.data is Map) {
        final d = response.data as Map;
        final inv = d['invoice'] is Map ? d['invoice'] as Map : const {};
        final rec = d['receipt'] is Map ? d['receipt'] as Map : const {};
        invoiceHtml.value    = _str(inv['html']);
        invoiceSubject.value = _str(inv['subject']);
        receiptHtml.value    = _str(rec['html']);
        receiptSubject.value = _str(rec['subject']);
        senderLine.value     = _str(d['sender']);
        previewVersion.value++;
      } else if (showErrors) {
        final data = response?.data;
        final msg = data is Map
            ? (data['error'] ?? data['message'])?.toString()
            : null;
        HelperUi.showToast(
          message: msg ?? ApiService.lastError ?? 'Failed to render preview.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('refreshPreview error: $e');
      if (showErrors) {
        HelperUi.showToast(
            message: 'Failed to render preview.', backgroundColor: Colors.red);
      }
    } finally {
      isPreviewLoading.value = false;
    }
  }
}
