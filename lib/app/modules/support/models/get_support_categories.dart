class SupportCategory {
  final int? id;
  final String? name;
  final String? appType;
  final DateTime? createdOn;
  final int? createdBy;
  final DateTime? updatedOn;
  final int? updatedBy;
  final int? status;

  SupportCategory({
    this.id,
    this.name,
    this.appType,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    this.status,
  });

  factory SupportCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SupportCategory();

    return SupportCategory(
      id: json['id'] as int?,
      name: json['name'] as String?,
      appType: json['app_type'] as String?,
      createdOn: json['created_on'] != null
          ? DateTime.tryParse(json['created_on'])
          : null,
      createdBy: json['created_by'] as int?,
      updatedOn: json['updated_on'] != null
          ? DateTime.tryParse(json['updated_on'])
          : null,
      updatedBy: json['updated_by'] as int?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'app_type': appType,
      'created_on': createdOn?.toIso8601String(),
      'created_by': createdBy,
      'updated_on': updatedOn?.toIso8601String(),
      'updated_by': updatedBy,
      'status': status,
    };
  }

  /// ✅ Null-safe support category name
  String get supportCategoryNames => name ?? '';
}
