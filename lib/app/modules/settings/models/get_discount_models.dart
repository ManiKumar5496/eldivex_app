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

  /// Convert JSON to Model
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: (json['coupon_id'] as num?)?.toInt() ?? 0,
      couponName: json['coupon_name'] ?? '',
      discountPercentage: json['discount_percentage'] ?? '0.00',
      discountUpperLimitValue: json['discount_upper_limit_value'] ?? '0.00',
    );
  }

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
        .map((json) => CouponModel.fromJson(json))
        .toList();
  }
}
