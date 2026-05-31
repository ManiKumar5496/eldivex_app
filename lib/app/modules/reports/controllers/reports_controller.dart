import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';

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

  // ── Schedule config ────────────────────────────────────────────────────────
  final RxBool scheduleEnabled = false.obs;
  final RxBool scheduleLoading = false.obs;

  // ── Branch list (populated from shared dashboard controller if needed) ─────
  // We re-use DashboardController.getAllBranches via Get.find() in the view.

  Future<void> fetchReport() async {
    loading.value = true;
    reportData.clear();
    try {
      final url = ApiConstants.generateReport(
        type:     reportType.value,
        from:     reportFrom.value.isEmpty ? null : reportFrom.value,
        to:       reportTo.value.isEmpty   ? null : reportTo.value,
        branchId: reportBranchId.value,
        format:   'json',
      );
      final response = await _api.getRaw(url);
      if (response == null || response.statusCode != 200) {
        debugPrint('[reports] fetchReport → ${response?.statusCode}');
        return;
      }
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List? ?? []);
      totalRows.value = (body['count'] as num? ?? list.length).toInt();
      reportData.value = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e, st) {
      debugPrint('[reports] fetchReport error: $e\n$st');
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadScheduleConfig() async {
    try {
      final response = await _api.getRaw(ApiConstants.getScheduledReports);
      if (response?.statusCode == 200) {
        final data = response!.data as Map<String, dynamic>;
        scheduleEnabled.value = (data['enabled'] as bool?) ?? false;
      }
    } catch (_) {}
  }

  Future<void> toggleSchedule(bool enabled) async {
    scheduleLoading.value = true;
    try {
      await _api.postRaw(
        ApiConstants.configureReportSchedule,
        {'enabled': enabled},
      );
      scheduleEnabled.value = enabled;
    } catch (e) {
      debugPrint('[reports] toggleSchedule error: $e');
    } finally {
      scheduleLoading.value = false;
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
