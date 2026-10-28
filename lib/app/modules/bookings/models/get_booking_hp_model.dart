class GetBookingHpModel {
  final int id;
  final int bkngId;
  final int hpUniqueId;
  final DateTime? interviewDate;
  final String? interviewTime;
  final DateTime? interviewExpirydate;
  final DateTime? reportingDatePlanned;
  final DateTime? endDatePlanned;
  final DateTime? reportingDateRequestedByClient;
  final String? inTime;
  final String? outTime;
  final DateTime? reportingDateActual;
  final DateTime? endDateActual;
  final DateTime? otpVerificationDatetime;
  final String? otpVerificationIpAddress;
  final DateTime? createdOn;
  final int createdBy;
  final DateTime? updatedOn;
  final int updatedBy;
  final int status;
  final DateTime? otpGeneratationDatetime;
  final String? placementTime;

  // HP Registration fields
  final int? hpRegId;
  final String? hpRegPhoto;
  final String? hpRegFirstName;
  final String? hpRegLastName;
  final String? hpRegEmail;
  final String? hpRegPhoneNumber;
  final String? hpRegAddress;
  final DateTime? hpRegDob;
  final int? hpRegGender;
  final String? hpRegCity;
  final String? hpRegState;
  final int? hpRegPinCode;
  final String? hpRegEmergencyContactPhone;
  final String? hpRegLanguages;
  final int? hpRegBranchId;
  final int? hpRegMaritalStatus;
  final int? hpRegExperience;
  final String? hpRegFatherName;
  final String? hpRegFatherOccupation;
  final String? hpRegMotherName;
  final String? hpRegIdentityProofType;
  final String? hpRegIdentityProofNumber;
  final String? hpRegIdentityProofFrontImage;
  final String? hpRegIdentityProofBackImage;
  final String? hpRegEducation;
  final String? hpRegEducationCertificate;
  final int? hpRegStatus;

  GetBookingHpModel({
    required this.id,
    required this.bkngId,
    required this.hpUniqueId,
    this.interviewDate,
    this.interviewTime,
    this.interviewExpirydate,
    this.reportingDatePlanned,
    this.endDatePlanned,
    this.reportingDateRequestedByClient,
    this.inTime,
    this.outTime,
    this.reportingDateActual,
    this.endDateActual,
    this.otpVerificationDatetime,
    this.otpVerificationIpAddress,
    this.createdOn,
    required this.createdBy,
    this.updatedOn,
    required this.updatedBy,
    required this.status,
    this.otpGeneratationDatetime,
    this.placementTime,
    this.hpRegId,
    this.hpRegPhoto,
    this.hpRegFirstName,
    this.hpRegLastName,
    this.hpRegEmail,
    this.hpRegPhoneNumber,
    this.hpRegAddress,
    this.hpRegDob,
    this.hpRegGender,
    this.hpRegCity,
    this.hpRegState,
    this.hpRegPinCode,
    this.hpRegEmergencyContactPhone,
    this.hpRegLanguages,
    this.hpRegBranchId,
    this.hpRegMaritalStatus,
    this.hpRegExperience,
    this.hpRegFatherName,
    this.hpRegFatherOccupation,
    this.hpRegMotherName,
    this.hpRegIdentityProofType,
    this.hpRegIdentityProofNumber,
    this.hpRegIdentityProofFrontImage,
    this.hpRegIdentityProofBackImage,
    this.hpRegEducation,
    this.hpRegEducationCertificate,
    this.hpRegStatus,
  });

  static int _i(dynamic v, [int fallback = 0]) =>
      v == null ? fallback : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? fallback);

  static int? _iN(dynamic v) =>
      v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

  static String? _s(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.trim() == 'NA' ? null : s;
  }

  static DateTime? _d(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  factory GetBookingHpModel.fromJson(Map<String, dynamic> json) {
    return GetBookingHpModel(
      id: _i(json['id']),
      bkngId: _i(json['bkng_id']),
      hpUniqueId: _i(json['hp_unique_id']),
      interviewDate: _d(json['interview_date']),
      interviewTime: _s(json['interview_time']),
      interviewExpirydate: _d(json['interview_expirydate']),
      reportingDatePlanned: _d(json['reporting_date_planned']),
      endDatePlanned: _d(json['end_date_planned']),
      reportingDateRequestedByClient:
          _d(json['reporting_date_requested_by_client']),
      inTime: _s(json['in_time']),
      outTime: _s(json['out_time']),
      reportingDateActual: _d(json['reporting_date_actual']),
      endDateActual: _d(json['end_date_actual']),
      otpVerificationDatetime: _d(json['otp_verification_datetime']),
      otpVerificationIpAddress: _s(json['otp_verification_ip_address']),
      createdOn: _d(json['created_on']),
      createdBy: _i(json['created_by']),
      updatedOn: _d(json['updated_on']),
      updatedBy: _i(json['updated_by']),
      status: _i(json['status']),
      otpGeneratationDatetime: _d(json['otp_generatation_datetime']),
      placementTime: _s(json['placement_time']),
      hpRegId: _iN(json['hp_reg_id']),
      hpRegPhoto: _s(json['hp_reg_photo']),
      hpRegFirstName: _s(json['hp_reg_first_name']),
      hpRegLastName: _s(json['hp_reg_last_name']),
      hpRegEmail: _s(json['hp_reg_email']),
      hpRegPhoneNumber: _s(json['hp_reg_phone_number']),
      hpRegAddress: _s(json['hp_reg_address']),
      hpRegDob: _d(json['hp_reg_dob']),
      hpRegGender: _iN(json['hp_reg_gender']),
      hpRegCity: _s(json['hp_reg_city']),
      hpRegState: _s(json['hp_reg_state']),
      hpRegPinCode: _iN(json['hp_reg_pin_code']),
      hpRegEmergencyContactPhone: _s(json['hp_reg_emergency_contact_phone']),
      hpRegLanguages: _s(json['hp_reg_languages']),
      hpRegBranchId: _iN(json['hp_reg_branch_id']),
      hpRegMaritalStatus: _iN(json['hp_reg_marital_status']),
      hpRegExperience: _iN(json['hp_reg_experience']),
      hpRegFatherName: _s(json['hp_reg_father_name']),
      hpRegFatherOccupation: _s(json['hp_reg_father_occupation']),
      hpRegMotherName: _s(json['hp_reg_mother_name']),
      hpRegIdentityProofType: _s(json['hp_reg_identity_proof_type']),
      hpRegIdentityProofNumber: _s(json['hp_reg_identity_proof_number']),
      hpRegIdentityProofFrontImage: _s(json['hp_reg_identity_proof_front_image']),
      hpRegIdentityProofBackImage: _s(json['hp_reg_identity_proof_back_image']),
      hpRegEducation: _s(json['hp_reg_education']),
      hpRegEducationCertificate: _s(json['hp_reg_education_certificate']),
      hpRegStatus: _iN(json['hp_reg_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bkng_id': bkngId,
      'hp_unique_id': hpUniqueId,
      'interview_date': interviewDate?.toIso8601String(),
      'interview_time': interviewTime,
      'interview_expirydate': interviewExpirydate?.toIso8601String(),
      'reporting_date_planned': reportingDatePlanned?.toIso8601String(),
      'end_date_planned': endDatePlanned?.toIso8601String(),
      'reporting_date_requested_by_client':
          reportingDateRequestedByClient?.toIso8601String(),
      'in_time': inTime,
      'out_time': outTime,
      'reporting_date_actual': reportingDateActual?.toIso8601String(),
      'end_date_actual': endDateActual?.toIso8601String(),
      'otp_verification_datetime':
          otpVerificationDatetime?.toIso8601String(),
      'otp_verification_ip_address': otpVerificationIpAddress,
      'created_on': createdOn?.toIso8601String(),
      'created_by': createdBy,
      'updated_on': updatedOn?.toIso8601String(),
      'updated_by': updatedBy,
      'status': status,
      'otp_generatation_datetime':
          otpGeneratationDatetime?.toIso8601String(),
      'placement_time': placementTime,
      'hp_reg_id': hpRegId,
      'hp_reg_photo': hpRegPhoto,
      'hp_reg_first_name': hpRegFirstName,
      'hp_reg_last_name': hpRegLastName,
      'hp_reg_email': hpRegEmail,
      'hp_reg_phone_number': hpRegPhoneNumber,
      'hp_reg_address': hpRegAddress,
      'hp_reg_dob': hpRegDob?.toIso8601String(),
      'hp_reg_gender': hpRegGender,
      'hp_reg_city': hpRegCity,
      'hp_reg_state': hpRegState,
      'hp_reg_pin_code': hpRegPinCode,
      'hp_reg_emergency_contact_phone': hpRegEmergencyContactPhone,
      'hp_reg_languages': hpRegLanguages,
      'hp_reg_branch_id': hpRegBranchId,
      'hp_reg_marital_status': hpRegMaritalStatus,
      'hp_reg_experience': hpRegExperience,
      'hp_reg_father_name': hpRegFatherName,
      'hp_reg_father_occupation': hpRegFatherOccupation,
      'hp_reg_mother_name': hpRegMotherName,
      'hp_reg_identity_proof_type': hpRegIdentityProofType,
      'hp_reg_identity_proof_number': hpRegIdentityProofNumber,
      'hp_reg_identity_proof_front_image': hpRegIdentityProofFrontImage,
      'hp_reg_identity_proof_back_image': hpRegIdentityProofBackImage,
      'hp_reg_education': hpRegEducation,
      'hp_reg_education_certificate': hpRegEducationCertificate,
      'hp_reg_status': hpRegStatus,
    };
  }
}
