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

  factory GetAllBannersModel.fromJson(Map<String, dynamic> json) {
    return GetAllBannersModel(
      bannerName: json["banner_name"] as String?,
      bannerDescription: json["banner_description"] as String?,
      bannerImage: json["banner_photo"] as String?,
      bannerStatus: json["banner_status"] as int?,
      bannerId: json["banner_id"] as int?,
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
