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
      pricePerMonth: (json['price_per_month'] as num?)?.toDouble() ?? 0,
      features:      feat,
    );
  }

  static List<SaasPlanModel> listFromJson(List<dynamic> list) =>
      list.map((e) => SaasPlanModel.fromJson(e as Map<String, dynamic>)).toList();

  String get limitLabel {
    final b = bookingLimit == 0 ? 'Unlimited' : '$bookingLimit bookings';
    final h = hpLimit      == 0 ? 'Unlimited' : '$hpLimit HPs';
    return '$b · $h';
  }
}
