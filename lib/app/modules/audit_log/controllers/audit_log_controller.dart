import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';

/// A single audit trail entry from the server.
class AuditLogEntry {
  final int id;
  final String entityType;
  final int? entityId;
  final String action;
  final int? changedBy;
  final String? changedByName;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String createdOn;

  const AuditLogEntry({
    required this.id,
    required this.entityType,
    required this.action,
    this.entityId,
    this.changedBy,
    this.changedByName,
    this.oldValues,
    this.newValues,
    required this.createdOn,
  });

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _toStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return (s.isEmpty || s == 'NA') ? null : s;
  }

  /// old_values / new_values arrive as a JSON object or a JSON-encoded string.
  static Map<String, dynamic>? _toMap(dynamic v) {
    if (v == null) return null;
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String && v.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id:            _toInt(json['id']) ?? 0,
      entityType:    _toStr(json['entity_type']) ?? '',
      entityId:      _toInt(json['entity_id']),
      action:        _toStr(json['action']) ?? '',
      changedBy:     _toInt(json['changed_by']),
      changedByName: _toStr(json['changed_by_name']),
      oldValues:     _toMap(json['old_values']),
      newValues:     _toMap(json['new_values']),
      createdOn:     _toStr(json['created_on']) ?? '',
    );
  }
}

class AuditLogController extends GetxController {
  final ApiService _api = ApiService();

  final RxBool  loading          = false.obs;
  final RxString loadError       = ''.obs;
  // Incremented per request; a response is applied only if it belongs to the
  // latest request, so fast paging/filtering never shows stale rows.
  int _requestSeq = 0;
  final RxList<AuditLogEntry> entries = <AuditLogEntry>[].obs;

  // Pagination
  final RxInt  currentPage = 1.obs;
  final RxInt  totalCount  = 0.obs;
  static const int pageSize = 50;

  // Filters
  final RxString filterEntityType = ''.obs;  // '' = All

  // Every entity_type the backend writes via logAudit().
  final List<String> entityTypes = const [
    'BOOKING',
    'HP',
    'SUPPORT_TICKET',
    'SERVICE',
    'BRANCH',
    'HOSTEL',
    'HOSTEL_STAY',
    'HOSTEL_SETTLEMENT',
    'ORGANISATION',
    'PLAN',
    'SAAS_INVOICE',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAuditLog();
  }

  Future<void> fetchAuditLog({bool reset = false}) async {
    if (reset) currentPage.value = 1;
    final seq = ++_requestSeq;
    loading.value = true;
    loadError.value = '';
    try {
      final url = ApiConstants.getAuditTrail(
        entityType: filterEntityType.value.isEmpty ? null : filterEntityType.value,
        page:       currentPage.value,
      );
      final response = await _api.getRaw(url);
      if (seq != _requestSeq) return; // a newer request superseded this one
      if (!ApiService.isOk(response) || response!.data is! Map) {
        loadError.value =
            ApiService.lastError ?? 'Failed to load the audit log.';
        return;
      }

      final data = response.data as Map;
      totalCount.value = AuditLogEntry._toInt(data['total']) ?? 0;

      final list = data['data'] is List ? data['data'] as List : const [];
      final parsed = <AuditLogEntry>[];
      for (final e in list) {
        if (e is! Map) continue;
        try {
          parsed.add(AuditLogEntry.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          debugPrint('[audit_log] skipped bad row: $err');
        }
      }
      entries.value = parsed;
    } catch (e, st) {
      if (seq != _requestSeq) return;
      debugPrint('[audit_log] fetchAuditLog error: $e\n$st');
      loadError.value = 'Failed to load the audit log.';
    } finally {
      if (seq == _requestSeq) loading.value = false;
    }
  }

  void applyEntityTypeFilter(String? type) {
    filterEntityType.value = type ?? '';
    fetchAuditLog(reset: true);
  }

  void nextPage() {
    final maxPage = (totalCount.value / pageSize).ceil();
    if (currentPage.value < maxPage) {
      currentPage.value++;
      fetchAuditLog();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAuditLog();
    }
  }

  /// Action badge colour
  Color actionColor(String action) {
    switch (action) {
      case 'CREATE':        return const Color(0xFF059669);
      case 'UPDATE':        return AppColor.cPrimaryButtonColor;
      case 'STATUS_CHANGE': return const Color(0xFFF59E0B);
      case 'DELETE':        return const Color(0xFFDC2626);
      default:              return AppColor.fontColorGrey;
    }
  }
}
