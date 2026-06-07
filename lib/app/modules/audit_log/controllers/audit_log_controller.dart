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

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parseJson(dynamic v) {
      if (v == null) return null;
      if (v is Map<String, dynamic>) return v;
      return null;
    }

    return AuditLogEntry(
      id:            (json['id']         as num? ?? 0).toInt(),
      entityType:     json['entity_type'] as String? ?? '',
      entityId:      (json['entity_id']  as num?)?.toInt(),
      action:         json['action']      as String? ?? '',
      changedBy:     (json['changed_by'] as num?)?.toInt(),
      changedByName:  json['changed_by_name'] as String?,
      oldValues:      parseJson(json['old_values']),
      newValues:      parseJson(json['new_values']),
      createdOn:      json['created_on'] as String? ?? '',
    );
  }
}

class AuditLogController extends GetxController {
  final ApiService _api = ApiService();

  final RxBool  loading          = false.obs;
  final RxList<AuditLogEntry> entries = <AuditLogEntry>[].obs;

  // Pagination
  final RxInt  currentPage = 1.obs;
  final RxInt  totalCount  = 0.obs;
  static const int pageSize = 50;

  // Filters
  final RxString filterEntityType = ''.obs;  // '' = All

  final List<String> entityTypes = const [
    'BOOKING',
    'HP',
    'SUPPORT_TICKET',
    'SERVICE',
    'BRANCH',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAuditLog();
  }

  Future<void> fetchAuditLog({bool reset = false}) async {
    if (reset) currentPage.value = 1;
    loading.value = true;
    try {
      final url = ApiConstants.getAuditTrail(
        entityType: filterEntityType.value.isEmpty ? null : filterEntityType.value,
        page:       currentPage.value,
      );
      final response = await _api.getRaw(url);
      if (response == null || response.statusCode != 200) {
        debugPrint('[audit_log] fetchAuditLog → ${response?.statusCode}');
        return;
      }

      final data = response.data as Map<String, dynamic>;
      totalCount.value = (data['total'] as num? ?? 0).toInt();

      final list = data['data'] as List? ?? [];
      entries.value = list
          .map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('[audit_log] fetchAuditLog error: $e\n$st');
    } finally {
      loading.value = false;
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
