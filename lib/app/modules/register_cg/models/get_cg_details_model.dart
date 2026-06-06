class GetCgDetails {
  final String? liveinPay;
  final String? liveoutPay;
  final String? monthlyLiveinPay;
  final String? monthlyLiveoutPay;
  final DateTime? hpEffectDate;

  final int hpRegId;
  final String hpRegPhoto;
  final String hpRegFirstName;
  final String hpRegLastName;
  final String hpRegEmail;
  final String hpRegPhoneNumber;
  final String hpRegGender;       // stored as "Male"/"Female"/etc.
  final String hpRegCity;
  final String hpRegState;
  final String hpRegPinCode;      // stored as text e.g. "600001" or "NA"
  final String hpRegLanguages;
  final int hpRegBranchId;
  final String hpRegMaritalStatus; // stored as "Married"/"Single"/etc.
  final String hpRegIdentityProofType;
  final String hpRegIdentityProofNumber;
  final String hpRegIdentityProofFrontImage;
  final String hpRegIdentityProofBackImage;
  final String hpRegEducation;
  final String hpRegEducationCertificate;
  final String hpRegAddress;
  final DateTime? hpRegDob;
  final String hpRegExperience;   // stored as text e.g. "2" or "NA"
  final int hpRegStatus;          // 1=Pending,2=Approved,3=Rejected,4=Terminated,5=ActiveBooking,6=OTPBooking

  GetCgDetails({
    this.liveinPay,
    this.liveoutPay,
    this.monthlyLiveinPay,
    this.monthlyLiveoutPay,
    this.hpEffectDate,
    required this.hpRegId,
    required this.hpRegPhoto,
    required this.hpRegFirstName,
    required this.hpRegLastName,
    required this.hpRegEmail,
    required this.hpRegPhoneNumber,
    required this.hpRegGender,
    required this.hpRegCity,
    required this.hpRegState,
    required this.hpRegPinCode,
    required this.hpRegLanguages,
    required this.hpRegBranchId,
    required this.hpRegMaritalStatus,
    required this.hpRegIdentityProofType,
    required this.hpRegIdentityProofNumber,
    required this.hpRegIdentityProofFrontImage,
    required this.hpRegIdentityProofBackImage,
    required this.hpRegEducation,
    required this.hpRegEducationCertificate,
    required this.hpRegAddress,
    required this.hpRegDob,
    required this.hpRegExperience,
    required this.hpRegStatus,
  });

  /// Safely parse a JSON value to int. Handles int, num, and numeric strings.
  static int _safeInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  factory GetCgDetails.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return GetCgDetails(
      liveinPay:        json['livein_pay']?.toString(),
      liveoutPay:       json['liveout_pay']?.toString(),
      monthlyLiveinPay: json['monthly_livein_pay']?.toString(),
      monthlyLiveoutPay:json['monthly_liveout_pay']?.toString(),
      hpEffectDate: json['hp_effect_date'] != null
          ? DateTime.tryParse(json['hp_effect_date'].toString())
          : null,
      hpRegId:          _safeInt(json['hp_reg_id']),
      hpRegPhoto:       json['hp_reg_photo']?.toString()       ?? '',
      hpRegFirstName:   json['hp_reg_first_name']?.toString()  ?? '',
      hpRegLastName:    json['hp_reg_last_name']?.toString()   ?? '',
      hpRegEmail:       json['hp_reg_email']?.toString()       ?? '',
      hpRegPhoneNumber: json['hp_reg_phone_number']?.toString()?? '',
      hpRegGender:      json['hp_reg_gender']?.toString()      ?? '',
      hpRegCity:        json['hp_reg_city']?.toString()        ?? '',
      hpRegState:       json['hp_reg_state']?.toString()       ?? '',
      hpRegPinCode:     json['hp_reg_pin_code']?.toString()    ?? '',
      hpRegLanguages:   json['hp_reg_languages']?.toString()   ?? '',
      hpRegBranchId:    _safeInt(json['hp_reg_branch_id']),
      hpRegMaritalStatus: json['hp_reg_marital_status']?.toString() ?? '',
      hpRegIdentityProofType:   json['hp_reg_identity_proof_type']?.toString()         ?? '',
      hpRegIdentityProofNumber: json['hp_reg_identity_proof_number']?.toString()       ?? '',
      hpRegIdentityProofFrontImage: json['hp_reg_identity_proof_front_image']?.toString() ?? '',
      hpRegIdentityProofBackImage:  json['hp_reg_identity_proof_back_image']?.toString()  ?? '',
      hpRegEducation:           json['hp_reg_education']?.toString()            ?? '',
      hpRegEducationCertificate:json['hp_reg_education_certificate']?.toString()?? '',
      hpRegAddress:     json['hp_reg_address']?.toString()     ?? '',
      hpRegDob: json['hp_reg_dob'] != null
          ? DateTime.tryParse(json['hp_reg_dob'].toString())
          : null,
      hpRegExperience:  json['hp_reg_experience']?.toString()  ?? '',
      hpRegStatus:      _safeInt(json['hp_reg_status']),
    );
  }

  static List<GetCgDetails> listFromJson(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((e) => GetCgDetails.fromJson(e)).toList();
  }
}
