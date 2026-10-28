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
      id: _toIntOrNull(json['id']),
      deviceId: _toStrOrNull(json['device_id']),
      userToken: _toStrOrNull(json['user_token']),
      userImage: _toStrOrNull(json['user_image']),
      phoneNumber: _toStrOrNull(json['phone_number']),
      status: _toIntOrNull(json['status']),
      createdOn: _toDate(json['created_on']),
      createdBy: _toIntOrNull(json['created_by']),
      updatedOn: _toDate(json['updated_on']),
      updatedBy: _toIntOrNull(json['updated_by']),
      userName: _toStrOrNull(json['user_name']),
      userLocation: _toStrOrNull(json['user_location']),
      userEmail: _toStrOrNull(json['user_email']),
      userGender: _toIntOrNull(json['user_gender']),
      isNewUserFlag: _toIntOrNull(json['is_new_user_flag']),
      userServiceCity: _toIntOrNull(json['user_service_city']),
      userSource: _toIntOrNull(json['user_source']),
      enquiredFor: _toIntOrNull(json['enquired_for']),
      leadPotential: _toIntOrNull(json['lead_potential']),
      enquiredForOther: _toStrOrNull(json['enquired_for_other']),
    );
  }

  /// Backend columns are loosely typed — numeric fields (user_gender,
  /// user_service_city, user_source, enquired_for, lead_potential, status…)
  /// are varchar in the DB and come back as numeric strings ("1") or the
  /// literal "NA". A hard `as int?` cast throws on those, which made
  /// fromJson throw and getList swallow the error → the whole client list
  /// silently rendered empty. Parse defensively so one odd value never
  /// blanks the list.
  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _toStrOrNull(dynamic v) => v?.toString();

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
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