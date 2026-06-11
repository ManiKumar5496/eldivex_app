class GetHostelsModel {
  final int id;
  final String hostelName;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String gender; // 'Male' | 'Female'
  final double ratePerDay;
  final int? capacity;
  final String? contactPersonName;
  final String? contactPhone;
  final String? contactEmail;
  final int status; // 1=Active, 0=Inactive
  final int? branchId;
  final String? branchName;

  const GetHostelsModel({
    required this.id,
    required this.hostelName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    required this.gender,
    required this.ratePerDay,
    this.capacity,
    this.contactPersonName,
    this.contactPhone,
    this.contactEmail,
    required this.status,
    this.branchId,
    this.branchName,
  });

  String get location => [city, state].where((e) => (e ?? '').isNotEmpty).join(', ');

  factory GetHostelsModel.fromJson(Map<String, dynamic> json) {
    return GetHostelsModel(
      id: _toInt(json['id']),
      hostelName: json['hostel_name']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      gender: json['gender']?.toString() ?? '',
      ratePerDay: _toDouble(json['rate_per_day']),
      capacity: json['capacity'] == null ? null : _toInt(json['capacity']),
      contactPersonName: json['contact_person_name']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      status: _toInt(json['status'], fallback: 1),
      branchId: json['branch_id'] == null ? null : _toInt(json['branch_id']),
      branchName: json['branch_name']?.toString(),
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

  static List<GetHostelsModel> listFromJson(List<dynamic> list) =>
      list.map((e) => GetHostelsModel.fromJson(e as Map<String, dynamic>)).toList();
}
