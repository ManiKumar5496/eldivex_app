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

  /// Backend columns are loosely typed (numeric strings, 'NA'), so every
  /// field is parsed defensively instead of cast.
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _toStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s == 'NA' ? null : s;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory SupportCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SupportCategory();

    return SupportCategory(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      appType: _toStr(json['app_type']),
      createdOn: _toDate(json['created_on']),
      createdBy: _toInt(json['created_by']),
      updatedOn: _toDate(json['updated_on']),
      updatedBy: _toInt(json['updated_by']),
      status: _toInt(json['status']),
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

  /// Null-safe support category name
  String get supportCategoryNames => name ?? '';

  // Equality by id so a dropdown selection survives a category reload.
  @override
  bool operator ==(Object other) =>
      other is SupportCategory && other.id != null && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
