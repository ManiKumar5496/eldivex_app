class GetAllBranchesModel {
  final int brId;
  final String brName;
  final String brPhone;
  final String brEmail;
  final String brAddress;

  GetAllBranchesModel({
    required this.brId,
    required this.brName,
    required this.brPhone,
    required this.brEmail,
    required this.brAddress,
  });

  factory GetAllBranchesModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return GetAllBranchesModel(
      brId: json["br_id"] ?? 0,
      brName: json["br_name"] ?? "",
      brPhone: json["br_phone"] ?? "",
      brEmail: json["br_email"] ?? "",
      brAddress: json["br_address"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "br_id": brId,
    "br_name": brName,
    "br_phone": brPhone,
    "br_email": brEmail,
    "br_address": brAddress,
  };
}
