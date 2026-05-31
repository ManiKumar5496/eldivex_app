class SaasUsageModel {
  final String planName;
  final String subStatus;
  final String? expiresOn;
  final int bookingsUsed;
  final int bookingsLimit;
  final int hpUsed;
  final int hpLimit;
  final int usagePctBookings;
  final int usagePctHp;

  SaasUsageModel({
    required this.planName,
    required this.subStatus,
    this.expiresOn,
    required this.bookingsUsed,
    required this.bookingsLimit,
    required this.hpUsed,
    required this.hpLimit,
    required this.usagePctBookings,
    required this.usagePctHp,
  });

  factory SaasUsageModel.fromJson(Map<String, dynamic> json) => SaasUsageModel(
        planName:        json['plan_name']?.toString() ?? '',
        subStatus:       json['sub_status']?.toString() ?? '',
        expiresOn:       json['expires_on']?.toString(),
        bookingsUsed:    (json['bookings_used'] as num?)?.toInt() ?? 0,
        bookingsLimit:   (json['bookings_limit'] as num?)?.toInt() ?? 0,
        hpUsed:          (json['hp_used'] as num?)?.toInt() ?? 0,
        hpLimit:         (json['hp_limit'] as num?)?.toInt() ?? 0,
        usagePctBookings:(json['usage_pct_bookings'] as num?)?.toInt() ?? 0,
        usagePctHp:      (json['usage_pct_hp'] as num?)?.toInt() ?? 0,
      );

  bool get isNearBookingLimit => usagePctBookings >= 80;
  bool get isNearHpLimit      => usagePctHp      >= 80;
}
