import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/saas_account_model.dart';
import '../models/saas_billing_invoice_model.dart';
import '../models/saas_plan_model.dart';
import '../models/saas_subscription_model.dart';
import '../models/saas_usage_model.dart';

class SaasAccountsController extends GetxController {
  final ApiService _api = ApiService();

  // ── Loading flags ─────────────────────────────────────────────────────────
  final RxBool loadingAccounts       = false.obs;
  final RxBool loadingPlans          = false.obs;
  final RxBool loadingDetail         = false.obs;
  final RxBool loadingInvoices       = false.obs;
  final RxBool loadingHealth         = false.obs;
  final RxBool saving                = false.obs;
  final RxBool checkingSlug          = false.obs;
  final RxBool checkingAdminEmail    = false.obs;
  final RxBool checkingDowngrade     = false.obs;

  // ── Data ──────────────────────────────────────────────────────────────────
  final RxList<SaasAccountModel>        accounts         = <SaasAccountModel>[].obs;
  final RxList<SaasAccountModel>        filteredAccounts = <SaasAccountModel>[].obs;
  final RxList<SaasPlanModel>           plans            = <SaasPlanModel>[].obs;
  final RxList<SaasSubscriptionModel>   subHistory       = <SaasSubscriptionModel>[].obs;
  final RxList<SaasBillingInvoiceModel> billingInvoices  = <SaasBillingInvoiceModel>[].obs;
  final RxList<Map<String, dynamic>>    healthSummary    = <Map<String, dynamic>>[].obs;
  final Rx<SaasAccountModel?>           selectedAccount  = Rx<SaasAccountModel?>(null);
  final Rx<SaasUsageModel?>             selectedUsage    = Rx<SaasUsageModel?>(null);

  // ── KPI ───────────────────────────────────────────────────────────────────
  final RxInt totalOrgs    = 0.obs;
  final RxInt activeOrgs   = 0.obs;
  final RxInt trialOrgs    = 0.obs;
  final RxInt expiringOrgs = 0.obs;

  // ── Validation state ──────────────────────────────────────────────────────
  final RxBool   slugAvailable      = true.obs;
  final RxBool   adminEmailAvailable = true.obs;
  final RxString slugCheckMessage   = ''.obs;
  final RxBool   downgradeBlocked   = false.obs;
  final RxString downgradeReason    = ''.obs;

  // ── Wizard ────────────────────────────────────────────────────────────────
  final RxInt wizardStep = 0.obs;

  // Step 1
  final nameCtrl    = TextEditingController();
  final slugCtrl    = TextEditingController();
  final emailCtrl   = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final addressCtrl = TextEditingController();

  // Step 2
  final RxString selectedPlanId = '1'.obs;

  // Step 3
  final RxBool   isTrial           = false.obs;
  final RxInt    trialDays         = 14.obs;
  final RxString subscriptionStart = ''.obs;
  final RxString subscriptionExpiry = ''.obs;
  final RxBool   autoRenew         = false.obs;

  // Step 4
  final adminNameCtrl     = TextEditingController();
  final adminEmailCtrl    = TextEditingController();
  final adminPasswordCtrl = TextEditingController();
  final adminConfirmCtrl  = TextEditingController();
  final RxBool passwordObscure = true.obs;
  final RxBool confirmObscure  = true.obs;

  // ── Filters ───────────────────────────────────────────────────────────────
  final RxString filterPlan      = ''.obs;
  final RxString filterSubStatus = ''.obs;
  final searchCtrl = TextEditingController();

  // ── Plan-change dialog ────────────────────────────────────────────────────
  final RxString targetPlanId = ''.obs;

  // ── Debounce timers ───────────────────────────────────────────────────────
  Timer? _slugDebounce;
  Timer? _adminEmailDebounce;

  // ── Billing form ──────────────────────────────────────────────────────────
  final RxInt    billingOrgId   = 0.obs;
  final RxInt    billingMonth   = DateTime.now().month.obs;
  final RxInt    billingYear    = DateTime.now().year.obs;
  final RxDouble billingAmount  = 0.0.obs;
  final dueDateCtrl = TextEditingController();

  // ── Status transition ─────────────────────────────────────────────────────
  final transitionReasonCtrl = TextEditingController();
  final slugConfirmCtrl      = TextEditingController();
  final RxString pendingTransition = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
    fetchPlans();
  }

  @override
  void onClose() {
    _slugDebounce?.cancel();
    _adminEmailDebounce?.cancel();
    nameCtrl.dispose();
    slugCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    adminNameCtrl.dispose();
    adminEmailCtrl.dispose();
    adminPasswordCtrl.dispose();
    adminConfirmCtrl.dispose();
    searchCtrl.dispose();
    transitionReasonCtrl.dispose();
    slugConfirmCtrl.dispose();
    dueDateCtrl.dispose();
    super.onClose();
  }

  // ── Data fetch ────────────────────────────────────────────────────────────

  Future<void> fetchAccounts() async {
    loadingAccounts.value = true;
    try {
      final resp = await _api.getList<SaasAccountModel>(
        ApiConstants.getSaasAccounts,
        (json) => SaasAccountModel.fromJson(json),
      );
      accounts.value = resp ?? [];
      filteredAccounts.value = accounts;
      _computeKpis();
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load accounts: $e');
    } finally {
      loadingAccounts.value = false;
    }
  }

  Future<void> fetchPlans() async {
    loadingPlans.value = true;
    try {
      final resp = await _api.getList<SaasPlanModel>(
        ApiConstants.getPlans,
        (json) => SaasPlanModel.fromJson(json),
      );
      plans.value = resp ?? [];
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load plans: $e');
    } finally {
      loadingPlans.value = false;
    }
  }

  Future<void> fetchAccountDetail(SaasAccountModel account) async {
    selectedAccount.value = account;
    loadingDetail.value = true;
    try {
      final resp = await _api.getRaw(ApiConstants.getOrgUsage(account.id));
      if (resp != null && resp.statusCode == 200) {
        selectedUsage.value = SaasUsageModel.fromJson(resp.data as Map<String, dynamic>);
      }
      final histResp = await _api.getList<SaasSubscriptionModel>(
        ApiConstants.getSubscriptionHistory(account.id),
        (json) => SaasSubscriptionModel.fromJson(json),
      );
      subHistory.value = histResp ?? [];
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load account detail: $e');
    } finally {
      loadingDetail.value = false;
    }
  }

  Future<void> fetchBillingInvoices({int? orgId}) async {
    loadingInvoices.value = true;
    try {
      final resp = await _api.getList<SaasBillingInvoiceModel>(
        ApiConstants.getSaasInvoices(orgId: orgId),
        (json) => SaasBillingInvoiceModel.fromJson(json),
      );
      billingInvoices.value = resp ?? [];
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load invoices: $e');
    } finally {
      loadingInvoices.value = false;
    }
  }

  Future<void> fetchHealthSummary() async {
    loadingHealth.value = true;
    try {
      final resp = await _api.getRaw(ApiConstants.getAccountHealthSummary);
      if (resp != null && resp.data is List) {
        healthSummary.value = List<Map<String, dynamic>>.from(
          (resp.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load health summary: $e');
    } finally {
      loadingHealth.value = false;
    }
  }

  // ── Real-time checks ──────────────────────────────────────────────────────

  void onSlugChanged(String value) {
    _slugDebounce?.cancel();
    if (value.length < 3) {
      slugAvailable.value = true;
      slugCheckMessage.value = '';
      checkingSlug.value = false;
      return;
    }
    checkingSlug.value = true;
    _slugDebounce = Timer(const Duration(milliseconds: 600), () {
      _checkSlugAvailability(value);
    });
  }

  Future<void> _checkSlugAvailability(String slug) async {
    try {
      final resp = await _api.getRaw(ApiConstants.checkSlugAvailable(slug));
      if (resp != null && resp.statusCode == 200) {
        slugAvailable.value = resp.data['available'] == true;
        slugCheckMessage.value =
            slugAvailable.value ? '' : 'Slug already in use.';
      }
    } catch (_) {
      slugAvailable.value = true;
    } finally {
      checkingSlug.value = false;
    }
  }

  void onAdminEmailChanged(String value) {
    _adminEmailDebounce?.cancel();
    if (value.isEmpty) {
      adminEmailAvailable.value = true;
      return;
    }
    _adminEmailDebounce = Timer(const Duration(milliseconds: 600), () {
      _checkAdminEmailAvailability(value);
    });
  }

  Future<void> _checkAdminEmailAvailability(String email) async {
    checkingAdminEmail.value = true;
    try {
      final resp = await _api.getRaw(ApiConstants.checkEmailAvailable(email));
      if (resp != null && resp.statusCode == 200) {
        adminEmailAvailable.value = resp.data['available'] == true;
      }
    } catch (_) {
      adminEmailAvailable.value = true;
    } finally {
      checkingAdminEmail.value = false;
    }
  }

  // ── Slug auto-generation ──────────────────────────────────────────────────

  void autoGenerateSlug(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    slugCtrl.text = slug;
    onSlugChanged(slug);
  }

  // ── Wizard ────────────────────────────────────────────────────────────────

  void nextStep() {
    if (!validateCurrentStep()) return;
    if (wizardStep.value < 3) wizardStep.value++;
  }

  void prevStep() {
    if (wizardStep.value > 0) wizardStep.value--;
  }

  bool validateCurrentStep() {
    switch (wizardStep.value) {
      case 0:
        if (nameCtrl.text.trim().length < 3) {
          HelperUi.showToast(message: 'Name must be at least 3 characters.');
          return false;
        }
        if (slugCtrl.text.trim().length < 3) {
          HelperUi.showToast(message: 'Slug must be at least 3 characters.');
          return false;
        }
        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(slugCtrl.text.trim())) {
          HelperUi.showToast(
              message: 'Slug may only contain lowercase letters, digits and hyphens.');
          return false;
        }
        if (!slugAvailable.value) {
          HelperUi.showToast(message: 'Slug is already in use. Choose a different one.');
          return false;
        }
        if (checkingSlug.value) {
          HelperUi.showToast(message: 'Waiting for slug check...');
          return false;
        }
        return true;

      case 1:
        if (selectedPlanId.value.isEmpty) {
          HelperUi.showToast(message: 'Please select a plan.');
          return false;
        }
        return true;

      case 2:
        if (isTrial.value && (trialDays.value < 1 || trialDays.value > 90)) {
          HelperUi.showToast(message: 'Trial days must be between 1 and 90.');
          return false;
        }
        return true;

      case 3:
        final email = adminEmailCtrl.text.trim();
        final pass  = adminPasswordCtrl.text;
        final conf  = adminConfirmCtrl.text;
        if (email.isNotEmpty) {
          if (!GetUtils.isEmail(email)) {
            HelperUi.showToast(message: 'Invalid admin email.');
            return false;
          }
          if (!adminEmailAvailable.value) {
            HelperUi.showToast(message: 'Admin email is already in use.');
            return false;
          }
          if (pass.length < 8) {
            HelperUi.showToast(message: 'Password must be at least 8 characters.');
            return false;
          }
          if (!RegExp(r'(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*])').hasMatch(pass)) {
            HelperUi.showToast(
                message: 'Password must contain uppercase, digit and special character.');
            return false;
          }
          if (pass != conf) {
            HelperUi.showToast(message: 'Passwords do not match.');
            return false;
          }
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> submitWizard() async {
    if (!validateCurrentStep()) return;
    saving.value = true;
    try {
      final planId = int.tryParse(selectedPlanId.value) ?? 1;
      final body = <String, dynamic>{
        'name':    nameCtrl.text.trim(),
        'slug':    slugCtrl.text.trim(),
        'email':   emailCtrl.text.trim(),
        'phone':   phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'plan_id': planId,
        if (isTrial.value) 'trial_days': trialDays.value,
        if (subscriptionExpiry.isNotEmpty) 'expires_on': subscriptionExpiry.value,
        if (adminEmailCtrl.text.trim().isNotEmpty) ...{
          'admin_name':     adminNameCtrl.text.trim(),
          'admin_email':    adminEmailCtrl.text.trim(),
          'admin_password': adminPasswordCtrl.text,
        },
      };
      final resp = await _api.postRaw(ApiConstants.createOrganisation, body);
      if (resp != null && resp.statusCode == 201) {
        HelperUi.showToast(
            message: 'Account created successfully.',
            backgroundColor: Colors.green);
        resetWizard();
        Get.back();
        await fetchAccounts();
      } else {
        final msg = resp?.data is Map
            ? (resp?.data['message'] ?? 'Failed to create account.')
            : 'Failed to create account.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  void resetWizard() {
    wizardStep.value = 0;
    nameCtrl.clear();
    slugCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    adminNameCtrl.clear();
    adminEmailCtrl.clear();
    adminPasswordCtrl.clear();
    adminConfirmCtrl.clear();
    selectedPlanId.value = '1';
    isTrial.value        = false;
    trialDays.value      = 14;
    subscriptionStart.value  = '';
    subscriptionExpiry.value = '';
    autoRenew.value      = false;
    slugAvailable.value  = true;
    adminEmailAvailable.value = true;
  }

  // ── Account actions ───────────────────────────────────────────────────────

  Future<void> transitionSubscriptionStatus(
    int orgId,
    String newStatus,
    String reason,
  ) async {
    saving.value = true;
    try {
      final resp = await _api.patchRaw(ApiConstants.transitionSubscriptionStatus, {
        'org_id':     orgId,
        'new_status': newStatus,
        'reason':     reason,
      });
      if (resp != null && resp.statusCode == 200) {
        HelperUi.showToast(
            message: 'Status changed to $newStatus.',
            backgroundColor: Colors.green);
        transitionReasonCtrl.clear();
        slugConfirmCtrl.clear();
        await fetchAccounts();
        if (selectedAccount.value?.id == orgId) {
          await fetchAccountDetail(selectedAccount.value!);
        }
      } else {
        final msg = resp?.data is Map
            ? (resp?.data['message'] ?? 'Failed to change status.')
            : 'Failed to change status.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  Future<void> changePlan(int orgId, int planId, {String? reason}) async {
    // First check downgrade viability
    final viable = await checkDowngradeViability(orgId, planId);
    if (!viable) return;

    saving.value = true;
    try {
      final resp = await _api.putRaw(ApiConstants.updateOrgPlan, {
        'org_id':  orgId,
        'plan_id': planId,
        if (reason != null) 'reason': reason,
      });
      if (resp != null && resp.statusCode == 200) {
        HelperUi.showToast(
            message: 'Plan updated successfully.',
            backgroundColor: Colors.green);
        await fetchAccounts();
        if (selectedAccount.value?.id == orgId) {
          await fetchAccountDetail(selectedAccount.value!);
        }
      } else {
        final msg = resp?.data is Map
            ? (resp?.data['message'] ?? 'Failed to change plan.')
            : 'Failed to change plan.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  Future<bool> checkDowngradeViability(int orgId, int planId) async {
    checkingDowngrade.value = true;
    downgradeBlocked.value  = false;
    downgradeReason.value   = '';
    try {
      final resp = await _api.postRaw(ApiConstants.checkDowngradeViability, {
        'org_id':        orgId,
        'target_plan_id': planId,
      });
      if (resp != null && resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        if (data['viable'] == false) {
          downgradeBlocked.value = true;
          downgradeReason.value  = data['reason']?.toString() ?? '';
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      return true;
    } finally {
      checkingDowngrade.value = false;
    }
  }

  Future<void> generateInvoice() async {
    if (billingOrgId.value == 0) {
      HelperUi.showToast(message: 'Select an organisation.');
      return;
    }
    saving.value = true;
    try {
      final body = <String, dynamic>{
        'org_id':       billingOrgId.value,
        'period_month': billingMonth.value,
        'period_year':  billingYear.value,
        if (billingAmount.value > 0) 'amount': billingAmount.value,
        if (dueDateCtrl.text.isNotEmpty) 'due_date': dueDateCtrl.text,
      };
      final resp = await _api.postRaw(ApiConstants.generateSaasInvoice, body);
      if (resp != null && resp.statusCode == 201) {
        HelperUi.showToast(
            message: 'Invoice generated.',
            backgroundColor: Colors.green);
        dueDateCtrl.clear();
        billingAmount.value = 0;
        await fetchBillingInvoices();
      } else {
        final msg = resp?.data is Map
            ? (resp?.data['message'] ?? 'Failed to generate invoice.')
            : 'Failed to generate invoice.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  Future<void> markInvoicePaid(
      int invoiceId, String? transactionRef, String? paymentDate) async {
    saving.value = true;
    try {
      final resp = await _api.patchRaw(ApiConstants.markSaasInvoicePaid, {
        'invoice_id':      invoiceId,
        if (transactionRef != null) 'transaction_ref': transactionRef,
        if (paymentDate    != null) 'payment_date':    paymentDate,
      });
      if (resp != null && resp.statusCode == 200) {
        HelperUi.showToast(
            message: 'Invoice marked as paid.',
            backgroundColor: Colors.green);
        await fetchBillingInvoices();
      } else {
        HelperUi.showToast(message: (resp?.data is Map ? resp?.data['message'] : null) ?? 'Failed to update invoice.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  // ── Filters / search ──────────────────────────────────────────────────────

  void applyFilters() {
    var list = accounts.toList();
    final query = searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((a) =>
              a.name.toLowerCase().contains(query) ||
              a.slug.toLowerCase().contains(query) ||
              a.email.toLowerCase().contains(query))
          .toList();
    }
    if (filterPlan.value.isNotEmpty) {
      list = list.where((a) => a.planName == filterPlan.value).toList();
    }
    if (filterSubStatus.value.isNotEmpty) {
      list = list.where((a) => a.subStatus == filterSubStatus.value).toList();
    }
    filteredAccounts.value = list;
  }

  void clearFilters() {
    filterPlan.value      = '';
    filterSubStatus.value = '';
    searchCtrl.clear();
    filteredAccounts.value = accounts;
  }

  // ── KPI compute ───────────────────────────────────────────────────────────

  void _computeKpis() {
    totalOrgs.value    = accounts.length;
    activeOrgs.value   = accounts.where((a) => a.subStatus == 'active').length;
    trialOrgs.value    = accounts.where((a) => a.subStatus == 'trial').length;
    expiringOrgs.value = accounts.where((a) => a.isExpiringSoon).length;
  }

  // ── Allowed transitions lookup ────────────────────────────────────────────

  List<String> allowedNextStatuses(String current) {
    const transitions = {
      'trial':     ['active', 'cancelled'],
      'active':    ['suspended', 'cancelled'],
      'suspended': ['active', 'cancelled'],
      'expired':   ['active', 'cancelled'],
      'cancelled': <String>[],
    };
    return transitions[current] ?? [];
  }

  // ── Check for existing invoice for period ─────────────────────────────────

  SaasBillingInvoiceModel? existingInvoiceForPeriod(
      int orgId, int month, int year) {
    try {
      return billingInvoices.firstWhereOrNull(
        (inv) =>
            inv.orgId == orgId &&
            inv.periodMonth == month &&
            inv.periodYear == year,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Password strength ─────────────────────────────────────────────────────

  String passwordStrength(String pass) {
    if (pass.length < 6) return 'Weak';
    int score = 0;
    if (pass.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'\d').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(pass)) score++;
    if (score <= 1) return 'Weak';
    if (score == 2) return 'Fair';
    return 'Strong';
  }
}
