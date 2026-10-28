import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';

class ReportsController extends GetxController {
  final ApiService _api = ApiService();

  // ── Report config ──────────────────────────────────────────────────────────
  final RxString reportType = 'bookings'.obs;
  final RxString reportFrom = ''.obs;
  final RxString reportTo   = ''.obs;
  final Rxn<int> reportBranchId = Rxn<int>();

  static const List<Map<String, String>> reportTypes = [
    {'value': 'bookings',       'label': 'Bookings'},
    {'value': 'revenue',        'label': 'Revenue'},
    {'value': 'hp_utilization', 'label': 'HP Utilization'},
    {'value': 'outstanding',    'label': 'Outstanding'},
  ];

  // ── Data ───────────────────────────────────────────────────────────────────
  final RxBool loading = false.obs;
  final RxList<Map<String, dynamic>> reportData = <Map<String, dynamic>>[].obs;
  final RxInt  totalRows = 0.obs;
  final RxBool downloading = false.obs;
  /// Non-empty when the last preview failed; shown in place of the table.
  final RxString reportError = ''.obs;
  /// True when the backend's plan gate rejected the report (403).
  final RxBool planBlocked = false.obs;

  // ── Schedule config ────────────────────────────────────────────────────────
  final RxBool scheduleEnabled = false.obs;
  final RxBool scheduleLoading = false.obs;

  // ── Branch list (populated from shared dashboard controller if needed) ─────
  // We re-use DashboardController.getAllBranches via Get.find() in the view.

  @override
  void onReady() {
    super.onReady();
    loadScheduleConfig();
  }

  /// False (with a toast) when both dates are set and From is after To.
  bool _validRange() {
    if (reportFrom.value.isNotEmpty &&
        reportTo.value.isNotEmpty &&
        reportFrom.value.compareTo(reportTo.value) > 0) {
      HelperUi.showToast(
        message: "'From' date must be on or before 'To' date.",
        backgroundColor: Colors.orange,
      );
      return false;
    }
    return true;
  }

  /// Turns a failed report response into the message shown to the user.
  void _applyFailure(dynamic response) {
    final status = response?.statusCode;
    final data = response?.data;
    final msg = data is Map ? (data['message'] ?? data['error'])?.toString() : null;
    // 403 without a code is the subscription plan gate (MODULE_FORBIDDEN and
    // ORG_SUSPENDED carry a code and are handled globally by ApiService).
    planBlocked.value = status == 403 && !(data is Map && data['code'] != null);
    if (planBlocked.value) {
      reportError.value =
          '${msg ?? 'Reports are not included in your current plan.'} '
          'Upgrade your subscription to use Reports.';
    } else {
      reportError.value = msg ?? ApiService.lastError ?? 'Could not generate the report.';
    }
  }

  Future<void> fetchReport() async {
    if (!_validRange()) return;
    loading.value = true;
    reportData.clear();
    totalRows.value = 0;
    reportError.value = '';
    planBlocked.value = false;
    try {
      final url = ApiConstants.generateReport(
        type:     reportType.value,
        from:     reportFrom.value.isEmpty ? null : reportFrom.value,
        to:       reportTo.value.isEmpty   ? null : reportTo.value,
        branchId: reportBranchId.value,
        format:   'json',
      );
      // getBytes returns error responses too (getRaw swallows them), so the
      // plan-gate 403 message can be shown.
      final response = await _api.getBytes(url);
      if (response == null || response.statusCode != 200) {
        debugPrint('[reports] fetchReport → ${response?.statusCode}');
        if (response == null) {
          reportError.value = ApiService.lastError ?? 'Could not generate the report.';
        } else {
          _applyFailure(response);
        }
        return;
      }
      final decoded = _decodeJson(response.data);
      final body = decoded is Map ? decoded : const {};
      final list = body['data'] is List ? body['data'] as List : const [];
      totalRows.value = int.tryParse('${body['count'] ?? ''}') ?? list.length;
      reportData.value = list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (reportData.isEmpty) {
        reportError.value = 'No data for the selected filters.';
      }
    } catch (e, st) {
      debugPrint('[reports] fetchReport error: $e\n$st');
      reportError.value = 'Could not generate the report.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadScheduleConfig() async {
    try {
      final response = await _api.getRaw(ApiConstants.getScheduledReports);
      if (response?.statusCode == 200 && response!.data is Map) {
        scheduleEnabled.value = response.data['enabled'] == true;
      }
    } catch (_) {}
  }

  Future<void> toggleSchedule(bool enabled) async {
    final previous = scheduleEnabled.value;
    scheduleEnabled.value = enabled;
    scheduleLoading.value = true;
    try {
      final response = await _api.postRaw(
        ApiConstants.configureReportSchedule,
        {'enabled': enabled},
      );
      if (!ApiService.isOk(response)) {
        scheduleEnabled.value = previous;
        final data = response?.data;
        HelperUi.showToast(
          message: (data is Map ? (data['message'] ?? data['error'])?.toString() : null) ??
              'Could not update the report schedule.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('[reports] toggleSchedule error: $e');
      scheduleEnabled.value = previous;
    } finally {
      scheduleLoading.value = false;
    }
  }

  dynamic _decodeJson(dynamic raw) {
    if (raw is List<int>) {
      return ApiService.decodeJsonBytes(raw);
    }
    return raw;
  }

  /// Downloads the CSV with the session's auth header (a plain link can't
  /// send it) and saves it through a blob URL.
  Future<void> downloadCsv() async {
    if (!_validRange() || downloading.value) return;
    downloading.value = true;
    try {
      final response = await _api.getBytes(csvDownloadUrl());
      final raw = response?.data;
      if (response == null || response.statusCode != 200 || raw is! List<int>) {
        if (response != null) _applyFailure(response);
        HelperUi.showToast(
          message: reportError.value.isNotEmpty
              ? reportError.value
              : (ApiService.lastError ?? 'Could not download the report.'),
          backgroundColor: Colors.red,
        );
        return;
      }
      final bytes = Uint8List.fromList(raw);
      final blob = web.Blob(
        [bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
      );
      final href = web.URL.createObjectURL(blob);
      final a = web.document.createElement('a') as web.HTMLAnchorElement;
      a.href = href;
      a.download = '${reportType.value}_report.csv';
      web.document.body?.append(a);
      a.click();
      a.remove();
      web.URL.revokeObjectURL(href);
    } catch (e) {
      debugPrint('[reports] downloadCsv error: $e');
      HelperUi.showToast(
        message: 'Could not download the report.',
        backgroundColor: Colors.red,
      );
    } finally {
      downloading.value = false;
    }
  }

  /// Builds and returns the CSV download URL for the current filter state.
  String csvDownloadUrl() => ApiConstants.generateReport(
    type:     reportType.value,
    from:     reportFrom.value.isEmpty ? null : reportFrom.value,
    to:       reportTo.value.isEmpty   ? null : reportTo.value,
    branchId: reportBranchId.value,
    format:   'csv',
  );

  /// Column headers for the selected report type (preview table).
  List<String> get columnHeaders {
    if (reportData.isEmpty) return [];
    return reportData.first.keys.toList();
  }
}
