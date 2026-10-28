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
      brId: _toInt(json["br_id"]),
      brName: _toStr(json["br_name"]),
      brPhone: _toStr(json["br_phone"]),
      brEmail: _toStr(json["br_email"]),
      brAddress: _toStr(json["br_address"]),
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

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

String _toStr(dynamic v) => v == null ? '' : v.toString();
