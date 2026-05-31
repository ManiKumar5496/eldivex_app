class ClientUserModel {
  final int? id;
  final String? deviceId;
  final String? userToken;
  final String? userImage;
  final String? phoneNumber;
  final int? status;
  final DateTime? createdOn;
  final int? createdBy;
  final DateTime? updatedOn;
  final int? updatedBy;
  final String? userName;
  final String? userLocation;
  final String? userEmail;
  final int? userGender;
  final int? isNewUserFlag;
  final int? userServiceCity;
  final int? userSource;
  final int? enquiredFor;
  final int? leadPotential;
  final String? enquiredForOther;

  ClientUserModel({
    this.id,
    this.deviceId,
    this.userToken,
    this.userImage,
    this.phoneNumber,
    this.status,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    this.userName,
    this.userLocation,
    this.userEmail,
    this.userGender,
    this.isNewUserFlag,
    this.userServiceCity,
    this.userSource,
    this.enquiredFor,
    this.leadPotential,
    this.enquiredForOther,
  });

  factory ClientUserModel.fromJson(Map<String, dynamic> json) {
    return ClientUserModel(
      id: json['id'] as int?,
      deviceId: json['device_id'] as String?,
      userToken: json['user_token'] as String?,
      userImage: json['user_image'] as String?,
      phoneNumber: json['phone_number'] as String?,
      status: json['status'] as int?,
      createdOn: json['created_on'] != null
          ? DateTime.tryParse(json['created_on'])
          : null,
      createdBy: json['created_by'] as int?,
      updatedOn: json['updated_on'] != null
          ? DateTime.tryParse(json['updated_on'])
          : null,
      updatedBy: json['updated_by'] as int?,
      userName: json['user_name'] as String?,
      userLocation: json['user_location'] as String?,
      userEmail: json['user_email'] as String?,
      userGender: json['user_gender'] as int?,
      isNewUserFlag: json['is_new_user_flag'] as int?,
      userServiceCity: json['user_service_city'] as int?,
      userSource: json['user_source'] as int?,
      enquiredFor: json['enquired_for'] as int?,
      leadPotential: json['lead_potential'] as int?,
      enquiredForOther: json['enquired_for_other'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'user_token': userToken,
      'user_image': userImage,
      'phone_number': phoneNumber,
      'status': status,
      'created_on': createdOn?.toIso8601String(),
      'created_by': createdBy,
      'updated_on': updatedOn?.toIso8601String(),
      'updated_by': updatedBy,
      'user_name': userName,
      'user_location': userLocation,
      'user_email': userEmail,
      'user_gender': userGender,
      'is_new_user_flag': isNewUserFlag,
      'user_service_city': userServiceCity,
      'user_source': userSource,
      'enquired_for': enquiredFor,
      'lead_potential': leadPotential,
      'enquired_for_other': enquiredForOther,
    };
  }

  // Helper methods
  String get displayName => userName?.isNotEmpty == true ? userName! : 'Unnamed User';
  String get displayEmail => userEmail?.isNotEmpty == true ? userEmail! : 'No email';
  String get displayPhone => phoneNumber ?? 'No phone';
  String get displayLocation => userLocation?.isNotEmpty == true ? userLocation! : 'Not specified';

  bool get isActive => status == 1;
  bool get isNewUser => isNewUserFlag == 1;

  String get genderLabel {
    switch (userGender) {
      case 1: return 'Male';
      case 2: return 'Female';
      case 3: return 'Other';
      default: return 'Not specified';
    }
  }

  String get userSourceLabel {
    switch (userSource) {
      case 1: return 'IVR';
      case 2: return 'Website';
      case 3: return 'Social Media';
      case 4: return 'Referral';
      case 5: return 'Walk-in';
      case 6: return 'Google Ads';
      case 7: return 'Other';
      default: return 'Unknown';
    }
  }

  String get leadPotentialLabel {
    switch (leadPotential) {
      case 1: return 'Hot';
      case 2: return 'Warm';
      case 3: return 'Cold';
      case 4: return 'Lost';
      default: return 'Unknown';
    }
  }
}