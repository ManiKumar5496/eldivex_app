class SaasAccountModel {
  final int id;
  final String name;
  final String slug;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String createdOn;
  final String planName;
  final String subStatus;
  final String? expiresOn;

  SaasAccountModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdOn,
    required this.planName,
    required this.subStatus,
    this.expiresOn,
  });

  factory SaasAccountModel.fromJson(Map<String, dynamic> json) => SaasAccountModel(
        id:        json['id'] as int? ?? 0,
        name:      json['name']?.toString()       ?? '',
        slug:      json['slug']?.toString()       ?? '',
        email:     json['email']?.toString()      ?? '',
        phone:     json['phone']?.toString()      ?? '',
        address:   json['address']?.toString()    ?? '',
        status:    json['status']?.toString()     ?? '',
        createdOn: json['created_on']?.toString() ?? '',
        planName:  json['plan_name']?.toString()  ?? 'None',
        subStatus: json['sub_status']?.toString() ?? '',
        expiresOn: json['expires_on']?.toString(),
      );

  static List<SaasAccountModel> listFromJson(List<dynamic> list) =>
      list.map((e) => SaasAccountModel.fromJson(e as Map<String, dynamic>)).toList();

  bool get isExpiringSoon {
    if (expiresOn == null) return false;
    final exp = DateTime.tryParse(expiresOn!);
    if (exp == null) return false;
    return exp.difference(DateTime.now()).inDays <= 30 &&
        exp.isAfter(DateTime.now());
  }

  int? get daysToExpiry {
    if (expiresOn == null) return null;
    final exp = DateTime.tryParse(expiresOn!);
    return exp?.difference(DateTime.now()).inDays;
  }
}
