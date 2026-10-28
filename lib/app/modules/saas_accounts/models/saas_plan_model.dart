class SaasPlanModel {
  final int id;
  final String name;
  final int bookingLimit;
  final int hpLimit;
  final double pricePerMonth;
  final Map<String, dynamic> features;

  SaasPlanModel({
    required this.id,
    required this.name,
    required this.bookingLimit,
    required this.hpLimit,
    required this.pricePerMonth,
    required this.features,
  });

  factory SaasPlanModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> feat = {};
    if (json['features'] is Map) {
      feat = Map<String, dynamic>.from(json['features'] as Map);
    }
    return SaasPlanModel(
      id:            json['id'] as int? ?? 0,
      name:          json['name']?.toString() ?? '',
      bookingLimit:  (json['booking_limit'] as num?)?.toInt() ?? 0,
      hpLimit:       (json['hp_limit'] as num?)?.toInt() ?? 0,
      pricePerMonth: _toDouble(json['price_per_month']),
      features:      feat,
    );
  }

  /// Tolerates DECIMAL columns serialized as String (e.g. "999.00")
  /// as well as numeric JSON values.
  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static List<SaasPlanModel> listFromJson(List<dynamic> list) =>
      list.map((e) => SaasPlanModel.fromJson(e as Map<String, dynamic>)).toList();

  String get limitLabel {
    final b = bookingLimit == 0 ? 'Unlimited' : '$bookingLimit bookings';
    final h = hpLimit      == 0 ? 'Unlimited' : '$hpLimit HPs';
    return '$b · $h';
  }
}
