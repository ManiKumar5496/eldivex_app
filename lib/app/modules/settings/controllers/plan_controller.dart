import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';

/// Settings → Plan & Renewal (Super Admin only): the organisation's plan, how
/// much of it is used, and requests to the Eldivex team to extend or change it.
class PlanController extends GetxController {
  final ApiService _api = ApiService();

  /// Extension periods the backend accepts (months).
  static const List<int> extendOptions = [1, 3, 6, 12];

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString loadError = ''.obs;

  final Rxn<Map<String, dynamic>> subscription = Rxn<Map<String, dynamic>>();
  final RxMap<String, dynamic> usage = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> plans = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> pendingRequest = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  static List<Map<String, dynamic>> _maps(dynamic v) => v is List
      ? v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
      : <Map<String, dynamic>>[];

  static Map<String, dynamic>? _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  String _message(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError ?? fallback;
  }

  /// GET /getPlanOverview
  Future<void> load() async {
    isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getPlanOverview);
      final data = response?.data;
      if (!ApiService.isOk(response) || data is! Map) {
        loadError.value = _message(response, 'Could not load your plan.');
        return;
      }
      loadError.value = '';
      subscription.value = _map(data['subscription']);
      usage.value = _map(data['usage']) ?? <String, dynamic>{};
      plans.value = _maps(data['plans']);
      requests.value = _maps(data['requests']);
      pendingRequest.value = _map(data['pending_request']);
    } catch (e) {
      loadError.value = 'Could not load your plan.';
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /requestPlanExtension. Returns true when the request was sent.
  Future<bool> requestExtension({
    required int planId,
    required int months,
    String notes = '',
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      final response = await _api.postRaw(ApiConstants.requestPlanExtension, {
        'plan_id': planId,
        'extend_months': months,
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
      });
      if (ApiService.isOk(response)) {
        HelperUi.showToast(
            message: 'Request sent to the Eldivex team.',
            backgroundColor: AppColor.success);
        await load();
        return true;
      }
      HelperUi.showToast(
          message: _message(response, 'Could not send the request.'),
          backgroundColor: Colors.red);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// PATCH /cancelPlanRequest/:id — withdraw the pending request.
  Future<void> withdraw(int id) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      final response = await _api.patchRaw(ApiConstants.cancelPlanRequest(id), {});
      if (ApiService.isOk(response)) {
        HelperUi.showToast(message: 'Request withdrawn.');
        await load();
      } else {
        HelperUi.showToast(
            message: _message(response, 'Could not withdraw the request.'),
            backgroundColor: Colors.red);
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}
