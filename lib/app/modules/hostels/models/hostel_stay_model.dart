class HostelStayModel {
  final int id;
  final int hostelId;
  final int hpId;
  final String checkInDate;
  final String? checkOutDate;
  final double ratePerDay;
  final String status; // 'active' | 'closed'
  final String hostelName;
  final String? hostelGender;
  final String hpName;
  final String? hpPhone;
  final String? hpGender;

  const HostelStayModel({
    required this.id,
    required this.hostelId,
    required this.hpId,
    required this.checkInDate,
    this.checkOutDate,
    required this.ratePerDay,
    required this.status,
    required this.hostelName,
    this.hostelGender,
    required this.hpName,
    this.hpPhone,
    this.hpGender,
  });

  bool get isOpen => checkOutDate == null || checkOutDate!.isEmpty;

  /// Nights billed up to today (open stays) or to the recorded check-out.
  int get nights {
    final inD = DateTime.tryParse(checkInDate);
    if (inD == null) return 0;
    final outD = isOpen ? DateTime.now() : DateTime.tryParse(checkOutDate!);
    if (outD == null) return 0;
    final diff = DateTime(outD.year, outD.month, outD.day)
        .difference(DateTime(inD.year, inD.month, inD.day))
        .inDays;
    return diff < 0 ? 0 : diff;
  }

  double get charge => nights * ratePerDay;

  factory HostelStayModel.fromJson(Map<String, dynamic> json) {
    return HostelStayModel(
      id: _toInt(json['id']),
      hostelId: _toInt(json['hostel_id']),
      hpId: _toInt(json['hp_id']),
      checkInDate: json['check_in_date']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString(),
      ratePerDay: _toDouble(json['rate_per_day']),
      status: json['status']?.toString() ?? 'active',
      hostelName: json['hostel_name']?.toString() ?? '',
      hostelGender: json['hostel_gender']?.toString(),
      hpName: (json['hp_name']?.toString() ?? '').trim(),
      hpPhone: json['hp_reg_phone_number']?.toString(),
      hpGender: json['hp_reg_gender']?.toString(),
    );
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static List<HostelStayModel> listFromJson(List<dynamic> list) =>
      list.map((e) => HostelStayModel.fromJson(e as Map<String, dynamic>)).toList();
}
