class HostelSettlementLine {
  final int hpId;
  final String hpName;
  final String? phone;
  final int nights;
  final double ratePerDay;
  final double amount;

  const HostelSettlementLine({
    required this.hpId,
    required this.hpName,
    this.phone,
    required this.nights,
    required this.ratePerDay,
    required this.amount,
  });

  factory HostelSettlementLine.fromJson(Map<String, dynamic> json) {
    return HostelSettlementLine(
      hpId: _toInt(json['hp_id']),
      hpName: (json['hp_name']?.toString() ?? '').trim(),
      phone: json['phone']?.toString(),
      nights: _toInt(json['nights']),
      ratePerDay: _toDouble(json['rate_per_day']),
      amount: _toDouble(json['amount']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }
}

/// Computed monthly reconciliation for a hostel (GET /getHostelSettlement).
class HostelSettlementModel {
  final int hostelId;
  final String hostelName;
  final String gender;
  final double ratePerDay;
  final String periodFrom;
  final String periodTo;
  final double totalAmount;
  final int totalNights;
  final int cgCount;
  final List<HostelSettlementLine> lines;

  const HostelSettlementModel({
    required this.hostelId,
    required this.hostelName,
    required this.gender,
    required this.ratePerDay,
    required this.periodFrom,
    required this.periodTo,
    required this.totalAmount,
    required this.totalNights,
    required this.cgCount,
    required this.lines,
  });

  factory HostelSettlementModel.fromJson(Map<String, dynamic> json) {
    return HostelSettlementModel(
      hostelId: HostelSettlementLine._toInt(json['hostel_id']),
      hostelName: json['hostel_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      ratePerDay: HostelSettlementLine._toDouble(json['rate_per_day']),
      periodFrom: json['period_from']?.toString() ?? '',
      periodTo: json['period_to']?.toString() ?? '',
      totalAmount: HostelSettlementLine._toDouble(json['total_amount']),
      totalNights: HostelSettlementLine._toInt(json['total_nights']),
      cgCount: HostelSettlementLine._toInt(json['cg_count']),
      lines: ((json['lines'] as List?) ?? [])
          .map((e) => HostelSettlementLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
