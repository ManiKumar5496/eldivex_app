class OtpResponseModel {
  final bool? status;
  final String? message;
  final OtpData? data;

  OtpResponseModel({
    this.status,
    this.message,
    this.data,
  });

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return OtpResponseModel(
      status: _toBool(json['status']),
      message: json['message']?.toString(),
      data: data is Map ? OtpData.fromJson(Map<String, dynamic>.from(data)) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class OtpData {
  /// Kept as a String so leading zeros ("0427") survive.
  final String? otp;
  final int? bkngId;
  final String? hpUniqueId;

  OtpData({
    this.otp,
    this.bkngId,
    this.hpUniqueId,
  });

  static String? _toStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return (s.isEmpty || s == 'NA') ? null : s;
  }

  factory OtpData.fromJson(Map<String, dynamic> json) {
    final bk = json['bkng_id'];
    return OtpData(
      otp: _toStr(json['otp']),
      bkngId: bk is num ? bk.toInt() : int.tryParse(bk?.toString() ?? ''),
      hpUniqueId: _toStr(json['hp_unique_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'bkng_id': bkngId,
      'hp_unique_id': hpUniqueId,
    };
  }
}
