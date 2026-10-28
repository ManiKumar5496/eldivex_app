class CouponModel {
  final int couponId;
  final String couponName;
  final String discountPercentage;
  final String discountUpperLimitValue;

  CouponModel({
    this.couponId = 0,
    required this.couponName,
    required this.discountPercentage,
    required this.discountUpperLimitValue,
  });

  static String _toStr(dynamic v, String fallback) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return (s.isEmpty || s == 'NA') ? fallback : s;
  }

  /// Convert JSON to Model (defensive: numbers may arrive as num or string)
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final id = json['coupon_id'];
    return CouponModel(
      couponId: id is num ? id.toInt() : int.tryParse(id?.toString() ?? '') ?? 0,
      couponName: _toStr(json['coupon_name'], ''),
      discountPercentage: _toStr(json['discount_percentage'], '0.00'),
      discountUpperLimitValue: _toStr(json['discount_upper_limit_value'], '0.00'),
    );
  }

  // Equality by id so a dropdown selection survives a coupon reload.
  @override
  bool operator ==(Object other) =>
      other is CouponModel &&
      (couponId != 0 ? other.couponId == couponId : other.couponName == couponName);

  @override
  int get hashCode => couponId != 0 ? couponId.hashCode : couponName.hashCode;

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'coupon_name': couponName,
      'discount_percentage': discountPercentage,
      'discount_upper_limit_value': discountUpperLimitValue,
    };
  }

  /// Convert List JSON to List<Model>
  static List<CouponModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map>()
        .map((json) => CouponModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
