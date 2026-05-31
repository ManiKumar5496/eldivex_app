class OtpResponseModel {
  final bool? status;
  final String? message;
  final OtpData? data;

  OtpResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? OtpData.fromJson(json['data'])
          : null,
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
  final int? otp;
  final int? bkngId;
  final int? hpUniqueId;

  OtpData({
    this.otp,
    this.bkngId,
    this.hpUniqueId,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      otp: json['otp'] is int
          ? json['otp'] as int?
          : int.tryParse(json['otp']?.toString() ?? ''),
      bkngId: json['bkng_id'] is int
          ? json['bkng_id'] as int?
          : int.tryParse(json['bkng_id']?.toString() ?? ''),
      hpUniqueId: json['hp_unique_id'] is int
          ? json['hp_unique_id'] as int?
          : int.tryParse(json['hp_unique_id']?.toString() ?? ''),
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
