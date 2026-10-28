class SaasSubscriptionModel {
  final int id;
  final int orgId;
  final int planId;
  final String planName;
  final double pricePerMonth;
  final String status;
  final String startedOn;
  final String? expiresOn;
  final String? activatedByName;

  SaasSubscriptionModel({
    required this.id,
    required this.orgId,
    required this.planId,
    required this.planName,
    required this.pricePerMonth,
    required this.status,
    required this.startedOn,
    this.expiresOn,
    this.activatedByName,
  });

  factory SaasSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SaasSubscriptionModel(
        id:              json['id'] as int? ?? 0,
        orgId:           json['org_id'] as int? ?? 0,
        planId:          json['plan_id'] as int? ?? 0,
        planName:        json['plan_name']?.toString() ?? '',
        pricePerMonth:   _toDouble(json['price_per_month']),
        status:          json['status']?.toString() ?? '',
        startedOn:       json['started_on']?.toString() ?? '',
        expiresOn:       json['expires_on']?.toString(),
        activatedByName: json['activated_by_name']?.toString(),
      );

  /// Tolerates DECIMAL columns serialized as String (e.g. "999.00")
  /// as well as numeric JSON values.
  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static List<SaasSubscriptionModel> listFromJson(List<dynamic> list) =>
      list.map((e) => SaasSubscriptionModel.fromJson(e as Map<String, dynamic>)).toList();

  bool get isExpired {
    if (expiresOn == null) return false;
    final exp = DateTime.tryParse(expiresOn!);
    return exp != null && exp.isBefore(DateTime.now());
  }

  int? get daysToExpiry {
    if (expiresOn == null) return null;
    final exp = DateTime.tryParse(expiresOn!);
    if (exp == null) return null;
    return exp.difference(DateTime.now()).inDays;
  }
}
