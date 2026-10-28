import 'dart:convert';

class GetAllBannersModel {
  final String? bannerName;
  final String? bannerDescription;
  final String? bannerImage;
  final int? bannerStatus;
  final int? bannerId;

  GetAllBannersModel({
    this.bannerName,
    this.bannerDescription,
    this.bannerImage,
    this.bannerStatus,
    this.bannerId,
  });

  GetAllBannersModel copyWith({
    String? bannerName,
    String? bannerDescription,
    String? bannerImage,
    int? bannerStatus,
    int? bannerId,
  }) {
    return GetAllBannersModel(
      bannerName: bannerName ?? this.bannerName,
      bannerDescription: bannerDescription ?? this.bannerDescription,
      bannerImage: bannerImage ?? this.bannerImage,
      bannerStatus: bannerStatus ?? this.bannerStatus,
      bannerId: bannerId ?? this.bannerId,
    );
  }

  factory GetAllBannersModel.fromRawJson(String str) =>
      GetAllBannersModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  /// Backend columns are loosely typed (numeric strings, 'NA'), so parse
  /// instead of casting — one odd row must not blank the whole list.
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _toStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s == 'NA' ? null : s;
  }

  factory GetAllBannersModel.fromJson(Map<String, dynamic> json) {
    return GetAllBannersModel(
      bannerName: _toStr(json["banner_name"]),
      bannerDescription: _toStr(json["banner_description"]),
      bannerImage: _toStr(json["banner_photo"]),
      bannerStatus: _toInt(json["banner_status"]),
      bannerId: _toInt(json["banner_id"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "banner_name": bannerName,
      "banner_description": bannerDescription,
      "banner_photo": bannerImage,
      "banner_status": bannerStatus,
      "banner_id": bannerId,
    };
  }
}
